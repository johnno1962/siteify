//
//  Siteify.swift
//  siteify
//
//  Created by John Holdsworth on 28/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Siteify.swift#89 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Cocoa
import SwiftLSPClient
#if SWIFT_PACKAGE
import SwiftRegex
import SourceKit
import Parallel
#endif

var filenameForFile = Synchronized([String: String]()), filesForFileName = [String: String]()

func htmlFile(_ file: String) -> String {
    return filenameForFile.synchronized { filenameForFile in
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

public let SwiftLatestToolchain = "/Library/Developer/Toolchains/swift-latest.xctoolchain"

public class Siteify: NotificationResponder {

    let sourceKit = SourceKit(logRequests: false)
    var toolchainPath: String
    var executablePath: String { return toolchainPath+"/usr/bin/sourcekit-lsp" }
    var lspServer: LanguageServer!
    let projectRoot: URL
    var htmlRoot: String!

    let fileThreads = 4

    func progress(str: String) {
        print("\u{001b}[2K"+str, separator: "", terminator: "\r")
        fflush(stdout)
    }

    public init(toolchainPath: String = SwiftLatestToolchain, projectRoot: String
    ) {
        let synchronizer = LanguageServerSynchronizer()
        var rootBuffer = [Int8](repeating: 0, count: Int(PATH_MAX))
        let cwd = String(cString: rootBuffer.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        })

        self.toolchainPath = toolchainPath
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

    var iconForType = Synchronized([String: String]())
    var packageSymbols = Synchronized([String: [DocumentSymbol]]())
    var referencesFallback = Synchronized([Loc: Location]())

    public func iconForFile(fullpath: String) -> String {
        return iconForType.synchronized { iconForType in
            let ext = URL(fileURLWithPath: fullpath).pathExtension
            var iconString = iconForType[ext]
            if iconString == nil {
                let image = NSWorkspace.shared.icon(forFileType: ext)
                let cgRef = image.cgImage(forProposedRect: nil, context:nil, hints:nil)!
                let newRep = NSBitmapImageRep(cgImage: cgRef)
                newRep.size = image.size
                iconString = String(format:"data:image/png;base64,%@",
                                    newRep.representation(using:.png,  properties:[:])!
                                        .base64EncodedString(options: []))
                iconForType[ext] = iconString
            }

            return iconString!
        }
    }

    public func generateSite(into: String) {
        htmlRoot = into
        let started = Date.timeIntervalSinceReferenceDate
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

        let patches = [
            "__DATE__": NSDate().description,
            "__ROOT__": projectRoot.path.replacingOccurrences(of: home, with: "~")
        ]

        indexFILE = copyTemplate(template: "index.html", patches: patches)
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

        // Generate alphabetical list of symbols defined at the top level
        if indexFILE != nil {
            let symbolsFILE = copyTemplate(template: "symbols.html", patches: patches)
            for sym in packageSymbols.synchronized({$0})
                .map({ (file, syms) in syms.map {(file, $0)}})
                .reduce([], +).sorted(by: {$0.1.name < $1.1.name}) {
                    sym.1.print(file: sym.0, indent: " ", to: symbolsFILE)
            }
            fclose(symbolsFILE)

            "<br><a href='symbols.html'>Package Symbols</a>".write(to: indexFILE!)
            fclose(indexFILE)
        }

        progress(str: String(format: "Site complete, %.0f seconds.\n",
                             Date.timeIntervalSinceReferenceDate - started))
    }

    public func processFile(relative: String) {
        let started = Date.timeIntervalSinceReferenceDate
        let fullURL = projectRoot.appendingPathComponent(relative)
        let fullpath = fullURL.path
        let htmlfile = htmlFile(fullpath)
        let synchronizer = LanguageServerSynchronizer()
        let gitInfo = GitInfo(fullpath: fullpath)

        if htmlRoot == nil {
            htmlRoot = "html"
        }
        progress(str: "Saving \(htmlRoot!)/\(htmlfile)")

        guard let data = try? Data(contentsOf: fullURL) else {
            NSLog("Unable to load file at path: \(fullURL.path)")
            return
        }

        if indexFILE != nil {
            let relurl = URL(fileURLWithPath: relative)
            "\(relurl.deletingLastPathComponent().relativePath)/<a href='\(htmlfile)'><img class=indeximg src='\(iconForFile(fullpath: relative))'>\(relurl.lastPathComponent)<a> \(comma.string(from: NSNumber(value: data.count))!) bytes<br>\n".write(to: indexFILE!)
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

            // Copy characters up to offset, update ptr
            // count line numbers and character position.
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

            // Use SourceKitService to tokenise file
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
                // Extract information from SourceKit dictionary
                // required to hyperlink identifiers
                (arg0, completion: @escaping (String) -> Void) in
                let (pre, dict, pos, text) = arg0
                let kind = dict.getUUIDString(key: self.sourceKit.kindID)
                let kindID = SKApi.variant_dictionary_get_uid(dict, self.sourceKit.kindID)
                let kindSuffix = NSURL(fileURLWithPath: kind).pathExtension!

                // Wrap derived html in <span> to colorize
                func complete(span: String, title: Any?) {
                    completion("\(pre)<span class='\(kindSuffix)'\(title != nil ? " title='\(title!)'" : "")>\(span)</span>")
                }

                if kindSuffix == "url" {
                    return complete(span: "<a href='\(text)'>\(text)</a>", title: nil)
                }

                // Only interested in identifers
                guard kindID == self.sourceKit.identifierID ||
                    kindID == self.sourceKit.typeIdenifierID else {
                    return complete(span: text, title: kind)
                }

                let docPos = TextDocumentPositionParams(textDocument: docId, position: pos)

                func hyperlinkIdentifier(result: LanguageServerResult<DefinitionResponse>) {
                    switch result {
                    case .success(let value):
                        switch value {
                        case .locationArray(let array):
                            guard let decl = array.first ??
                                self.referencesFallback.synchronized({ referencesFallback in
                                    referencesFallback[Loc(path: fullpath, pos: pos)]
                                }) else {
                                return complete(span: text, title: "\(result)")
                            }

                            // Is this the definition on the identifier?
                            // If so, list the referenes as a popup table.
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
                                                complete(span: "<a name='\(decl.anchor)' \(popup != "" ? "href='#' " : "")onclick='return expand(this);'>" +
                                                    "\(text)<span class='references'><table>\(markup != nil ? "<tr><td colspan=2>\(HTML(fromMarkup: markup!))" : "")\(popup)</table></span></a>", title: "usrString2")
                                                self.referencesFallback.synchronized {
                                                    referencesFallback in
                                                    for ref in refs {
                                                        referencesFallback[Loc(path: ref.file, pos: ref.range.start)] = decl
                                                    }
                                                }
                                            } else {
                                                complete(span: "<a name='\(decl.anchor)'>\(text)</a>", title: decl.filebase)
                                            }
                                        }

                                        // cannot multithread "hover" requests
                                        if self.fileThreads > 1 {
                                            processRefs()
                                        } else {
                                            // Hover can be used to extract markup
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
                                        return complete(span: "#ERR1 \(text)", title: err)
                                    }
                                }
                            } else if decl.file.starts(with: self.projectRoot.path) {
                                complete(span: "<a name='\(pos.anchor)' href='\(decl.href)'>\(text)</a>", title: decl.filebase)
                            } else {
                                complete(span: text, title: URL(fileURLWithPath: decl.file).lastPathComponent)
                            }
                        default:
                            complete(span: text, title: "#DFLT: \(result)")
                        }

                    case .failure(let err):
                        return complete(span: "#ERR2 \(text)", title: err)
                    }
                }

                // typeDefinition doesn't seem to work
                if false && kindID == self.sourceKit.typeIdenifierID {
                    self.lspServer.typeDefinition(params: docPos, block: hyperlinkIdentifier)
                } else {
                    self.lspServer.definition(params: docPos, block: hyperlinkIdentifier)
                }
            }.joined() + skipTo(offset: data.count)

            // Start with template for source file...
            let repoURL = gitInfo.repoURL()
            let htmlFILE = copyTemplate(template: "source.html", patches: [
                "__FILE__": relative, "__REPO__": repoURL,
                "__IMG__": iconForFile(fullpath: relative)],
                                        dest: htmlRoot+"/"+htmlfile)

            // Add dictionary of commit info for line number blame
            """
                <script>

                var repo = "\(repoURL)";
                var commits = \(gitInfo.commitJSON() ?? "{}");

                </script>

                """.write(to: htmlFILE)

            // Patch line numbers into file (generated in JavaScript)
            lineno = 0
            html[#"^"#.anchorsMatchLines] = { (groups: [String], stop) -> String in
                lineno += 1
                if let linenoScript = gitInfo.nextBlame(lineno: lineno) {
                    return linenoScript
                } else {
                    return String(format: "<a class=linenum name='L%d'>%04d</a>  ", lineno, lineno)
                }
            }

            // Write hyperlinked page
            html.write(to: htmlFILE)
            fclose(htmlFILE)

            // Remember document symbols contained in file
            if fullpath.containsMatch(of: #"\.(swift|mm?)$"#) {
                switch synchronizer.sync({
                    self.lspServer.documentSymbol(params: DocumentSymbolParams(textDocument: docId), block: $0)
                }) {
                case .documentSymbols(let filesyms):
                    let htmlfile = htmlFile(fullpath)
                    packageSymbols.synchronized { packageSymbols in
                        packageSymbols[htmlfile] = filesyms
                    }
                default:
                    break
                }
            }

            // Tidy up
            synchronizer.sync {
                self.lspServer.didCloseTextDocument(params: DidCloseTextDocumentParams(textDocument: docId), block: $0)
            }
            SKApi.response_dispose(resp)

            progress(str: String(format: "Saved \(htmlRoot!)/\(htmlfile) %.3f seconds",
                                 Date.timeIntervalSinceReferenceDate - started))
        }
    }

    let home = String(cString: getenv("HOME"))
    let resources = String(cString: getenv("HOME"))+"/Library/siteify/"

    func copyTemplate(template: String, patches: [String: String] = [:], dest: String? = nil) -> UnsafeMutablePointer<FILE> {
        var input = (try? String(contentsOfFile: resources+template)) ?? Self.resources[template]!
        for (tag, value) in patches {
            input[tag] = value
        }
        let filename = dest ?? htmlRoot+"/"+template
        guard let outFILE = fopen(filename, "w") else {
            fatalError("Could not open output file: \(filename)")
        }
        input.write(to: outFILE)
        return outFILE
    }

    // NotificationReponder delegate methods

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

extension String {

    func write(to: UnsafeMutablePointer<FILE>) {
        _ = withCString { fputs($0, to) }
    }
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

struct Loc: Hashable {
    let path: String
    let pos: Position
}

extension SymbolKind {
    static let kindMap = [
        Self.enumMember: "case",
        .property: "var",
        .method: "func",
        .namespace: "extension",
        .interface: "protocol"
    ]
    var swiftify: String { "<span class=keyword>\(Self.kindMap[self] ?? "\(self)")</span>" }
}

extension DocumentSymbol {

    func print(file: String, indent: String, to: UnsafeMutablePointer<FILE>) {
        if kind != .variable {
            let href = "\(file)#L\(range.start.line+1)"
            let braces = kind == .class || kind == .struct || kind == .enum || kind == .namespace
            "\(indent)\(kind.swiftify) <a href='\(href)' title='\(href)'>\(name)</a>\(braces  ? " {" : "")\n".write(to: to)
            for sym in children ?? [] {
                sym.print(file: file, indent: indent + "  ", to: to)
            }
            if braces {
                "\(indent)}\n\n".write(to: to)
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
