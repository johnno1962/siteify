//
//  main.swift
//  siteify
//
//  Created by John Holdsworth on 16/02/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/main.swift#38 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation
import SwiftLSPClient
#if SWIFT_PACKAGE
import SourceKit
#endif

Siteify(projectRoot: ".").generateSite(into: "html")
