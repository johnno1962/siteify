
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
