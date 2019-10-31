
## siteify - Build a hyperlinked Web Site from project's Swift sources.

Created as a means of testing SourceKit but generally useful as a mean for browsing
sourcecode, siteify is a Swift script that creates a
hyperlinked and cross referenced version of your Swift source that can be navigated
in a Web Browser. Links over symbol references take you to their definition and
clicking on a link on the definition will list the places the symbol is referenced.

![Icon](http://injectionforxcode.johnholdsworth.com/siteify2.png)

To use, download and build this project using `swift build` or using the
.xcodeproj in Xcode then _cd_ into into your project's root and run 'swift build'
to update the index and type ~/bin/siteify. You'll need to download a recent
development toolchain from [swift.org](https://swift.org/download/) to get the
required sourcekit-lsp executable.

This will build your project recording it's constituent Swift sources, index them
then build the site in the directory ./html. Any PRs on de-glitching the CSS styling
more than welcome.


This project uses the [ChimeHQ/SwiftLSPClient](https://github.com/ChimeHQ/SwiftLSPClient) under a `BSD 3-Clause "New" or "Revised" License"` to communicate with the [Apple LSP server](https://github.com/apple/sourcekit-lsp)

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

This source includes a header file "sourcekit.h" from Apple's Swift Open Source distribution under Apache License v2.0
