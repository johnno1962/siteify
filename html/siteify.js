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
