//
//  Siteify.swift
//  siteify
//
//  Created by John Holdsworth on 28/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Siteify.swift#59 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation
import SwiftLSPClient
#if SWIFT_PACKAGE
import SourceKit
#endif

@_silgen_name("popen")
func popen(_ command: UnsafePointer<Int8>, _ perms: UnsafePointer<Int8>) -> UnsafeMutablePointer<FILE>!
@_silgen_name("pclose")
func pclose(_ fp: UnsafeMutablePointer<FILE>?)

var filenameForFile = [String: String](), filesForFileName = [String: String]()

let filenameLock = NSLock()

func htmlFile(_ file: String) -> String {
    filenameLock.lock()
    defer { filenameLock.unlock() }
    if let filename = filenameForFile[file] {
        return filename
    }
    var filename = NSURL(fileURLWithPath: file).lastPathComponent!
    while filesForFileName[filename] != nil {
        filename += "_"
    }
    filename += ".html"
    filesForFileName[filename] = file
    filenameForFile[file] = filename
    return filename
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
    let fileThreads = 8
    var htmlRoot: String!

    func progress(str: String) {
        print("\u{001b}[2K"+str, separator: "", terminator: "\r")
        fflush(stdout)
    }

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
            guard let server = server else {
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
    var comma: NumberFormatter = {
        let comma = NumberFormatter()
        comma.numberStyle = NumberFormatter.Style.decimal
        return comma
    }()

    let symbolsLock = NSLock()
    var packageSymbols = [String: [DocumentSymbol]]()
    let referencesLock = NSLock()
    var referencesFallback = [Loc: Location]()

    public func generateSite(into: String) {
        htmlRoot = into
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: htmlRoot) {
            do {
                try filemgr.createDirectory(atPath: htmlRoot, withIntermediateDirectories: false, attributes: nil)
            } catch {
                fatalError("Could not create directory \(htmlRoot!): \(error)")
            }
        }

        fclose(copyTemplate(template: "siteify.js"))
        fclose(copyTemplate(template: "siteify.css"))
        indexFILE = copyTemplate(template: "index.html", patches: [
            "__DATE__": NSDate().description,
            "__ROOT__": projectRoot.path.replacingOccurrences(of: home, with: "~")])
        setbuf(indexFILE, nil)

        filemgr.enumerator(atPath: projectRoot.path)?
            .compactMap { $0 as? String }.sorted()
            .concurrentMap(maxConcurrency: fileThreads) { (relative, completion: (String?) -> Void) in
                if // !relative.starts(with: "Tests/") && ///
                    (try? LanguageIdentifier(for: URL(fileURLWithPath: relative))) != nil {
                    self.processFile(relative: relative)
                }
                return completion(relative)
            }

        let xrefFILE = copyTemplate(template: "symbols.html")
        for sym in self.symbolsLock.synchronized({packageSymbols})
            .map({ (file, syms) in syms.map {(file, $0)}})
            .reduce([], +).sorted(by: {$0.1.name < $1.1.name}) {
                sym.1.print(file: sym.0, indent: " ", to: xrefFILE)
        }
        fclose(xrefFILE)

        fputs("<br><a href='symbols.html'>Package Symbols</a>", indexFILE)
        fclose(indexFILE)

        progress(str: "Site complete.\n")
    }

    public func processFile(relative: String) {
        let fullpath = projectRoot.appendingPathComponent(relative).path
        let htmlfile = htmlFile(fullpath)
        let synchronizer = LanguageServerSynchronizer()
        if htmlRoot == nil {
            htmlRoot = "html"
        }
        progress(str: "Saving \(htmlRoot!)/\(htmlfile)")
        let directory = URL(fileURLWithPath: fullpath).deletingLastPathComponent().path
        let blameFILE = popen("cd \"\(directory)\"; git blame -t \"\(fullpath)\"", "r")

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fullpath)) else {
            NSLog("Unable to load file at path: \(fullpath)")
            return
        }

        if indexFILE != nil {
            let relurl = URL(fileURLWithPath: relative)
            fputs("\(relurl.deletingLastPathComponent().relativePath)/<a href='\(htmlfile)'>\(relurl.lastPathComponent)<a> \(comma.string(from: NSNumber(value: data.count))!) bytes<br>\n", indexFILE)
        }

        let docId = TextDocumentIdentifier(path: fullpath)
        synchronizer.sync {
            self.lspServer.didOpenTextDocument(params: DidOpenTextDocumentParams(textDocument: try! TextDocumentItem(contentsOfFile: fullpath)), block: $0)
        }

        data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            let start = buffer.baseAddress!.assumingMemoryBound(to: Int8.self)
            var ptr = 0, linestart = 0, lineno = 0, col = 0

            func escape(html: String) -> String {
                return html
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
            }

            func skipTo(offset: Int) -> String {
                while let line = memchr(start + linestart,
                                        Int32(UInt8(ascii: "\n")),
                                        offset - linestart) {
                    lineno += 1
                    linestart = UnsafePointer<Int8>(line
                        .assumingMemoryBound(to: Int8.self)) - start + 1
                    if linestart < offset && start[linestart] == UInt8(ascii: "\r") {
                        linestart += 1
                    }
                }
                col = NSString(bytes: start + linestart,
                               length: offset - linestart,
                               encoding: String.Encoding.utf8.rawValue)?.length ?? 0

                let out = NSString(bytes: start + ptr, length: offset - ptr,
                                   encoding: String.Encoding.utf8.rawValue) ?? ""
                ptr = offset
                return escape(html: out as String)
            }

            var fileLineCache = [String: [String]]()
            func reflines(file: String, line: Int) -> String {
                if fileLineCache[file] == nil {
                    fileLineCache[file] =
                        (try? String(contentsOfFile: file))?
                        .components(separatedBy: "\n")
                }
                if let lines = fileLineCache[file], line < lines.count {
                    return escape(html: lines[line])
                }
                return ""
            }

            let resp = self.sourceKit.syntaxMap(filePath: fullpath)
            let dict = SKApi.response_get_value(resp)
            let syntaxMap = SKApi.variant_dictionary_get_value(dict, self.sourceKit.syntaxID)

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
                let completion2 = { (span: String, title: Any?) in
                    completion("\(pre)<span class='\(kindSuffix)'\(title != nil ? " title='\(title!)'" : "")>\(span)</span>")
                }

                if kindSuffix == "url" {
                    return completion2("<a href='\(text)'>\(text)</a>", nil)
                }
                guard kindID == self.sourceKit.identifierID ||
                    kindID == self.sourceKit.typeID else {
                    return completion2(text, kind)
                }

                let docPos = TextDocumentPositionParams(textDocument: docId, position: pos)
                self.lspServer.definition(params: docPos) { result in
                    switch result {
                    case .success(let value):
                        switch value {
                        case .locationArray(let array):
                            guard let decl = array.first ??
                                self.referencesLock.synchronized({
                                    self.referencesFallback[Loc(path: fullpath, pos: pos)]
                                }) else {
                                return completion2(text, "\(result)")
                            }
                            if decl.file == fullpath && decl.range.start == pos {
                                self.lspServer.references(params: ReferenceParams(textDocument: TextDocumentIdentifier(path: fullpath), position: pos, context: ReferenceContext(includeDeclaration: false))) { result in
                                    switch result {
                                    case .success(let refs):
                                        var markup: String?
                                        
                                        func processRefs() {
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
                                                completion2("<a name='\(decl.anchor)' \(popup != "" ? "href='#' " : "")onclick='return expand(this);'>" +
                                                    "\(text)<span class='references'><table>\(markup != nil ? "<tr><td colspan=2>\(HTML(fromMarkup: markup!))" : "")\(popup)</table></span></a>", "usrString2")
                                                self.referencesLock.synchronized {
                                                    for ref in refs {
                                                        self.referencesFallback[Loc(path: ref.file, pos: ref.range.start)] = decl
                                                    }
                                                }
                                            } else {
                                                completion2("<a name='\(decl.anchor)'>\(text)</a>", decl.filebase)
                                            }
                                        }

                                        // cannot multithread "hover" requests
                                        if self.fileThreads > 1 {
                                            processRefs()
                                        } else {
                                            self.lspServer.hover(params: docPos) { result in
                                                switch result {
                                                case .success(let value):
                                                    switch value?.contents {
                                                    case .markupContent(let content):
                                                        markup = content.value
                                                    default:
                                                        break
                                                    }
                                                default:
                                                    break
                                                }
                                                processRefs()
                                            }
                                        }
                                    case .failure(let err):
                                        return completion2("#ERROR \(text)", err)
                                    }
                                }
                            } else if decl.file.starts(with: self.projectRoot.path) {
                                completion2("<a name='\(pos.anchor)' href='\(decl.href)'>\(text)</a>", decl.filebase)
                            } else {
                                completion2(text, URL(fileURLWithPath: decl.file).lastPathComponent)
                            }
                        default:
                            completion2(text, "default: \(result)")
                        }

                    case .failure(let err):
                        return completion2("#ERR \(text)", err)
                    }
                }
            }.joined() + skipTo(offset: data.count)

            lineno = 0
            var blame = [Int8](repeating: 0, count: 10000)
            blame.withUnsafeMutableBufferPointer {
                (buffer: inout UnsafeMutableBufferPointer<Int8>) in
                let buffro = buffer
                let base = buffro.baseAddress!
                html["(^|\n)"] = { (groups: [String], stop) -> String in
                    lineno += 1
                    if blameFILE != nil,
                        let blame = fgets(base, Int32(buffro.count), blameFILE),
                        let (author, when): (String, String) =
                            String(cString: blame)[#"\((.*?) +(\d+) [-+ ]\d+ +\d+\)"#] {
                            return groups[1] + String(format: "<script> lineLink(\"\(author)\", \(when), \"%04d\") </script>", lineno)
                    } else {
                        return groups[1] + String(format: "<a class=linenum name='L%d'>%04d</a>    ", lineno, lineno)
                    }
                }
            }
            pclose(blameFILE)

            let htmlFILE = copyTemplate(template: "source.html", patches: [
                "__FILE__": relative], dest: htmlRoot+"/"+htmlfile)
            _ = html.withCString { fputs($0, htmlFILE) }
            fclose(htmlFILE)

            if fullpath.containsMatch(of: #"\.(swift|mm?)$"#) {
                switch synchronizer.sync({
                    self.lspServer.documentSymbol(params: DocumentSymbolParams(textDocument: docId), block: $0)
                }) {
                case .documentSymbols(let filesyms):
                    let htmlfile = htmlFile(fullpath)
                    self.symbolsLock.synchronized {
                        self.packageSymbols[htmlfile] = filesyms
                    }
                default:
                    break
                }
            }

            synchronizer.sync {
                self.lspServer.didCloseTextDocument(params: DidCloseTextDocumentParams(textDocument: docId), block: $0)
            }
            SKApi.response_dispose(resp)

            progress(str: "Saved \(htmlRoot!)/\(htmlfile)")
        }
    }

    let home = String(cString: getenv("HOME"))
    let resources = String(cString: getenv("HOME"))+"/Library/siteify/"

    func copyTemplate(template: String, patches: [String: String] = [:], dest: String? = nil) -> UnsafeMutablePointer<FILE> {
        var input = (try? String(contentsOfFile: resources+template)) ?? Self.resources[template]!
        for (tag, value) in patches {
            input = input.replacingOccurrences(of: tag, with: value)
        }
        let filename = dest ?? htmlRoot+"/"+template
        guard let outFILE = fopen(filename, "w") else {
            fatalError("Could not open output file: \(filename)")
        }
        _ = input.withCString { fputs($0, outFILE) }
        return outFILE
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

struct Loc: Hashable {
    let path: String
    let pos: Position
}

extension Position {

    var anchor: String { "\(line+1)_\(character)" }
}

extension Location {

    var file: String { URL(string: uri)!.path }
    var htmlname: String { htmlFile(URL(string: uri)!.path) }
    var filebase: String { URL(string: uri)!.lastPathComponent }
    var line: Int { range.start.line }
    var anchor: String { range.start.anchor }
    var href: String { "\(htmlname)#\(anchor)" }
}

extension SymbolKind {
    static let kindMap = [
        Self.enumMember: "case",
        .property: "var",
        .method: "func",
        .namespace: "extension",
        .interface: "protocol"
    ]
    var swiftify: String { Self.kindMap[self] ?? "\(self)" }
}

extension DocumentSymbol {

    func print(file: String, indent: String, to: UnsafeMutablePointer<FILE>) {
        if kind != .variable {
            let href = "\(file)#L\(range.start.line+1)"
            let braces = kind == .class || kind == .struct || kind == .enum || kind == .namespace
            fputs("\(indent)\(kind.swiftify) <a href='\(href)' title='\(href)'>\(name)</a>\(braces  ? " {" : "")\n", to)
            for sym in children ?? [] {
                sym.print(file: file, indent: indent + "  ", to: to)
            }
            if braces {
                fputs("\(indent)}\n\n", to)
            }
        }
    }
}

func HTML(fromMarkup: String) -> String {
    var text = fromMarkup
    text["^(#+)(.*)\n".anchorsMatchLines] = {
        (groups: [String], stop) -> String in
        let h = "h\(groups[1].utf8.count + 2)"
        return "<\(h)>\(groups[2])</\(h)>"
    }
    text["```\n(.*?)```\n?".dotMatchesLineSeparators] = "$1"
    text["`([^`]*)`"] = "<b>$1</b>"
    text["\n"] = "<br>"
    return text
}
