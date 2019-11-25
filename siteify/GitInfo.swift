//
//  GitInfo.swift
//  siteify
//
//  Created by John Holdsworth on 24/11/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/GitInfo.swift#4 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation

public class GitInfo {

    let gitExecutable = "/usr/bin/git"
    let blameStream: TaskGenerator
    let logStream: TaskGenerator
    let sourceDir: String

    init(fullpath: String) {
        let fullURL = URL(fileURLWithPath: fullpath)
        sourceDir = fullURL.deletingLastPathComponent().path
        blameStream = TaskGenerator(launchPath: gitExecutable,
                                        arguments: ["blame", "-t", fullpath],
                                        directory: sourceDir)
        logStream = TaskGenerator(launchPath: gitExecutable,
                                        arguments: ["log", fullpath],
                                        directory: sourceDir)
    }

    func repoURL() -> String {
        var repoURL = sourceDir
        for _ in 0 ..< 5 {
            if let remote = TaskGenerator(launchPath: gitExecutable,
                                          arguments: ["remote", "-v"], directory: repoURL).allOutput(),
                let (_, url): (String, String) = remote[#"(origin)\s+(\S+)"#] {
                repoURL = url
                if repoURL.starts(with: "http") {
                    break
                }
            }
        }
        return repoURL[".git$", ""]
    }

    func commitJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let logInfo = logStream.allOutput() {
            let logDict = [String: [String: String]](uniqueKeysWithValues: logInfo[#"""
                    commit \^?((\w{7}).*)
                    Author:\s+([^<]+).*
                    Date:\s+(.*)
                    ((?:\n(?!commit).*)*)
                    """#]
                .map({ (info: (String, String, String, String, String)) in
                    return (info.1, ["author": info.2, "hash": info.0,
                                     "date": info.3, "message": info.4])
                }))
            if let logJSON = try? encoder.encode(logDict),
                let logString = String(data: logJSON, encoding: .utf8) {
                return logString
            }
        }

        return nil
    }

    func nextBlame(lineno: Int) -> String? {
        if let blame = blameStream.next(),
            let (commit, _, when): (String, String, String) =
                blame[#"\^?(\w{7})\w? .*?\((.*?) +(\d+) [-+ ]\d+ +\d+\)"#] {
            return "<script> lineLink(\"\(commit)\", \(when), \"\(String(format: "%04d", lineno))\") </script>"
        } else {
            return nil
        }
    }
}
