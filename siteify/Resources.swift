//
//  Resources.swift
//  siteify
//
//  Created by John Holdsworth on 31/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//

extension Siteify {
    static let resources = [
        "index.html": """
            <html><head>
            <meta charset="UTF-8">
            <link rel="stylesheet" type="text/css" href="siteify.css">
            </head><html><body><h3>Generated from __ROOT__ on __DATE__</h3>
            """,

        "siteify.css": """

            body, table { font: 10pt Menlo Regular; }

            .builtin  { color: #A90D91; }
            .comment  { color: #10743E; }
            .url  { color: blue; }
            .doccomment { color: #10743E; }
            .identifier { color: #3F6E74; }
            .keyword { color: #AD0D91; }
            .number { color: #1D26E1; }
            .string { color: #CB444D; }
            .typeidentifier { color: #5C2599; }
            .linenum { color: black; }

            @media (prefers-color-scheme: dark) {
                body { background: #292A30; color: #DFDFE0; }
                .builtin  { color: #A90D91; }
                .comment  { color: #7F8C98; }
                .url, a:link  { color: #6699FC; }
                .doccomment { color: #7F8C98; }
                .identifier { color: #D9C97C; }
                .keyword { color: #EE77B1; }
                .number { color: #D9C97C; }
                .string { color: #EF7E6E; }
                .typeidentifier { color: #DABAFE; }
                .linenum { color: #717276; }
                a:visited { color: #7679DC }
            }

            span.references { display: none; position: absolute; border: 2px outset; z-index: 100; }
            span.references table { background-color: white; color: #292A30; }
            span.references table tr td { border: 1px inset; }
            """,

        "siteify.js": #"""

            //  $Id: //depot/siteify/siteify/Resources.swift#16 $

            var lastlink;

            function expand(a) {
                if ( a.children[0].style.display != "block" ) {
                    if ( lastlink )
                        lastlink.style.display = "none";
                    a.children[0].style.display = "block";
                    lastlink = a.children[0];
                }
                else {
                    a.children[0].style.display = "none";
                    lastlink = null;
                }
                return false;
            }

            function lineLink(commit, author, when, lineno) {
                when *= 1000
                var age = Date.now() - when
                var day = 24*60*60*1000
                var fade = 0
                if (age < day)
                    fade = 1
                else if (age < 7 * day)
                    fade = .5
                else if (age < 31 * day)
                    fade = .25
                var log = (commits[commit]||"").replace(/[\n"&]/g, function(e){ return"&#"+e.charCodeAt(0)+";" })
                document.write("<a class=linenum name='L"+parseInt(lineno)+
                    "' style='border-right: 4px solid rgba(0, 255, 0, "+fade+
                    ");' title=\""+author+" "+new Date(when).toString()+"\n"+log+"\">"+lineno+" </a> ")
            }

            """#,

        "source.html": """
            <html><head>
                <meta charset="UTF-8">
                <title>__FILE__</title>
                <link rel="stylesheet" type="text/css" href="siteify.css">
                <script src="siteify.js"></script>
            </head><html><body><h3>__FILE__</h3><pre>

            """,

        "symbols.html": """
            <html><head>
            <meta charset="UTF-8">
            <title>Symbols</title>
            <link rel="stylesheet" type="text/css" href="siteify.css">
            </head><html><body><h3>Package Symbols</h3><pre>

            """
    ]
}
