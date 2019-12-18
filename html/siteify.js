//
//  siteify.js
//  siteify
//
//  Created by John Holdsworth on 28/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Resources.swift#51 $
//
//  Repo: https://github.com/johnno1962/siteify
//

var openDecl;

function expandDecl(a,evnt) {
    var popup = a.parentElement.children[1]
    if (popup.style.display != "block") {
        if (openDecl)
            openDecl.style.display = "none";
        popup.style.display = "block";
        openDecl = popup;
    }
    else {
        popup.style.display = "none";
        openDecl = null;
    }
    (evnt || event).stopPropagation()
    return false;
}

function refClick(a,closePopup,evnt) {
    if (closePopup) {
        openDecl.style.display = "none";
        openDecl = null;
    }
    return true
}

var lastSpan

function extendShade(evnt) {
    if (openDecl){
        openDecl.style.display = "none";
        openDecl = null;
    }
    var span = (evnt || event).target
    if (span && span.href)
        return
    while(span && span.className != "shade" && span.className != "shaded")
        span = span.parentElement
    if (lastSpan && lastSpan != span) {
        while (lastSpan) {
            if (lastSpan.className == "shaded")
                lastSpan.className = "shade"
            lastSpan = lastSpan.parentElement
        }
    }
    lastSpan = span
    while(span && span.className != "shade")
        span = span.parentElement
    if (span && span.className == "shade")
        span.className = "shaded"
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
