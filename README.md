
## siteify - Build a hyperlinked Web Site from project's Swift sources.

siteify is a Swift executable that uses SourceKit to create a hyperlinked and
cross referenced version of your Swift source that can be navigated in a Web
Browser. Links over symbol references take you to their definition and clicking
on a link on the definition will list the places the symbol is referenced.

![Icon](http://injectionforxcode.johnholdsworth.com/siteify2.png)

To test drive using the source of this project, use [this link](http://injectionforxcode.johnholdsworth.com/siteify/main.html).
A listing of all symbols is available in [xref.html](http://injectionforxcode.johnholdsworth.com/siteify/xref.html)

To use, download and build this project and _cd_ into into your project's root 
and type ~/bin/siteify then any arguments that would be required to build your 
project using xcodebuild. For example, for a complex workspace you may need to
type something along the lines of:

~/bin/siteify -workspace MyProj.xcworkspace -scheme MyProj -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPad Air'

This will build your project recording it's constituent Swift sources, index them
then build the site in the directory ./html. Any PRs on de-glitching the CSS styling
more than welcome.

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

This source includes a header file "sourcekit.h" from Apple's Swift distribution under Apache License v2.0
