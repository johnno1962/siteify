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
        <style type="text/css">
            body, table { font: 14pt Helvetica Neue; }
        </style>
        </head><body>
        <h4>Generated from __ROOT__ on __DATE__</h4>
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

        span.references { display: none; position: absolute; border: 2px outset; z-index: 100; }
        span.references table { background-color: white; }
        span.references table tr td { border: 1px inset; }
        """,
        
        "source.html": """
        <html><head>
            <meta charset="UTF-8">
            <link rel="stylesheet" type="text/css" href="siteify.css">
        <script>

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

        </script></head><body><h3>__FILE__</h3><pre>
        """,

        "xref.html": """
        <html><head>
        <meta charset="UTF-8">
        <style type="text/css">
            body, table { font: 12pt Helvetica Neue; }
        </style>
        </head><body>
        """
    ]
}
