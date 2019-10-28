//
//  Siteify.swift
//  siteify
//
//  Created by John Holdsworth on 28/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Entity.swift#7 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation
import SwiftLSPClient
#if SWIFT_PACKAGE
import SourceKit
#endif

var filenameForFile = [String:String](), filesForFileName = [String:String]()

func fileFilename(file: String) -> String {
    if let filename = filenameForFile[file] {
        return filename
    }
    var filename = NSURL(fileURLWithPath: file).deletingPathExtension!.lastPathComponent
    while filesForFileName[filename] != nil {
        filename += "_"
    }
    filesForFileName[filename] = file
    filenameForFile[file] = filename
    return filename
}

var comma: NumberFormatter = {
    let comma = NumberFormatter()
    comma.numberStyle = NumberFormatter.Style.decimal
    return comma
}()

func progress(str: String) {
    print("\u{001b}[2K"+str, separator: "", terminator: "\r")
    fflush(stdout)
}

public class Siteify {

    let host: LanguageServerProcessHost
    var lspServer: LanguageServer?
    let sourceKit = SourceKit(isTTY: false)
    let projectRoot: String

    let synchronizer: NSLock = {
        let lock = NSLock()
        lock.lock()
        return lock
    }()

    func syncCheck(_ block: @escaping (@escaping (LanguageServerError?) -> Void) -> Void) {
        block({
            (error: LanguageServerError?) in
            if let error = error {
                fatalError("syncError: \(error)")
            }
            self.synchronizer.unlock()
        })
        synchronizer.lock()
    }

    func syncResult<RESP>(_ block: @escaping (@escaping (LanguageServerResult<RESP>) -> Void) -> Void) -> RESP {
        var theResponse: RESP?
        block({
            (response: LanguageServerResult) in
            switch response {
            case .success(let value):
                theResponse = value
            case .failure(let error):
                fatalError("Error response \(error)")
            }
            self.synchronizer.unlock()
        })
        synchronizer.lock()
        return theResponse!
    }

    public init(projectRoot: String) {
        var rootBuffer = [Int8](repeating: 0, count: 1024)
        let cwd = String(cString: rootBuffer.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        })
        self.projectRoot = URL(fileURLWithPath: projectRoot,
            relativeTo: URL(fileURLWithPath: cwd)).path

        let executablePath = "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/sourcekit-lsp"
        let PATH = ProcessInfo.processInfo.environment["PATH"] ?? "/usr/bin"
        host = LanguageServerProcessHost(path: executablePath, arguments: [],
                                         environment: ["PATH": PATH])

        host.start { (server) in
            guard let server = server else {
                fatalError("unable to launch server")
            }
            self.lspServer = server
        }

        let processId = Int(ProcessInfo.processInfo.processIdentifier)
        let capabilities = ClientCapabilities(workspace: nil, textDocument: nil, experimental: nil)

        let params = InitializeParams(processId: processId,
                                      rootPath: projectRoot,
                                      rootURI: nil,
                                      initializationOptions: nil,
                                      capabilities: capabilities,
                                      trace: Tracing.off,
                                      workspaceFolders: [WorkspaceFolder(uri: "file://\(projectRoot)/", name: "siteify")])

        print(syncResult({
            self.lspServer!.initialize(params: params, block: $0)
        }))
    }

    var index: UnsafeMutablePointer<FILE>?

    public func generateSite(into: String) {
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: "html") {
            try! filemgr.createDirectory(atPath: "html", withIntermediateDirectories: false, attributes: nil)
        }
        fclose(copyTemplate(template: "siteify.css"))
        index = copyTemplate(template: "index.html", patches: [
            "__DATE__": NSDate().description,
            "__ROOT__": projectRoot.replacingOccurrences(of: home, with: "~")])

        for file in filemgr.enumerator(atPath: projectRoot)! {
            if let path = file as? String, !path.starts(with: ".build"),
                (try? LanguageIdentifier(for: URL(fileURLWithPath: path))) != nil {
                processFile(path: projectRoot + "/" + path)
            }
        }
    }

    public func processFile(path: String) {
        let htmlfile = fileFilename(file: path)+".html"
        let relative = path.replacingOccurrences(of: projectRoot+"/", with: "")
        progress(str: "Saving html/\(htmlfile)")
        var html = ""

        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            if index != nil {
                fputs("<a href='\(htmlfile)'>\(relative)<a> \(comma.string(from: NSNumber(value: data.count))!) bytes<br>\n", index)
            }

            syncCheck {
                self.lspServer!.didOpenTextDocument(params: DidOpenTextDocumentParams(textDocument: try! TextDocumentItem(contentsAt: path)), block: $0)
            }
            data.withUnsafeBytes {
                (start: UnsafePointer<Int8>) in
                var curr = start
                var line = 0
                func position(for offset: Int) -> Position {
                    while let next = UnsafePointer<Int8>(strchr(curr, Int32("\n".utf8.first!))),
                        next - start < offset {
                            curr = next + 1
                            line += 1
                    }
                    return Position(line: line,
                                    character: offset - (curr - start))
                }

                let newline = Int8("\n".utf16.last!)
                var ptr = 0, lineno = 1, col = 1

                func skipTo(offset: Int) -> String {
                    let out = NSString(bytes: start+ptr, length: offset-ptr, encoding: String.Encoding.utf8.rawValue) ?? ""
                    while ptr < offset {
                        if start[ptr] == newline {
                            lineno += 1
                            col = 1
                        }
                        else {
                            col += 1
                        }
                        ptr += 1
                    }
                    return out
                        .replacingOccurrences(of: "&", with: "&amp;")
                        .replacingOccurrences(of: "<", with: "&lt;") as String
                }

                var fileLineCache = [String: [String]]()
                func reflines(file: String, line: Int) -> String {
                    if fileLineCache[file] == nil {
                        fileLineCache[file] =
                            (try? String(contentsOfFile: file))?
                            .components(separatedBy: "\n")
                    }
                    if let lines = fileLineCache[file], line < lines.count {
                        return lines[line]
                            .replacingOccurrences(of: "&", with: "&amp;")
                            .replacingOccurrences(of: "<", with: "&lt;")
                    }
                    return ""
                }

                let resp = self.sourceKit.syntaxMap(filePath: path)
                let dict = SKApi.sourcekitd_response_get_value(resp)
//                SKApi.sourcekitd_response_description_dump(resp)
//                print(syncCall({
//                    self.lspServer!.documentSymbol(params: DocumentSymbolParams(textDocument: TextDocumentIdentifier(path: path)), block: $0)}))
                sourceKit.recurseOver(childID: self.sourceKit.syntaxID, resp: dict) { dict in
                    let offset = dict.getInt(key: self.sourceKit.offsetID)
                    let length = dict.getInt(key: self.sourceKit.lengthID)
                    let pos = position(for: offset)
                    print(offset, pos)
                    html += skipTo(offset: offset)
                    let text = skipTo(offset: offset+length)
                    let kind = dict.getUUIDString(key: self.sourceKit.kindID)
                    let kindSuffix = NSURL(fileURLWithPath: kind).pathExtension!
                    var span = "<a name='\(pos.anchor)'>\(text)</a>"
                    if kindSuffix == "url" {
                        span = "<a href='\(text)'>\(text)</a>"
                    }
                    if SKApi.sourcekitd_variant_dictionary_get_uid(dict, self.sourceKit.kindID) == self.sourceKit.identifierID {
                        var def: Location?
                        let res = self.syncResult {
                            self.lspServer!.definition(params: TextDocumentPositionParams(textDocument: TextDocumentIdentifier(path: path), position: pos), block: $0)
                        }
                        switch res {
                        case .locationArray(let a) where a.count > 0:
                            def = a.first
                            print(res as Any)
                        default:
                            break
                        }

                        if let decl = def,
                            decl.file == path &&
                            decl.range.start == pos,
                            let refs = self.syncResult({
                                self.lspServer!.references(params: ReferenceParams(textDocument: TextDocumentIdentifier(path: path), position: pos, context: ReferenceContext(includeDeclaration: false)), block: $0)}) {

                            if refs.count > 0 && decl.file.starts(with: self.projectRoot) {
                                    var popup = ""
                                    for ref in refs {
                                        let keepListOpen = ref.file != decl.file ? "event.stopPropagation(); " : ""
                                        if ref.href == decl.href {
                                            continue
                                        }
                                        popup += "<tr><td style='text-decoration: underline;' onclick='document.location.href=\"\(ref.href)\"; \(keepListOpen)return false;'>\(ref.filename).swift:\(ref.line+1)</td>"
                                        popup += "<td><pre>\(reflines(file: ref.file, line: ref.line))</pre></td>"
                                        print(popup)
                                    }
                                    span = "<a name='\(decl.anchor)' href='#' title='\("usrString2")' onclick='return expand(this);'>" +
                                        "\(text)<span class='references'><table>\(popup)</table></span></a>"
                            }
                            else {
                                span = "<a name='\(decl.anchor)' title='\("usrString3")'>\(text)</a>"
                            }
                        } else if let decl = def, decl.file.starts(with: self.projectRoot) {
                            span = "<a name='\(pos.anchor)' href='\(decl.href)' title='\("usrString1")'>\(text)</a>"
                        }
                    }

                    html += "<span class='\(kindSuffix)'>\(span)</span>"
                }

                html += skipTo(offset: data.count)
            }

            var htmp = html
            var line = 0

            htmp["(^|\n)"] = { (groups: [String], stop) -> String in
                line += 1
                return groups[1] + String(format: "%04d    ", line)
            }

            let out = copyTemplate(template: "source.html", patches: [:], dest: "html/"+htmlfile)
            htmp.withCString { _ = fputs($0, out) }
            fclose(out)
        }
    }

    let home = String(cString: getenv("HOME"))
    let resources = String(cString: getenv("HOME"))+"/Library/siteify/"

    func copyTemplate(template: String, patches: [String:String] = [:], dest: String? = nil) -> UnsafeMutablePointer<FILE> {
        var input = try! NSString(contentsOfFile: resources+template,
              encoding: String.Encoding.utf8.rawValue)
        for (tag, value) in patches {
            input = input.replacingOccurrences(of: tag, with: value) as NSString
        }
        let out = fopen(dest ?? "html/"+template, "w")!
        (input as String).withCString {
            fputs($0, out)
        }
        return out
    }
}

extension Position {

    var anchor: String {
        return "\(line+1)_\(character)"
    }
}

extension Location {

    var file: String {
        return URL(string: uri)!.path
    }

    var filename: String {
        return fileFilename(file: URL(string: uri)!.path)
    }

    var href: String {
        return "\(filename).html#\(range.start.anchor)"
    }

    var line: Int {
        return range.start.line
    }

    var anchor: String {
        return range.start.anchor
    }
}
