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
            <title>Siteify of __ROOT__</title>
            </head><html><body class=index><h3>Generated from __ROOT__ on __DATE__</h3>
            """,

        "source.html": """
            <html><head>
                <meta charset="UTF-8">
                <title>__FILE__</title>
                <link rel="stylesheet" type="text/css" href="siteify.css">
                <script src="siteify.js"></script>
            </head><html><body class=source><h3><img src='__IMG__'> Source: __FILE__ (<a href='index.html'>Index</a>)<br/><br/>Repo: <a href='__REPO__'>__REPO__</a></h3><pre>

            """,

        "symbols.html": """
            <html><head>
            <meta charset="UTF-8">
            <title>Symbols in __ROOT__</title>
            <link rel="stylesheet" type="text/css" href="siteify.css">
            </head><html><body><h2>Package Symbols</h2><pre>

            """,

        "siteify.css": """

            body, table { font: 10pt Menlo Regular; }
            body.index img { ddisplay: none; width: 16px; height: 16px; position: relative; top: 3px; }
            body.source img { position: relative; top: 3px; left: -1px; }

            .builtin  { color: #A90D91; }
            .comment  { color: #10743E; }
            .url  { color: blue; }
            .doccomment { color: #10743E; }
            .identifier { color: #3F6E74; }
            .keyword { color: #AD0D91; }
            .number { color: #1D26E1; }
            .string { color: #CB444D; }
            .typeidentifier { color: #5C2599; }

            .linenum { color: black; text-decoration: none; }
            a.linenum:hover { text-decoration: underline; }
            .highlight { border-right: 4px solid rgba(0, 255, 0, 0); }
            .lastday { border-right: 4px solid rgba(0, 255, 0, 1); }
            .lastweek { border-right: 4px solid rgba(0, 255, 0, .5); }
            .lastmonth { border-right: 4px solid rgba(0, 255, 0, .25); }
            .lastyear { border-right: 4px solid rgba(0, 255, 0, .125); }

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
            //
            //  siteify.js
            //  siteify
            //
            //  Created by John Holdsworth on 28/10/2019.
            //  Copyright © 2019 John Holdsworth. All rights reserved.
            //
            //  $Id: //depot/siteify/siteify/Resources.swift#32 $
            //
            //  Repo: https://github.com/johnno1962/siteify
            //

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

            function lineLink(commit, when, lineno) {
                when *= 1000
                var age = Date.now() - when
                var day = 24*60*60*1000
                var fade = ""
                if (age < day)
                    fade = " lastday"
                else if (age < 7 * day)
                    fade = " lastweek"
                else if (age < 31 * day)
                    fade = " lastmonth"
                else if (age < 365 * day)
                    fade = " lastyear"
                var info = commits[commit] || {
                    "message": "\n    [Outside blame range]\n"}
                var title = "Author: "+(info["author"]||"Unknown")+"\n"+
                    (info["date"]||new Date(when))+"\n"+(info["message"]||"")

                document.write("<a class='linenum' name=L"+parseInt(lineno)+
                    " title='"+title.replace(/['\n&]/g, function(e) {
                        return"&#"+e.charCodeAt(0)+";"
                    })+"' href='"+repo+"/commit/"+info["hash"]+"'>"+
                    lineno+"</a><span class='highlight"+fade+"'> </span> ")
            }

            """#,
    ]
}
