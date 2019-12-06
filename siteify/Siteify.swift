//
//  Siteify.swift
//  siteify
//
//  Created by John Holdsworth on 28/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Siteify.swift#125 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Cocoa
import SwiftLSPClient
#if SWIFT_PACKAGE
import SourceKit
#endif
import Parallel
import GitInfo

public typealias FilePathString = String
public typealias HTMLFileString = String

public class Siteify: NotificationResponder {

    public static var toolchainPath = "/Library/Developer/Toolchains/swift-latest.xctoolchain"
    public static var dotPath = "/usr/local/bin/dot"
    public static var fileTimeout = 100.0
    public static var fileThreads = 8

    static weak var lastSiteify: Siteify?

    let sourceKit = SourceKit(logRequests: false)
    var executablePath: String { return Self.toolchainPath+"/usr/bin/sourcekit-lsp" }
    let filemgr = FileManager.default
    var lspServer: LanguageServer!
    let projectRoot: URL
    var htmlRoot: String!

    func progress(str: String) {
        print("\u{001b}[2K"+str, separator: "", terminator: "\r")
        fflush(stdout)
    }

    public init(projectRoot: String) {
        let synchronizer = LanguageServerSynchronizer()
        var rootBuffer = [Int8](repeating: 0, count: Int(PATH_MAX))
        let cwd = String(cString: rootBuffer.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        })

        self.projectRoot = URL(fileURLWithPath: projectRoot,
                               relativeTo: URL(fileURLWithPath: cwd))
        Self.lastSiteify = self

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

    var packageSymbols = Synchronized([HTMLFileString: [DocumentSymbol]]())
    var referencesFallback = Synchronized([Reference: Location]())
    var symStarts = Synchronized([HTMLFileString: [Int: Position]]())

    var iconForType = Cached(getter: { (ext: String) -> String in
        let image = NSWorkspace.shared.icon(forFileType: ext)
        let cgRef = image.cgImage(forProposedRect: nil, context:nil, hints:nil)!
        let newRep = NSBitmapImageRep(cgImage: cgRef)
        newRep.size = image.size
        return String(format:"data:image/png;base64,%@",
                            newRep.representation(using:.png,  properties:[:])!
                                .base64EncodedString(options: []))
    })

    public func iconForFile(fullpath: FilePathString) -> String {
        iconForType.get(key: URL(fileURLWithPath: fullpath).pathExtension)
    }

    var fileLineCache = Cached(getter: { (file: FilePathString) -> [String]? in
        return (try? String(contentsOfFile: file))?
                        .components(separatedBy: "\n")
    })
    func reflines(file: FilePathString, line: Int) -> String {
        if let lines = fileLineCache.get(key: file), line < lines.count {
            return escape(html: lines[line])
        }
        return ""
    }

    func escape(html: String) -> String {
        return html
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }

    static var filenameInUse = [HTMLFileString: FilePathString](),
            filenameForFile = Cached(getter: {
        (file: FilePathString) -> HTMLFileString in
        var filename = NSURL(fileURLWithPath: file).lastPathComponent!
        while filenameInUse[filename + ".html"] != nil {
            filename += "_"
        }
        filename += ".html"
        filenameInUse[filename] = file
        return filename
    })

    static func uniqueHTMLFile(_ file: FilePathString) -> HTMLFileString {
        return filenameForFile.get(key: file)
    }

    public func generateSite(into: String) {
        htmlRoot = into
        let started = Date.timeIntervalSinceReferenceDate
        if !filemgr.fileExists(atPath: htmlRoot) {
            do {
                try filemgr.createDirectory(atPath: htmlRoot, withIntermediateDirectories: false, attributes: nil)
            } catch {
                fatalError("Could not create directory \(htmlRoot!): \(error)")
            }
        }

        fclose(copyTemplate(template: "siteify.js"))
        fclose(copyTemplate(template: "siteify.css"))

        let repoURL = GitInfo.repoURLS.get(key: projectRoot.path)

        let patches = [
            "__ROOT__": projectRoot.path.replacingOccurrences(of: home, with: "~"),
            "__DATE__": NSDate().description,
            "__REPO__": repoURL
        ]

        indexFILE = copyTemplate(template: "index.html", patches: patches)
        setbuf(indexFILE, nil)

        // Some clangd targets do not complete so we need to time them out
        let reaperQueue = DispatchQueue(label: "FileReaper", qos: .userInteractive)
        let outstanding = Synchronized([String: TimeInterval]())
        var processing = true

        filemgr.enumerator(atPath: projectRoot.path)?
            .compactMap { $0 as? String }.sorted()
            .concurrentMap(maxConcurrency: Self.fileThreads) {
                (relative, completion: @escaping (String?) -> Void) in
                outstanding.synchronized { outstanding in
                    outstanding[relative] = Date.timeIntervalSinceReferenceDate
                }
                var timedout = false

                @discardableResult
                func recordCompletion() -> TimeInterval? {
                    return outstanding.synchronized { outstanding -> TimeInterval? in
                        if let started = outstanding[relative] {
                            if processing {
                                completion(relative)
                            }
                            outstanding[relative] = nil
                            return started
                        }
                        return nil
                    }
                }

                let url = URL(fileURLWithPath: relative)
                if !relative.starts(with: "html/") &&
                    url.lastPathComponent != "output-file-map.json" &&
                    (try? LanguageIdentifier(for: url)) != nil {
                    reaperQueue.asyncAfter(deadline: .now() + Self.fileTimeout) {
                        if let started = recordCompletion() {
                            print("Timeout: ", relative,
                                  Date.timeIntervalSinceReferenceDate - started)
                            timedout = true
                        }
                    }

                    self.processFile(relative: relative, timedout: &timedout)
                }

                recordCompletion()
            }

        processing = false

        // Generate alphabetical list of symbols defined at the top level
        if indexFILE != nil {
            progress(str: "Writing Package Symbols")
            writePackageSymbols(patches: patches)
            "<br><a href='symbols.html'>Package Symbols</a>".write(to: indexFILE!)

            if filemgr.fileExists(atPath: Self.dotPath) {
                progress(str: "Writing Class Graph")
                writeClassGraph(graphSubpackages: true, patches: patches)
                ", <a href='canviz.html'>Class Graph</a>".write(to: indexFILE!)
            }

            fclose(indexFILE)
        }

        progress(str: String(format: "Site complete, %.0f seconds.\n",
                             Date.timeIntervalSinceReferenceDate - started))
    }

    func writePackageSymbols(patches: [String: String]) {
        let symbolsFILE = copyTemplate(template: "symbols.html", patches: patches)
        for sym in packageSymbols.synchronized({$0})
                .map({ (file, syms) in syms.map {(file, $0)}})
                .reduce([], +).sorted(by: {$0.1.name < $1.1.name}) {
            sym.1.print(file: sym.0, indent: " ", to: symbolsFILE)
            "\n".write(to: symbolsFILE)
        }
        fclose(symbolsFILE)
    }

    func writeClassGraph(graphSubpackages: Bool, patches: [String: String]) {
        let canvizRoot = htmlRoot!+"/canviz-0.1/"
        let tmpfile = "/tmp/canviz_\(getpid()).gv"
        guard let dotFILE = fopen(tmpfile, "w") else {
            NSLog("Could not open dot file")
            return
        }

        try! filemgr.createDirectory(atPath: canvizRoot,
                        withIntermediateDirectories: true, attributes: nil)
        fclose(copyTemplate(template: "path.js", dest: canvizRoot+"path.js"))
        fclose(copyTemplate(template: "prototype.js", dest: canvizRoot+"prototype.js"))
        fclose(copyTemplate(template: "canviz.js", dest: canvizRoot+"canviz.js"))
        fclose(copyTemplate(template: "canviz.css", dest: canvizRoot+"canviz.css"))
        fclose(copyTemplate(template: "LICENSE.txt", dest: canvizRoot+"LICENSE.txt"))
        fclose(copyTemplate(template: "README.txt", dest: canvizRoot+"README.txt"))
        fclose(copyTemplate(template: "canviz.html", patches: patches))

        "digraph sweep {\n    node [];\n".write(to: dotFILE)

        var nodeNum = 0
        var nodes = [String: Int]()
        var edges = [String: [String: Int]]()

        func edge(_ from: DocumentSymbol, _ fromFile: FilePathString,
                  _ to: DocumentSymbol, _ toFile: FilePathString) {
            func register(node: DocumentSymbol, filepath: FilePathString) {
                if nodes[node.name] == nil {
                    let color = filepath.contains(".build/checkouts/") ?
                        " fillcolor=\"#e0e0e0\"" : " fillcolor=\"#ffffff\""
                    let shape = node.kind == .interface ?
                        " shape=\"box\"" : ""
                    "    \(nodeNum) [label=\"\(node.name)\" tooltip=\"\(filepath.replacingOccurrences(of: projectRoot.path+"/", with: ""))\" href=\"\(node.href(htmlfile: Self.uniqueHTMLFile(filepath)))\" style=\"filled\"\(color)\(shape)];\n".write(to: dotFILE)
                    nodes[node.name] = nodeNum
                    nodeNum += 1
                }
            }

            if edges[from.name]?[to.name] == nil {
                if edges[from.name] == nil {
                    register(node: from, filepath: fromFile)
                    edges[from.name] = [:]
                }
                register(node: to, filepath: toFile)
                edges[from.name]![to.name] = 0
            }
            edges[from.name]?[to.name]? += 1
        }

        for (ref, decl) in referencesFallback.synchronized({$0}) {
            if graphSubpackages ||
                !ref.filepath.contains(".build/checkouts/") ||
                !decl.filepath.contains(".build/checkouts/"),
                let from = containingType(file: ref.filepath, pos: ref.pos),
                let to = containingType(file: decl.filepath, pos: decl.range.start),
                from.name != to.name {
                edge(from, ref.filepath, to, decl.filepath)
            }
        }

        for (fromName, toDict) in edges {
            for (toName, count) in toDict {
                "    \(nodes[fromName]!) -> \(nodes[toName]!) [width=\(count)];\n".write(to: dotFILE)
            }
        }

        "}\n".write(to: dotFILE)
        fclose(dotFILE)

        let runDot = Process()
        runDot.launchPath = Self.dotPath
        runDot.arguments = [tmpfile, "-Txdot", "-o\(htmlRoot!)/canviz.gv"]
        runDot.launch()
        runDot.waitUntilExit()

        try? filemgr.removeItem(atPath: tmpfile)
    }

    func containingType(file: FilePathString, pos: Position) -> DocumentSymbol? {
        let htmlfile = Self.uniqueHTMLFile(file)
        guard let symbols = packageSymbols.synchronized({ $0[htmlfile] }) else {
            return nil
        }

        for sym in symbols {
            if sym.kind != .typeParameter &&
                sym.range.start.line <= pos.line &&
                pos.line <= sym.range.end.line &&
                symStarts.synchronized({ $0[htmlfile]?[sym.range.start.line] }) != nil {
                return sym
            }
        }

        return nil
    }

    public func processFile(relative: String, timedout: UnsafeMutablePointer<Bool>? = nil) {
        let started = Date.timeIntervalSinceReferenceDate
        let fullURL = projectRoot.appendingPathComponent(relative)
        let fullpath: FilePathString = fullURL.path
        let htmlfile: HTMLFileString = Self.uniqueHTMLFile(fullpath)
        let synchronizer = LanguageServerSynchronizer()
        let gitInfo = GitInfo(fullpath: fullpath)

        if htmlRoot == nil {
            htmlRoot = "html"
        }
        progress(str: "Saving \(htmlRoot!)/\(htmlfile)")

        let docId = TextDocumentIdentifier(path: fullpath)
        guard let docItem = try? TextDocumentItem(contentsOfFile: fullpath) else {
            NSLog("Unable to load file at path: \(fullURL.path)")
            return
        }

        let byteCount = docItem.text.utf8.count
        if indexFILE != nil {
            let relurl = URL(fileURLWithPath: relative)
            "\(relurl.deletingLastPathComponent().relativePath)/<a href='\(htmlfile)'><img class=indeximg src='\(iconForFile(fullpath: relative))'>\(relurl.lastPathComponent)<a> \(comma.string(from: NSNumber(value: byteCount))!) bytes<br>\n".write(to: indexFILE!)
        }

        synchronizer.sync {
            self.lspServer.didOpenTextDocument(params: DidOpenTextDocumentParams(textDocument: docItem), block: $0)
        }

        docItem.text.withCString { (start) in
            var ptr = 0, linestart = 0, lineno = 0, col = 0
            var firstSyms = [Int: Position]()

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
                    let body = skipTo(offset: offset+length)
                    return (pre, dict, pos, body)
            }.concurrentMap(maxConcurrency: 1
                            /* cannot multithread per file */) {
                // Extract information from SourceKit dictionary
                // required to hyperlink identifiers
                (arg0, completion: @escaping (String) -> Void) in
                let (pre, dict, pos, body) = arg0
                let kind = dict.getUUIDString(key: self.sourceKit.kindID)
                let kindID = SKApi.variant_dictionary_get_uid(dict, self.sourceKit.kindID)
                let kindSuffix = NSURL(fileURLWithPath: kind).pathExtension!

                // Wrap derived html in <span> to colorize
                func complete(body: String, title: Any?) {
                    completion("\(pre)<span class='\(kindSuffix)'\(title != nil ? " title='\(title!)'" : "")>\(body)</span>")
                }

                if kindSuffix == "url" {
                    return complete(body: "<a href='\(body)'>\(body)</a>", title: nil)
                }

                // Only interested in identifers
                guard (kindID == self.sourceKit.identifierID ||
                    kindID == self.sourceKit.typeIdenifierID) &&
                    timedout?.pointee != true else {
                    return complete(body: body, title: kind)
                }

                let docPos = TextDocumentPositionParams(textDocument: docId, position: pos)

                func hyperlinkIdentifier(result: LanguageServerResult<DefinitionResponse>) {
                    switch result {
                    case .success(let value):
                        switch value {
                        case .locationArray(let array):
                            guard let decl = array.first ??
                                self.referencesFallback.synchronized({ referencesFallback in
                                    referencesFallback[Reference(filepath: fullpath, pos: pos)]
                                }) else {
                                return complete(body: "<a name='\(pos.anchor)'>\(body)</a>", title: "\(result)")
                            }

                            // Is this the definition on the identifier?
                            // If so, list the referenes as a popup table.
                            if decl.filepath == fullpath && decl.range.start == pos {

                                self.lspServer.references(params: ReferenceParams(textDocument: TextDocumentIdentifier(path: fullpath), position: pos, context: ReferenceContext(includeDeclaration: false))) { result in
                                    switch result {
                                    case .success(let refs):
                                        var markup: String?

                                        func processRefs() {
                                            if let refs = refs, refs.count > 0 &&
                                                decl.filepath.starts(with: self.projectRoot.path) {
                                                var popup = ""

                                                for ref in refs {
                                                    let keepListOpen = ref.filepath != decl.filepath ? "event.stopPropagation(); " : ""
                                                    if ref.href == decl.href {
                                                        continue
                                                    }
                                                    popup += "<tr><td style='text-decoration: underline;' onclick='document.location.href=\"\(ref.href)\"; \(keepListOpen)return false;'>\(ref.filebase):\(ref.line+1)</td>"
                                                    popup += "<td><pre>\(self.reflines(file: ref.filepath, line: ref.line))</pre></td>"
                                                }

                                                if firstSyms[pos.line] == nil && !popup.isEmpty {
                                                    firstSyms[pos.line] = pos
                                                }

                                                complete(body: "<a name='\(decl.anchor)' \(popup.isEmpty ? "" : "href='#' ")onclick='return expand(this);'>" +
                                                    "\(body)<span class='references'><table>\(markup != nil ? "<tr><td colspan=2>\(HTML(fromMarkup: markup!))" : "")\(popup)</table></span></a>", title: "usrString2")
                                                self.referencesFallback.synchronized {
                                                    referencesFallback in
                                                    for ref in refs {
                                                        referencesFallback[Reference(filepath: ref.filepath, pos: ref.range.start)] = decl
                                                    }
                                                }
                                            } else {
                                                complete(body: "<a name='\(decl.anchor)'>\(body)</a>", title: decl.filebase)
                                            }
                                        }

                                        // cannot multithread "hover" requests
                                        if Self.fileThreads > 1 {
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
                                        return complete(body: "#ERR1 \(body)", title: err)
                                    }
                                }
                            } else if decl.filepath.starts(with: self.projectRoot.path) {
                                complete(body: "<a name='\(pos.anchor)' href='\(decl.href)'>\(body)</a>", title: decl.filebase)
                            } else {
                                complete(body: "<a name='\(pos.anchor)'>\(body)</a>", title: decl.filebase)
                           }
                        default:
                            complete(body: body, title: "#DFLT: \(result)")
                        }

                    case .failure(let err):
                        return complete(body: "#ERR2 \(body)", title: err)
                    }
                }

                // typeDefinition doesn't seem to work
                if false && kindID == self.sourceKit.typeIdenifierID {
                    self.lspServer.typeDefinition(params: docPos, block: hyperlinkIdentifier)
                } else {
                    self.lspServer.definition(params: docPos, block: hyperlinkIdentifier)
                }
            }.joined() + skipTo(offset: byteCount)

            // Start with template for source file...
            let repoURL = gitInfo.repoURL()
            let commitJSON = gitInfo.commitJSON()
            let htmlFILE = copyTemplate(template: "source.html", patches: [
                "__FILE__": relative, "__REPO__": repoURL,
                "__CRDATE__": gitInfo.created ?? "Unknown",
                "__MDATE__": gitInfo.modified ?? "Unknown",
                "__IMG__": iconForFile(fullpath: relative)],
                                        dest: htmlRoot+"/"+htmlfile)

            // Add dictionary of commit info for line number blame
            """
                <script>

                var repo = "\(repoURL[".git$", ""])";
                var commits = \(commitJSON ?? "{}");

                </script>

                """.write(to: htmlFILE)

            // Patch line numbers into file (generated in JavaScript)
            lineno = 0
            html = html.components(separatedBy: "\n").map { line in
                lineno += 1
                if let linenoScript = gitInfo.nextBlame(lineno: lineno) {
                    return linenoScript + line
                } else {
                    return String(format: "<a class=linenum name='L%d'>%04d</a>  ", lineno, lineno) + line
                }
            }.joined(separator: "\n")

            // Write hyperlinked page
            html.write(to: htmlFILE)
            fclose(htmlFILE)

            symStarts.synchronized { symStarts in
                symStarts[htmlfile] = firstSyms
            }

            // Remember document symbols contained in file
            if fullpath.containsMatch(of: #"\.(swift)$"#) {
                switch synchronizer.sync({
                    self.lspServer.documentSymbol(params: DocumentSymbolParams(textDocument: docId), block: $0)
                }) {
                case .documentSymbols(let filesyms):
                    let htmlfile = Self.uniqueHTMLFile(fullpath)
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

    let home = NSHomeDirectory()
    let resources = NSHomeDirectory()+"/Library/siteify/"

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

    var filepath: FilePathString { URL(string: uri)!.path }
    var htmlname: String { Siteify.uniqueHTMLFile(filepath) }
    var filebase: String { URL(string: uri)!.lastPathComponent }
    var line: Int { range.start.line }
    var anchor: String { range.start.anchor }
    var href: String { "\(htmlname)#\(anchor)" }
}

struct Reference: Hashable {
    let filepath: FilePathString
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

    func href(htmlfile: String) -> String {
        if let realPos = Siteify.lastSiteify?.symStarts
                .synchronized({ $0[htmlfile]?[range.start.line] }) {
            return "\(htmlfile)#\(realPos.anchor)"
        } else {
            return "\(htmlfile)#L\(range.start.line+1)"
        }
    }

    func print(file: HTMLFileString, indent: String, to: UnsafeMutablePointer<FILE>) {
        if kind != .variable {
            let braces = kind == .class || kind == .struct || kind == .enum || kind == .interface || kind == .namespace
            "\(indent)\(kind.swiftify) <a href='\(href(htmlfile: file))' title='\(self)'>\(name)</a>\(braces  ? " {" : "")\n".write(to: to)
            for sym in children ?? [] {
                sym.print(file: file, indent: indent + "  ", to: to)
            }
            if braces {
                "\(indent)}\n".write(to: to)
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
