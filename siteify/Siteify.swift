//
//  Siteify.swift
//  siteify
//
//  Created by John Holdsworth on 28/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Siteify.swift#22 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation
import SwiftLSPClient
#if SWIFT_PACKAGE
import SourceKit
#endif

var filenameForFile = [String: String](), filesForFileName = [String: String]()

let filenameLock = NSLock()

func fileFilename(file: String) -> String {
    filenameLock.lock()
    defer { filenameLock.unlock() }
    if let filename = filenameForFile[file] {
        return filename
    }
    var filename = NSURL(fileURLWithPath: file).lastPathComponent!
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

struct LanguageServerSynchronizer {
    let semaphore = DispatchSemaphore(value: 0)
    var errorHandler = {
        (message: String) in
        fatalError(message)
    }

    func sync(_ block: @escaping (@escaping (LanguageServerError?) -> Void) -> Void) {
        block({ (error: LanguageServerError?) in
            if error != nil {
                self.errorHandler("LanguageServerError: \(error!)")
            }
            self.semaphore.signal()
        })
        semaphore.wait()
    }

    func sync<RESP>(_ block: @escaping (@escaping (LanguageServerResult<RESP>) -> Void) -> Void) -> RESP {
        var theResponse: RESP?
        block({ (response: LanguageServerResult) in
            switch response {
            case .success(let value):
                theResponse = value
            case .failure(let error):
                self.errorHandler("Error response \(error)")
            }
            self.semaphore.signal()
        })
        semaphore.wait()
        return theResponse!
    }
}

public class Siteify: NotificationResponder {

    let sourceKit = SourceKit(logRequests: false)
    let executablePath = "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/sourcekit-lsp"
    var lspServer: LanguageServer!
    let projectRoot: URL

    public init(projectRoot: String) {
        let synchronizer = LanguageServerSynchronizer()
        var rootBuffer = [Int8](repeating: 0, count: 1024)
        let cwd = String(cString: rootBuffer.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        })
        self.projectRoot = URL(fileURLWithPath: projectRoot,
                               relativeTo: URL(fileURLWithPath: cwd))

        let PATH = ProcessInfo.processInfo.environment["PATH"] ?? "/usr/bin"
        let host = LanguageServerProcessHost(path: executablePath, arguments: [],
                                         environment: ["PATH": PATH])

        host.start { (server) in
            guard let server = server as? JSONRPCLanguageServer else {
                fatalError("unable to launch server")
            }
            server.notificationResponder = self
            self.lspServer = server
        }

        let processId = Int(ProcessInfo.processInfo.processIdentifier)
        let capabilities = ClientCapabilities(workspace: nil, textDocument: nil, experimental: nil)

        let workspace = WorkspaceFolder(uri: self.projectRoot.absoluteString, name: "siteify")
        let params = InitializeParams(processId: processId,
                                      rootPath: projectRoot,
                                      rootURI: nil,
                                      initializationOptions: nil,
                                      capabilities: capabilities,
                                      trace: Tracing.off,
                                      workspaceFolders: [workspace])

        _ = synchronizer.sync({
            self.lspServer.initialize(params: params, block: $0)
        })
    }

    var indexFILE: UnsafeMutablePointer<FILE>?

    public func generateSite(into: String) {
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: "html") {
            try! filemgr.createDirectory(atPath: "html", withIntermediateDirectories: false, attributes: nil)
        }
        fclose(copyTemplate(template: "siteify.css"))
        indexFILE = copyTemplate(template: "index.html", patches: [
            "__DATE__": NSDate().description,
            "__ROOT__": projectRoot.path.replacingOccurrences(of: home, with: "~")])
        setbuf(indexFILE, nil)

        filemgr.enumerator(atPath: projectRoot.path)?
            .compactMap { $0 as? String }.sorted()
            .concurrentMap(maxConcurrency: 8) { (path, completion: (String?) -> Void) in
                if (try? LanguageIdentifier(for: URL(fileURLWithPath: path))) != nil {
                    self.processFile(path: self.projectRoot.appendingPathComponent(path).path)
                }
                return completion(path)
            }

        progress(str: "Site complete.")
    }

    public func processFile(path: String) {
        let synchronizer = LanguageServerSynchronizer()
        let htmlfile = fileFilename(file: path)+".html"
        let relative = path.replacingOccurrences(of: projectRoot.path+"/", with: "")
        progress(str: "Saving html/\(htmlfile)")

        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            if indexFILE != nil {
                fputs("<a href='\(htmlfile)'>\(relative)<a> \(comma.string(from: NSNumber(value: data.count))!) bytes<br>\n", indexFILE)
            }

            synchronizer.sync {
                self.lspServer.didOpenTextDocument(params: DidOpenTextDocumentParams(textDocument: try! TextDocumentItem(contentsOfFile: path)), block: $0)
            }
            data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                let start = buffer.baseAddress!.assumingMemoryBound(to: Int8.self)
                var ptr = 0, linestart = 0, lineno = 0, col = 0

                func skipTo(offset: Int) -> String {
                    while let line = memchr(start + linestart,
                                            Int32(UInt8(ascii: "\n")), offset - linestart) {
                        lineno += 1
                        linestart = UnsafePointer<Int8>(line
                            .assumingMemoryBound(to: Int8.self)) - start + 1
                        if start[linestart] == UInt8(ascii: "\r") {
                            linestart += 1
                        }
                    }
                    col = (NSString(bytes: start + linestart,
                                    length: offset - linestart,
                                    encoding: String.Encoding.utf8.rawValue) ?? "").length
                    
                    let out = NSString(bytes: start+ptr, length: offset-ptr,
                                       encoding: String.Encoding.utf8.rawValue) ?? ""
                    ptr = offset
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
                let dict = SKApi.response_get_value(resp)
                let syntaxMap = SKApi.variant_dictionary_get_value( dict, self.sourceKit.syntaxID )
                var html = (0..<SKApi.variant_array_get_count(syntaxMap))
                    .map { (index: Int) -> (String, sourcekitd_variant_t, Position, String) in
                        let dict = SKApi.variant_array_get_value(syntaxMap, index)
                        let offset = dict.getInt(key: self.sourceKit.offsetID)
                        let length = dict.getInt(key: self.sourceKit.lengthID)
                        let pre = skipTo(offset: offset)
                        let pos = Position(line: lineno, character: col)
                        let text = skipTo(offset: offset+length)
                        return (pre, dict, pos, text)
                }.concurrentMap(maxConcurrency: 1
                                /* cannot multithread per file */) {
                    (arg0, completion: @escaping (String) -> Void) in
                    let (pre, dict, pos, text) = arg0
                    let kind = dict.getUUIDString(key: self.sourceKit.kindID)
                    let kindID = SKApi.variant_dictionary_get_uid(dict, self.sourceKit.kindID)
                    let kindSuffix = NSURL(fileURLWithPath: kind).pathExtension!
                    let completion2 = { (span: String) in
                        completion("\(pre)<span class='\(kindSuffix)'>\(span)</span>")
                    }

                    if kindSuffix == "url" {
                        return completion2("<a href='\(text)'>\(text)</a>")
                    }
                    guard kindID == self.sourceKit.identifierID ||
                        kindID == self.sourceKit.typeID else {
                        return completion2(text)
                    }

                    let docPos = TextDocumentPositionParams(textDocument: TextDocumentIdentifier(path: path), position: pos)
                    self.lspServer.definition(params: docPos) { result in
                        switch result {
                        case .success(let value):
                            switch value {
                            case .locationArray(let a) where a.count > 0:
                                let decl = a.first!
                                if decl.file == path && decl.range.start == pos {
                                    self.lspServer.references(params: ReferenceParams(textDocument: TextDocumentIdentifier(path: path), position: pos, context: ReferenceContext(includeDeclaration: false))) {
                                        result in
                                        switch result {
                                        case .success(let refs):
                                            if let refs = refs, refs.count > 0 &&
                                                decl.file.starts(with: self.projectRoot.path) {
                                                var popup = ""
                                                for ref in refs {
                                                    let keepListOpen = ref.file != decl.file ? "event.stopPropagation(); " : ""
                                                    if ref.href == decl.href {
                                                        continue
                                                    }
                                                    popup += "<tr><td style='text-decoration: underline;' onclick='document.location.href=\"\(ref.href)\"; \(keepListOpen)return false;'>\(ref.filebase):\(ref.line+1)</td>"
                                                    popup += "<td><pre>\(reflines(file: ref.file, line: ref.line))</pre></td>"
                                                }
                                                completion2("<a name='\(decl.anchor)' \(popup != "" ? "href='#' " : "")title='\("usrString2")' onclick='return expand(this);'>" +
                                                    "\(text)<span class='references'><table>\(popup)</table></span></a>")
                                            } else {
                                                completion2("<a name='\(decl.anchor)' title='\("usrString3")'>\(text)</a>")
                                            }
                                        case .failure(let err):
                                            return completion2("<span title='\(err)'>#ERROR \(text)</span>")
                                        }
                                    }
                                } else if decl.file.starts(with: self.projectRoot.path) {
                                    completion2("<a name='\(pos.anchor)' href='\(decl.href)' title='\("usrString1")'>\(text)</a>")
                                } else {
                                    completion2(text)
                                }
                            default:
                                completion2(text)
                                break
                            }

                        case .failure(let err):
                            return completion2("<span title='\(err)'>#ERROR \(text)</span>")
                        }
                    }
                }.joined() + skipTo(offset: data.count)

                lineno = 0
                html["(^|\n)"] = { (groups: [String], stop) -> String in
                    lineno += 1
                    return groups[1] + String(format: "<span class=linenum>%04d</span>    ", lineno)
                }

                let htmlFILE = copyTemplate(template: "source.html", patches: ["__FILE__":
                    path.replacingOccurrences(of: projectRoot.path + "/", with: "")],
                                       dest: "html/"+htmlfile)
                _ = html.withCString { fputs($0, htmlFILE) }
                fclose(htmlFILE)

                SKApi.response_dispose(resp)
                synchronizer.sync {
                    self.lspServer.didCloseTextDocument(params: DidCloseTextDocumentParams(textDocument: TextDocumentIdentifier(path: path)), block: $0)
                }
            }
        }

        progress(str: "Saved html/\(htmlfile)")
    }

    let home = String(cString: getenv("HOME"))
    let resources = String(cString: getenv("HOME"))+"/Library/siteify/"

    func copyTemplate(template: String, patches: [String:String] = [:], dest: String? = nil) -> UnsafeMutablePointer<FILE> {
        var input = Self.resources[template]!
        for (tag, value) in patches {
            input = input.replacingOccurrences(of: tag, with: value)
        }
        let out = fopen(dest ?? "html/"+template, "w")!
        _ = input.withCString {
            fputs($0, out)
        }
        return out
    }

    public func languageServerInitialized(_ server: LanguageServer) {
    }

    public func languageServer(_ server: LanguageServer, logMessage message: LogMessageParams) {
        if !message.message.starts(with: "could not open compilation") {
            NSLog("logMessage: \(message)")
        }
    }

    public func languageServer(_ server: LanguageServer, showMessage message: ShowMessageParams) {
        NSLog("showMessage: \(message)")
    }

    public func languageServer(_ server: LanguageServer, showMessageRequest messageRequest: ShowMessageRequestParams) {
        NSLog("showMessageRequest: \(messageRequest)")
    }

    public func languageServer(_ server: LanguageServer, publishDiagnostics diagnosticsParams: PublishDiagnosticsParams) {
        if diagnosticsParams.diagnostics.count > 1 {
            NSLog("publishDiagnostics: \(diagnosticsParams)")
        }
    }

    public func languageServer(_ server: LanguageServer, failedToDecodeNotification notificationName: String, with error: Error) {
        NSLog("failedToDecodeNotification: \(notificationName)  \(error)")
    }
}

extension Position {

    var anchor: String { "\(line+1)_\(character)" }
}

extension Location {

    var file: String { URL(string: uri)!.path }
    var filename: String { fileFilename(file: URL(string: uri)!.path) }
    var filebase: String { URL(string: uri)!.lastPathComponent }
    var line: Int { range.start.line }
    var anchor: String { range.start.anchor }
    var href: String { "\(filename).html#\(anchor)" }
}
