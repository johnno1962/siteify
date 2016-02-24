//
//  main.swift
//  siteify
//
//  Created by John Holdsworth on 16/02/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/main.swift#34 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation

let filemgr = NSFileManager.defaultManager()
let SK = SourceKit()
isTTY = false

func progress( str: String ) {
    print( "\u{001b}[2K"+str, separator: "", terminator: "\r" )
    fflush( stdout )
}

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

let buildLog: FileGenerator
let storedLog = "siteify.log"
var storingLog: NSFileHandle? = nil
var linkProblem = false

class StatusGenerator: TaskGenerator {

    override func next() -> String? {
        let next = super.next()
        if next == nil {
            let failedLog = "failed.log"
            if filemgr.fileExistsAtPath( failedLog ) {
                try! filemgr.removeItemAtPath( failedLog )
            }

            task.waitUntilExit()
            if task.terminationStatus != EXIT_SUCCESS && !linkProblem {
                try! filemgr.moveItemAtPath( storedLog, toPath: failedLog )
                print( "\nxcodebuild failed, consult ./\(failedLog)" )
                exit( 1 )
            }
        }
        return next
    }

}

if filemgr.fileExistsAtPath( storedLog ) {
    buildLog = FileGenerator(path: storedLog)!
}
else if filemgr.fileExistsAtPath( "Package.swift" ) {
    if filemgr.fileExistsAtPath( ".build" ) {
        try! filemgr.removeItemAtPath( ".build" )
    }
    buildLog = StatusGenerator( launchPath: "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift",
                                arguments: ["build", "-v", "-v"] )
    storingLog = NSFileHandle( createForWritingAtPath: storedLog )
}
else {
    var buildargs = Process.arguments
    "/tmp/siteify.XXXX".withCString( { (str) in
        buildargs[0] = "SYMROOT="+String.fromCString( mktemp( UnsafeMutablePointer<Int8>(str) ) )!
    } )
    buildLog = StatusGenerator( launchPath: "/usr/bin/xcodebuild", arguments: buildargs )
    storingLog = NSFileHandle( createForWritingAtPath: storedLog )
}

var compilations = [(String, sourcekitd_object_t)]()

for line in buildLog.sequence {

    if storingLog == nil, let symroot = line["^    SYMROOT = ([^\n]+)"][1] where !filemgr.fileExistsAtPath( symroot ) {
        print( "Pre-built project no longer exists, rerun to rebuild" )
        try! filemgr.removeItemAtPath( storedLog )
        exit( 1 )
    }
    else if line["ld: framework not found ImageIO for architecture x86_64"] {
        linkProblem = true
    }

    let regex = line["-primary-file (?:\"([^\"]+)\"|(\\S+)) "]

    if let primary = regex[1] ?? regex[2] {
        compilations.append( (primary, SK.array( SK.compilerArgs( line ) ) ) )
        if storingLog != nil {
            progress( "Built \(primary)" )
        }
    }

    storingLog?.writeString( line+"\n" )
}

storingLog?.closeFile()

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
        SK.recurseOver( SK.entitiesID, resp: dict, block: { dict in
            if let usrString = dict.getString( SK.usrID ) {
                let kind = dict.getUUIDString( SK.kindID )
                let entity = Entity( file: file,
                    line: dict.getInt( SK.lineID ),
                    col: dict.getInt( SK.colID ),
                    kind: kind, decl: kind.containsString( ".decl." ) )

                if usrs[usrString] == nil {
                    usrs[usrString] = USR()
                }

                if !kind.containsString( ".decl.extension." ), var usr = usrs[usrString] {
                    usr.references.append( entity )
                    usr.reflines.append( entity.patchText( data, value: "\\w*" )! )

                    if !kind.containsString( ".accessor." ) {
                        entities[entity] = dict
                    }
                }
            }
        } )
    }
}

for (entity, dict) in entities {
    if let usr = dict.getString( SK.usrID ) {
        if entity.decl, var usr = usrs[usr] {
            usr.declaring = entity
        }
    }
}

var filenameForFile = [String:String](), filesForFileName = [String:String]()

func fileFilename( file: String ) -> String {
    if let filename = filenameForFile[file] {
        return filename
    }
    var filename = NSURL( fileURLWithPath: file ).URLByDeletingPathExtension!.lastPathComponent!
    while filesForFileName[filename] != nil {
        filename += "_"
    }
    filesForFileName[filename] = file
    filenameForFile[file] = filename
    return filename
}

extension Entity {

    var anchor: String {
        return "\(line)_\(col)"
    }

    var filename: String {
        return fileFilename( file )
    }

    var href: String {
        return "\(filename).html#\(anchor)"
    }

}

let home = String.fromCString( getenv("HOME") )!
let resources = home+"/Library/siteify/"

func copyTemplate( template: String, patches: [String:String] = [:], dest: String? = nil ) -> UnsafeMutablePointer<FILE> {
    var input = try! NSString( contentsOfFile: resources+template, encoding: NSUTF8StringEncoding )
    for (tag, value) in patches {
        input = input.stringByReplacingOccurrencesOfString( tag, withString: value )
    }
    let out = fopen( dest ?? "html/"+template, "w" )
    fputs( input.UTF8String, out )
    return out
}

if !filemgr.fileExistsAtPath( "html" ) {
    try! filemgr.createDirectoryAtPath( "html", withIntermediateDirectories: false, attributes: nil )
}
fclose( copyTemplate( "siteify.css" ) )

var buff = [Int8]( count: Int(PATH_MAX), repeatedValue: 0 )
let cwd = String.fromCString( getcwd( &buff, buff.count ) )!

let index = copyTemplate( "index.html", patches: ["__DATE__": NSDate().description,
    "__ROOT__": cwd.stringByReplacingOccurrencesOfString( home, withString: "~" )] )

fileno = 0

var comma = NSNumberFormatter()
comma.numberStyle = NSNumberFormatterStyle.DecimalStyle

for (file, argv) in compilations {
    if let data = NSData( contentsOfFile: file ) {
        let bytes = UnsafePointer<Int8>( data.bytes )
        let filename = fileFilename( file )+".html"
        let relative = file.stringByReplacingOccurrencesOfString( cwd+"/", withString: "" )

        fileno += 1
        progress( "Saving \(fileno)/\(compilations.count) html/\(filename)" )

        fputs( "<a href='\(filename)'>\(relative)<a> \(comma.stringFromNumber(data.length)!) bytes<br>\n", index )

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
            return out.stringByReplacingOccurrencesOfString( "&", withString: "&amp;" )
                      .stringByReplacingOccurrencesOfString( "<", withString: "&lt;" ) as String
        }

        var html = ""

        let resp = SK.syntaxMap( file, compilerArgs: argv )
        let dict = sourcekitd_response_get_value( resp )
        let map = sourcekitd_variant_dictionary_get_value( dict, SK.syntaxID )
        sourcekitd_variant_array_apply( map ) { (_,dict) in
            let offset = dict.getInt( SK.offsetID )
            let length = dict.getInt( SK.lengthID )

            html += skipTo( offset )

            let ent = Entity( file: file, line: line, col: col )
            let text = skipTo( offset+length )
            var span = "<a name='\(ent.anchor)'>\(text)</a>"

            let kind = dict.getUUIDString( SK.kindID )
            let kindSuffix = NSURL( fileURLWithPath: kind ).pathExtension!

            if kindSuffix == "url" {
                span = "<a href='\(text)'>\(text)</a>"
            }
            else if let dict = entities[ent], usrString = dict.getString( SK.usrID ) {
                if let usr = usrs[usrString], decl = usr.declaring {
                    if decl != ent {
                        span = "<a name='\(ent.anchor)' href='\(decl.href)' title='\(usrString)'>\(text)</a>"
                    }
                    else if usr.references.count > 1 {
                        var popup = ""
                        for i in 0..<usr.references.count {
                            let ref = usr.references[i]
                            if ref == ent {
                                continue
                            }
                            let keepListOpen = ref.file != decl.file ? "event.stopPropagation(); " : ""
                            popup += "<tr><td style='text-decoration: underline;' onclick='document.location.href=\"\(ref.href)\"; \(keepListOpen)return false;'>\(ref.filename).swift:\(ref.line)</td>"
                            popup += "<td><pre>\(usr.reflines[i])</pre></td>"
                        }
                        span = "<a name='\(ent.anchor)' href='#' title='\(usrString)' onclick='return expand(this);'>" +
                                        "\(text)<span class='references'><table>\(popup)</table></span></a>"
                    }
                }
                else {
                    span = "<a name='\(ent.anchor)' title='\(usrString)'>\(text)</a>"
                }
            }

            html += "<span class='\(kindSuffix)'>\(span)</span>"
            return true
        }

        html += skipTo( data.length )

        let htmp = RegexMutable( html )
        line = 0

        htmp["(^|\\n)"] ~= { (group: String) in
            line += 1
            return group + (NSString( format: "%04d    ", line ) as String)
        }

        let out = copyTemplate( "source.html", patches: [:], dest: "html/"+filename )
        fputs( htmp.UTF8String, out )
        fclose( out )
    }
}

var symbols = [(String,String,String)]()

for (usrString, usr) in usrs {
    if usrString.hasPrefix( "s:" ), let decl = usrs[usrString]?.declaring {
        let usrString = usrString.substringFromIndex( usrString.startIndex.advancedBy( 2 ) )
        symbols.append( (_stdlib_demangleName( "_T"+usrString ), usrString, decl.href) )
    }
}

let xref = copyTemplate( "xref.html" )

for (symbol,usrString,href) in symbols.sort( { $0.0 < $1.0 } ) {
    let symbol = symbol.stringByReplacingOccurrencesOfString( "<", withString: "&lt;" )
    fputs( "<a href='\(href)' title='\(usrString)'>\(symbol)<a><br>\n", xref )
}

fclose( xref )

fputs( "<a href='xref.html'>Declared Symbols<a><br>\n", index )

fclose( index )

progress( "Site built, open ./html/index.html in your browser.\n" )
