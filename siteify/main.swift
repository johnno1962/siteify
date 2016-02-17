//
//  main.swift
//  siteify
//
//  Created by John Holdsworth on 16/02/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/main.swift#2 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation

let filemgr = NSFileManager.defaultManager()
let SK = SourceKit()
isTTY = false

extension NSFileHandle {

    convenience init?( createForWritingAtPath path: String ) {
        filemgr.createFileAtPath( path, contents:nil, attributes:nil )
        self.init( forWritingAtPath: path )
    }

    func writeString( str: String ) {
        str.withCString { bytes in
            writeData( NSData( bytesNoCopy: UnsafeMutablePointer<Void>(bytes),
                length: Int(strlen(bytes)), freeWhenDone: false ) )
        }
    }

}

func progress( str: String ) {
    print( "\u{001b}[2K"+str, separator: "", terminator: "\r" )
    fflush( stdout )
}

let buildLog: FileGenerator
let storedLog = "siteify.log"
var storingLog: NSFileHandle? = nil

class StatusGenerator: TaskGenerator {

    override func next() -> String? {
        let next = super.next()
        if next == nil {
            let failedLog = "failed.log"
            if filemgr.fileExistsAtPath( failedLog ) {
                try! filemgr.removeItemAtPath( failedLog )
            }

            task.waitUntilExit()
            if task.terminationStatus != EXIT_SUCCESS {
                try! filemgr.moveItemAtPath( storedLog, toPath: failedLog )
                print( "xcodebuild failed, consult ./\(failedLog)" )
                exit( 1 )
            }
        }
        return next
    }
    
}

if filemgr.fileExistsAtPath( storedLog ) {
    buildLog = FileGenerator(path: storedLog)!
}
else {
    var buildargs = Process.arguments
    "/tmp/siteify.XXXX".withCString( { (str) in
        buildargs[0] = "SYMROOT="+String.fromCString( mktemp( UnsafeMutablePointer<Int8>(str) ) )!
    } )
    buildLog = StatusGenerator(launchPath: "/usr/bin/xcodebuild", arguments: buildargs, directory: ".")
    storingLog = NSFileHandle( createForWritingAtPath: storedLog )
}

var compilations = [(String, sourcekitd_object_t)]()

for line in buildLog.sequence {
    let regex = line["-primary-file (?:\"([^\"]+)\"|(\\S+)) "]

    if let primary = regex[1] ?? regex[2] {
        let spaceToTheLeftOfAnOddNumberOfQoutes = " (?=[^\"]*\"[^\"]*(?:(?:\"[^\"]*){2})* -o )"
        let line = line
            .stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet() )
            .stringByReplacingOccurrencesOfString( "\\\"", withString: "---" )
            .stringByReplacingOccurrencesOfString( spaceToTheLeftOfAnOddNumberOfQoutes,
                withString: "___", options: .RegularExpressionSearch, range: nil )
            .stringByReplacingOccurrencesOfString( "\"", withString: "" )

        let argv = line.componentsSeparatedByString( " " )
            .map { $0.stringByReplacingOccurrencesOfString( "___", withString: " " )
            .stringByReplacingOccurrencesOfString( "---", withString: "\"" ) }
        var out = [String]()

        var i=1
        while i<argv.count {
            let arg = argv[i]
            if arg == "-frontend" {
                out.append( "-Xfrontend" )
                out.append( "-j4" )
            }
            else if arg == "-primary-file" {
            }
            else if arg.hasPrefix( "-emit-" ) ||
                arg == "-serialize-diagnostics-path" {
                    i += 1
            }
            else if arg == "-o" {
                break
            }
            else {
                out.append( arg )
            }
            i += 1
        }

        compilations.append( (primary, SK.array( out ) ) )
        if storingLog != nil {
            progress( "Built \(primary)" )
        }
    }

    storingLog?.writeString( line+"\n" )
}

storingLog?.closeFile()

struct Entity: Hashable {

    let file: String
    let line: Int
    let col: Int

    var hashValue: Int {
        return Int(line + col)
    }

    var anchor: String {
        return "\(line)_\(col)"
    }

    func regex( text: String ) -> ByteRegex {
        var pattern = "^"
        var line = self.line
        while line > 100 {
            pattern += "(?:[^\n]*\n){100}"
            line -= 100
        }
        var col = self.col, largecol = ""
        while col > 100 {
            largecol += ".{100}"
            col -= 100
        }
        pattern += "(?:[^\n]*\n){\(line-1)}(\(largecol).{\(col-1)}[^\n]*?)(\\Q\(text)\\E)([^\n]*)"
        return ByteRegex( pattern: pattern )
    }

    func patchText( contents: NSData, value: String ) -> String? {
        if let matches = regex( value ).match( contents ) {
            return htmlClean( contents, match: matches[1] ) +
           "<b>" + htmlClean( contents, match: matches[2] ) + "</b>" +
                   htmlClean( contents, match: matches[3] )
        }
        return "MATCH FAILED line:\(line) column:\(col)"
    }

    func htmlClean( contents: NSData, match: regmatch_t ) -> String {
        var range = match.range
        if range.length > contents.length - range.location {
            range.length = contents.length - range.location
        }
        return String.fromData( contents.subdataWithRange( range ) )?
            .stringByReplacingOccurrencesOfString( "&", withString: "&amp;" )
            .stringByReplacingOccurrencesOfString( "<", withString: "&lt;" ) ?? "CONVERSION FAILED"
    }
}

func ==(lhs: Entity, rhs: Entity) -> Bool {
    return lhs.line == rhs.line && lhs.col == rhs.col && lhs.file == rhs.file
}

var entities = [Entity:sourcekitd_variant_t]()

class USR {

    var references = [Entity]()
    var reflines = [String]()
    var declaring: Entity?

}

var usrs = [String:USR]()
var fileno = 0

for (file, argv) in compilations {
    fileno += 1
    progress( "Indexing \(fileno)/\(compilations.count) \(file)" )

    if let data = NSData( contentsOfFile: file ) {
        let resp = SK.indexFile( file, compilerArgs: argv )
        let dict = sourcekitd_response_get_value( resp )
        SK.recurseOver( SK.entitiesID, resp: dict, visualiser: nil, block: { dict in
            if let usr = dict.getString( SK.usrID ) {
                let entity = Entity( file: file,
                    line: dict.getInt( SK.lineID ),
                    col: dict.getInt( SK.colID ) )

                entities[entity] = dict

                if usrs[usr] == nil {
                    usrs[usr] = USR()
                }

                usrs[usr]!.references.append( entity )
                usrs[usr]!.reflines.append( entity.patchText( data, value: "" )!
                    .stringByReplacingOccurrencesOfString( "  ", withString: " &nbsp;" ) )
            }
        } )
    }
}

for (entity, dict) in entities {
    if let usr = dict.getString( SK.usrID ) {
        let kind = dict.getUUIDString( SK.kindID )
        if kind.containsString( ".decl." ), var usr = usrs[usr] {
            usr.declaring = entity
        }
    }
}

let resources = String.fromCString( getenv( "HOME" ) )!+"/Library/siteify/"

func copyTemplate( template: String, patches: [String:String], dest: String ) -> UnsafeMutablePointer<FILE> {
    var input = try! NSString( contentsOfFile: resources+template, encoding: NSUTF8StringEncoding )
    for (tag, value) in patches {
        input = input.stringByReplacingOccurrencesOfString( tag, withString: value )
    }
    let out = fopen( dest, "w" )
    fputs( input as String, out )
    return out
}

if !filemgr.fileExistsAtPath( "html" ) {
    try! filemgr.createDirectoryAtPath( "html", withIntermediateDirectories: false, attributes: nil )
}

fclose( copyTemplate( "siteify.css", patches: [:], dest: "html/siteify.css" ) )
let index = copyTemplate( "index.html", patches: [:], dest: "html/index.html" )
var buff = [Int8]( count: Int(PATH_MAX), repeatedValue: 0 )
let cwd = String.fromCString( getcwd( &buff, buff.count ) )!

fileno = 0

for (file, argv) in compilations {
    fileno += 1
    progress( "Saving \(fileno)/\(compilations.count) \(file)" )

    let relative = file.stringByReplacingOccurrencesOfString( cwd+"/", withString: "" )
    let filename = NSURL( fileURLWithPath: file ).URLByDeletingPathExtension!.lastPathComponent!+".html"
    fputs( "<a href='\(filename)'>\(relative)<a><br>\n", index )

    if let data = NSData( contentsOfFile: file ) {
        let bytes = UnsafePointer<Int8>( data.bytes )
        let newline = Int8("\n".utf16.last!)
        var ptr = 0, line = 1, col = 1

        func skipTo( offset: Int ) -> String {
            let out = NSString( bytes: bytes+ptr, length: offset-ptr, encoding: NSUTF8StringEncoding ) ?? ""
            while ptr < offset {
                if bytes[ptr] == newline {
                    line += 1
                    col = 1
                }
                else {
                    col += 1
                }
                ptr += 1
            }
            return out as String
        }

        var html = ""

        let resp = SK.syntaxMap( file, compilerArgs: argv )
        let dict = sourcekitd_response_get_value( resp )
        let map = sourcekitd_variant_dictionary_get_value( dict, SK.syntaxID )
        sourcekitd_variant_array_apply( map ) { (_,dict) in
            let kind = dict.getUUIDString( SK.kindID )
            let kindSuffix = NSURL(fileURLWithPath: kind).pathExtension!
            let offset = dict.getInt( SK.offsetID )
            let length = dict.getInt( SK.lengthID )

            html += skipTo( offset )

            let ent = Entity(file: file, line: line, col: col)
            var text = skipTo( offset+length ).stringByReplacingOccurrencesOfString( "<", withString: "&lt;" )

            if kindSuffix == "url" {
                text = "<a href='\(text)'>\(text)</a>"
            }
            else if let dict = entities[ent] {
                if let usrString = dict.getString( SK.usrID ), usr = usrs[usrString], decl = usr.declaring {
                    if decl != ent {
                        let file = NSURL( fileURLWithPath: decl.file ).URLByDeletingPathExtension!.lastPathComponent!
                        text = "<a name='\(ent.anchor)' href='\(file).html#\(decl.anchor)'>\(text)<a>"
                    }
                    else if usr.references.count > 1 {
                        var popup = ""
                        for i in 0..<usr.references.count {
                            let ref = usr.references[i]
                            if ref == ent {
                                continue
                            }
                            let file = NSURL( fileURLWithPath: ref.file ).URLByDeletingPathExtension!.lastPathComponent!
                            popup += "<tr><td onclick='document.location.href=\"\(file).html#\(ref.anchor)\"; return false;'>\(file).swift:\(ref.line)</td>"
                            popup += "<td>\(usr.reflines[i])</td>"
                        }
                        text = "<a name='\(ent.anchor)' href='#' onclick='return expand(this);'>\(text)<span class='references'><table>\(popup)</table></span></a>"
                    }
                    else {
                        text = "<a name='\(ent.anchor)'>\(text)</a>"
                    }
                }
            }

            html += "<span class='\(kindSuffix)'>"+text+"</span>"
            return true
        }

        html += skipTo( data.length )
        let htmp = NSMutableString( string: html )

        line = 0
        htmp["(^|\\n)"] ~= { (group: String) in
            line += 1
            return group + (NSString( format: "%04d    ", line ) as String)
        }

        let out = copyTemplate( "source.html", patches: [:], dest: "html/"+filename )
        fputs( htmp as String, out )
        fclose( out )
    }
}

progress( "Site built, open ./html/index.html in your browser\n" )
