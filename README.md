
## siteify - Build a hyperlinked Web Site from project's Swift sources.

Created as a means of testing SourceKit but useful more generally as a mean for browsing
source code, `siteify` is a Swift program that creates a hyperlinked HTML reference of a
project that can be built with the Swift Package Manager and be navigated in a Web Browser.
Links over symbol references take you to their definition and clicking on the link on a definition
will list links for the places the symbol is referenced.

For example, the source of this project is available to browse [here](http://johnholdsworth.com/siteify/html/).

![Icon](http://injectionforxcode.johnholdsworth.com/siteify2.png)

To use, download, and build this project using Xcode. There will be a short pause before the
first build while the package dependancies are resolved after which the build the binary and
required frameworks are installed as `~/bin/siteify`.

_cd_ into the root the SPM project you wish to document and run `swift build` in
order to update it's index and type `~/bin/siteify` (you'll need to download a recent
development toolchain from [swift.org](https://swift.org/download/) to get the required
`sourcekit-lsp` executable).  `siteify` can take a command line argument which is
the SPM repo to process but always places the generated html in the directory `html`
created in the current working directory and opens the file `html/index.html`.

### Customisation

Siteify generates html files based on templates built into the app from the source
[`Resources.swift`](siteify/Resouces.swift). Certain information about a file is patched
in at the last minute using tags such as `\_\_ROOT\_\_`, `\_\_DATE\_\_`, `\_\_REPO\_\_` 
and, for individual source files , `\_\_CRDATE\_\_`, , `\_\_MDATE\_\_` along with the system
`\_\_IMG\_\_` for that type of file. These templates are compiled into the application but
can be overridden by placing your own HTML/CSS/JS templates in `~/Library/Siteify` for the
styling you prefer.

This project uses [ChimeHQ/SwiftLSPClient](https://github.com/ChimeHQ/SwiftLSPClient)
under a `BSD 3-Clause "New" or "Revised" License"` to communicate with the 
[Apple LSP server](https://github.com/apple/sourcekit-lsp)

### MIT License

Copyright (C) 2016 John Holdsworth

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

This source includes a header file "sourcekit.h" from Apple's Swift Open Source distribution under Apache License v2.0 and a very old version of [canviz](http://www.ryandesign.com/canviz/) which allows you to render [graphviz](https://www.graphviz.org/) "dot" files of class inter-relationships if you have `/usr/local/bin/dot` installed and you view the generated files through a web server.
