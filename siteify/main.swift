//
//  main.swift
//  siteify
//
//  Created by John Holdsworth on 16/02/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/main.swift#41 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Cocoa

let projectRoot = CommandLine.arguments.dropFirst().first
Siteify(projectRoot: projectRoot ?? ".").generateSite(into: "html")

NSWorkspace.shared.open(URL(fileURLWithPath: "html/index.html"))
