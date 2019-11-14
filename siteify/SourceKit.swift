//
//  SourceKit.swift
//  refactord
//
//  Created by John Holdsworth on 19/12/2015.
//  Copyright © 2015 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/SourceKit.swift#16 $
//
//  Repo: https://github.com/johnno1962/Refactorator
//

import Foundation
#if SWIFT_PACKAGE
import SourceKit
#endif

protocol Visualiser {

    func enter()
    func present(dict: sourcekitd_variant_t, indent: String)
    func exit()

}

extension sourcekitd_variant_t {

    func getInt(key: sourcekitd_uid_t) -> Int {
        return Int(SKApi.variant_dictionary_get_int64(self, key))
    }

    func getString(key: sourcekitd_uid_t) -> String? {
        let cstr = SKApi.variant_dictionary_get_string(self, key)
        return cstr != nil ? String(cString: cstr!) : nil
    }

    func getUUIDString(key: sourcekitd_uid_t) -> String {
        let uuid = SKApi.variant_dictionary_get_uid(self, key)
        return String(cString: SKApi.uid_get_string_ptr(uuid!)!)
    }

}

/** Thanks to: https://github.com/jpsim/SourceKitten/blob/master/Source/SourceKittenFramework/library_wrapper_sourcekitd.swift **/

struct DynamicLinkLibrary {
    let path: String
    let handle: UnsafeMutableRawPointer

    func load<T>(symbol: String) -> T {
        if let sym = dlsym(handle, symbol) {
            return unsafeBitCast(sym, to: T.self)
        }
        let errorString = String(cString: dlerror())
        fatalError("Finding symbol \(symbol) failed: \(errorString)")
    }
}

func appsIn(dir: String, matcher: (_ name: String) -> Bool) -> [String] {
    return (try! FileManager.default.contentsOfDirectory(atPath: dir))
        .filter(matcher).sorted().reversed().map { "\(dir)/\($0)" }
}

#if os(Linux)
let toolchainLoader = Loader(searchPaths: [linuxSourceKitLibPath])
#else
let toolchainLoader = Loader(searchPaths: [
    "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/lib/",
    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/"
    ])
#endif

struct Loader {
    let searchPaths: [String]

    func load(path: String) -> DynamicLinkLibrary {
        let fullPaths = searchPaths.map { $0.appending(path) }

        // try all fullPaths that contains target file,
        // then try loading with simple path that depends resolving to DYLD
        for fullPath in fullPaths + [path] {
            if let handle = dlopen(fullPath, RTLD_LAZY) {
                return DynamicLinkLibrary(path: path, handle: handle)
            }
        }

        fatalError("Loading \(path) from \(searchPaths): \(String(cString: dlerror()))")
    }
}

#if os(Linux)
    private let path = "libsourcekitdInProc.so"
#else
    private let path = "sourcekitd.framework/Versions/A/sourcekitd"
#endif
private let library = toolchainLoader.load(path: path)

public class SourceKitEntryPoints {

    public lazy var initialize: @convention(c) () -> Void = library.load(symbol: "sourcekitd_initialize")
    public lazy var shutdown: @convention(c) () -> Void = library.load(symbol: "sourcekitd_shutdown")
    public lazy var set_interrupted_connection_handler: @convention(c) (@escaping sourcekitd_interrupted_connection_handler_t) -> Void = library.load(symbol: "sourcekitd_set_interrupted_connection_handler")
    public lazy var uid_get_from_cstr: @convention(c) (UnsafePointer<Int8>) -> (sourcekitd_uid_t?) = library.load(symbol: "sourcekitd_uid_get_from_cstr")
    public lazy var uid_get_from_buf: @convention(c) (UnsafePointer<Int8>, Int) -> (sourcekitd_uid_t?) = library.load(symbol: "sourcekitd_uid_get_from_buf")
    public lazy var uid_get_length: @convention(c) (sourcekitd_uid_t) -> (Int) = library.load(symbol: "sourcekitd_uid_get_length")
    public lazy var uid_get_string_ptr: @convention(c) (sourcekitd_uid_t) -> (UnsafePointer<Int8>?) = library.load(symbol: "sourcekitd_uid_get_string_ptr")
    public lazy var request_retain: @convention(c) (sourcekitd_object_t) -> (sourcekitd_object_t?) = library.load(symbol: "sourcekitd_request_retain")
    public lazy var request_release: @convention(c) (sourcekitd_object_t) -> Void = library.load(symbol: "sourcekitd_request_release")
    public lazy var request_dictionary_create: @convention(c) (UnsafePointer<sourcekitd_uid_t?>?, UnsafePointer<sourcekitd_object_t?>?, Int) -> (sourcekitd_object_t?) = library.load(symbol: "sourcekitd_request_dictionary_create")
    public lazy var request_dictionary_set_value: @convention(c) (sourcekitd_object_t, sourcekitd_uid_t, sourcekitd_object_t) -> Void = library.load(symbol: "sourcekitd_request_dictionary_set_value")
    public lazy var request_dictionary_set_string: @convention(c) (sourcekitd_object_t, sourcekitd_uid_t, UnsafePointer<Int8>) -> Void = library.load(symbol: "sourcekitd_request_dictionary_set_string")
    public lazy var request_dictionary_set_stringbuf: @convention(c) (sourcekitd_object_t, sourcekitd_uid_t, UnsafePointer<Int8>, Int) -> Void = library.load(symbol: "sourcekitd_request_dictionary_set_stringbuf")
    public lazy var request_dictionary_set_int64: @convention(c) (sourcekitd_object_t, sourcekitd_uid_t, Int64) -> Void = library.load(symbol: "sourcekitd_request_dictionary_set_int64")
    public lazy var request_dictionary_set_uid: @convention(c) (sourcekitd_object_t, sourcekitd_uid_t, sourcekitd_uid_t) -> Void = library.load(symbol: "sourcekitd_request_dictionary_set_uid")
    public lazy var request_array_create: @convention(c) (UnsafePointer<sourcekitd_object_t?>?, Int) -> (sourcekitd_object_t?) = library.load(symbol: "sourcekitd_request_array_create")
    public lazy var request_array_set_value: @convention(c) (sourcekitd_object_t, Int, sourcekitd_object_t) -> Void = library.load(symbol: "sourcekitd_request_array_set_value")
    public lazy var request_array_set_string: @convention(c) (sourcekitd_object_t, Int, UnsafePointer<Int8>) -> Void = library.load(symbol: "sourcekitd_request_array_set_string")
    public lazy var request_array_set_stringbuf: @convention(c) (sourcekitd_object_t, Int, UnsafePointer<Int8>, Int) -> Void = library.load(symbol: "sourcekitd_request_array_set_stringbuf")
    public lazy var request_array_set_int64: @convention(c) (sourcekitd_object_t, Int, Int64) -> Void = library.load(symbol: "sourcekitd_request_array_set_int64")
    public lazy var request_array_set_uid: @convention(c) (sourcekitd_object_t, Int, sourcekitd_uid_t) -> Void = library.load(symbol: "sourcekitd_request_array_set_uid")
    public lazy var request_int64_create: @convention(c) (Int64) -> (sourcekitd_object_t?) = library.load(symbol: "sourcekitd_request_int64_create")
    public lazy var request_string_create: @convention(c) (UnsafePointer<Int8>) -> (sourcekitd_object_t?) = library.load(symbol: "sourcekitd_request_string_create")
    public lazy var request_uid_create: @convention(c) (sourcekitd_uid_t) -> (sourcekitd_object_t?) = library.load(symbol: "sourcekitd_request_uid_create")
    public lazy var request_create_from_yaml: @convention(c) (UnsafePointer<Int8>, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> (sourcekitd_object_t?) = library.load(symbol: "sourcekitd_request_create_from_yaml")
    public lazy var request_description_dump: @convention(c) (sourcekitd_object_t) -> Void = library.load(symbol: "sourcekitd_request_description_dump")
    public lazy var request_description_copy: @convention(c) (sourcekitd_object_t) -> (UnsafeMutablePointer<Int8>?) = library.load(symbol: "sourcekitd_request_description_copy")
    public lazy var response_dispose: @convention(c) (sourcekitd_response_t) -> Void = library.load(symbol: "sourcekitd_response_dispose")
    public lazy var response_is_error: @convention(c) (sourcekitd_response_t) -> (Bool) = library.load(symbol: "sourcekitd_response_is_error")
    public lazy var response_error_get_kind: @convention(c) (sourcekitd_response_t) -> (sourcekitd_error_t) = library.load(symbol: "sourcekitd_response_error_get_kind")
    public lazy var response_error_get_description: @convention(c) (sourcekitd_response_t) -> (UnsafePointer<Int8>?) = library.load(symbol: "sourcekitd_response_error_get_description")
    public lazy var response_get_value: @convention(c) (sourcekitd_response_t) -> (sourcekitd_variant_t) = library.load(symbol: "sourcekitd_response_get_value")
    public lazy var variant_get_type: @convention(c) (sourcekitd_variant_t) -> (sourcekitd_variant_type_t) = library.load(symbol: "sourcekitd_variant_get_type")
    public lazy var variant_dictionary_get_value: @convention(c) (sourcekitd_variant_t, sourcekitd_uid_t) -> (sourcekitd_variant_t) = library.load(symbol: "sourcekitd_variant_dictionary_get_value")
    public lazy var variant_dictionary_get_string: @convention(c) (sourcekitd_variant_t, sourcekitd_uid_t) -> (UnsafePointer<Int8>?) = library.load(symbol: "sourcekitd_variant_dictionary_get_string")
    public lazy var variant_dictionary_get_int64: @convention(c) (sourcekitd_variant_t, sourcekitd_uid_t) -> (Int64) = library.load(symbol: "sourcekitd_variant_dictionary_get_int64")
    public lazy var variant_dictionary_get_bool: @convention(c) (sourcekitd_variant_t, sourcekitd_uid_t) -> (Bool) = library.load(symbol: "sourcekitd_variant_dictionary_get_bool")
    public lazy var variant_dictionary_get_uid: @convention(c) (sourcekitd_variant_t, sourcekitd_uid_t) -> (sourcekitd_uid_t?) = library.load(symbol: "sourcekitd_variant_dictionary_get_uid")
    public lazy var variant_dictionary_apply_f: @convention(c) (sourcekitd_variant_t, @escaping sourcekitd_variant_dictionary_applier_f_t, UnsafeMutableRawPointer?) -> (Bool) = library.load(symbol: "sourcekitd_variant_dictionary_apply_f")
    public lazy var variant_array_get_count: @convention(c) (sourcekitd_variant_t) -> (Int) = library.load(symbol: "sourcekitd_variant_array_get_count")
    public lazy var variant_array_get_value: @convention(c) (sourcekitd_variant_t, Int) -> (sourcekitd_variant_t) = library.load(symbol: "sourcekitd_variant_array_get_value")
    public lazy var variant_array_get_string: @convention(c) (sourcekitd_variant_t, Int) -> (UnsafePointer<Int8>?) = library.load(symbol: "sourcekitd_variant_array_get_string")
    public lazy var variant_array_get_int64: @convention(c) (sourcekitd_variant_t, Int) -> (Int64) = library.load(symbol: "sourcekitd_variant_array_get_int64")
    public lazy var variant_array_get_bool: @convention(c) (sourcekitd_variant_t, Int) -> (Bool) = library.load(symbol: "sourcekitd_variant_array_get_bool")
    public lazy var variant_array_get_uid: @convention(c) (sourcekitd_variant_t, Int) -> (sourcekitd_uid_t?) = library.load(symbol: "sourcekitd_variant_array_get_uid")
    public lazy var variant_array_apply_f: @convention(c) (sourcekitd_variant_t, @escaping sourcekitd_variant_array_applier_f_t, UnsafeMutableRawPointer?) -> (Bool) = library.load(symbol: "sourcekitd_variant_array_apply_f")
    public lazy var variant_array_apply: @convention(c) (sourcekitd_variant_t, @escaping sourcekitd_variant_array_applier_t) -> (Bool) = library.load(symbol: "sourcekitd_variant_array_apply")
    public lazy var variant_int64_get_value: @convention(c) (sourcekitd_variant_t) -> (Int64) = library.load(symbol: "sourcekitd_variant_int64_get_value")
    public lazy var variant_bool_get_value: @convention(c) (sourcekitd_variant_t) -> (Bool) = library.load(symbol: "sourcekitd_variant_bool_get_value")
    public lazy var variant_string_get_length: @convention(c) (sourcekitd_variant_t) -> (Int) = library.load(symbol: "sourcekitd_variant_string_get_length")
    public lazy var variant_string_get_ptr: @convention(c) (sourcekitd_variant_t) -> (UnsafePointer<Int8>?) = library.load(symbol: "sourcekitd_variant_string_get_ptr")
    public lazy var variant_uid_get_value: @convention(c) (sourcekitd_variant_t) -> (sourcekitd_uid_t?) = library.load(symbol: "sourcekitd_variant_uid_get_value")
    public lazy var response_description_dump: @convention(c) (sourcekitd_response_t) -> Void = library.load(symbol: "sourcekitd_response_description_dump")
    public lazy var response_description_dump_filedesc: @convention(c) (sourcekitd_response_t, Int32) -> Void = library.load(symbol: "sourcekitd_response_description_dump_filedesc")
    public lazy var response_description_copy: @convention(c) (sourcekitd_response_t) -> (UnsafeMutablePointer<Int8>?) = library.load(symbol: "sourcekitd_response_description_copy")
    public lazy var variant_description_dump: @convention(c) (sourcekitd_variant_t) -> Void = library.load(symbol: "sourcekitd_variant_description_dump")
    public lazy var variant_description_dump_filedesc: @convention(c) (sourcekitd_variant_t, Int32) -> Void = library.load(symbol: "sourcekitd_variant_description_dump_filedesc")
    public lazy var variant_description_copy: @convention(c) (sourcekitd_variant_t) -> (UnsafeMutablePointer<Int8>?) = library.load(symbol: "sourcekitd_variant_description_copy")
    public lazy var variant_json_description_copy: @convention(c) (sourcekitd_variant_t) -> (UnsafeMutablePointer<Int8>?) = library.load(symbol: "sourcekitd_variant_json_description_copy")
    public lazy var send_request_sync: @convention(c) (sourcekitd_object_t) -> (sourcekitd_response_t?) = library.load(symbol: "sourcekitd_send_request_sync")
    public lazy var send_request: @convention(c) (sourcekitd_object_t, UnsafeMutablePointer<sourcekitd_request_handle_t?>?, sourcekitd_response_receiver_t?) -> Void = library.load(symbol: "sourcekitd_send_request")
    public lazy var cancel_request: @convention(c) (sourcekitd_request_handle_t?) -> Void = library.load(symbol: "sourcekitd_cancel_request")
    public lazy var set_notification_handler: @convention(c) (sourcekitd_response_receiver_t?) -> Void = library.load(symbol: "sourcekitd_set_notification_handler")
    public lazy var set_uid_handler: @convention(c) (sourcekitd_uid_handler_t?) -> Void = library.load(symbol: "sourcekitd_set_uid_handler")
    public lazy var set_uid_handlers: @convention(c) (sourcekitd_uid_from_str_handler_t?, sourcekitd_str_from_uid_handler_t?) -> Void = library.load(symbol: "sourcekitd_set_uid_handlers")
}

public let SKApi = SourceKitEntryPoints()

public class SourceKit {

    /** request types */
    private lazy var requestID = SKApi.uid_get_from_cstr("key.request")!
    private lazy var cursorRequestID = SKApi.uid_get_from_cstr("source.request.cursorinfo")!
    private lazy var indexRequestID = SKApi.uid_get_from_cstr("source.request.indexsource")!
    private lazy var editorCloseID = SKApi.uid_get_from_cstr("source.request.editor.close")!
    private lazy var editorOpenID = SKApi.uid_get_from_cstr("source.request.editor.open")!

    private lazy var enableMapID = SKApi.uid_get_from_cstr("key.enablesyntaxmap")!
    private lazy var enableSubID = SKApi.uid_get_from_cstr("key.enablesubstructure")!
    private lazy var syntaxOnlyID = SKApi.uid_get_from_cstr("key.syntactic_only")!

    /** request arguments */
    public lazy var offsetID = SKApi.uid_get_from_cstr("key.offset")!
    public lazy var sourceFileID = SKApi.uid_get_from_cstr("key.sourcefile")!
    public lazy var compilerArgsID = SKApi.uid_get_from_cstr("key.compilerargs")!

    /** sub entity lists */
    public lazy var depedenciesID = SKApi.uid_get_from_cstr("key.dependencies")!
    public lazy var overridesID = SKApi.uid_get_from_cstr("key.overrides")!
    public lazy var entitiesID = SKApi.uid_get_from_cstr("key.entities")!
    public lazy var syntaxID = SKApi.uid_get_from_cstr("key.syntaxmap")!
    public lazy var identifierID = SKApi.uid_get_from_cstr("source.lang.swift.syntaxtype.identifier")!
    public lazy var typeID = SKApi.uid_get_from_cstr("source.lang.swift.syntaxtype.typeidentifier")!

    /** entity attributes */
    public lazy var receiverID = SKApi.uid_get_from_cstr("key.receiver_usr")!
    public lazy var isDynamicID = SKApi.uid_get_from_cstr("key.is_dynamic")!
    public lazy var isSystemID = SKApi.uid_get_from_cstr("key.is_system")!
    public lazy var moduleID = SKApi.uid_get_from_cstr("key.modulename")!
    public lazy var lengthID = SKApi.uid_get_from_cstr("key.length")!
    public lazy var kindID = SKApi.uid_get_from_cstr("key.kind")!
    public lazy var nameID = SKApi.uid_get_from_cstr("key.name")!
    public lazy var lineID = SKApi.uid_get_from_cstr("key.line")!
    public lazy var colID = SKApi.uid_get_from_cstr("key.column")!
    public lazy var usrID = SKApi.uid_get_from_cstr("key.usr")!

    /** kinds */
    public lazy var clangID = SKApi.uid_get_from_cstr("source.lang.swift.import.module.clang")

    /** declarations */
    public lazy var structID = SKApi.uid_get_from_cstr("source.lang.swift.decl.struct")
    public lazy var classID = SKApi.uid_get_from_cstr("source.lang.swift.decl.class")
    public lazy var enumID = SKApi.uid_get_from_cstr("source.lang.swift.decl.enum")

    /** references */
    public lazy var classVarID = SKApi.uid_get_from_cstr("source.lang.swift.ref.function.var.class")
    public lazy var classMethodID = SKApi.uid_get_from_cstr("source.lang.swift.ref.function.method.class")
    public lazy var initID = SKApi.uid_get_from_cstr("source.lang.swift.ref.function.constructor")
    public lazy var varID = SKApi.uid_get_from_cstr("source.lang.swift.ref.var.instance")
    public lazy var methodID = SKApi.uid_get_from_cstr("source.lang.swift.ref.function.method.instance")
    public lazy var elementID = SKApi.uid_get_from_cstr("source.lang.swift.ref.enumelement")

    let logRequests: Bool

    init(logRequests: Bool = isatty(STDERR_FILENO) != 0) {
        SKApi.initialize()
        self.logRequests = logRequests
    }

    public func array(argv: [String]) -> sourcekitd_object_t {
        let objects = argv.map { SKApi.request_string_create($0) }
        return SKApi.request_array_create(objects, objects.count)!
    }

    func error(resp: sourcekitd_response_t) -> String? {
        if SKApi.response_is_error(resp) {
            return String(cString: SKApi.response_error_get_description(resp)!)
        }
        return nil
    }

    public func sendRequest(req: sourcekitd_object_t) -> sourcekitd_response_t {

        if logRequests {
            SKApi.request_description_dump(req)
        }

        var resp: sourcekitd_response_t!
        while true {
            resp = SKApi.send_request_sync(req)
            let err = error(resp: resp)
            if err == "restoring service" || err == "semantic editor is disabled" {
                sleep(1)
                continue
            } else {
                break
            }
        }

        SKApi.request_release(req)

        if logRequests && !SKApi.response_is_error(resp) {
            SKApi.response_description_dump_filedesc(resp, STDERR_FILENO)
        }

        return resp
    }

    public func cursorInfo(filePath: String, byteOffset: Int32,
                           compilerArgs: sourcekitd_object_t) -> sourcekitd_response_t {
        let req = SKApi.request_dictionary_create(nil, nil, 0)!

        SKApi.request_dictionary_set_uid(req, requestID, cursorRequestID)
        SKApi.request_dictionary_set_string(req, sourceFileID, filePath)
        SKApi.request_dictionary_set_int64(req, offsetID, Int64(byteOffset))
        SKApi.request_dictionary_set_value(req, compilerArgsID, compilerArgs)

        return sendRequest(req: req)
    }

    func indexFile(filePath: String, compilerArgs: sourcekitd_object_t) -> sourcekitd_response_t {
        let req = SKApi.request_dictionary_create(nil, nil, 0)!

        SKApi.request_dictionary_set_uid(req, requestID, indexRequestID)
        SKApi.request_dictionary_set_string(req, sourceFileID, filePath)
        SKApi.request_dictionary_set_value(req, compilerArgsID, compilerArgs)

        return sendRequest(req: req)
    }

    public func syntaxMap(filePath: String, compilerArgs: sourcekitd_object_t? = nil) -> sourcekitd_response_t {
        var req = SKApi.request_dictionary_create(nil, nil, 0)!

        SKApi.request_dictionary_set_uid(req, requestID, editorOpenID)
        SKApi.request_dictionary_set_string(req, nameID, filePath)
        SKApi.request_dictionary_set_string(req, sourceFileID, filePath)
        SKApi.request_dictionary_set_value(req, compilerArgsID, compilerArgs ?? array(argv: []))
        SKApi.request_dictionary_set_int64(req, enableMapID, 1)
        SKApi.request_dictionary_set_int64(req, enableSubID, 0)
        SKApi.request_dictionary_set_int64(req, syntaxOnlyID, 1)

        let resp = sendRequest(req: req)

        req = SKApi.request_dictionary_create(nil, nil, 0)!
        SKApi.request_dictionary_set_uid(req, requestID, editorCloseID)
        SKApi.request_dictionary_set_string(req, nameID, filePath)
        SKApi.request_dictionary_set_string(req, sourceFileID, filePath)

        SKApi.response_dispose(sendRequest(req: req))

        return resp
    }

    func recurseOver(childID: sourcekitd_uid_t, resp: sourcekitd_variant_t,
                     indent: String = "", visualiser: Visualiser? = nil,
                     block: @escaping (_ dict: sourcekitd_variant_t) -> Void) {
        let children = SKApi.variant_dictionary_get_value(resp, childID)
            if SKApi.variant_get_type(children) == SOURCEKITD_VARIANT_TYPE_ARRAY {

                visualiser?.enter()
                _ = SKApi.variant_array_apply(children) { (_, dict) in

                    block(dict)
                    visualiser?.present(dict: dict, indent: indent)

                    self.recurseOver(childID: childID, resp: dict, indent: indent+"  ",
                                     visualiser: visualiser, block: block)
                    return true
                }
                visualiser?.exit()
            }
    }

    func compilerArgs(buildCommand: String, filelist: [String]? = nil) -> [String] {
        let spaceToTheLeftOfAnOddNumberOfQoutes = " (?=[^\"]*\"[^\"]*(?:(?:\"[^\"]*){2})* -o)"
        let line = buildCommand
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\\"", with: "---")
            .replacingOccurrences(of: spaceToTheLeftOfAnOddNumberOfQoutes,
                                   with: "___", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "\"", with: "")

        let argv = line.components(separatedBy: " ")
                .map { $0.replacingOccurrences(of: "___", with: " ")
                    .replacingOccurrences(of: "---", with: "\"") }

        var out = [String]()
        var argno  = 1

        while argno < argv.count {
            let arg = argv[argno ]
            if arg == "-frontend" {
                out.append("-Xfrontend")
                out.append("-j4")
            } else if arg == "-primary-file" {
            } else if arg.hasPrefix("-emit-") ||
                arg == "-serialize-diagnostics-path" {
                    argno  += 1
            } else if arg == "-o" {
                break
            } else if arg == "-filelist" && filelist != nil {
                out += filelist!
                argno  += 1
            } else {
                out.append(arg)
            }
            argno  += 1
        }

        return out
    }

    func disectUSR(usr: NSString) -> [String]? {
        guard usr.hasPrefix("s:") else { return nil }

        let digits = CharacterSet.decimalDigits
        let scanner = Scanner(string: usr as String)
        var out = [String]()
        var wasZero = false

        while !scanner.isAtEnd {

            var name: NSString?
            scanner.scanUpToCharacters(from: digits, into: &name)
            if name != nil, let name = name as String? {
                if wasZero {
                    out[out.count-1] += "0" + name
                    wasZero = false
                } else {
                    out.append(name)
                }
            }

            var len = 0
            scanner.scanInt(&len)
            wasZero = len == 0
            if wasZero {
                continue
            }

            if len > usr.length-scanner.scanLocation {
                len = usr.length-scanner.scanLocation
            }
            
            let range = NSMakeRange(scanner.scanLocation, len)
            out.append(usr.substring(with: range))
            scanner.scanLocation += len
        }

        return out
    }
}
