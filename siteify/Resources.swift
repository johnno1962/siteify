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
            </head><html><body class=index>
            <h2>Generated from __ROOT__ on __DATE__</h2>
            <h3>Repo: <a href='__REPO__'>__REPO__</a></h3>
            """,

        "source.html": """
            <html><head>
                <meta charset="UTF-8">
                <title>__FILE__</title>
                <link rel="stylesheet" type="text/css" href="siteify.css">
                <script src="siteify.js"></script>
            </head><html><body class=source>
            <h2><img src='__IMG__'> Source: __FILE__ (Return to <a href='index.html'>Index</a>)</h2>
            <h3>Repo: <a href='__REPO__'>__REPO__</a></h3>
            <table><tr><td>Initial Commit:<td>__CRDATE__
            <tr><td>Last modified:<td>__MDATE__</table><pre>

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
            //  $Id: //depot/siteify/siteify/Resources.swift#39 $
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

        "canviz.html": #"""
            <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
            "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
            <!--
             This file is part of Canviz. See http://www.canviz.org/
             $Id: //depot/siteify/siteify/Resources.swift#39 $
             -->
            <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
                <head>
                    <meta name="MSSmartTagsPreventParsing" content="true" />
                    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
                    <link rel="stylesheet" type="text/css" href="canviz-0.1/canviz.css" />
                    <link rel="stylesheet" type="text/css" href="siteify/canviz.css" />
                    <title>Siteify Object Graph</title>
                    <script type="text/javascript" src="canviz-0.1/prototype.js"></script>
                    <script type="text/javascript" src="canviz-0.1/path.js"></script>
                    <script type="text/javascript" src="canviz-0.1/canviz.js"></script>
                    <script>
                        var canviz;
                        document.observe('dom:loaded', function() {
                             canviz = new Canviz('canviz', 'canviz.gv?flush='+Math.random());
                        });
                        function sendClient(selector,pathID) {
                            prompt(selector,pathID)
                        }
                        function set_graph_scale(select) {
                            canviz.setScale(select.value);
                            canviz.draw();
                            window.scrollTo(0,0);
                        }
                        function click_node(node) {
                            sendClient( "open:", node );
                        }
                        window.onscroll = function() {
                            $('menus').style.left = document.body.scrollLeft+"px";
                        }
                    </script>
                </head>
                <body>
                    <div id="menus" style="position: relative;">
                        Repo: <a href='__REPO__'>__REPO__</a> Scale Image:

                        <select name="graph_scale" id="graph_scale" onchange="set_graph_scale(this)">
                            <option value="1" selected>100%</option>
                            <option value="0.75">75%</option>
                            <option value="0.5">50%</option>
                            <option value="0.35">35%</option>
                            <option value="0.25">25%</option>
                            <option value="0.15">15%</option>
                            <option value="0.1">10%</option>
                            <option value="0.05">5%</option>
                        </select>

                        Return to <a href='index.html'>Index</a>
                    </div>

                    <div id="debug_output" style="display:none"></div>

                    <div class="graph">
                        <div id="canviz"></div>
                    </div>

                </body>
            </html>
            """#,

        "prototype.js": #"""
            /*  Prototype JavaScript framework, version 1.6.0.3
             *  (c) 2005-2008 Sam Stephenson
             *
             *  Prototype is freely distributable under the terms of an MIT-style license.
             *  For details, see the Prototype web site: http://www.prototypejs.org/
             *
             *--------------------------------------------------------------------------*/

            var Prototype = {
              Version: '1.6.0.3',

              Browser: {
                IE:     !!(window.attachEvent &&
                  navigator.userAgent.indexOf('Opera') === -1),
                Opera:  navigator.userAgent.indexOf('Opera') > -1,
                WebKit: navigator.userAgent.indexOf('AppleWebKit/') > -1,
                Gecko:  navigator.userAgent.indexOf('Gecko') > -1 &&
                  navigator.userAgent.indexOf('KHTML') === -1,
                MobileSafari: !!navigator.userAgent.match(/Apple.*Mobile.*Safari/)
              },

              BrowserFeatures: {
                XPath: !!document.evaluate,
                SelectorsAPI: !!document.querySelector,
                ElementExtensions: !!window.HTMLElement,
                SpecificElementExtensions:
                  document.createElement('div')['__proto__'] &&
                  document.createElement('div')['__proto__'] !==
                    document.createElement('form')['__proto__']
              },

              ScriptFragment: '<script[^>]*>([\\S\\s]*?)<\/script>',
              JSONFilter: /^\/\*-secure-([\s\S]*)\*\/\s*$/,

              emptyFunction: function() { },
              K: function(x) { return x }
            };

            if (Prototype.Browser.MobileSafari)
              Prototype.BrowserFeatures.SpecificElementExtensions = false;


            /* Based on Alex Arnell's inheritance implementation. */
            var Class = {
              create: function() {
                var parent = null, properties = $A(arguments);
                if (Object.isFunction(properties[0]))
                  parent = properties.shift();

                function klass() {
                  this.initialize.apply(this, arguments);
                }

                Object.extend(klass, Class.Methods);
                klass.superclass = parent;
                klass.subclasses = [];

                if (parent) {
                  var subclass = function() { };
                  subclass.prototype = parent.prototype;
                  klass.prototype = new subclass;
                  parent.subclasses.push(klass);
                }

                for (var i = 0; i < properties.length; i++)
                  klass.addMethods(properties[i]);

                if (!klass.prototype.initialize)
                  klass.prototype.initialize = Prototype.emptyFunction;

                klass.prototype.constructor = klass;

                return klass;
              }
            };

            Class.Methods = {
              addMethods: function(source) {
                var ancestor   = this.superclass && this.superclass.prototype;
                var properties = Object.keys(source);

                if (!Object.keys({ toString: true }).length)
                  properties.push("toString", "valueOf");

                for (var i = 0, length = properties.length; i < length; i++) {
                  var property = properties[i], value = source[property];
                  if (ancestor && Object.isFunction(value) &&
                      value.argumentNames().first() == "$super") {
                    var method = value;
                    value = (function(m) {
                      return function() { return ancestor[m].apply(this, arguments) };
                    })(property).wrap(method);

                    value.valueOf = method.valueOf.bind(method);
                    value.toString = method.toString.bind(method);
                  }
                  this.prototype[property] = value;
                }

                return this;
              }
            };

            var Abstract = { };

            Object.extend = function(destination, source) {
              for (var property in source)
                destination[property] = source[property];
              return destination;
            };

            Object.extend(Object, {
              inspect: function(object) {
                try {
                  if (Object.isUndefined(object)) return 'undefined';
                  if (object === null) return 'null';
                  return object.inspect ? object.inspect() : String(object);
                } catch (e) {
                  if (e instanceof RangeError) return '...';
                  throw e;
                }
              },

              toJSON: function(object) {
                var type = typeof object;
                switch (type) {
                  case 'undefined':
                  case 'function':
                  case 'unknown': return;
                  case 'boolean': return object.toString();
                }

                if (object === null) return 'null';
                if (object.toJSON) return object.toJSON();
                if (Object.isElement(object)) return;

                var results = [];
                for (var property in object) {
                  var value = Object.toJSON(object[property]);
                  if (!Object.isUndefined(value))
                    results.push(property.toJSON() + ': ' + value);
                }

                return '{' + results.join(', ') + '}';
              },

              toQueryString: function(object) {
                return $H(object).toQueryString();
              },

              toHTML: function(object) {
                return object && object.toHTML ? object.toHTML() : String.interpret(object);
              },

              keys: function(object) {
                var keys = [];
                for (var property in object)
                  keys.push(property);
                return keys;
              },

              values: function(object) {
                var values = [];
                for (var property in object)
                  values.push(object[property]);
                return values;
              },

              clone: function(object) {
                return Object.extend({ }, object);
              },

              isElement: function(object) {
                return !!(object && object.nodeType == 1);
              },

              isArray: function(object) {
                return object != null && typeof object == "object" &&
                  'splice' in object && 'join' in object;
              },

              isHash: function(object) {
                return object instanceof Hash;
              },

              isFunction: function(object) {
                return typeof object == "function";
              },

              isString: function(object) {
                return typeof object == "string";
              },

              isNumber: function(object) {
                return typeof object == "number";
              },

              isUndefined: function(object) {
                return typeof object == "undefined";
              }
            });

            Object.extend(Function.prototype, {
              argumentNames: function() {
                var names = this.toString().match(/^[\s\(]*function[^(]*\(([^\)]*)\)/)[1]
                  .replace(/\s+/g, '').split(',');
                return names.length == 1 && !names[0] ? [] : names;
              },

              bind: function() {
                if (arguments.length < 2 && Object.isUndefined(arguments[0])) return this;
                var __method = this, args = $A(arguments), object = args.shift();
                return function() {
                  return __method.apply(object, args.concat($A(arguments)));
                }
              },

              bindAsEventListener: function() {
                var __method = this, args = $A(arguments), object = args.shift();
                return function(event) {
                  return __method.apply(object, [event || window.event].concat(args));
                }
              },

              curry: function() {
                if (!arguments.length) return this;
                var __method = this, args = $A(arguments);
                return function() {
                  return __method.apply(this, args.concat($A(arguments)));
                }
              },

              delay: function() {
                var __method = this, args = $A(arguments), timeout = args.shift() * 1000;
                return window.setTimeout(function() {
                  return __method.apply(__method, args);
                }, timeout);
              },

              defer: function() {
                var args = [0.01].concat($A(arguments));
                return this.delay.apply(this, args);
              },

              wrap: function(wrapper) {
                var __method = this;
                return function() {
                  return wrapper.apply(this, [__method.bind(this)].concat($A(arguments)));
                }
              },

              methodize: function() {
                if (this._methodized) return this._methodized;
                var __method = this;
                return this._methodized = function() {
                  return __method.apply(null, [this].concat($A(arguments)));
                };
              }
            });

            Date.prototype.toJSON = function() {
              return '"' + this.getUTCFullYear() + '-' +
                (this.getUTCMonth() + 1).toPaddedString(2) + '-' +
                this.getUTCDate().toPaddedString(2) + 'T' +
                this.getUTCHours().toPaddedString(2) + ':' +
                this.getUTCMinutes().toPaddedString(2) + ':' +
                this.getUTCSeconds().toPaddedString(2) + 'Z"';
            };

            var Try = {
              these: function() {
                var returnValue;

                for (var i = 0, length = arguments.length; i < length; i++) {
                  var lambda = arguments[i];
                  try {
                    returnValue = lambda();
                    break;
                  } catch (e) { }
                }

                return returnValue;
              }
            };

            RegExp.prototype.match = RegExp.prototype.test;

            RegExp.escape = function(str) {
              return String(str).replace(/([.*+?^=!:${}()|[\]\/\\])/g, '\\$1');
            };

            /*--------------------------------------------------------------------------*/

            var PeriodicalExecuter = Class.create({
              initialize: function(callback, frequency) {
                this.callback = callback;
                this.frequency = frequency;
                this.currentlyExecuting = false;

                this.registerCallback();
              },

              registerCallback: function() {
                this.timer = setInterval(this.onTimerEvent.bind(this), this.frequency * 1000);
              },

              execute: function() {
                this.callback(this);
              },

              stop: function() {
                if (!this.timer) return;
                clearInterval(this.timer);
                this.timer = null;
              },

              onTimerEvent: function() {
                if (!this.currentlyExecuting) {
                  try {
                    this.currentlyExecuting = true;
                    this.execute();
                  } finally {
                    this.currentlyExecuting = false;
                  }
                }
              }
            });
            Object.extend(String, {
              interpret: function(value) {
                return value == null ? '' : String(value);
              },
              specialChar: {
                '\b': '\\b',
                '\t': '\\t',
                '\n': '\\n',
                '\f': '\\f',
                '\r': '\\r',
                '\\': '\\\\'
              }
            });

            Object.extend(String.prototype, {
              gsub: function(pattern, replacement) {
                var result = '', source = this, match;
                replacement = arguments.callee.prepareReplacement(replacement);

                while (source.length > 0) {
                  if (match = source.match(pattern)) {
                    result += source.slice(0, match.index);
                    result += String.interpret(replacement(match));
                    source  = source.slice(match.index + match[0].length);
                  } else {
                    result += source, source = '';
                  }
                }
                return result;
              },

              sub: function(pattern, replacement, count) {
                replacement = this.gsub.prepareReplacement(replacement);
                count = Object.isUndefined(count) ? 1 : count;

                return this.gsub(pattern, function(match) {
                  if (--count < 0) return match[0];
                  return replacement(match);
                });
              },

              scan: function(pattern, iterator) {
                this.gsub(pattern, iterator);
                return String(this);
              },

              truncate: function(length, truncation) {
                length = length || 30;
                truncation = Object.isUndefined(truncation) ? '...' : truncation;
                return this.length > length ?
                  this.slice(0, length - truncation.length) + truncation : String(this);
              },

              strip: function() {
                return this.replace(/^\s+/, '').replace(/\s+$/, '');
              },

              stripTags: function() {
                return this.replace(/<\/?[^>]+>/gi, '');
              },

              stripScripts: function() {
                return this.replace(new RegExp(Prototype.ScriptFragment, 'img'), '');
              },

              extractScripts: function() {
                var matchAll = new RegExp(Prototype.ScriptFragment, 'img');
                var matchOne = new RegExp(Prototype.ScriptFragment, 'im');
                return (this.match(matchAll) || []).map(function(scriptTag) {
                  return (scriptTag.match(matchOne) || ['', ''])[1];
                });
              },

              evalScripts: function() {
                return this.extractScripts().map(function(script) { return eval(script) });
              },

              escapeHTML: function() {
                var self = arguments.callee;
                self.text.data = this;
                return self.div.innerHTML;
              },

              unescapeHTML: function() {
                var div = new Element('div');
                div.innerHTML = this.stripTags();
                return div.childNodes[0] ? (div.childNodes.length > 1 ?
                  $A(div.childNodes).inject('', function(memo, node) { return memo+node.nodeValue }) :
                  div.childNodes[0].nodeValue) : '';
              },

              toQueryParams: function(separator) {
                var match = this.strip().match(/([^?#]*)(#.*)?$/);
                if (!match) return { };

                return match[1].split(separator || '&').inject({ }, function(hash, pair) {
                  if ((pair = pair.split('='))[0]) {
                    var key = decodeURIComponent(pair.shift());
                    var value = pair.length > 1 ? pair.join('=') : pair[0];
                    if (value != undefined) value = decodeURIComponent(value);

                    if (key in hash) {
                      if (!Object.isArray(hash[key])) hash[key] = [hash[key]];
                      hash[key].push(value);
                    }
                    else hash[key] = value;
                  }
                  return hash;
                });
              },

              toArray: function() {
                return this.split('');
              },

              succ: function() {
                return this.slice(0, this.length - 1) +
                  String.fromCharCode(this.charCodeAt(this.length - 1) + 1);
              },

              times: function(count) {
                return count < 1 ? '' : new Array(count + 1).join(this);
              },

              camelize: function() {
                var parts = this.split('-'), len = parts.length;
                if (len == 1) return parts[0];

                var camelized = this.charAt(0) == '-'
                  ? parts[0].charAt(0).toUpperCase() + parts[0].substring(1)
                  : parts[0];

                for (var i = 1; i < len; i++)
                  camelized += parts[i].charAt(0).toUpperCase() + parts[i].substring(1);

                return camelized;
              },

              capitalize: function() {
                return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase();
              },

              underscore: function() {
                return this.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'#{1}_#{2}').gsub(/([a-z\d])([A-Z])/,'#{1}_#{2}').gsub(/-/,'_').toLowerCase();
              },

              dasherize: function() {
                return this.gsub(/_/,'-');
              },

              inspect: function(useDoubleQuotes) {
                var escapedString = this.gsub(/[\x00-\x1f\\]/, function(match) {
                  var character = String.specialChar[match[0]];
                  return character ? character : '\\u00' + match[0].charCodeAt().toPaddedString(2, 16);
                });
                if (useDoubleQuotes) return '"' + escapedString.replace(/"/g, '\\"') + '"';
                return "'" + escapedString.replace(/'/g, '\\\'') + "'";
              },

              toJSON: function() {
                return this.inspect(true);
              },

              unfilterJSON: function(filter) {
                return this.sub(filter || Prototype.JSONFilter, '#{1}');
              },

              isJSON: function() {
                var str = this;
                if (str.blank()) return false;
                str = this.replace(/\\./g, '@').replace(/"[^"\\\n\r]*"/g, '');
                return (/^[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]*$/).test(str);
              },

              evalJSON: function(sanitize) {
                var json = this.unfilterJSON();
                try {
                  if (!sanitize || json.isJSON()) return eval('(' + json + ')');
                } catch (e) { }
                throw new SyntaxError('Badly formed JSON string: ' + this.inspect());
              },

              include: function(pattern) {
                return this.indexOf(pattern) > -1;
              },

              startsWith: function(pattern) {
                return this.indexOf(pattern) === 0;
              },

              endsWith: function(pattern) {
                var d = this.length - pattern.length;
                return d >= 0 && this.lastIndexOf(pattern) === d;
              },

              empty: function() {
                return this == '';
              },

              blank: function() {
                return /^\s*$/.test(this);
              },

              interpolate: function(object, pattern) {
                return new Template(this, pattern).evaluate(object);
              }
            });

            if (Prototype.Browser.WebKit || Prototype.Browser.IE) Object.extend(String.prototype, {
              escapeHTML: function() {
                return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
              },
              unescapeHTML: function() {
                return this.stripTags().replace(/&amp;/g,'&').replace(/&lt;/g,'<').replace(/&gt;/g,'>');
              }
            });

            String.prototype.gsub.prepareReplacement = function(replacement) {
              if (Object.isFunction(replacement)) return replacement;
              var template = new Template(replacement);
              return function(match) { return template.evaluate(match) };
            };

            String.prototype.parseQuery = String.prototype.toQueryParams;

            Object.extend(String.prototype.escapeHTML, {
              div:  document.createElement('div'),
              text: document.createTextNode('')
            });

            String.prototype.escapeHTML.div.appendChild(String.prototype.escapeHTML.text);

            var Template = Class.create({
              initialize: function(template, pattern) {
                this.template = template.toString();
                this.pattern = pattern || Template.Pattern;
              },

              evaluate: function(object) {
                if (Object.isFunction(object.toTemplateReplacements))
                  object = object.toTemplateReplacements();

                return this.template.gsub(this.pattern, function(match) {
                  if (object == null) return '';

                  var before = match[1] || '';
                  if (before == '\\') return match[2];

                  var ctx = object, expr = match[3];
                  var pattern = /^([^.[]+|\[((?:.*?[^\\])?)\])(\.|\[|$)/;
                  match = pattern.exec(expr);
                  if (match == null) return before;

                  while (match != null) {
                    var comp = match[1].startsWith('[') ? match[2].gsub('\\\\]', ']') : match[1];
                    ctx = ctx[comp];
                    if (null == ctx || '' == match[3]) break;
                    expr = expr.substring('[' == match[3] ? match[1].length : match[0].length);
                    match = pattern.exec(expr);
                  }

                  return before + String.interpret(ctx);
                });
              }
            });
            Template.Pattern = /(^|.|\r|\n)(#\{(.*?)\})/;

            var $break = { };

            var Enumerable = {
              each: function(iterator, context) {
                var index = 0;
                try {
                  this._each(function(value) {
                    iterator.call(context, value, index++);
                  });
                } catch (e) {
                  if (e != $break) throw e;
                }
                return this;
              },

              eachSlice: function(number, iterator, context) {
                var index = -number, slices = [], array = this.toArray();
                if (number < 1) return array;
                while ((index += number) < array.length)
                  slices.push(array.slice(index, index+number));
                return slices.collect(iterator, context);
              },

              all: function(iterator, context) {
                iterator = iterator || Prototype.K;
                var result = true;
                this.each(function(value, index) {
                  result = result && !!iterator.call(context, value, index);
                  if (!result) throw $break;
                });
                return result;
              },

              any: function(iterator, context) {
                iterator = iterator || Prototype.K;
                var result = false;
                this.each(function(value, index) {
                  if (result = !!iterator.call(context, value, index))
                    throw $break;
                });
                return result;
              },

              collect: function(iterator, context) {
                iterator = iterator || Prototype.K;
                var results = [];
                this.each(function(value, index) {
                  results.push(iterator.call(context, value, index));
                });
                return results;
              },

              detect: function(iterator, context) {
                var result;
                this.each(function(value, index) {
                  if (iterator.call(context, value, index)) {
                    result = value;
                    throw $break;
                  }
                });
                return result;
              },

              findAll: function(iterator, context) {
                var results = [];
                this.each(function(value, index) {
                  if (iterator.call(context, value, index))
                    results.push(value);
                });
                return results;
              },

              grep: function(filter, iterator, context) {
                iterator = iterator || Prototype.K;
                var results = [];

                if (Object.isString(filter))
                  filter = new RegExp(filter);

                this.each(function(value, index) {
                  if (filter.match(value))
                    results.push(iterator.call(context, value, index));
                });
                return results;
              },

              include: function(object) {
                if (Object.isFunction(this.indexOf))
                  if (this.indexOf(object) != -1) return true;

                var found = false;
                this.each(function(value) {
                  if (value == object) {
                    found = true;
                    throw $break;
                  }
                });
                return found;
              },

              inGroupsOf: function(number, fillWith) {
                fillWith = Object.isUndefined(fillWith) ? null : fillWith;
                return this.eachSlice(number, function(slice) {
                  while(slice.length < number) slice.push(fillWith);
                  return slice;
                });
              },

              inject: function(memo, iterator, context) {
                this.each(function(value, index) {
                  memo = iterator.call(context, memo, value, index);
                });
                return memo;
              },

              invoke: function(method) {
                var args = $A(arguments).slice(1);
                return this.map(function(value) {
                  return value[method].apply(value, args);
                });
              },

              max: function(iterator, context) {
                iterator = iterator || Prototype.K;
                var result;
                this.each(function(value, index) {
                  value = iterator.call(context, value, index);
                  if (result == null || value >= result)
                    result = value;
                });
                return result;
              },

              min: function(iterator, context) {
                iterator = iterator || Prototype.K;
                var result;
                this.each(function(value, index) {
                  value = iterator.call(context, value, index);
                  if (result == null || value < result)
                    result = value;
                });
                return result;
              },

              partition: function(iterator, context) {
                iterator = iterator || Prototype.K;
                var trues = [], falses = [];
                this.each(function(value, index) {
                  (iterator.call(context, value, index) ?
                    trues : falses).push(value);
                });
                return [trues, falses];
              },

              pluck: function(property) {
                var results = [];
                this.each(function(value) {
                  results.push(value[property]);
                });
                return results;
              },

              reject: function(iterator, context) {
                var results = [];
                this.each(function(value, index) {
                  if (!iterator.call(context, value, index))
                    results.push(value);
                });
                return results;
              },

              sortBy: function(iterator, context) {
                return this.map(function(value, index) {
                  return {
                    value: value,
                    criteria: iterator.call(context, value, index)
                  };
                }).sort(function(left, right) {
                  var a = left.criteria, b = right.criteria;
                  return a < b ? -1 : a > b ? 1 : 0;
                }).pluck('value');
              },

              toArray: function() {
                return this.map();
              },

              zip: function() {
                var iterator = Prototype.K, args = $A(arguments);
                if (Object.isFunction(args.last()))
                  iterator = args.pop();

                var collections = [this].concat(args).map($A);
                return this.map(function(value, index) {
                  return iterator(collections.pluck(index));
                });
              },

              size: function() {
                return this.toArray().length;
              },

              inspect: function() {
                return '#<Enumerable:' + this.toArray().inspect() + '>';
              }
            };

            Object.extend(Enumerable, {
              map:     Enumerable.collect,
              find:    Enumerable.detect,
              select:  Enumerable.findAll,
              filter:  Enumerable.findAll,
              member:  Enumerable.include,
              entries: Enumerable.toArray,
              every:   Enumerable.all,
              some:    Enumerable.any
            });
            function $A(iterable) {
              if (!iterable) return [];
              if (iterable.toArray) return iterable.toArray();
              var length = iterable.length || 0, results = new Array(length);
              while (length--) results[length] = iterable[length];
              return results;
            }

            if (Prototype.Browser.WebKit) {
              $A = function(iterable) {
                if (!iterable) return [];
                // In Safari, only use the `toArray` method if it's not a NodeList.
                // A NodeList is a function, has an function `item` property, and a numeric
                // `length` property. Adapted from Google Doctype.
                if (!(typeof iterable === 'function' && typeof iterable.length ===
                    'number' && typeof iterable.item === 'function') && iterable.toArray)
                  return iterable.toArray();
                var length = iterable.length || 0, results = new Array(length);
                while (length--) results[length] = iterable[length];
                return results;
              };
            }

            Array.from = $A;

            Object.extend(Array.prototype, Enumerable);

            if (!Array.prototype._reverse) Array.prototype._reverse = Array.prototype.reverse;

            Object.extend(Array.prototype, {
              _each: function(iterator) {
                for (var i = 0, length = this.length; i < length; i++)
                  iterator(this[i]);
              },

              clear: function() {
                this.length = 0;
                return this;
              },

              first: function() {
                return this[0];
              },

              last: function() {
                return this[this.length - 1];
              },

              compact: function() {
                return this.select(function(value) {
                  return value != null;
                });
              },

              flatten: function() {
                return this.inject([], function(array, value) {
                  return array.concat(Object.isArray(value) ?
                    value.flatten() : [value]);
                });
              },

              without: function() {
                var values = $A(arguments);
                return this.select(function(value) {
                  return !values.include(value);
                });
              },

              reverse: function(inline) {
                return (inline !== false ? this : this.toArray())._reverse();
              },

              reduce: function() {
                return this.length > 1 ? this : this[0];
              },

              uniq: function(sorted) {
                return this.inject([], function(array, value, index) {
                  if (0 == index || (sorted ? array.last() != value : !array.include(value)))
                    array.push(value);
                  return array;
                });
              },

              intersect: function(array) {
                return this.uniq().findAll(function(item) {
                  return array.detect(function(value) { return item === value });
                });
              },

              clone: function() {
                return [].concat(this);
              },

              size: function() {
                return this.length;
              },

              inspect: function() {
                return '[' + this.map(Object.inspect).join(', ') + ']';
              },

              toJSON: function() {
                var results = [];
                this.each(function(object) {
                  var value = Object.toJSON(object);
                  if (!Object.isUndefined(value)) results.push(value);
                });
                return '[' + results.join(', ') + ']';
              }
            });

            // use native browser JS 1.6 implementation if available
            if (Object.isFunction(Array.prototype.forEach))
              Array.prototype._each = Array.prototype.forEach;

            if (!Array.prototype.indexOf) Array.prototype.indexOf = function(item, i) {
              i || (i = 0);
              var length = this.length;
              if (i < 0) i = length + i;
              for (; i < length; i++)
                if (this[i] === item) return i;
              return -1;
            };

            if (!Array.prototype.lastIndexOf) Array.prototype.lastIndexOf = function(item, i) {
              i = isNaN(i) ? this.length : (i < 0 ? this.length + i : i) + 1;
              var n = this.slice(0, i).reverse().indexOf(item);
              return (n < 0) ? n : i - n - 1;
            };

            Array.prototype.toArray = Array.prototype.clone;

            function $w(string) {
              if (!Object.isString(string)) return [];
              string = string.strip();
              return string ? string.split(/\s+/) : [];
            }

            if (Prototype.Browser.Opera){
              Array.prototype.concat = function() {
                var array = [];
                for (var i = 0, length = this.length; i < length; i++) array.push(this[i]);
                for (var i = 0, length = arguments.length; i < length; i++) {
                  if (Object.isArray(arguments[i])) {
                    for (var j = 0, arrayLength = arguments[i].length; j < arrayLength; j++)
                      array.push(arguments[i][j]);
                  } else {
                    array.push(arguments[i]);
                  }
                }
                return array;
              };
            }
            Object.extend(Number.prototype, {
              toColorPart: function() {
                return this.toPaddedString(2, 16);
              },

              succ: function() {
                return this + 1;
              },

              times: function(iterator, context) {
                $R(0, this, true).each(iterator, context);
                return this;
              },

              toPaddedString: function(length, radix) {
                var string = this.toString(radix || 10);
                return '0'.times(length - string.length) + string;
              },

              toJSON: function() {
                return isFinite(this) ? this.toString() : 'null';
              }
            });

            $w('abs round ceil floor').each(function(method){
              Number.prototype[method] = Math[method].methodize();
            });
            function $H(object) {
              return new Hash(object);
            };

            var Hash = Class.create(Enumerable, (function() {

              function toQueryPair(key, value) {
                if (Object.isUndefined(value)) return key;
                return key + '=' + encodeURIComponent(String.interpret(value));
              }

              return {
                initialize: function(object) {
                  this._object = Object.isHash(object) ? object.toObject() : Object.clone(object);
                },

                _each: function(iterator) {
                  for (var key in this._object) {
                    var value = this._object[key], pair = [key, value];
                    pair.key = key;
                    pair.value = value;
                    iterator(pair);
                  }
                },

                set: function(key, value) {
                  return this._object[key] = value;
                },

                get: function(key) {
                  // simulating poorly supported hasOwnProperty
                  if (this._object[key] !== Object.prototype[key])
                    return this._object[key];
                },

                unset: function(key) {
                  var value = this._object[key];
                  delete this._object[key];
                  return value;
                },

                toObject: function() {
                  return Object.clone(this._object);
                },

                keys: function() {
                  return this.pluck('key');
                },

                values: function() {
                  return this.pluck('value');
                },

                index: function(value) {
                  var match = this.detect(function(pair) {
                    return pair.value === value;
                  });
                  return match && match.key;
                },

                merge: function(object) {
                  return this.clone().update(object);
                },

                update: function(object) {
                  return new Hash(object).inject(this, function(result, pair) {
                    result.set(pair.key, pair.value);
                    return result;
                  });
                },

                toQueryString: function() {
                  return this.inject([], function(results, pair) {
                    var key = encodeURIComponent(pair.key), values = pair.value;

                    if (values && typeof values == 'object') {
                      if (Object.isArray(values))
                        return results.concat(values.map(toQueryPair.curry(key)));
                    } else results.push(toQueryPair(key, values));
                    return results;
                  }).join('&');
                },

                inspect: function() {
                  return '#<Hash:{' + this.map(function(pair) {
                    return pair.map(Object.inspect).join(': ');
                  }).join(', ') + '}>';
                },

                toJSON: function() {
                  return Object.toJSON(this.toObject());
                },

                clone: function() {
                  return new Hash(this);
                }
              }
            })());

            Hash.prototype.toTemplateReplacements = Hash.prototype.toObject;
            Hash.from = $H;
            var ObjectRange = Class.create(Enumerable, {
              initialize: function(start, end, exclusive) {
                this.start = start;
                this.end = end;
                this.exclusive = exclusive;
              },

              _each: function(iterator) {
                var value = this.start;
                while (this.include(value)) {
                  iterator(value);
                  value = value.succ();
                }
              },

              include: function(value) {
                if (value < this.start)
                  return false;
                if (this.exclusive)
                  return value < this.end;
                return value <= this.end;
              }
            });

            var $R = function(start, end, exclusive) {
              return new ObjectRange(start, end, exclusive);
            };

            var Ajax = {
              getTransport: function() {
                return Try.these(
                  function() {return new XMLHttpRequest()},
                  function() {return new ActiveXObject('Msxml2.XMLHTTP')},
                  function() {return new ActiveXObject('Microsoft.XMLHTTP')}
                ) || false;
              },

              activeRequestCount: 0
            };

            Ajax.Responders = {
              responders: [],

              _each: function(iterator) {
                this.responders._each(iterator);
              },

              register: function(responder) {
                if (!this.include(responder))
                  this.responders.push(responder);
              },

              unregister: function(responder) {
                this.responders = this.responders.without(responder);
              },

              dispatch: function(callback, request, transport, json) {
                this.each(function(responder) {
                  if (Object.isFunction(responder[callback])) {
                    try {
                      responder[callback].apply(responder, [request, transport, json]);
                    } catch (e) { }
                  }
                });
              }
            };

            Object.extend(Ajax.Responders, Enumerable);

            Ajax.Responders.register({
              onCreate:   function() { Ajax.activeRequestCount++ },
              onComplete: function() { Ajax.activeRequestCount-- }
            });

            Ajax.Base = Class.create({
              initialize: function(options) {
                this.options = {
                  method:       'post',
                  asynchronous: true,
                  contentType:  'application/x-www-form-urlencoded',
                  encoding:     'UTF-8',
                  parameters:   '',
                  evalJSON:     true,
                  evalJS:       true
                };
                Object.extend(this.options, options || { });

                this.options.method = this.options.method.toLowerCase();

                if (Object.isString(this.options.parameters))
                  this.options.parameters = this.options.parameters.toQueryParams();
                else if (Object.isHash(this.options.parameters))
                  this.options.parameters = this.options.parameters.toObject();
              }
            });

            Ajax.Request = Class.create(Ajax.Base, {
              _complete: false,

              initialize: function($super, url, options) {
                $super(options);
                this.transport = Ajax.getTransport();
                this.request(url);
              },

              request: function(url) {
                this.url = url;
                this.method = this.options.method;
                var params = Object.clone(this.options.parameters);

                if (!['get', 'post'].include(this.method)) {
                  // simulate other verbs over post
                  params['_method'] = this.method;
                  this.method = 'post';
                }

                this.parameters = params;

                if (params = Object.toQueryString(params)) {
                  // when GET, append parameters to URL
                  if (this.method == 'get')
                    this.url += (this.url.include('?') ? '&' : '?') + params;
                  else if (/Konqueror|Safari|KHTML/.test(navigator.userAgent))
                    params += '&_=';
                }

                try {
                  var response = new Ajax.Response(this);
                  if (this.options.onCreate) this.options.onCreate(response);
                  Ajax.Responders.dispatch('onCreate', this, response);

                  this.transport.open(this.method.toUpperCase(), this.url,
                    this.options.asynchronous);

                  if (this.options.asynchronous) this.respondToReadyState.bind(this).defer(1);

                  this.transport.onreadystatechange = this.onStateChange.bind(this);
                  this.setRequestHeaders();

                  this.body = this.method == 'post' ? (this.options.postBody || params) : null;
                  this.transport.send(this.body);

                  /* Force Firefox to handle ready state 4 for synchronous requests */
                  if (!this.options.asynchronous && this.transport.overrideMimeType)
                    this.onStateChange();

                }
                catch (e) {
                  this.dispatchException(e);
                }
              },

              onStateChange: function() {
                var readyState = this.transport.readyState;
                if (readyState > 1 && !((readyState == 4) && this._complete))
                  this.respondToReadyState(this.transport.readyState);
              },

              setRequestHeaders: function() {
                var headers = {
                  'X-Requested-With': 'XMLHttpRequest',
                  'X-Prototype-Version': Prototype.Version,
                  'Accept': 'text/javascript, text/html, application/xml, text/xml, */*'
                };

                if (this.method == 'post') {
                  headers['Content-type'] = this.options.contentType +
                    (this.options.encoding ? '; charset=' + this.options.encoding : '');

                  /* Force "Connection: close" for older Mozilla browsers to work
                   * around a bug where XMLHttpRequest sends an incorrect
                   * Content-length header. See Mozilla Bugzilla #246651.
                   */
                  if (this.transport.overrideMimeType &&
                      (navigator.userAgent.match(/Gecko\/(\d{4})/) || [0,2005])[1] < 2005)
                        headers['Connection'] = 'close';
                }

                // user-defined headers
                if (typeof this.options.requestHeaders == 'object') {
                  var extras = this.options.requestHeaders;

                  if (Object.isFunction(extras.push))
                    for (var i = 0, length = extras.length; i < length; i += 2)
                      headers[extras[i]] = extras[i+1];
                  else
                    $H(extras).each(function(pair) { headers[pair.key] = pair.value });
                }

                for (var name in headers)
                  this.transport.setRequestHeader(name, headers[name]);
              },

              success: function() {
                var status = this.getStatus();
                return !status || (status >= 200 && status < 300);
              },

              getStatus: function() {
                try {
                  return this.transport.status || 0;
                } catch (e) { return 0 }
              },

              respondToReadyState: function(readyState) {
                var state = Ajax.Request.Events[readyState], response = new Ajax.Response(this);

                if (state == 'Complete') {
                  try {
                    this._complete = true;
                    (this.options['on' + response.status]
                     || this.options['on' + (this.success() ? 'Success' : 'Failure')]
                     || Prototype.emptyFunction)(response, response.headerJSON);
                  } catch (e) {
                    this.dispatchException(e);
                  }

                  var contentType = response.getHeader('Content-type');
                  if (this.options.evalJS == 'force'
                      || (this.options.evalJS && this.isSameOrigin() && contentType
                      && contentType.match(/^\s*(text|application)\/(x-)?(java|ecma)script(;.*)?\s*$/i)))
                    this.evalResponse();
                }

                try {
                  (this.options['on' + state] || Prototype.emptyFunction)(response, response.headerJSON);
                  Ajax.Responders.dispatch('on' + state, this, response, response.headerJSON);
                } catch (e) {
                  this.dispatchException(e);
                }

                if (state == 'Complete') {
                  // avoid memory leak in MSIE: clean up
                  this.transport.onreadystatechange = Prototype.emptyFunction;
                }
              },

              isSameOrigin: function() {
                var m = this.url.match(/^\s*https?:\/\/[^\/]*/);
                return !m || (m[0] == '#{protocol}//#{domain}#{port}'.interpolate({
                  protocol: location.protocol,
                  domain: document.domain,
                  port: location.port ? ':' + location.port : ''
                }));
              },

              getHeader: function(name) {
                try {
                  return this.transport.getResponseHeader(name) || null;
                } catch (e) { return null }
              },

              evalResponse: function() {
                try {
                  return eval((this.transport.responseText || '').unfilterJSON());
                } catch (e) {
                  this.dispatchException(e);
                }
              },

              dispatchException: function(exception) {
                (this.options.onException || Prototype.emptyFunction)(this, exception);
                Ajax.Responders.dispatch('onException', this, exception);
              }
            });

            Ajax.Request.Events =
              ['Uninitialized', 'Loading', 'Loaded', 'Interactive', 'Complete'];

            Ajax.Response = Class.create({
              initialize: function(request){
                this.request = request;
                var transport  = this.transport  = request.transport,
                    readyState = this.readyState = transport.readyState;

                if((readyState > 2 && !Prototype.Browser.IE) || readyState == 4) {
                  this.status       = this.getStatus();
                  this.statusText   = this.getStatusText();
                  this.responseText = String.interpret(transport.responseText);
                  this.headerJSON   = this._getHeaderJSON();
                }

                if(readyState == 4) {
                  var xml = transport.responseXML;
                  this.responseXML  = Object.isUndefined(xml) ? null : xml;
                  this.responseJSON = this._getResponseJSON();
                }
              },

              status:      0,
              statusText: '',

              getStatus: Ajax.Request.prototype.getStatus,

              getStatusText: function() {
                try {
                  return this.transport.statusText || '';
                } catch (e) { return '' }
              },

              getHeader: Ajax.Request.prototype.getHeader,

              getAllHeaders: function() {
                try {
                  return this.getAllResponseHeaders();
                } catch (e) { return null }
              },

              getResponseHeader: function(name) {
                return this.transport.getResponseHeader(name);
              },

              getAllResponseHeaders: function() {
                return this.transport.getAllResponseHeaders();
              },

              _getHeaderJSON: function() {
                var json = this.getHeader('X-JSON');
                if (!json) return null;
                json = decodeURIComponent(escape(json));
                try {
                  return json.evalJSON(this.request.options.sanitizeJSON ||
                    !this.request.isSameOrigin());
                } catch (e) {
                  this.request.dispatchException(e);
                }
              },

              _getResponseJSON: function() {
                var options = this.request.options;
                if (!options.evalJSON || (options.evalJSON != 'force' &&
                  !(this.getHeader('Content-type') || '').include('application/json')) ||
                    this.responseText.blank())
                      return null;
                try {
                  return this.responseText.evalJSON(options.sanitizeJSON ||
                    !this.request.isSameOrigin());
                } catch (e) {
                  this.request.dispatchException(e);
                }
              }
            });

            Ajax.Updater = Class.create(Ajax.Request, {
              initialize: function($super, container, url, options) {
                this.container = {
                  success: (container.success || container),
                  failure: (container.failure || (container.success ? null : container))
                };

                options = Object.clone(options);
                var onComplete = options.onComplete;
                options.onComplete = (function(response, json) {
                  this.updateContent(response.responseText);
                  if (Object.isFunction(onComplete)) onComplete(response, json);
                }).bind(this);

                $super(url, options);
              },

              updateContent: function(responseText) {
                var receiver = this.container[this.success() ? 'success' : 'failure'],
                    options = this.options;

                if (!options.evalScripts) responseText = responseText.stripScripts();

                if (receiver = $(receiver)) {
                  if (options.insertion) {
                    if (Object.isString(options.insertion)) {
                      var insertion = { }; insertion[options.insertion] = responseText;
                      receiver.insert(insertion);
                    }
                    else options.insertion(receiver, responseText);
                  }
                  else receiver.update(responseText);
                }
              }
            });

            Ajax.PeriodicalUpdater = Class.create(Ajax.Base, {
              initialize: function($super, container, url, options) {
                $super(options);
                this.onComplete = this.options.onComplete;

                this.frequency = (this.options.frequency || 2);
                this.decay = (this.options.decay || 1);

                this.updater = { };
                this.container = container;
                this.url = url;

                this.start();
              },

              start: function() {
                this.options.onComplete = this.updateComplete.bind(this);
                this.onTimerEvent();
              },

              stop: function() {
                this.updater.options.onComplete = undefined;
                clearTimeout(this.timer);
                (this.onComplete || Prototype.emptyFunction).apply(this, arguments);
              },

              updateComplete: function(response) {
                if (this.options.decay) {
                  this.decay = (response.responseText == this.lastText ?
                    this.decay * this.options.decay : 1);

                  this.lastText = response.responseText;
                }
                this.timer = this.onTimerEvent.bind(this).delay(this.decay * this.frequency);
              },

              onTimerEvent: function() {
                this.updater = new Ajax.Updater(this.container, this.url, this.options);
              }
            });
            function $(element) {
              if (arguments.length > 1) {
                for (var i = 0, elements = [], length = arguments.length; i < length; i++)
                  elements.push($(arguments[i]));
                return elements;
              }
              if (Object.isString(element))
                element = document.getElementById(element);
              return Element.extend(element);
            }

            if (Prototype.BrowserFeatures.XPath) {
              document._getElementsByXPath = function(expression, parentElement) {
                var results = [];
                var query = document.evaluate(expression, $(parentElement) || document,
                  null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
                for (var i = 0, length = query.snapshotLength; i < length; i++)
                  results.push(Element.extend(query.snapshotItem(i)));
                return results;
              };
            }

            /*--------------------------------------------------------------------------*/

            if (!window.Node) var Node = { };

            if (!Node.ELEMENT_NODE) {
              // DOM level 2 ECMAScript Language Binding
              Object.extend(Node, {
                ELEMENT_NODE: 1,
                ATTRIBUTE_NODE: 2,
                TEXT_NODE: 3,
                CDATA_SECTION_NODE: 4,
                ENTITY_REFERENCE_NODE: 5,
                ENTITY_NODE: 6,
                PROCESSING_INSTRUCTION_NODE: 7,
                COMMENT_NODE: 8,
                DOCUMENT_NODE: 9,
                DOCUMENT_TYPE_NODE: 10,
                DOCUMENT_FRAGMENT_NODE: 11,
                NOTATION_NODE: 12
              });
            }

            (function() {
              var element = this.Element;
              this.Element = function(tagName, attributes) {
                attributes = attributes || { };
                tagName = tagName.toLowerCase();
                var cache = Element.cache;
                if (Prototype.Browser.IE && attributes.name) {
                  tagName = '<' + tagName + ' name="' + attributes.name + '">';
                  delete attributes.name;
                  return Element.writeAttribute(document.createElement(tagName), attributes);
                }
                if (!cache[tagName]) cache[tagName] = Element.extend(document.createElement(tagName));
                return Element.writeAttribute(cache[tagName].cloneNode(false), attributes);
              };
              Object.extend(this.Element, element || { });
              if (element) this.Element.prototype = element.prototype;
            }).call(window);

            Element.cache = { };

            Element.Methods = {
              visible: function(element) {
                return $(element).style.display != 'none';
              },

              toggle: function(element) {
                element = $(element);
                Element[Element.visible(element) ? 'hide' : 'show'](element);
                return element;
              },

              hide: function(element) {
                element = $(element);
                element.style.display = 'none';
                return element;
              },

              show: function(element) {
                element = $(element);
                element.style.display = '';
                return element;
              },

              remove: function(element) {
                element = $(element);
                element.parentNode.removeChild(element);
                return element;
              },

              update: function(element, content) {
                element = $(element);
                if (content && content.toElement) content = content.toElement();
                if (Object.isElement(content)) return element.update().insert(content);
                content = Object.toHTML(content);
                element.innerHTML = content.stripScripts();
                content.evalScripts.bind(content).defer();
                return element;
              },

              replace: function(element, content) {
                element = $(element);
                if (content && content.toElement) content = content.toElement();
                else if (!Object.isElement(content)) {
                  content = Object.toHTML(content);
                  var range = element.ownerDocument.createRange();
                  range.selectNode(element);
                  content.evalScripts.bind(content).defer();
                  content = range.createContextualFragment(content.stripScripts());
                }
                element.parentNode.replaceChild(content, element);
                return element;
              },

              insert: function(element, insertions) {
                element = $(element);

                if (Object.isString(insertions) || Object.isNumber(insertions) ||
                    Object.isElement(insertions) || (insertions && (insertions.toElement || insertions.toHTML)))
                      insertions = {bottom:insertions};

                var content, insert, tagName, childNodes;

                for (var position in insertions) {
                  content  = insertions[position];
                  position = position.toLowerCase();
                  insert = Element._insertionTranslations[position];

                  if (content && content.toElement) content = content.toElement();
                  if (Object.isElement(content)) {
                    insert(element, content);
                    continue;
                  }

                  content = Object.toHTML(content);

                  tagName = ((position == 'before' || position == 'after')
                    ? element.parentNode : element).tagName.toUpperCase();

                  childNodes = Element._getContentFromAnonymousElement(tagName, content.stripScripts());

                  if (position == 'top' || position == 'after') childNodes.reverse();
                  childNodes.each(insert.curry(element));

                  content.evalScripts.bind(content).defer();
                }

                return element;
              },

              wrap: function(element, wrapper, attributes) {
                element = $(element);
                if (Object.isElement(wrapper))
                  $(wrapper).writeAttribute(attributes || { });
                else if (Object.isString(wrapper)) wrapper = new Element(wrapper, attributes);
                else wrapper = new Element('div', wrapper);
                if (element.parentNode)
                  element.parentNode.replaceChild(wrapper, element);
                wrapper.appendChild(element);
                return wrapper;
              },

              inspect: function(element) {
                element = $(element);
                var result = '<' + element.tagName.toLowerCase();
                $H({'id': 'id', 'className': 'class'}).each(function(pair) {
                  var property = pair.first(), attribute = pair.last();
                  var value = (element[property] || '').toString();
                  if (value) result += ' ' + attribute + '=' + value.inspect(true);
                });
                return result + '>';
              },

              recursivelyCollect: function(element, property) {
                element = $(element);
                var elements = [];
                while (element = element[property])
                  if (element.nodeType == 1)
                    elements.push(Element.extend(element));
                return elements;
              },

              ancestors: function(element) {
                return $(element).recursivelyCollect('parentNode');
              },

              descendants: function(element) {
                return $(element).select("*");
              },

              firstDescendant: function(element) {
                element = $(element).firstChild;
                while (element && element.nodeType != 1) element = element.nextSibling;
                return $(element);
              },

              immediateDescendants: function(element) {
                if (!(element = $(element).firstChild)) return [];
                while (element && element.nodeType != 1) element = element.nextSibling;
                if (element) return [element].concat($(element).nextSiblings());
                return [];
              },

              previousSiblings: function(element) {
                return $(element).recursivelyCollect('previousSibling');
              },

              nextSiblings: function(element) {
                return $(element).recursivelyCollect('nextSibling');
              },

              siblings: function(element) {
                element = $(element);
                return element.previousSiblings().reverse().concat(element.nextSiblings());
              },

              match: function(element, selector) {
                if (Object.isString(selector))
                  selector = new Selector(selector);
                return selector.match($(element));
              },

              up: function(element, expression, index) {
                element = $(element);
                if (arguments.length == 1) return $(element.parentNode);
                var ancestors = element.ancestors();
                return Object.isNumber(expression) ? ancestors[expression] :
                  Selector.findElement(ancestors, expression, index);
              },

              down: function(element, expression, index) {
                element = $(element);
                if (arguments.length == 1) return element.firstDescendant();
                return Object.isNumber(expression) ? element.descendants()[expression] :
                  Element.select(element, expression)[index || 0];
              },

              previous: function(element, expression, index) {
                element = $(element);
                if (arguments.length == 1) return $(Selector.handlers.previousElementSibling(element));
                var previousSiblings = element.previousSiblings();
                return Object.isNumber(expression) ? previousSiblings[expression] :
                  Selector.findElement(previousSiblings, expression, index);
              },

              next: function(element, expression, index) {
                element = $(element);
                if (arguments.length == 1) return $(Selector.handlers.nextElementSibling(element));
                var nextSiblings = element.nextSiblings();
                return Object.isNumber(expression) ? nextSiblings[expression] :
                  Selector.findElement(nextSiblings, expression, index);
              },

              select: function() {
                var args = $A(arguments), element = $(args.shift());
                return Selector.findChildElements(element, args);
              },

              adjacent: function() {
                var args = $A(arguments), element = $(args.shift());
                return Selector.findChildElements(element.parentNode, args).without(element);
              },

              identify: function(element) {
                element = $(element);
                var id = element.readAttribute('id'), self = arguments.callee;
                if (id) return id;
                do { id = 'anonymous_element_' + self.counter++ } while ($(id));
                element.writeAttribute('id', id);
                return id;
              },

              readAttribute: function(element, name) {
                element = $(element);
                if (Prototype.Browser.IE) {
                  var t = Element._attributeTranslations.read;
                  if (t.values[name]) return t.values[name](element, name);
                  if (t.names[name]) name = t.names[name];
                  if (name.include(':')) {
                    return (!element.attributes || !element.attributes[name]) ? null :
                     element.attributes[name].value;
                  }
                }
                return element.getAttribute(name);
              },

              writeAttribute: function(element, name, value) {
                element = $(element);
                var attributes = { }, t = Element._attributeTranslations.write;

                if (typeof name == 'object') attributes = name;
                else attributes[name] = Object.isUndefined(value) ? true : value;

                for (var attr in attributes) {
                  name = t.names[attr] || attr;
                  value = attributes[attr];
                  if (t.values[attr]) name = t.values[attr](element, value);
                  if (value === false || value === null)
                    element.removeAttribute(name);
                  else if (value === true)
                    element.setAttribute(name, name);
                  else element.setAttribute(name, value);
                }
                return element;
              },

              getHeight: function(element) {
                return $(element).getDimensions().height;
              },

              getWidth: function(element) {
                return $(element).getDimensions().width;
              },

              classNames: function(element) {
                return new Element.ClassNames(element);
              },

              hasClassName: function(element, className) {
                if (!(element = $(element))) return;
                var elementClassName = element.className;
                return (elementClassName.length > 0 && (elementClassName == className ||
                  new RegExp("(^|\\s)" + className + "(\\s|$)").test(elementClassName)));
              },

              addClassName: function(element, className) {
                if (!(element = $(element))) return;
                if (!element.hasClassName(className))
                  element.className += (element.className ? ' ' : '') + className;
                return element;
              },

              removeClassName: function(element, className) {
                if (!(element = $(element))) return;
                element.className = element.className.replace(
                  new RegExp("(^|\\s+)" + className + "(\\s+|$)"), ' ').strip();
                return element;
              },

              toggleClassName: function(element, className) {
                if (!(element = $(element))) return;
                return element[element.hasClassName(className) ?
                  'removeClassName' : 'addClassName'](className);
              },

              // removes whitespace-only text node children
              cleanWhitespace: function(element) {
                element = $(element);
                var node = element.firstChild;
                while (node) {
                  var nextNode = node.nextSibling;
                  if (node.nodeType == 3 && !/\S/.test(node.nodeValue))
                    element.removeChild(node);
                  node = nextNode;
                }
                return element;
              },

              empty: function(element) {
                return $(element).innerHTML.blank();
              },

              descendantOf: function(element, ancestor) {
                element = $(element), ancestor = $(ancestor);

                if (element.compareDocumentPosition)
                  return (element.compareDocumentPosition(ancestor) & 8) === 8;

                if (ancestor.contains)
                  return ancestor.contains(element) && ancestor !== element;

                while (element = element.parentNode)
                  if (element == ancestor) return true;

                return false;
              },

              scrollTo: function(element) {
                element = $(element);
                var pos = element.cumulativeOffset();
                window.scrollTo(pos[0], pos[1]);
                return element;
              },

              getStyle: function(element, style) {
                element = $(element);
                style = style == 'float' ? 'cssFloat' : style.camelize();
                var value = element.style[style];
                if (!value || value == 'auto') {
                  var css = document.defaultView.getComputedStyle(element, null);
                  value = css ? css[style] : null;
                }
                if (style == 'opacity') return value ? parseFloat(value) : 1.0;
                return value == 'auto' ? null : value;
              },

              getOpacity: function(element) {
                return $(element).getStyle('opacity');
              },

              setStyle: function(element, styles) {
                element = $(element);
                var elementStyle = element.style, match;
                if (Object.isString(styles)) {
                  element.style.cssText += ';' + styles;
                  return styles.include('opacity') ?
                    element.setOpacity(styles.match(/opacity:\s*(\d?\.?\d*)/)[1]) : element;
                }
                for (var property in styles)
                  if (property == 'opacity') element.setOpacity(styles[property]);
                  else
                    elementStyle[(property == 'float' || property == 'cssFloat') ?
                      (Object.isUndefined(elementStyle.styleFloat) ? 'cssFloat' : 'styleFloat') :
                        property] = styles[property];

                return element;
              },

              setOpacity: function(element, value) {
                element = $(element);
                element.style.opacity = (value == 1 || value === '') ? '' :
                  (value < 0.00001) ? 0 : value;
                return element;
              },

              getDimensions: function(element) {
                element = $(element);
                var display = element.getStyle('display');
                if (display != 'none' && display != null) // Safari bug
                  return {width: element.offsetWidth, height: element.offsetHeight};

                // All *Width and *Height properties give 0 on elements with display none,
                // so enable the element temporarily
                var els = element.style;
                var originalVisibility = els.visibility;
                var originalPosition = els.position;
                var originalDisplay = els.display;
                els.visibility = 'hidden';
                els.position = 'absolute';
                els.display = 'block';
                var originalWidth = element.clientWidth;
                var originalHeight = element.clientHeight;
                els.display = originalDisplay;
                els.position = originalPosition;
                els.visibility = originalVisibility;
                return {width: originalWidth, height: originalHeight};
              },

              makePositioned: function(element) {
                element = $(element);
                var pos = Element.getStyle(element, 'position');
                if (pos == 'static' || !pos) {
                  element._madePositioned = true;
                  element.style.position = 'relative';
                  // Opera returns the offset relative to the positioning context, when an
                  // element is position relative but top and left have not been defined
                  if (Prototype.Browser.Opera) {
                    element.style.top = 0;
                    element.style.left = 0;
                  }
                }
                return element;
              },

              undoPositioned: function(element) {
                element = $(element);
                if (element._madePositioned) {
                  element._madePositioned = undefined;
                  element.style.position =
                    element.style.top =
                    element.style.left =
                    element.style.bottom =
                    element.style.right = '';
                }
                return element;
              },

              makeClipping: function(element) {
                element = $(element);
                if (element._overflow) return element;
                element._overflow = Element.getStyle(element, 'overflow') || 'auto';
                if (element._overflow !== 'hidden')
                  element.style.overflow = 'hidden';
                return element;
              },

              undoClipping: function(element) {
                element = $(element);
                if (!element._overflow) return element;
                element.style.overflow = element._overflow == 'auto' ? '' : element._overflow;
                element._overflow = null;
                return element;
              },

              cumulativeOffset: function(element) {
                var valueT = 0, valueL = 0;
                do {
                  valueT += element.offsetTop  || 0;
                  valueL += element.offsetLeft || 0;
                  element = element.offsetParent;
                } while (element);
                return Element._returnOffset(valueL, valueT);
              },

              positionedOffset: function(element) {
                var valueT = 0, valueL = 0;
                do {
                  valueT += element.offsetTop  || 0;
                  valueL += element.offsetLeft || 0;
                  element = element.offsetParent;
                  if (element) {
                    if (element.tagName.toUpperCase() == 'BODY') break;
                    var p = Element.getStyle(element, 'position');
                    if (p !== 'static') break;
                  }
                } while (element);
                return Element._returnOffset(valueL, valueT);
              },

              absolutize: function(element) {
                element = $(element);
                if (element.getStyle('position') == 'absolute') return element;
                // Position.prepare(); // To be done manually by Scripty when it needs it.

                var offsets = element.positionedOffset();
                var top     = offsets[1];
                var left    = offsets[0];
                var width   = element.clientWidth;
                var height  = element.clientHeight;

                element._originalLeft   = left - parseFloat(element.style.left  || 0);
                element._originalTop    = top  - parseFloat(element.style.top || 0);
                element._originalWidth  = element.style.width;
                element._originalHeight = element.style.height;

                element.style.position = 'absolute';
                element.style.top    = top + 'px';
                element.style.left   = left + 'px';
                element.style.width  = width + 'px';
                element.style.height = height + 'px';
                return element;
              },

              relativize: function(element) {
                element = $(element);
                if (element.getStyle('position') == 'relative') return element;
                // Position.prepare(); // To be done manually by Scripty when it needs it.

                element.style.position = 'relative';
                var top  = parseFloat(element.style.top  || 0) - (element._originalTop || 0);
                var left = parseFloat(element.style.left || 0) - (element._originalLeft || 0);

                element.style.top    = top + 'px';
                element.style.left   = left + 'px';
                element.style.height = element._originalHeight;
                element.style.width  = element._originalWidth;
                return element;
              },

              cumulativeScrollOffset: function(element) {
                var valueT = 0, valueL = 0;
                do {
                  valueT += element.scrollTop  || 0;
                  valueL += element.scrollLeft || 0;
                  element = element.parentNode;
                } while (element);
                return Element._returnOffset(valueL, valueT);
              },

              getOffsetParent: function(element) {
                if (element.offsetParent) return $(element.offsetParent);
                if (element == document.body) return $(element);

                while ((element = element.parentNode) && element != document.body)
                  if (Element.getStyle(element, 'position') != 'static')
                    return $(element);

                return $(document.body);
              },

              viewportOffset: function(forElement) {
                var valueT = 0, valueL = 0;

                var element = forElement;
                do {
                  valueT += element.offsetTop  || 0;
                  valueL += element.offsetLeft || 0;

                  // Safari fix
                  if (element.offsetParent == document.body &&
                    Element.getStyle(element, 'position') == 'absolute') break;

                } while (element = element.offsetParent);

                element = forElement;
                do {
                  if (!Prototype.Browser.Opera || (element.tagName && (element.tagName.toUpperCase() == 'BODY'))) {
                    valueT -= element.scrollTop  || 0;
                    valueL -= element.scrollLeft || 0;
                  }
                } while (element = element.parentNode);

                return Element._returnOffset(valueL, valueT);
              },

              clonePosition: function(element, source) {
                var options = Object.extend({
                  setLeft:    true,
                  setTop:     true,
                  setWidth:   true,
                  setHeight:  true,
                  offsetTop:  0,
                  offsetLeft: 0
                }, arguments[2] || { });

                // find page position of source
                source = $(source);
                var p = source.viewportOffset();

                // find coordinate system to use
                element = $(element);
                var delta = [0, 0];
                var parent = null;
                // delta [0,0] will do fine with position: fixed elements,
                // position:absolute needs offsetParent deltas
                if (Element.getStyle(element, 'position') == 'absolute') {
                  parent = element.getOffsetParent();
                  delta = parent.viewportOffset();
                }

                // correct by body offsets (fixes Safari)
                if (parent == document.body) {
                  delta[0] -= document.body.offsetLeft;
                  delta[1] -= document.body.offsetTop;
                }

                // set position
                if (options.setLeft)   element.style.left  = (p[0] - delta[0] + options.offsetLeft) + 'px';
                if (options.setTop)    element.style.top   = (p[1] - delta[1] + options.offsetTop) + 'px';
                if (options.setWidth)  element.style.width = source.offsetWidth + 'px';
                if (options.setHeight) element.style.height = source.offsetHeight + 'px';
                return element;
              }
            };

            Element.Methods.identify.counter = 1;

            Object.extend(Element.Methods, {
              getElementsBySelector: Element.Methods.select,
              childElements: Element.Methods.immediateDescendants
            });

            Element._attributeTranslations = {
              write: {
                names: {
                  className: 'class',
                  htmlFor:   'for'
                },
                values: { }
              }
            };

            if (Prototype.Browser.Opera) {
              Element.Methods.getStyle = Element.Methods.getStyle.wrap(
                function(proceed, element, style) {
                  switch (style) {
                    case 'left': case 'top': case 'right': case 'bottom':
                      if (proceed(element, 'position') === 'static') return null;
                    case 'height': case 'width':
                      // returns '0px' for hidden elements; we want it to return null
                      if (!Element.visible(element)) return null;

                      // returns the border-box dimensions rather than the content-box
                      // dimensions, so we subtract padding and borders from the value
                      var dim = parseInt(proceed(element, style), 10);

                      if (dim !== element['offset' + style.capitalize()])
                        return dim + 'px';

                      var properties;
                      if (style === 'height') {
                        properties = ['border-top-width', 'padding-top',
                         'padding-bottom', 'border-bottom-width'];
                      }
                      else {
                        properties = ['border-left-width', 'padding-left',
                         'padding-right', 'border-right-width'];
                      }
                      return properties.inject(dim, function(memo, property) {
                        var val = proceed(element, property);
                        return val === null ? memo : memo - parseInt(val, 10);
                      }) + 'px';
                    default: return proceed(element, style);
                  }
                }
              );

              Element.Methods.readAttribute = Element.Methods.readAttribute.wrap(
                function(proceed, element, attribute) {
                  if (attribute === 'title') return element.title;
                  return proceed(element, attribute);
                }
              );
            }

            else if (Prototype.Browser.IE) {
              // IE doesn't report offsets correctly for static elements, so we change them
              // to "relative" to get the values, then change them back.
              Element.Methods.getOffsetParent = Element.Methods.getOffsetParent.wrap(
                function(proceed, element) {
                  element = $(element);
                  // IE throws an error if element is not in document
                  try { element.offsetParent }
                  catch(e) { return $(document.body) }
                  var position = element.getStyle('position');
                  if (position !== 'static') return proceed(element);
                  element.setStyle({ position: 'relative' });
                  var value = proceed(element);
                  element.setStyle({ position: position });
                  return value;
                }
              );

              $w('positionedOffset viewportOffset').each(function(method) {
                Element.Methods[method] = Element.Methods[method].wrap(
                  function(proceed, element) {
                    element = $(element);
                    try { element.offsetParent }
                    catch(e) { return Element._returnOffset(0,0) }
                    var position = element.getStyle('position');
                    if (position !== 'static') return proceed(element);
                    // Trigger hasLayout on the offset parent so that IE6 reports
                    // accurate offsetTop and offsetLeft values for position: fixed.
                    var offsetParent = element.getOffsetParent();
                    if (offsetParent && offsetParent.getStyle('position') === 'fixed')
                      offsetParent.setStyle({ zoom: 1 });
                    element.setStyle({ position: 'relative' });
                    var value = proceed(element);
                    element.setStyle({ position: position });
                    return value;
                  }
                );
              });

              Element.Methods.cumulativeOffset = Element.Methods.cumulativeOffset.wrap(
                function(proceed, element) {
                  try { element.offsetParent }
                  catch(e) { return Element._returnOffset(0,0) }
                  return proceed(element);
                }
              );

              Element.Methods.getStyle = function(element, style) {
                element = $(element);
                style = (style == 'float' || style == 'cssFloat') ? 'styleFloat' : style.camelize();
                var value = element.style[style];
                if (!value && element.currentStyle) value = element.currentStyle[style];

                if (style == 'opacity') {
                  if (value = (element.getStyle('filter') || '').match(/alpha\(opacity=(.*)\)/))
                    if (value[1]) return parseFloat(value[1]) / 100;
                  return 1.0;
                }

                if (value == 'auto') {
                  if ((style == 'width' || style == 'height') && (element.getStyle('display') != 'none'))
                    return element['offset' + style.capitalize()] + 'px';
                  return null;
                }
                return value;
              };

              Element.Methods.setOpacity = function(element, value) {
                function stripAlpha(filter){
                  return filter.replace(/alpha\([^\)]*\)/gi,'');
                }
                element = $(element);
                var currentStyle = element.currentStyle;
                if ((currentStyle && !currentStyle.hasLayout) ||
                  (!currentStyle && element.style.zoom == 'normal'))
                    element.style.zoom = 1;

                var filter = element.getStyle('filter'), style = element.style;
                if (value == 1 || value === '') {
                  (filter = stripAlpha(filter)) ?
                    style.filter = filter : style.removeAttribute('filter');
                  return element;
                } else if (value < 0.00001) value = 0;
                style.filter = stripAlpha(filter) +
                  'alpha(opacity=' + (value * 100) + ')';
                return element;
              };

              Element._attributeTranslations = {
                read: {
                  names: {
                    'class': 'className',
                    'for':   'htmlFor'
                  },
                  values: {
                    _getAttr: function(element, attribute) {
                      return element.getAttribute(attribute, 2);
                    },
                    _getAttrNode: function(element, attribute) {
                      var node = element.getAttributeNode(attribute);
                      return node ? node.value : "";
                    },
                    _getEv: function(element, attribute) {
                      attribute = element.getAttribute(attribute);
                      return attribute ? attribute.toString().slice(23, -2) : null;
                    },
                    _flag: function(element, attribute) {
                      return $(element).hasAttribute(attribute) ? attribute : null;
                    },
                    style: function(element) {
                      return element.style.cssText.toLowerCase();
                    },
                    title: function(element) {
                      return element.title;
                    }
                  }
                }
              };

              Element._attributeTranslations.write = {
                names: Object.extend({
                  cellpadding: 'cellPadding',
                  cellspacing: 'cellSpacing'
                }, Element._attributeTranslations.read.names),
                values: {
                  checked: function(element, value) {
                    element.checked = !!value;
                  },

                  style: function(element, value) {
                    element.style.cssText = value ? value : '';
                  }
                }
              };

              Element._attributeTranslations.has = {};

              $w('colSpan rowSpan vAlign dateTime accessKey tabIndex ' +
                  'encType maxLength readOnly longDesc frameBorder').each(function(attr) {
                Element._attributeTranslations.write.names[attr.toLowerCase()] = attr;
                Element._attributeTranslations.has[attr.toLowerCase()] = attr;
              });

              (function(v) {
                Object.extend(v, {
                  href:        v._getAttr,
                  src:         v._getAttr,
                  type:        v._getAttr,
                  action:      v._getAttrNode,
                  disabled:    v._flag,
                  checked:     v._flag,
                  readonly:    v._flag,
                  multiple:    v._flag,
                  onload:      v._getEv,
                  onunload:    v._getEv,
                  onclick:     v._getEv,
                  ondblclick:  v._getEv,
                  onmousedown: v._getEv,
                  onmouseup:   v._getEv,
                  onmouseover: v._getEv,
                  onmousemove: v._getEv,
                  onmouseout:  v._getEv,
                  onfocus:     v._getEv,
                  onblur:      v._getEv,
                  onkeypress:  v._getEv,
                  onkeydown:   v._getEv,
                  onkeyup:     v._getEv,
                  onsubmit:    v._getEv,
                  onreset:     v._getEv,
                  onselect:    v._getEv,
                  onchange:    v._getEv
                });
              })(Element._attributeTranslations.read.values);
            }

            else if (Prototype.Browser.Gecko && /rv:1\.8\.0/.test(navigator.userAgent)) {
              Element.Methods.setOpacity = function(element, value) {
                element = $(element);
                element.style.opacity = (value == 1) ? 0.999999 :
                  (value === '') ? '' : (value < 0.00001) ? 0 : value;
                return element;
              };
            }

            else if (Prototype.Browser.WebKit) {
              Element.Methods.setOpacity = function(element, value) {
                element = $(element);
                element.style.opacity = (value == 1 || value === '') ? '' :
                  (value < 0.00001) ? 0 : value;

                if (value == 1)
                  if(element.tagName.toUpperCase() == 'IMG' && element.width) {
                    element.width++; element.width--;
                  } else try {
                    var n = document.createTextNode(' ');
                    element.appendChild(n);
                    element.removeChild(n);
                  } catch (e) { }

                return element;
              };

              // Safari returns margins on body which is incorrect if the child is absolutely
              // positioned.  For performance reasons, redefine Element#cumulativeOffset for
              // KHTML/WebKit only.
              Element.Methods.cumulativeOffset = function(element) {
                var valueT = 0, valueL = 0;
                do {
                  valueT += element.offsetTop  || 0;
                  valueL += element.offsetLeft || 0;
                  if (element.offsetParent == document.body)
                    if (Element.getStyle(element, 'position') == 'absolute') break;

                  element = element.offsetParent;
                } while (element);

                return Element._returnOffset(valueL, valueT);
              };
            }

            if (Prototype.Browser.IE || Prototype.Browser.Opera) {
              // IE and Opera are missing .innerHTML support for TABLE-related and SELECT elements
              Element.Methods.update = function(element, content) {
                element = $(element);

                if (content && content.toElement) content = content.toElement();
                if (Object.isElement(content)) return element.update().insert(content);

                content = Object.toHTML(content);
                var tagName = element.tagName.toUpperCase();

                if (tagName in Element._insertionTranslations.tags) {
                  $A(element.childNodes).each(function(node) { element.removeChild(node) });
                  Element._getContentFromAnonymousElement(tagName, content.stripScripts())
                    .each(function(node) { element.appendChild(node) });
                }
                else element.innerHTML = content.stripScripts();

                content.evalScripts.bind(content).defer();
                return element;
              };
            }

            if ('outerHTML' in document.createElement('div')) {
              Element.Methods.replace = function(element, content) {
                element = $(element);

                if (content && content.toElement) content = content.toElement();
                if (Object.isElement(content)) {
                  element.parentNode.replaceChild(content, element);
                  return element;
                }

                content = Object.toHTML(content);
                var parent = element.parentNode, tagName = parent.tagName.toUpperCase();

                if (Element._insertionTranslations.tags[tagName]) {
                  var nextSibling = element.next();
                  var fragments = Element._getContentFromAnonymousElement(tagName, content.stripScripts());
                  parent.removeChild(element);
                  if (nextSibling)
                    fragments.each(function(node) { parent.insertBefore(node, nextSibling) });
                  else
                    fragments.each(function(node) { parent.appendChild(node) });
                }
                else element.outerHTML = content.stripScripts();

                content.evalScripts.bind(content).defer();
                return element;
              };
            }

            Element._returnOffset = function(l, t) {
              var result = [l, t];
              result.left = l;
              result.top = t;
              return result;
            };

            Element._getContentFromAnonymousElement = function(tagName, html) {
              var div = new Element('div'), t = Element._insertionTranslations.tags[tagName];
              if (t) {
                div.innerHTML = t[0] + html + t[1];
                t[2].times(function() { div = div.firstChild });
              } else div.innerHTML = html;
              return $A(div.childNodes);
            };

            Element._insertionTranslations = {
              before: function(element, node) {
                element.parentNode.insertBefore(node, element);
              },
              top: function(element, node) {
                element.insertBefore(node, element.firstChild);
              },
              bottom: function(element, node) {
                element.appendChild(node);
              },
              after: function(element, node) {
                element.parentNode.insertBefore(node, element.nextSibling);
              },
              tags: {
                TABLE:  ['<table>',                '</table>',                   1],
                TBODY:  ['<table><tbody>',         '</tbody></table>',           2],
                TR:     ['<table><tbody><tr>',     '</tr></tbody></table>',      3],
                TD:     ['<table><tbody><tr><td>', '</td></tr></tbody></table>', 4],
                SELECT: ['<select>',               '</select>',                  1]
              }
            };

            (function() {
              Object.extend(this.tags, {
                THEAD: this.tags.TBODY,
                TFOOT: this.tags.TBODY,
                TH:    this.tags.TD
              });
            }).call(Element._insertionTranslations);

            Element.Methods.Simulated = {
              hasAttribute: function(element, attribute) {
                attribute = Element._attributeTranslations.has[attribute] || attribute;
                var node = $(element).getAttributeNode(attribute);
                return !!(node && node.specified);
              }
            };

            Element.Methods.ByTag = { };

            Object.extend(Element, Element.Methods);

            if (!Prototype.BrowserFeatures.ElementExtensions &&
                document.createElement('div')['__proto__']) {
              window.HTMLElement = { };
              window.HTMLElement.prototype = document.createElement('div')['__proto__'];
              Prototype.BrowserFeatures.ElementExtensions = true;
            }

            Element.extend = (function() {
              if (Prototype.BrowserFeatures.SpecificElementExtensions)
                return Prototype.K;

              var Methods = { }, ByTag = Element.Methods.ByTag;

              var extend = Object.extend(function(element) {
                if (!element || element._extendedByPrototype ||
                    element.nodeType != 1 || element == window) return element;

                var methods = Object.clone(Methods),
                  tagName = element.tagName.toUpperCase(), property, value;

                // extend methods for specific tags
                if (ByTag[tagName]) Object.extend(methods, ByTag[tagName]);

                for (property in methods) {
                  value = methods[property];
                  if (Object.isFunction(value) && !(property in element))
                    element[property] = value.methodize();
                }

                element._extendedByPrototype = Prototype.emptyFunction;
                return element;

              }, {
                refresh: function() {
                  // extend methods for all tags (Safari doesn't need this)
                  if (!Prototype.BrowserFeatures.ElementExtensions) {
                    Object.extend(Methods, Element.Methods);
                    Object.extend(Methods, Element.Methods.Simulated);
                  }
                }
              });

              extend.refresh();
              return extend;
            })();

            Element.hasAttribute = function(element, attribute) {
              if (element.hasAttribute) return element.hasAttribute(attribute);
              return Element.Methods.Simulated.hasAttribute(element, attribute);
            };

            Element.addMethods = function(methods) {
              var F = Prototype.BrowserFeatures, T = Element.Methods.ByTag;

              if (!methods) {
                Object.extend(Form, Form.Methods);
                Object.extend(Form.Element, Form.Element.Methods);
                Object.extend(Element.Methods.ByTag, {
                  "FORM":     Object.clone(Form.Methods),
                  "INPUT":    Object.clone(Form.Element.Methods),
                  "SELECT":   Object.clone(Form.Element.Methods),
                  "TEXTAREA": Object.clone(Form.Element.Methods)
                });
              }

              if (arguments.length == 2) {
                var tagName = methods;
                methods = arguments[1];
              }

              if (!tagName) Object.extend(Element.Methods, methods || { });
              else {
                if (Object.isArray(tagName)) tagName.each(extend);
                else extend(tagName);
              }

              function extend(tagName) {
                tagName = tagName.toUpperCase();
                if (!Element.Methods.ByTag[tagName])
                  Element.Methods.ByTag[tagName] = { };
                Object.extend(Element.Methods.ByTag[tagName], methods);
              }

              function copy(methods, destination, onlyIfAbsent) {
                onlyIfAbsent = onlyIfAbsent || false;
                for (var property in methods) {
                  var value = methods[property];
                  if (!Object.isFunction(value)) continue;
                  if (!onlyIfAbsent || !(property in destination))
                    destination[property] = value.methodize();
                }
              }

              function findDOMClass(tagName) {
                var klass;
                var trans = {
                  "OPTGROUP": "OptGroup", "TEXTAREA": "TextArea", "P": "Paragraph",
                  "FIELDSET": "FieldSet", "UL": "UList", "OL": "OList", "DL": "DList",
                  "DIR": "Directory", "H1": "Heading", "H2": "Heading", "H3": "Heading",
                  "H4": "Heading", "H5": "Heading", "H6": "Heading", "Q": "Quote",
                  "INS": "Mod", "DEL": "Mod", "A": "Anchor", "IMG": "Image", "CAPTION":
                  "TableCaption", "COL": "TableCol", "COLGROUP": "TableCol", "THEAD":
                  "TableSection", "TFOOT": "TableSection", "TBODY": "TableSection", "TR":
                  "TableRow", "TH": "TableCell", "TD": "TableCell", "FRAMESET":
                  "FrameSet", "IFRAME": "IFrame"
                };
                if (trans[tagName]) klass = 'HTML' + trans[tagName] + 'Element';
                if (window[klass]) return window[klass];
                klass = 'HTML' + tagName + 'Element';
                if (window[klass]) return window[klass];
                klass = 'HTML' + tagName.capitalize() + 'Element';
                if (window[klass]) return window[klass];

                window[klass] = { };
                window[klass].prototype = document.createElement(tagName)['__proto__'];
                return window[klass];
              }

              if (F.ElementExtensions) {
                copy(Element.Methods, HTMLElement.prototype);
                copy(Element.Methods.Simulated, HTMLElement.prototype, true);
              }

              if (F.SpecificElementExtensions) {
                for (var tag in Element.Methods.ByTag) {
                  var klass = findDOMClass(tag);
                  if (Object.isUndefined(klass)) continue;
                  copy(T[tag], klass.prototype);
                }
              }

              Object.extend(Element, Element.Methods);
              delete Element.ByTag;

              if (Element.extend.refresh) Element.extend.refresh();
              Element.cache = { };
            };

            document.viewport = {
              getDimensions: function() {
                var dimensions = { }, B = Prototype.Browser;
                $w('width height').each(function(d) {
                  var D = d.capitalize();
                  if (B.WebKit && !document.evaluate) {
                    // Safari <3.0 needs self.innerWidth/Height
                    dimensions[d] = self['inner' + D];
                  } else if (B.Opera && parseFloat(window.opera.version()) < 9.5) {
                    // Opera <9.5 needs document.body.clientWidth/Height
                    dimensions[d] = document.body['client' + D]
                  } else {
                    dimensions[d] = document.documentElement['client' + D];
                  }
                });
                return dimensions;
              },

              getWidth: function() {
                return this.getDimensions().width;
              },

              getHeight: function() {
                return this.getDimensions().height;
              },

              getScrollOffsets: function() {
                return Element._returnOffset(
                  window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft,
                  window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop);
              }
            };
            /* Portions of the Selector class are derived from Jack Slocum's DomQuery,
             * part of YUI-Ext version 0.40, distributed under the terms of an MIT-style
             * license.  Please see http://www.yui-ext.com/ for more information. */

            var Selector = Class.create({
              initialize: function(expression) {
                this.expression = expression.strip();

                if (this.shouldUseSelectorsAPI()) {
                  this.mode = 'selectorsAPI';
                } else if (this.shouldUseXPath()) {
                  this.mode = 'xpath';
                  this.compileXPathMatcher();
                } else {
                  this.mode = "normal";
                  this.compileMatcher();
                }

              },

              shouldUseXPath: function() {
                if (!Prototype.BrowserFeatures.XPath) return false;

                var e = this.expression;

                // Safari 3 chokes on :*-of-type and :empty
                if (Prototype.Browser.WebKit &&
                 (e.include("-of-type") || e.include(":empty")))
                  return false;

                // XPath can't do namespaced attributes, nor can it read
                // the "checked" property from DOM nodes
                if ((/(\[[\w-]*?:|:checked)/).test(e))
                  return false;

                return true;
              },

              shouldUseSelectorsAPI: function() {
                if (!Prototype.BrowserFeatures.SelectorsAPI) return false;

                if (!Selector._div) Selector._div = new Element('div');

                // Make sure the browser treats the selector as valid. Test on an
                // isolated element to minimize cost of this check.
                try {
                  Selector._div.querySelector(this.expression);
                } catch(e) {
                  return false;
                }

                return true;
              },

              compileMatcher: function() {
                var e = this.expression, ps = Selector.patterns, h = Selector.handlers,
                    c = Selector.criteria, le, p, m;

                if (Selector._cache[e]) {
                  this.matcher = Selector._cache[e];
                  return;
                }

                this.matcher = ["this.matcher = function(root) {",
                                "var r = root, h = Selector.handlers, c = false, n;"];

                while (e && le != e && (/\S/).test(e)) {
                  le = e;
                  for (var i in ps) {
                    p = ps[i];
                    if (m = e.match(p)) {
                      this.matcher.push(Object.isFunction(c[i]) ? c[i](m) :
                        new Template(c[i]).evaluate(m));
                      e = e.replace(m[0], '');
                      break;
                    }
                  }
                }

                this.matcher.push("return h.unique(n);\n}");
                eval(this.matcher.join('\n'));
                Selector._cache[this.expression] = this.matcher;
              },

              compileXPathMatcher: function() {
                var e = this.expression, ps = Selector.patterns,
                    x = Selector.xpath, le, m;

                if (Selector._cache[e]) {
                  this.xpath = Selector._cache[e]; return;
                }

                this.matcher = ['.//*'];
                while (e && le != e && (/\S/).test(e)) {
                  le = e;
                  for (var i in ps) {
                    if (m = e.match(ps[i])) {
                      this.matcher.push(Object.isFunction(x[i]) ? x[i](m) :
                        new Template(x[i]).evaluate(m));
                      e = e.replace(m[0], '');
                      break;
                    }
                  }
                }

                this.xpath = this.matcher.join('');
                Selector._cache[this.expression] = this.xpath;
              },

              findElements: function(root) {
                root = root || document;
                var e = this.expression, results;

                switch (this.mode) {
                  case 'selectorsAPI':
                    // querySelectorAll queries document-wide, then filters to descendants
                    // of the context element. That's not what we want.
                    // Add an explicit context to the selector if necessary.
                    if (root !== document) {
                      var oldId = root.id, id = $(root).identify();
                      e = "#" + id + " " + e;
                    }

                    results = $A(root.querySelectorAll(e)).map(Element.extend);
                    root.id = oldId;

                    return results;
                  case 'xpath':
                    return document._getElementsByXPath(this.xpath, root);
                  default:
                   return this.matcher(root);
                }
              },

              match: function(element) {
                this.tokens = [];

                var e = this.expression, ps = Selector.patterns, as = Selector.assertions;
                var le, p, m;

                while (e && le !== e && (/\S/).test(e)) {
                  le = e;
                  for (var i in ps) {
                    p = ps[i];
                    if (m = e.match(p)) {
                      // use the Selector.assertions methods unless the selector
                      // is too complex.
                      if (as[i]) {
                        this.tokens.push([i, Object.clone(m)]);
                        e = e.replace(m[0], '');
                      } else {
                        // reluctantly do a document-wide search
                        // and look for a match in the array
                        return this.findElements(document).include(element);
                      }
                    }
                  }
                }

                var match = true, name, matches;
                for (var i = 0, token; token = this.tokens[i]; i++) {
                  name = token[0], matches = token[1];
                  if (!Selector.assertions[name](element, matches)) {
                    match = false; break;
                  }
                }

                return match;
              },

              toString: function() {
                return this.expression;
              },

              inspect: function() {
                return "#<Selector:" + this.expression.inspect() + ">";
              }
            });

            Object.extend(Selector, {
              _cache: { },

              xpath: {
                descendant:   "//*",
                child:        "/*",
                adjacent:     "/following-sibling::*[1]",
                laterSibling: '/following-sibling::*',
                tagName:      function(m) {
                  if (m[1] == '*') return '';
                  return "[local-name()='" + m[1].toLowerCase() +
                         "' or local-name()='" + m[1].toUpperCase() + "']";
                },
                className:    "[contains(concat(' ', @class, ' '), ' #{1} ')]",
                id:           "[@id='#{1}']",
                attrPresence: function(m) {
                  m[1] = m[1].toLowerCase();
                  return new Template("[@#{1}]").evaluate(m);
                },
                attr: function(m) {
                  m[1] = m[1].toLowerCase();
                  m[3] = m[5] || m[6];
                  return new Template(Selector.xpath.operators[m[2]]).evaluate(m);
                },
                pseudo: function(m) {
                  var h = Selector.xpath.pseudos[m[1]];
                  if (!h) return '';
                  if (Object.isFunction(h)) return h(m);
                  return new Template(Selector.xpath.pseudos[m[1]]).evaluate(m);
                },
                operators: {
                  '=':  "[@#{1}='#{3}']",
                  '!=': "[@#{1}!='#{3}']",
                  '^=': "[starts-with(@#{1}, '#{3}')]",
                  '$=': "[substring(@#{1}, (string-length(@#{1}) - string-length('#{3}') + 1))='#{3}']",
                  '*=': "[contains(@#{1}, '#{3}')]",
                  '~=': "[contains(concat(' ', @#{1}, ' '), ' #{3} ')]",
                  '|=': "[contains(concat('-', @#{1}, '-'), '-#{3}-')]"
                },
                pseudos: {
                  'first-child': '[not(preceding-sibling::*)]',
                  'last-child':  '[not(following-sibling::*)]',
                  'only-child':  '[not(preceding-sibling::* or following-sibling::*)]',
                  'empty':       "[count(*) = 0 and (count(text()) = 0)]",
                  'checked':     "[@checked]",
                  'disabled':    "[(@disabled) and (@type!='hidden')]",
                  'enabled':     "[not(@disabled) and (@type!='hidden')]",
                  'not': function(m) {
                    var e = m[6], p = Selector.patterns,
                        x = Selector.xpath, le, v;

                    var exclusion = [];
                    while (e && le != e && (/\S/).test(e)) {
                      le = e;
                      for (var i in p) {
                        if (m = e.match(p[i])) {
                          v = Object.isFunction(x[i]) ? x[i](m) : new Template(x[i]).evaluate(m);
                          exclusion.push("(" + v.substring(1, v.length - 1) + ")");
                          e = e.replace(m[0], '');
                          break;
                        }
                      }
                    }
                    return "[not(" + exclusion.join(" and ") + ")]";
                  },
                  'nth-child':      function(m) {
                    return Selector.xpath.pseudos.nth("(count(./preceding-sibling::*) + 1) ", m);
                  },
                  'nth-last-child': function(m) {
                    return Selector.xpath.pseudos.nth("(count(./following-sibling::*) + 1) ", m);
                  },
                  'nth-of-type':    function(m) {
                    return Selector.xpath.pseudos.nth("position() ", m);
                  },
                  'nth-last-of-type': function(m) {
                    return Selector.xpath.pseudos.nth("(last() + 1 - position()) ", m);
                  },
                  'first-of-type':  function(m) {
                    m[6] = "1"; return Selector.xpath.pseudos['nth-of-type'](m);
                  },
                  'last-of-type':   function(m) {
                    m[6] = "1"; return Selector.xpath.pseudos['nth-last-of-type'](m);
                  },
                  'only-of-type':   function(m) {
                    var p = Selector.xpath.pseudos; return p['first-of-type'](m) + p['last-of-type'](m);
                  },
                  nth: function(fragment, m) {
                    var mm, formula = m[6], predicate;
                    if (formula == 'even') formula = '2n+0';
                    if (formula == 'odd')  formula = '2n+1';
                    if (mm = formula.match(/^(\d+)$/)) // digit only
                      return '[' + fragment + "= " + mm[1] + ']';
                    if (mm = formula.match(/^(-?\d*)?n(([+-])(\d+))?/)) { // an+b
                      if (mm[1] == "-") mm[1] = -1;
                      var a = mm[1] ? Number(mm[1]) : 1;
                      var b = mm[2] ? Number(mm[2]) : 0;
                      predicate = "[((#{fragment} - #{b}) mod #{a} = 0) and " +
                      "((#{fragment} - #{b}) div #{a} >= 0)]";
                      return new Template(predicate).evaluate({
                        fragment: fragment, a: a, b: b });
                    }
                  }
                }
              },

              criteria: {
                tagName:      'n = h.tagName(n, r, "#{1}", c);      c = false;',
                className:    'n = h.className(n, r, "#{1}", c);    c = false;',
                id:           'n = h.id(n, r, "#{1}", c);           c = false;',
                attrPresence: 'n = h.attrPresence(n, r, "#{1}", c); c = false;',
                attr: function(m) {
                  m[3] = (m[5] || m[6]);
                  return new Template('n = h.attr(n, r, "#{1}", "#{3}", "#{2}", c); c = false;').evaluate(m);
                },
                pseudo: function(m) {
                  if (m[6]) m[6] = m[6].replace(/"/g, '\\"');
                  return new Template('n = h.pseudo(n, "#{1}", "#{6}", r, c); c = false;').evaluate(m);
                },
                descendant:   'c = "descendant";',
                child:        'c = "child";',
                adjacent:     'c = "adjacent";',
                laterSibling: 'c = "laterSibling";'
              },

              patterns: {
                // combinators must be listed first
                // (and descendant needs to be last combinator)
                laterSibling: /^\s*~\s*/,
                child:        /^\s*>\s*/,
                adjacent:     /^\s*\+\s*/,
                descendant:   /^\s/,

                // selectors follow
                tagName:      /^\s*(\*|[\w\-]+)(\b|$)?/,
                id:           /^#([\w\-\*]+)(\b|$)/,
                className:    /^\.([\w\-\*]+)(\b|$)/,
                pseudo:
            /^:((first|last|nth|nth-last|only)(-child|-of-type)|empty|checked|(en|dis)abled|not)(\((.*?)\))?(\b|$|(?=\s|[:+~>]))/,
                attrPresence: /^\[((?:[\w]+:)?[\w]+)\]/,
                attr:         /\[((?:[\w-]*:)?[\w-]+)\s*(?:([!^$*~|]?=)\s*((['"])([^\4]*?)\4|([^'"][^\]]*?)))?\]/
              },

              // for Selector.match and Element#match
              assertions: {
                tagName: function(element, matches) {
                  return matches[1].toUpperCase() == element.tagName.toUpperCase();
                },

                className: function(element, matches) {
                  return Element.hasClassName(element, matches[1]);
                },

                id: function(element, matches) {
                  return element.id === matches[1];
                },

                attrPresence: function(element, matches) {
                  return Element.hasAttribute(element, matches[1]);
                },

                attr: function(element, matches) {
                  var nodeValue = Element.readAttribute(element, matches[1]);
                  return nodeValue && Selector.operators[matches[2]](nodeValue, matches[5] || matches[6]);
                }
              },

              handlers: {
                // UTILITY FUNCTIONS
                // joins two collections
                concat: function(a, b) {
                  for (var i = 0, node; node = b[i]; i++)
                    a.push(node);
                  return a;
                },

                // marks an array of nodes for counting
                mark: function(nodes) {
                  var _true = Prototype.emptyFunction;
                  for (var i = 0, node; node = nodes[i]; i++)
                    node._countedByPrototype = _true;
                  return nodes;
                },

                unmark: function(nodes) {
                  for (var i = 0, node; node = nodes[i]; i++)
                    node._countedByPrototype = undefined;
                  return nodes;
                },

                // mark each child node with its position (for nth calls)
                // "ofType" flag indicates whether we're indexing for nth-of-type
                // rather than nth-child
                index: function(parentNode, reverse, ofType) {
                  parentNode._countedByPrototype = Prototype.emptyFunction;
                  if (reverse) {
                    for (var nodes = parentNode.childNodes, i = nodes.length - 1, j = 1; i >= 0; i--) {
                      var node = nodes[i];
                      if (node.nodeType == 1 && (!ofType || node._countedByPrototype)) node.nodeIndex = j++;
                    }
                  } else {
                    for (var i = 0, j = 1, nodes = parentNode.childNodes; node = nodes[i]; i++)
                      if (node.nodeType == 1 && (!ofType || node._countedByPrototype)) node.nodeIndex = j++;
                  }
                },

                // filters out duplicates and extends all nodes
                unique: function(nodes) {
                  if (nodes.length == 0) return nodes;
                  var results = [], n;
                  for (var i = 0, l = nodes.length; i < l; i++)
                    if (!(n = nodes[i])._countedByPrototype) {
                      n._countedByPrototype = Prototype.emptyFunction;
                      results.push(Element.extend(n));
                    }
                  return Selector.handlers.unmark(results);
                },

                // COMBINATOR FUNCTIONS
                descendant: function(nodes) {
                  var h = Selector.handlers;
                  for (var i = 0, results = [], node; node = nodes[i]; i++)
                    h.concat(results, node.getElementsByTagName('*'));
                  return results;
                },

                child: function(nodes) {
                  var h = Selector.handlers;
                  for (var i = 0, results = [], node; node = nodes[i]; i++) {
                    for (var j = 0, child; child = node.childNodes[j]; j++)
                      if (child.nodeType == 1 && child.tagName != '!') results.push(child);
                  }
                  return results;
                },

                adjacent: function(nodes) {
                  for (var i = 0, results = [], node; node = nodes[i]; i++) {
                    var next = this.nextElementSibling(node);
                    if (next) results.push(next);
                  }
                  return results;
                },

                laterSibling: function(nodes) {
                  var h = Selector.handlers;
                  for (var i = 0, results = [], node; node = nodes[i]; i++)
                    h.concat(results, Element.nextSiblings(node));
                  return results;
                },

                nextElementSibling: function(node) {
                  while (node = node.nextSibling)
                    if (node.nodeType == 1) return node;
                  return null;
                },

                previousElementSibling: function(node) {
                  while (node = node.previousSibling)
                    if (node.nodeType == 1) return node;
                  return null;
                },

                // TOKEN FUNCTIONS
                tagName: function(nodes, root, tagName, combinator) {
                  var uTagName = tagName.toUpperCase();
                  var results = [], h = Selector.handlers;
                  if (nodes) {
                    if (combinator) {
                      // fastlane for ordinary descendant combinators
                      if (combinator == "descendant") {
                        for (var i = 0, node; node = nodes[i]; i++)
                          h.concat(results, node.getElementsByTagName(tagName));
                        return results;
                      } else nodes = this[combinator](nodes);
                      if (tagName == "*") return nodes;
                    }
                    for (var i = 0, node; node = nodes[i]; i++)
                      if (node.tagName.toUpperCase() === uTagName) results.push(node);
                    return results;
                  } else return root.getElementsByTagName(tagName);
                },

                id: function(nodes, root, id, combinator) {
                  var targetNode = $(id), h = Selector.handlers;
                  if (!targetNode) return [];
                  if (!nodes && root == document) return [targetNode];
                  if (nodes) {
                    if (combinator) {
                      if (combinator == 'child') {
                        for (var i = 0, node; node = nodes[i]; i++)
                          if (targetNode.parentNode == node) return [targetNode];
                      } else if (combinator == 'descendant') {
                        for (var i = 0, node; node = nodes[i]; i++)
                          if (Element.descendantOf(targetNode, node)) return [targetNode];
                      } else if (combinator == 'adjacent') {
                        for (var i = 0, node; node = nodes[i]; i++)
                          if (Selector.handlers.previousElementSibling(targetNode) == node)
                            return [targetNode];
                      } else nodes = h[combinator](nodes);
                    }
                    for (var i = 0, node; node = nodes[i]; i++)
                      if (node == targetNode) return [targetNode];
                    return [];
                  }
                  return (targetNode && Element.descendantOf(targetNode, root)) ? [targetNode] : [];
                },

                className: function(nodes, root, className, combinator) {
                  if (nodes && combinator) nodes = this[combinator](nodes);
                  return Selector.handlers.byClassName(nodes, root, className);
                },

                byClassName: function(nodes, root, className) {
                  if (!nodes) nodes = Selector.handlers.descendant([root]);
                  var needle = ' ' + className + ' ';
                  for (var i = 0, results = [], node, nodeClassName; node = nodes[i]; i++) {
                    nodeClassName = node.className;
                    if (nodeClassName.length == 0) continue;
                    if (nodeClassName == className || (' ' + nodeClassName + ' ').include(needle))
                      results.push(node);
                  }
                  return results;
                },

                attrPresence: function(nodes, root, attr, combinator) {
                  if (!nodes) nodes = root.getElementsByTagName("*");
                  if (nodes && combinator) nodes = this[combinator](nodes);
                  var results = [];
                  for (var i = 0, node; node = nodes[i]; i++)
                    if (Element.hasAttribute(node, attr)) results.push(node);
                  return results;
                },

                attr: function(nodes, root, attr, value, operator, combinator) {
                  if (!nodes) nodes = root.getElementsByTagName("*");
                  if (nodes && combinator) nodes = this[combinator](nodes);
                  var handler = Selector.operators[operator], results = [];
                  for (var i = 0, node; node = nodes[i]; i++) {
                    var nodeValue = Element.readAttribute(node, attr);
                    if (nodeValue === null) continue;
                    if (handler(nodeValue, value)) results.push(node);
                  }
                  return results;
                },

                pseudo: function(nodes, name, value, root, combinator) {
                  if (nodes && combinator) nodes = this[combinator](nodes);
                  if (!nodes) nodes = root.getElementsByTagName("*");
                  return Selector.pseudos[name](nodes, value, root);
                }
              },

              pseudos: {
                'first-child': function(nodes, value, root) {
                  for (var i = 0, results = [], node; node = nodes[i]; i++) {
                    if (Selector.handlers.previousElementSibling(node)) continue;
                      results.push(node);
                  }
                  return results;
                },
                'last-child': function(nodes, value, root) {
                  for (var i = 0, results = [], node; node = nodes[i]; i++) {
                    if (Selector.handlers.nextElementSibling(node)) continue;
                      results.push(node);
                  }
                  return results;
                },
                'only-child': function(nodes, value, root) {
                  var h = Selector.handlers;
                  for (var i = 0, results = [], node; node = nodes[i]; i++)
                    if (!h.previousElementSibling(node) && !h.nextElementSibling(node))
                      results.push(node);
                  return results;
                },
                'nth-child':        function(nodes, formula, root) {
                  return Selector.pseudos.nth(nodes, formula, root);
                },
                'nth-last-child':   function(nodes, formula, root) {
                  return Selector.pseudos.nth(nodes, formula, root, true);
                },
                'nth-of-type':      function(nodes, formula, root) {
                  return Selector.pseudos.nth(nodes, formula, root, false, true);
                },
                'nth-last-of-type': function(nodes, formula, root) {
                  return Selector.pseudos.nth(nodes, formula, root, true, true);
                },
                'first-of-type':    function(nodes, formula, root) {
                  return Selector.pseudos.nth(nodes, "1", root, false, true);
                },
                'last-of-type':     function(nodes, formula, root) {
                  return Selector.pseudos.nth(nodes, "1", root, true, true);
                },
                'only-of-type':     function(nodes, formula, root) {
                  var p = Selector.pseudos;
                  return p['last-of-type'](p['first-of-type'](nodes, formula, root), formula, root);
                },

                // handles the an+b logic
                getIndices: function(a, b, total) {
                  if (a == 0) return b > 0 ? [b] : [];
                  return $R(1, total).inject([], function(memo, i) {
                    if (0 == (i - b) % a && (i - b) / a >= 0) memo.push(i);
                    return memo;
                  });
                },

                // handles nth(-last)-child, nth(-last)-of-type, and (first|last)-of-type
                nth: function(nodes, formula, root, reverse, ofType) {
                  if (nodes.length == 0) return [];
                  if (formula == 'even') formula = '2n+0';
                  if (formula == 'odd')  formula = '2n+1';
                  var h = Selector.handlers, results = [], indexed = [], m;
                  h.mark(nodes);
                  for (var i = 0, node; node = nodes[i]; i++) {
                    if (!node.parentNode._countedByPrototype) {
                      h.index(node.parentNode, reverse, ofType);
                      indexed.push(node.parentNode);
                    }
                  }
                  if (formula.match(/^\d+$/)) { // just a number
                    formula = Number(formula);
                    for (var i = 0, node; node = nodes[i]; i++)
                      if (node.nodeIndex == formula) results.push(node);
                  } else if (m = formula.match(/^(-?\d*)?n(([+-])(\d+))?/)) { // an+b
                    if (m[1] == "-") m[1] = -1;
                    var a = m[1] ? Number(m[1]) : 1;
                    var b = m[2] ? Number(m[2]) : 0;
                    var indices = Selector.pseudos.getIndices(a, b, nodes.length);
                    for (var i = 0, node, l = indices.length; node = nodes[i]; i++) {
                      for (var j = 0; j < l; j++)
                        if (node.nodeIndex == indices[j]) results.push(node);
                    }
                  }
                  h.unmark(nodes);
                  h.unmark(indexed);
                  return results;
                },

                'empty': function(nodes, value, root) {
                  for (var i = 0, results = [], node; node = nodes[i]; i++) {
                    // IE treats comments as element nodes
                    if (node.tagName == '!' || node.firstChild) continue;
                    results.push(node);
                  }
                  return results;
                },

                'not': function(nodes, selector, root) {
                  var h = Selector.handlers, selectorType, m;
                  var exclusions = new Selector(selector).findElements(root);
                  h.mark(exclusions);
                  for (var i = 0, results = [], node; node = nodes[i]; i++)
                    if (!node._countedByPrototype) results.push(node);
                  h.unmark(exclusions);
                  return results;
                },

                'enabled': function(nodes, value, root) {
                  for (var i = 0, results = [], node; node = nodes[i]; i++)
                    if (!node.disabled && (!node.type || node.type !== 'hidden'))
                      results.push(node);
                  return results;
                },

                'disabled': function(nodes, value, root) {
                  for (var i = 0, results = [], node; node = nodes[i]; i++)
                    if (node.disabled) results.push(node);
                  return results;
                },

                'checked': function(nodes, value, root) {
                  for (var i = 0, results = [], node; node = nodes[i]; i++)
                    if (node.checked) results.push(node);
                  return results;
                }
              },

              operators: {
                '=':  function(nv, v) { return nv == v; },
                '!=': function(nv, v) { return nv != v; },
                '^=': function(nv, v) { return nv == v || nv && nv.startsWith(v); },
                '$=': function(nv, v) { return nv == v || nv && nv.endsWith(v); },
                '*=': function(nv, v) { return nv == v || nv && nv.include(v); },
                '$=': function(nv, v) { return nv.endsWith(v); },
                '*=': function(nv, v) { return nv.include(v); },
                '~=': function(nv, v) { return (' ' + nv + ' ').include(' ' + v + ' '); },
                '|=': function(nv, v) { return ('-' + (nv || "").toUpperCase() +
                 '-').include('-' + (v || "").toUpperCase() + '-'); }
              },

              split: function(expression) {
                var expressions = [];
                expression.scan(/(([\w#:.~>+()\s-]+|\*|\[.*?\])+)\s*(,|$)/, function(m) {
                  expressions.push(m[1].strip());
                });
                return expressions;
              },

              matchElements: function(elements, expression) {
                var matches = $$(expression), h = Selector.handlers;
                h.mark(matches);
                for (var i = 0, results = [], element; element = elements[i]; i++)
                  if (element._countedByPrototype) results.push(element);
                h.unmark(matches);
                return results;
              },

              findElement: function(elements, expression, index) {
                if (Object.isNumber(expression)) {
                  index = expression; expression = false;
                }
                return Selector.matchElements(elements, expression || '*')[index || 0];
              },

              findChildElements: function(element, expressions) {
                expressions = Selector.split(expressions.join(','));
                var results = [], h = Selector.handlers;
                for (var i = 0, l = expressions.length, selector; i < l; i++) {
                  selector = new Selector(expressions[i].strip());
                  h.concat(results, selector.findElements(element));
                }
                return (l > 1) ? h.unique(results) : results;
              }
            });

            if (Prototype.Browser.IE) {
              Object.extend(Selector.handlers, {
                // IE returns comment nodes on getElementsByTagName("*").
                // Filter them out.
                concat: function(a, b) {
                  for (var i = 0, node; node = b[i]; i++)
                    if (node.tagName !== "!") a.push(node);
                  return a;
                },

                // IE improperly serializes _countedByPrototype in (inner|outer)HTML.
                unmark: function(nodes) {
                  for (var i = 0, node; node = nodes[i]; i++)
                    node.removeAttribute('_countedByPrototype');
                  return nodes;
                }
              });
            }

            function $$() {
              return Selector.findChildElements(document, $A(arguments));
            }
            var Form = {
              reset: function(form) {
                $(form).reset();
                return form;
              },

              serializeElements: function(elements, options) {
                if (typeof options != 'object') options = { hash: !!options };
                else if (Object.isUndefined(options.hash)) options.hash = true;
                var key, value, submitted = false, submit = options.submit;

                var data = elements.inject({ }, function(result, element) {
                  if (!element.disabled && element.name) {
                    key = element.name; value = $(element).getValue();
                    if (value != null && element.type != 'file' && (element.type != 'submit' || (!submitted &&
                        submit !== false && (!submit || key == submit) && (submitted = true)))) {
                      if (key in result) {
                        // a key is already present; construct an array of values
                        if (!Object.isArray(result[key])) result[key] = [result[key]];
                        result[key].push(value);
                      }
                      else result[key] = value;
                    }
                  }
                  return result;
                });

                return options.hash ? data : Object.toQueryString(data);
              }
            };

            Form.Methods = {
              serialize: function(form, options) {
                return Form.serializeElements(Form.getElements(form), options);
              },

              getElements: function(form) {
                return $A($(form).getElementsByTagName('*')).inject([],
                  function(elements, child) {
                    if (Form.Element.Serializers[child.tagName.toLowerCase()])
                      elements.push(Element.extend(child));
                    return elements;
                  }
                );
              },

              getInputs: function(form, typeName, name) {
                form = $(form);
                var inputs = form.getElementsByTagName('input');

                if (!typeName && !name) return $A(inputs).map(Element.extend);

                for (var i = 0, matchingInputs = [], length = inputs.length; i < length; i++) {
                  var input = inputs[i];
                  if ((typeName && input.type != typeName) || (name && input.name != name))
                    continue;
                  matchingInputs.push(Element.extend(input));
                }

                return matchingInputs;
              },

              disable: function(form) {
                form = $(form);
                Form.getElements(form).invoke('disable');
                return form;
              },

              enable: function(form) {
                form = $(form);
                Form.getElements(form).invoke('enable');
                return form;
              },

              findFirstElement: function(form) {
                var elements = $(form).getElements().findAll(function(element) {
                  return 'hidden' != element.type && !element.disabled;
                });
                var firstByIndex = elements.findAll(function(element) {
                  return element.hasAttribute('tabIndex') && element.tabIndex >= 0;
                }).sortBy(function(element) { return element.tabIndex }).first();

                return firstByIndex ? firstByIndex : elements.find(function(element) {
                  return ['input', 'select', 'textarea'].include(element.tagName.toLowerCase());
                });
              },

              focusFirstElement: function(form) {
                form = $(form);
                form.findFirstElement().activate();
                return form;
              },

              request: function(form, options) {
                form = $(form), options = Object.clone(options || { });

                var params = options.parameters, action = form.readAttribute('action') || '';
                if (action.blank()) action = window.location.href;
                options.parameters = form.serialize(true);

                if (params) {
                  if (Object.isString(params)) params = params.toQueryParams();
                  Object.extend(options.parameters, params);
                }

                if (form.hasAttribute('method') && !options.method)
                  options.method = form.method;

                return new Ajax.Request(action, options);
              }
            };

            /*--------------------------------------------------------------------------*/

            Form.Element = {
              focus: function(element) {
                $(element).focus();
                return element;
              },

              select: function(element) {
                $(element).select();
                return element;
              }
            };

            Form.Element.Methods = {
              serialize: function(element) {
                element = $(element);
                if (!element.disabled && element.name) {
                  var value = element.getValue();
                  if (value != undefined) {
                    var pair = { };
                    pair[element.name] = value;
                    return Object.toQueryString(pair);
                  }
                }
                return '';
              },

              getValue: function(element) {
                element = $(element);
                var method = element.tagName.toLowerCase();
                return Form.Element.Serializers[method](element);
              },

              setValue: function(element, value) {
                element = $(element);
                var method = element.tagName.toLowerCase();
                Form.Element.Serializers[method](element, value);
                return element;
              },

              clear: function(element) {
                $(element).value = '';
                return element;
              },

              present: function(element) {
                return $(element).value != '';
              },

              activate: function(element) {
                element = $(element);
                try {
                  element.focus();
                  if (element.select && (element.tagName.toLowerCase() != 'input' ||
                      !['button', 'reset', 'submit'].include(element.type)))
                    element.select();
                } catch (e) { }
                return element;
              },

              disable: function(element) {
                element = $(element);
                element.disabled = true;
                return element;
              },

              enable: function(element) {
                element = $(element);
                element.disabled = false;
                return element;
              }
            };

            /*--------------------------------------------------------------------------*/

            var Field = Form.Element;
            var $F = Form.Element.Methods.getValue;

            /*--------------------------------------------------------------------------*/

            Form.Element.Serializers = {
              input: function(element, value) {
                switch (element.type.toLowerCase()) {
                  case 'checkbox':
                  case 'radio':
                    return Form.Element.Serializers.inputSelector(element, value);
                  default:
                    return Form.Element.Serializers.textarea(element, value);
                }
              },

              inputSelector: function(element, value) {
                if (Object.isUndefined(value)) return element.checked ? element.value : null;
                else element.checked = !!value;
              },

              textarea: function(element, value) {
                if (Object.isUndefined(value)) return element.value;
                else element.value = value;
              },

              select: function(element, value) {
                if (Object.isUndefined(value))
                  return this[element.type == 'select-one' ?
                    'selectOne' : 'selectMany'](element);
                else {
                  var opt, currentValue, single = !Object.isArray(value);
                  for (var i = 0, length = element.length; i < length; i++) {
                    opt = element.options[i];
                    currentValue = this.optionValue(opt);
                    if (single) {
                      if (currentValue == value) {
                        opt.selected = true;
                        return;
                      }
                    }
                    else opt.selected = value.include(currentValue);
                  }
                }
              },

              selectOne: function(element) {
                var index = element.selectedIndex;
                return index >= 0 ? this.optionValue(element.options[index]) : null;
              },

              selectMany: function(element) {
                var values, length = element.length;
                if (!length) return null;

                for (var i = 0, values = []; i < length; i++) {
                  var opt = element.options[i];
                  if (opt.selected) values.push(this.optionValue(opt));
                }
                return values;
              },

              optionValue: function(opt) {
                // extend element because hasAttribute may not be native
                return Element.extend(opt).hasAttribute('value') ? opt.value : opt.text;
              }
            };

            /*--------------------------------------------------------------------------*/

            Abstract.TimedObserver = Class.create(PeriodicalExecuter, {
              initialize: function($super, element, frequency, callback) {
                $super(callback, frequency);
                this.element   = $(element);
                this.lastValue = this.getValue();
              },

              execute: function() {
                var value = this.getValue();
                if (Object.isString(this.lastValue) && Object.isString(value) ?
                    this.lastValue != value : String(this.lastValue) != String(value)) {
                  this.callback(this.element, value);
                  this.lastValue = value;
                }
              }
            });

            Form.Element.Observer = Class.create(Abstract.TimedObserver, {
              getValue: function() {
                return Form.Element.getValue(this.element);
              }
            });

            Form.Observer = Class.create(Abstract.TimedObserver, {
              getValue: function() {
                return Form.serialize(this.element);
              }
            });

            /*--------------------------------------------------------------------------*/

            Abstract.EventObserver = Class.create({
              initialize: function(element, callback) {
                this.element  = $(element);
                this.callback = callback;

                this.lastValue = this.getValue();
                if (this.element.tagName.toLowerCase() == 'form')
                  this.registerFormCallbacks();
                else
                  this.registerCallback(this.element);
              },

              onElementEvent: function() {
                var value = this.getValue();
                if (this.lastValue != value) {
                  this.callback(this.element, value);
                  this.lastValue = value;
                }
              },

              registerFormCallbacks: function() {
                Form.getElements(this.element).each(this.registerCallback, this);
              },

              registerCallback: function(element) {
                if (element.type) {
                  switch (element.type.toLowerCase()) {
                    case 'checkbox':
                    case 'radio':
                      Event.observe(element, 'click', this.onElementEvent.bind(this));
                      break;
                    default:
                      Event.observe(element, 'change', this.onElementEvent.bind(this));
                      break;
                  }
                }
              }
            });

            Form.Element.EventObserver = Class.create(Abstract.EventObserver, {
              getValue: function() {
                return Form.Element.getValue(this.element);
              }
            });

            Form.EventObserver = Class.create(Abstract.EventObserver, {
              getValue: function() {
                return Form.serialize(this.element);
              }
            });
            if (!window.Event) var Event = { };

            Object.extend(Event, {
              KEY_BACKSPACE: 8,
              KEY_TAB:       9,
              KEY_RETURN:   13,
              KEY_ESC:      27,
              KEY_LEFT:     37,
              KEY_UP:       38,
              KEY_RIGHT:    39,
              KEY_DOWN:     40,
              KEY_DELETE:   46,
              KEY_HOME:     36,
              KEY_END:      35,
              KEY_PAGEUP:   33,
              KEY_PAGEDOWN: 34,
              KEY_INSERT:   45,

              cache: { },

              relatedTarget: function(event) {
                var element;
                switch(event.type) {
                  case 'mouseover': element = event.fromElement; break;
                  case 'mouseout':  element = event.toElement;   break;
                  default: return null;
                }
                return Element.extend(element);
              }
            });

            Event.Methods = (function() {
              var isButton;

              if (Prototype.Browser.IE) {
                var buttonMap = { 0: 1, 1: 4, 2: 2 };
                isButton = function(event, code) {
                  return event.button == buttonMap[code];
                };

              } else if (Prototype.Browser.WebKit) {
                isButton = function(event, code) {
                  switch (code) {
                    case 0: return event.which == 1 && !event.metaKey;
                    case 1: return event.which == 1 && event.metaKey;
                    default: return false;
                  }
                };

              } else {
                isButton = function(event, code) {
                  return event.which ? (event.which === code + 1) : (event.button === code);
                };
              }

              return {
                isLeftClick:   function(event) { return isButton(event, 0) },
                isMiddleClick: function(event) { return isButton(event, 1) },
                isRightClick:  function(event) { return isButton(event, 2) },

                element: function(event) {
                  event = Event.extend(event);

                  var node          = event.target,
                      type          = event.type,
                      currentTarget = event.currentTarget;

                  if (currentTarget && currentTarget.tagName) {
                    // Firefox screws up the "click" event when moving between radio buttons
                    // via arrow keys. It also screws up the "load" and "error" events on images,
                    // reporting the document as the target instead of the original image.
                    if (type === 'load' || type === 'error' ||
                      (type === 'click' && currentTarget.tagName.toLowerCase() === 'input'
                        && currentTarget.type === 'radio'))
                          node = currentTarget;
                  }
                  if (node.nodeType == Node.TEXT_NODE) node = node.parentNode;
                  return Element.extend(node);
                },

                findElement: function(event, expression) {
                  var element = Event.element(event);
                  if (!expression) return element;
                  var elements = [element].concat(element.ancestors());
                  return Selector.findElement(elements, expression, 0);
                },

                pointer: function(event) {
                  var docElement = document.documentElement,
                  body = document.body || { scrollLeft: 0, scrollTop: 0 };
                  return {
                    x: event.pageX || (event.clientX +
                      (docElement.scrollLeft || body.scrollLeft) -
                      (docElement.clientLeft || 0)),
                    y: event.pageY || (event.clientY +
                      (docElement.scrollTop || body.scrollTop) -
                      (docElement.clientTop || 0))
                  };
                },

                pointerX: function(event) { return Event.pointer(event).x },
                pointerY: function(event) { return Event.pointer(event).y },

                stop: function(event) {
                  Event.extend(event);
                  event.preventDefault();
                  event.stopPropagation();
                  event.stopped = true;
                }
              };
            })();

            Event.extend = (function() {
              var methods = Object.keys(Event.Methods).inject({ }, function(m, name) {
                m[name] = Event.Methods[name].methodize();
                return m;
              });

              if (Prototype.Browser.IE) {
                Object.extend(methods, {
                  stopPropagation: function() { this.cancelBubble = true },
                  preventDefault:  function() { this.returnValue = false },
                  inspect: function() { return "[object Event]" }
                });

                return function(event) {
                  if (!event) return false;
                  if (event._extendedByPrototype) return event;

                  event._extendedByPrototype = Prototype.emptyFunction;
                  var pointer = Event.pointer(event);
                  Object.extend(event, {
                    target: event.srcElement,
                    relatedTarget: Event.relatedTarget(event),
                    pageX:  pointer.x,
                    pageY:  pointer.y
                  });
                  return Object.extend(event, methods);
                };

              } else {
                Event.prototype = Event.prototype || document.createEvent("HTMLEvents")['__proto__'];
                Object.extend(Event.prototype, methods);
                return Prototype.K;
              }
            })();

            Object.extend(Event, (function() {
              var cache = Event.cache;

              function getEventID(element) {
                if (element._prototypeEventID) return element._prototypeEventID[0];
                arguments.callee.id = arguments.callee.id || 1;
                return element._prototypeEventID = [++arguments.callee.id];
              }

              function getDOMEventName(eventName) {
                if (eventName && eventName.include(':')) return "dataavailable";
                return eventName;
              }

              function getCacheForID(id) {
                return cache[id] = cache[id] || { };
              }

              function getWrappersForEventName(id, eventName) {
                var c = getCacheForID(id);
                return c[eventName] = c[eventName] || [];
              }

              function createWrapper(element, eventName, handler) {
                var id = getEventID(element);
                var c = getWrappersForEventName(id, eventName);
                if (c.pluck("handler").include(handler)) return false;

                var wrapper = function(event) {
                  if (!Event || !Event.extend ||
                    (event.eventName && event.eventName != eventName))
                      return false;

                  Event.extend(event);
                  handler.call(element, event);
                };

                wrapper.handler = handler;
                c.push(wrapper);
                return wrapper;
              }

              function findWrapper(id, eventName, handler) {
                var c = getWrappersForEventName(id, eventName);
                return c.find(function(wrapper) { return wrapper.handler == handler });
              }

              function destroyWrapper(id, eventName, handler) {
                var c = getCacheForID(id);
                if (!c[eventName]) return false;
                c[eventName] = c[eventName].without(findWrapper(id, eventName, handler));
              }

              function destroyCache() {
                for (var id in cache)
                  for (var eventName in cache[id])
                    cache[id][eventName] = null;
              }


              // Internet Explorer needs to remove event handlers on page unload
              // in order to avoid memory leaks.
              if (window.attachEvent) {
                window.attachEvent("onunload", destroyCache);
              }

              // Safari has a dummy event handler on page unload so that it won't
              // use its bfcache. Safari <= 3.1 has an issue with restoring the "document"
              // object when page is returned to via the back button using its bfcache.
              if (Prototype.Browser.WebKit) {
                window.addEventListener('unload', Prototype.emptyFunction, false);
              }

              return {
                observe: function(element, eventName, handler) {
                  element = $(element);
                  var name = getDOMEventName(eventName);

                  var wrapper = createWrapper(element, eventName, handler);
                  if (!wrapper) return element;

                  if (element.addEventListener) {
                    element.addEventListener(name, wrapper, false);
                  } else {
                    element.attachEvent("on" + name, wrapper);
                  }

                  return element;
                },

                stopObserving: function(element, eventName, handler) {
                  element = $(element);
                  var id = getEventID(element), name = getDOMEventName(eventName);

                  if (!handler && eventName) {
                    getWrappersForEventName(id, eventName).each(function(wrapper) {
                      element.stopObserving(eventName, wrapper.handler);
                    });
                    return element;

                  } else if (!eventName) {
                    Object.keys(getCacheForID(id)).each(function(eventName) {
                      element.stopObserving(eventName);
                    });
                    return element;
                  }

                  var wrapper = findWrapper(id, eventName, handler);
                  if (!wrapper) return element;

                  if (element.removeEventListener) {
                    element.removeEventListener(name, wrapper, false);
                  } else {
                    element.detachEvent("on" + name, wrapper);
                  }

                  destroyWrapper(id, eventName, handler);

                  return element;
                },

                fire: function(element, eventName, memo) {
                  element = $(element);
                  if (element == document && document.createEvent && !element.dispatchEvent)
                    element = document.documentElement;

                  var event;
                  if (document.createEvent) {
                    event = document.createEvent("HTMLEvents");
                    event.initEvent("dataavailable", true, true);
                  } else {
                    event = document.createEventObject();
                    event.eventType = "ondataavailable";
                  }

                  event.eventName = eventName;
                  event.memo = memo || { };

                  if (document.createEvent) {
                    element.dispatchEvent(event);
                  } else {
                    element.fireEvent(event.eventType, event);
                  }

                  return Event.extend(event);
                }
              };
            })());

            Object.extend(Event, Event.Methods);

            Element.addMethods({
              fire:          Event.fire,
              observe:       Event.observe,
              stopObserving: Event.stopObserving
            });

            Object.extend(document, {
              fire:          Element.Methods.fire.methodize(),
              observe:       Element.Methods.observe.methodize(),
              stopObserving: Element.Methods.stopObserving.methodize(),
              loaded:        false
            });

            (function() {
              /* Support for the DOMContentLoaded event is based on work by Dan Webb,
                 Matthias Miller, Dean Edwards and John Resig. */

              var timer;

              function fireContentLoadedEvent() {
                if (document.loaded) return;
                if (timer) window.clearInterval(timer);
                document.fire("dom:loaded");
                document.loaded = true;
              }

              if (document.addEventListener) {
                if (Prototype.Browser.WebKit) {
                  timer = window.setInterval(function() {
                    if (/loaded|complete/.test(document.readyState))
                      fireContentLoadedEvent();
                  }, 0);

                  Event.observe(window, "load", fireContentLoadedEvent);

                } else {
                  document.addEventListener("DOMContentLoaded",
                    fireContentLoadedEvent, false);
                }

              } else {
                document.write("<script id=__onDOMContentLoaded defer src=//:><\/script>");
                $("__onDOMContentLoaded").onreadystatechange = function() {
                  if (this.readyState == "complete") {
                    this.onreadystatechange = null;
                    fireContentLoadedEvent();
                  }
                };
              }
            })();
            /*------------------------------- DEPRECATED -------------------------------*/

            Hash.toQueryString = Object.toQueryString;

            var Toggle = { display: Element.toggle };

            Element.Methods.childOf = Element.Methods.descendantOf;

            var Insertion = {
              Before: function(element, content) {
                return Element.insert(element, {before:content});
              },

              Top: function(element, content) {
                return Element.insert(element, {top:content});
              },

              Bottom: function(element, content) {
                return Element.insert(element, {bottom:content});
              },

              After: function(element, content) {
                return Element.insert(element, {after:content});
              }
            };

            var $continue = new Error('"throw $continue" is deprecated, use "return" instead');

            // This should be moved to script.aculo.us; notice the deprecated methods
            // further below, that map to the newer Element methods.
            var Position = {
              // set to true if needed, warning: firefox performance problems
              // NOT neeeded for page scrolling, only if draggable contained in
              // scrollable elements
              includeScrollOffsets: false,

              // must be called before calling withinIncludingScrolloffset, every time the
              // page is scrolled
              prepare: function() {
                this.deltaX =  window.pageXOffset
                            || document.documentElement.scrollLeft
                            || document.body.scrollLeft
                            || 0;
                this.deltaY =  window.pageYOffset
                            || document.documentElement.scrollTop
                            || document.body.scrollTop
                            || 0;
              },

              // caches x/y coordinate pair to use with overlap
              within: function(element, x, y) {
                if (this.includeScrollOffsets)
                  return this.withinIncludingScrolloffsets(element, x, y);
                this.xcomp = x;
                this.ycomp = y;
                this.offset = Element.cumulativeOffset(element);

                return (y >= this.offset[1] &&
                        y <  this.offset[1] + element.offsetHeight &&
                        x >= this.offset[0] &&
                        x <  this.offset[0] + element.offsetWidth);
              },

              withinIncludingScrolloffsets: function(element, x, y) {
                var offsetcache = Element.cumulativeScrollOffset(element);

                this.xcomp = x + offsetcache[0] - this.deltaX;
                this.ycomp = y + offsetcache[1] - this.deltaY;
                this.offset = Element.cumulativeOffset(element);

                return (this.ycomp >= this.offset[1] &&
                        this.ycomp <  this.offset[1] + element.offsetHeight &&
                        this.xcomp >= this.offset[0] &&
                        this.xcomp <  this.offset[0] + element.offsetWidth);
              },

              // within must be called directly before
              overlap: function(mode, element) {
                if (!mode) return 0;
                if (mode == 'vertical')
                  return ((this.offset[1] + element.offsetHeight) - this.ycomp) /
                    element.offsetHeight;
                if (mode == 'horizontal')
                  return ((this.offset[0] + element.offsetWidth) - this.xcomp) /
                    element.offsetWidth;
              },

              // Deprecation layer -- use newer Element methods now (1.5.2).

              cumulativeOffset: Element.Methods.cumulativeOffset,

              positionedOffset: Element.Methods.positionedOffset,

              absolutize: function(element) {
                Position.prepare();
                return Element.absolutize(element);
              },

              relativize: function(element) {
                Position.prepare();
                return Element.relativize(element);
              },

              realOffset: Element.Methods.cumulativeScrollOffset,

              offsetParent: Element.Methods.getOffsetParent,

              page: Element.Methods.viewportOffset,

              clone: function(source, target, options) {
                options = options || { };
                return Element.clonePosition(target, source, options);
              }
            };

            /*--------------------------------------------------------------------------*/

            if (!document.getElementsByClassName) document.getElementsByClassName = function(instanceMethods){
              function iter(name) {
                return name.blank() ? null : "[contains(concat(' ', @class, ' '), ' " + name + " ')]";
              }

              instanceMethods.getElementsByClassName = Prototype.BrowserFeatures.XPath ?
              function(element, className) {
                className = className.toString().strip();
                var cond = /\s/.test(className) ? $w(className).map(iter).join('') : iter(className);
                return cond ? document._getElementsByXPath('.//*' + cond, element) : [];
              } : function(element, className) {
                className = className.toString().strip();
                var elements = [], classNames = (/\s/.test(className) ? $w(className) : null);
                if (!classNames && !className) return elements;

                var nodes = $(element).getElementsByTagName('*');
                className = ' ' + className + ' ';

                for (var i = 0, child, cn; child = nodes[i]; i++) {
                  if (child.className && (cn = ' ' + child.className + ' ') && (cn.include(className) ||
                      (classNames && classNames.all(function(name) {
                        return !name.toString().blank() && cn.include(' ' + name + ' ');
                      }))))
                    elements.push(Element.extend(child));
                }
                return elements;
              };

              return function(className, parentElement) {
                return $(parentElement || document.body).getElementsByClassName(className);
              };
            }(Element.Methods);

            /*--------------------------------------------------------------------------*/

            Element.ClassNames = Class.create();
            Element.ClassNames.prototype = {
              initialize: function(element) {
                this.element = $(element);
              },

              _each: function(iterator) {
                this.element.className.split(/\s+/).select(function(name) {
                  return name.length > 0;
                })._each(iterator);
              },

              set: function(className) {
                this.element.className = className;
              },

              add: function(classNameToAdd) {
                if (this.include(classNameToAdd)) return;
                this.set($A(this).concat(classNameToAdd).join(' '));
              },

              remove: function(classNameToRemove) {
                if (!this.include(classNameToRemove)) return;
                this.set($A(this).without(classNameToRemove).join(' '));
              },

              toString: function() {
                return $A(this).join(' ');
              }
            };

            Object.extend(Element.ClassNames.prototype, Enumerable);

            /*--------------------------------------------------------------------------*/

            Element.addMethods();
            """#,

        "path.js": #"""
            // $Id: //depot/siteify/siteify/Resources.swift#39 $

            var Point = Class.create({
                initialize: function(x, y) {
                    this.x = x;
                    this.y = y;
                },
                offset: function(dx, dy) {
                    this.x += dx;
                    this.y += dy;
                },
                distanceFrom: function(point) {
                    var dx = this.x - point.x;
                    var dy = this.y - point.y;
                    return Math.sqrt(dx * dx + dy * dy);
                },
                makePath: function(ctx) {
                    ctx.moveTo(this.x, this.y);
                    ctx.lineTo(this.x + 0.001, this.y);
                }
            });

            var Bezier = Class.create({
                initialize: function(points) {
                    this.points = points;
                    this.order = points.length;
                },
                reset: function() {
                    with (Bezier.prototype) {
                        this.controlPolygonLength = controlPolygonLength;
                        this.chordLength = chordLength;
                        this.triangle = triangle;
                        this.chordPoints = chordPoints;
                        this.coefficients = coefficients;
                    }
                },
                offset: function(dx, dy) {
                    this.points.each(function(point) {
                        point.offset(dx, dy);
                    });
                    this.reset();
                },
                getBB: function() {
                    if (!this.order) return undefined;
                    var l, t, r, b, p = this.points[0];
                    l = r = p.x;
                    t = b = p.y;
                    this.points.each(function(point) {
                        l = Math.min(l, point.x);
                        t = Math.min(t, point.y);
                        r = Math.max(r, point.x);
                        b = Math.max(b, point.y);
                    });
                    var rect = new Rect(l, t, r, b);
                    return (this.getBB = function() {return rect;})();
                },
                isPointInBB: function(x, y, tolerance) {
                    if (Object.isUndefined(tolerance)) tolerance = 0;
                    var bb = this.getBB();
                    if (0 < tolerance) {
                        bb = Object.clone(bb);
                        bb.inset(-tolerance, -tolerance);
                    }
                    return !(x < bb.l || x > bb.r || y < bb.t || y > bb.b);
                },
                isPointOnBezier: function(x, y, tolerance) {
                    if (Object.isUndefined(tolerance)) tolerance = 0;
                    if (!this.isPointInBB(x, y, tolerance)) return false;
                    var segments = this.chordPoints();
                    var p1 = segments[0].p;
                    var p2, x1, y1, x2, y2, bb, twice_area, base, height;
                    for (var i = 1; i < segments.length; ++i) {
                        p2 = segments[i].p;
                        x1 = p1.x;
                        y1 = p1.y;
                        x2 = p2.x;
                        y2 = p2.y;
                        bb = new Rect(x1, y1, x2, y2);
                        if (bb.isPointInBB(x, y, tolerance)) {
                            twice_area = Math.abs(x1 * y2 + x2 * y + x * y1 - x2 * y1 - x * y2 - x1 * y);
                            base = p1.distanceFrom(p2);
                            height = twice_area / base;
                            if (height <= tolerance) return true;
                        }
                        p1 = p2;
                    }
                    return false;
                },
                // Based on Oliver Steele's bezier.js library.
                controlPolygonLength: function() {
                    var len = 0;
                    for (var i = 1; i < this.order; ++i) {
                        len += this.points[i - 1].distanceFrom(this.points[i]);
                    }
                    return (this.controlPolygonLength = function() {return len;})();
                },
                // Based on Oliver Steele's bezier.js library.
                chordLength: function() {
                    var len = this.points[0].distanceFrom(this.points[this.order - 1]);
                    return (this.chordLength = function() {return len;})();
                },
                // From Oliver Steele's bezier.js library.
                triangle: function() {
                    var upper = this.points;
                    var m = [upper];
                    for (var i = 1; i < this.order; ++i) {
                        var lower = [];
                        for (var j = 0; j < this.order - i; ++j) {
                            var c0 = upper[j];
                            var c1 = upper[j + 1];
                            lower[j] = new Point((c0.x + c1.x) / 2, (c0.y + c1.y) / 2);
                        }
                        m.push(lower);
                        upper = lower;
                    }
                    return (this.triangle = function() {return m;})();
                },
                // Based on Oliver Steele's bezier.js library.
                triangleAtT: function(t) {
                    var s = 1 - t;
                    var upper = this.points;
                    var m = [upper];
                    for (var i = 1; i < this.order; ++i) {
                        var lower = [];
                        for (var j = 0; j < this.order - i; ++j) {
                            var c0 = upper[j];
                            var c1 = upper[j + 1];
                            lower[j] = new Point(c0.x * s + c1.x * t, c0.y * s + c1.y * t);
                        }
                        m.push(lower);
                        upper = lower;
                    }
                    return m;
                },
                // Returns two beziers resulting from splitting this bezier at t=0.5.
                // Based on Oliver Steele's bezier.js library.
                split: function(t) {
                    if ('undefined' == typeof t) t = 0.5;
                    var m = (0.5 == t) ? this.triangle() : this.triangleAtT(t);
                    var leftPoints  = new Array(this.order);
                    var rightPoints = new Array(this.order);
                    for (var i = 0; i < this.order; ++i) {
                        leftPoints[i]  = m[i][0];
                        rightPoints[i] = m[this.order - 1 - i][i];
                    }
                    return {left: new Bezier(leftPoints), right: new Bezier(rightPoints)};
                },
                // Returns a bezier which is the portion of this bezier from t1 to t2.
                // Thanks to Peter Zin on comp.graphics.algorithms.
                mid: function(t1, t2) {
                    return this.split(t2).left.split(t1 / t2).right;
                },
                // Returns points (and their corresponding times in the bezier) that form
                // an approximate polygonal representation of the bezier.
                // Based on the algorithm described in Jeremy Gibbons' dashed.ps.gz
                chordPoints: function() {
                    var p = [{tStart: 0, tEnd: 0, dt: 0, p: this.points[0]}].concat(this._chordPoints(0, 1));
                    return (this.chordPoints = function() {return p;})();
                },
                _chordPoints: function(tStart, tEnd) {
                    var tolerance = 0.001;
                    var dt = tEnd - tStart;
                    if (this.controlPolygonLength() <= (1 + tolerance) * this.chordLength()) {
                        return [{tStart: tStart, tEnd: tEnd, dt: dt, p: this.points[this.order - 1]}];
                    } else {
                        var tMid = tStart + dt / 2;
                        var halves = this.split();
                        return halves.left._chordPoints(tStart, tMid).concat(halves.right._chordPoints(tMid, tEnd));
                    }
                },
                // Returns an array of times between 0 and 1 that mark the bezier evenly
                // in space.
                // Based in part on the algorithm described in Jeremy Gibbons' dashed.ps.gz
                markedEvery: function(distance, firstDistance) {
                    var nextDistance = firstDistance || distance;
                    var segments = this.chordPoints();
                    var times = [];
                    var t = 0; // time
                    var dt; // delta t
                    var segment;
                    var remainingDistance;
                    for (var i = 1; i < segments.length; ++i) {
                        segment = segments[i];
                        segment.length = segment.p.distanceFrom(segments[i - 1].p);
                        if (0 == segment.length) {
                            t += segment.dt;
                        } else {
                            dt = nextDistance / segment.length * segment.dt;
                            segment.remainingLength = segment.length;
                            while (segment.remainingLength >= nextDistance) {
                                segment.remainingLength -= nextDistance;
                                t += dt;
                                times.push(t);
                                if (distance != nextDistance) {
                                    nextDistance = distance;
                                    dt = nextDistance / segment.length * segment.dt;
                                }
                            }
                            nextDistance -= segment.remainingLength;
                            t = segment.tEnd;
                        }
                    }
                    return {times: times, nextDistance: nextDistance};
                },
                // Return the coefficients of the polynomials for x and y in t.
                // From Oliver Steele's bezier.js library.
                coefficients: function() {
                    // This function deals with polynomials, represented as
                    // arrays of coefficients.  p[i] is the coefficient of n^i.

                    // p0, p1 => p0 + (p1 - p0) * n
                    // side-effects (denormalizes) p0, for convienence
                    function interpolate(p0, p1) {
                        p0.push(0);
                        var p = new Array(p0.length);
                        p[0] = p0[0];
                        for (var i = 0; i < p1.length; ++i) {
                            p[i + 1] = p0[i + 1] + p1[i] - p0[i];
                        }
                        return p;
                    }
                    // folds +interpolate+ across a graph whose fringe is
                    // the polynomial elements of +ns+, and returns its TOP
                    function collapse(ns) {
                        while (ns.length > 1) {
                            var ps = new Array(ns.length-1);
                            for (var i = 0; i < ns.length - 1; ++i) {
                                ps[i] = interpolate(ns[i], ns[i + 1]);
                            }
                            ns = ps;
                        }
                        return ns[0];
                    }
                    // xps and yps are arrays of polynomials --- concretely realized
                    // as arrays of arrays
                    var xps = [];
                    var yps = [];
                    for (var i = 0, pt; pt = this.points[i++]; ) {
                        xps.push([pt.x]);
                        yps.push([pt.y]);
                    }
                    var result = {xs: collapse(xps), ys: collapse(yps)};
                    return (this.coefficients = function() {return result;})();
                },
                // Return the point at time t.
                // From Oliver Steele's bezier.js library.
                pointAtT: function(t) {
                    var c = this.coefficients();
                    var cx = c.xs, cy = c.ys;
                    // evaluate cx[0] + cx[1]t +cx[2]t^2 ....

                    // optimization: start from the end, to save one
                    // muliplicate per order (we never need an explicit t^n)

                    // optimization: special-case the last element
                    // to save a multiply-add
                    var x = cx[cx.length - 1], y = cy[cy.length - 1];

                    for (var i = cx.length - 1; --i >= 0; ) {
                        x = x * t + cx[i];
                        y = y * t + cy[i];
                    }
                    return new Point(x, y);
                },
                // Render the Bezier to a WHATWG 2D canvas context.
                // Based on Oliver Steele's bezier.js library.
                makePath: function (ctx, moveTo) {
                    if ('undefined' == typeof moveTo) moveTo = true;
                    if (moveTo) ctx.moveTo(this.points[0].x, this.points[0].y);
                    var fn = this.pathCommands[this.order];
                    if (fn) {
                        var coords = [];
                        for (var i = 1 == this.order ? 0 : 1; i < this.points.length; ++i) {
                            coords.push(this.points[i].x);
                            coords.push(this.points[i].y);
                        }
                        fn.apply(ctx, coords);
                    }
                },
                // Wrapper functions to work around Safari, in which, up to at least 2.0.3,
                // fn.apply isn't defined on the context primitives.
                // Based on Oliver Steele's bezier.js library.
                pathCommands: [
                    null,
                    // This will have an effect if there's a line thickness or end cap.
                    function(x, y) {
                        this.lineTo(x + 0.001, y);
                    },
                    function(x, y) {
                        this.lineTo(x, y);
                    },
                    function(x1, y1, x2, y2) {
                        this.quadraticCurveTo(x1, y1, x2, y2);
                    },
                    function(x1, y1, x2, y2, x3, y3) {
                        this.bezierCurveTo(x1, y1, x2, y2, x3, y3);
                    }
                ],
                makeDashedPath: function(ctx, dashLength, firstDistance, drawFirst) {
                    if (!firstDistance) firstDistance = dashLength;
                    if ('undefined' == typeof drawFirst) drawFirst = true;
                    var markedEvery = this.markedEvery(dashLength, firstDistance);
                    if (drawFirst) markedEvery.times.unshift(0);
                    var drawLast = (markedEvery.times.length % 2);
                    if (drawLast) markedEvery.times.push(1);
                    for (var i = 1; i < markedEvery.times.length; i += 2) {
                        this.mid(markedEvery.times[i - 1], markedEvery.times[i]).makePath(ctx);
                    }
                    return {firstDistance: markedEvery.nextDistance, drawFirst: drawLast};
                },
                makeDottedPath: function(ctx, dotSpacing, firstDistance) {
                    if (!firstDistance) firstDistance = dotSpacing;
                    var markedEvery = this.markedEvery(dotSpacing, firstDistance);
                    if (dotSpacing == firstDistance) markedEvery.times.unshift(0);
                    markedEvery.times.each(function(t) {
                        this.pointAtT(t).makePath(ctx);
                    }.bind(this));
                    return markedEvery.nextDistance;
                }
            });

            var Path = Class.create({
                initialize: function(segments) {
                    this.segments = segments || [];
                },
                setupSegments: function() {},
                // Based on Oliver Steele's bezier.js library.
                addBezier: function(pointsOrBezier) {
                    this.segments.push(pointsOrBezier instanceof Array ? new Bezier(pointsOrBezier) : pointsOrBezier);
                },
                offset: function(dx, dy) {
                    if (0 == this.segments.length) this.setupSegments();
                    this.segments.each(function(segment) {
                        segment.offset(dx, dy);
                    });
                },
                getBB: function() {
                    if (0 == this.segments.length) this.setupSegments();
                    var l, t, r, b, p = this.segments[0].points[0];
                    l = r = p.x;
                    t = b = p.y;
                    this.segments.each(function(segment) {
                        segment.points.each(function(point) {
                            l = Math.min(l, point.x);
                            t = Math.min(t, point.y);
                            r = Math.max(r, point.x);
                            b = Math.max(b, point.y);
                        });
                    });
                    var rect = new Rect(l, t, r, b);
                    return (this.getBB = function() {return rect;})();
                },
                isPointInBB: function(x, y, tolerance) {
                    if (Object.isUndefined(tolerance)) tolerance = 0;
                    var bb = this.getBB();
                    if (0 < tolerance) {
                        bb = Object.clone(bb);
                        bb.inset(-tolerance, -tolerance);
                    }
                    return !(x < bb.l || x > bb.r || y < bb.t || y > bb.b);
                },
                isPointOnPath: function(x, y, tolerance) {
                    if (Object.isUndefined(tolerance)) tolerance = 0;
                    if (!this.isPointInBB(x, y, tolerance)) return false;
                    var result = false;
                    this.segments.each(function(segment) {
                        if (segment.isPointOnBezier(x, y, tolerance)) {
                            result = true;
                            throw $break;
                        }
                    });
                    return result;
                },
                isPointInPath: function(x, y) {
                    return false;
                },
                // Based on Oliver Steele's bezier.js library.
                makePath: function(ctx) {
                    if (0 == this.segments.length) this.setupSegments();
                    var moveTo = true;
                    this.segments.each(function(segment) {
                        segment.makePath(ctx, moveTo);
                        moveTo = false;
                    });
                },
                makeDashedPath: function(ctx, dashLength, firstDistance, drawFirst) {
                    if (0 == this.segments.length) this.setupSegments();
                    var info = {
                        drawFirst: ('undefined' == typeof drawFirst) ? true : drawFirst,
                        firstDistance: firstDistance || dashLength
                    };
                    this.segments.each(function(segment) {
                        info = segment.makeDashedPath(ctx, dashLength, info.firstDistance, info.drawFirst);
                    });
                },
                makeDottedPath: function(ctx, dotSpacing, firstDistance) {
                    if (0 == this.segments.length) this.setupSegments();
                    if (!firstDistance) firstDistance = dotSpacing;
                    this.segments.each(function(segment) {
                        firstDistance = segment.makeDottedPath(ctx, dotSpacing, firstDistance);
                    });
                }
            });

            var Polygon = Class.create(Path, {
                initialize: function($super, points) {
                    this.points = points || [];
                    $super();
                },
                setupSegments: function() {
                    this.points.each(function(p, i) {
                        var next = i + 1;
                        if (this.points.length == next) next = 0;
                        this.addBezier([
                            p,
                            this.points[next]
                        ]);
                    }.bind(this));
                }
            });

            var Rect = Class.create(Polygon, {
                initialize: function($super, l, t, r, b) {
                    this.l = l;
                    this.t = t;
                    this.r = r;
                    this.b = b;
                    $super();
                },
                inset: function (ix, iy) {
                    this.l += ix;
                    this.t += iy;
                    this.r -= ix;
                    this.b -= iy;
                    return this;
                },
                expandToInclude: function(rect) {
                    this.l = Math.min(this.l, rect.l);
                    this.t = Math.min(this.t, rect.t);
                    this.r = Math.max(this.r, rect.r);
                    this.b = Math.max(this.b, rect.b);
                },
                getWidth: function() {
                    return this.r - this.l;
                },
                getHeight: function() {
                    return this.b - this.t;
                },
                setupSegments: function($super) {
                    var w = this.getWidth();
                    var h = this.getHeight();
                    this.points = [
                        new Point(this.l, this.t),
                        new Point(this.l + w, this.t),
                        new Point(this.l + w, this.t + h),
                        new Point(this.l, this.t + h)
                    ];
                    $super();
                }
            });

            var Ellipse = Class.create(Path, {
                KAPPA: 0.5522847498,
                initialize: function($super, cx, cy, rx, ry) {
                    this.cx = cx; // center x
                    this.cy = cy; // center y
                    this.rx = rx; // radius x
                    this.ry = ry; // radius y
                    $super();
                },
                setupSegments: function() {
                    this.addBezier([
                        new Point(this.cx, this.cy - this.ry),
                        new Point(this.cx + this.KAPPA * this.rx, this.cy - this.ry),
                        new Point(this.cx + this.rx, this.cy - this.KAPPA * this.ry),
                        new Point(this.cx + this.rx, this.cy)
                    ]);
                    this.addBezier([
                        new Point(this.cx + this.rx, this.cy),
                        new Point(this.cx + this.rx, this.cy + this.KAPPA * this.ry),
                        new Point(this.cx + this.KAPPA * this.rx, this.cy + this.ry),
                        new Point(this.cx, this.cy + this.ry)
                    ]);
                    this.addBezier([
                        new Point(this.cx, this.cy + this.ry),
                        new Point(this.cx - this.KAPPA * this.rx, this.cy + this.ry),
                        new Point(this.cx - this.rx, this.cy + this.KAPPA * this.ry),
                        new Point(this.cx - this.rx, this.cy)
                    ]);
                    this.addBezier([
                        new Point(this.cx - this.rx, this.cy),
                        new Point(this.cx - this.rx, this.cy - this.KAPPA * this.ry),
                        new Point(this.cx - this.KAPPA * this.rx, this.cy - this.ry),
                        new Point(this.cx, this.cy - this.ry)
                    ]);
                }
            });
            """#,

        "canviz.js": #"""
            /*
             * This file is part of Canviz. See http://www.canviz.org/
             * $Id: //depot/siteify/siteify/Resources.swift#39 $
             */

            var CanvizTokenizer = Class.create({
                initialize: function(str) {
                    this.str = str;
                },
                takeChars: function(num) {
                    if (!num) {
                        num = 1;
                    }
                    var tokens = new Array();
                    while (num--) {
                        var matches = this.str.match(/^(\S+)\s*/);
                        if (matches) {
                            this.str = this.str.substr(matches[0].length);
                            tokens.push(matches[1]);
                        } else {
                            tokens.push(false);
                        }
                    }
                    if (1 == tokens.length) {
                        return tokens[0];
                    } else {
                        return tokens;
                    }
                },
                takeNumber: function(num) {
                    if (!num) {
                        num = 1;
                    }
                    if (1 == num) {
                        return Number(this.takeChars());
                    } else {
                        var tokens = this.takeChars(num);
                        while (num--) {
                            tokens[num] = Number(tokens[num]);
                        }
                        return tokens;
                    }
                },
                takeString: function() {
                    var byteCount = Number(this.takeChars()), charCount = 0, charCode;
                    if ('-' != this.str.charAt(0)) {
                        return false;
                    }
                    while (0 < byteCount) {
                        ++charCount;
                        charCode = this.str.charCodeAt(charCount);
                        if (0x80 > charCode) {
                            --byteCount;
                        } else if (0x800 > charCode) {
                            byteCount -= 2;
                        } else {
                            byteCount -= 3;
                        }
                    }
                    var str = this.str.substr(1, charCount);
                    this.str = this.str.substr(1 + charCount).replace(/^\s+/, '');
                    return str;
                }
            });

            var edgePaths = {};
            var edgeHeads = {};

            var CanvizEntity = Class.create({
                initialize: function(defaultAttrHashName, name, canviz, rootGraph, parentGraph, immediateGraph) {
                    this.defaultAttrHashName = defaultAttrHashName;
                    this.name = name;
                    this.canviz = canviz;
                    this.rootGraph = rootGraph;
                    this.parentGraph = parentGraph;
                    this.immediateGraph = immediateGraph;
                    this.attrs = $H();
                    this.drawAttrs = $H();
                },
                initBB: function() {
                    var matches = this.getAttr('pos').match(/([0-9.]+),([0-9.]+)/);
                    var x = Math.round(matches[1]);
                    var y = Math.round(this.canviz.height - matches[2]);
                    this.bbRect = new Rect(x, y, x, y);
                },
                getAttr: function(attrName, escString) {
                    if (Object.isUndefined(escString)) escString = false;
                    var attrValue = this.attrs.get(attrName);
                    if (Object.isUndefined(attrValue)) {
                        var graph = this.parentGraph;
                        while (!Object.isUndefined(graph)) {
                            attrValue = graph[this.defaultAttrHashName].get(attrName);
                            if (Object.isUndefined(attrValue)) {
                                graph = graph.parentGraph;
                            } else {
                                break;
                            }
                        }
                    }
                    if (attrValue && escString) {
                        attrValue = attrValue.replace(this.escStringMatchRe, function(match, p1) {
                            switch (p1) {
                                case 'N': // fall through
                                case 'E': return this.name;
                                case 'T': return this.tailNode;
                                case 'H': return this.headNode;
                                case 'G': return this.immediateGraph.name;
                                case 'L': return this.getAttr('label', true);
                            }
                            return match;
                        }.bind(this));
                    }
                    return attrValue;
                },
                draw: function(ctx, ctxScale, redrawCanvasOnly) {
                    var i, tokens, fillColor, strokeColor;
                    if (!redrawCanvasOnly) {
                        this.initBB();
                        var bbDiv = new Element('div');
                        this.canviz.elements.appendChild(bbDiv);
                    }
                    this.drawAttrs.each(function(drawAttr) {
                        var command = drawAttr.value;
            //            debug(command);
                        var tokenizer = new CanvizTokenizer(command);
                        var token = tokenizer.takeChars();
                        if (token) {
                            var dashStyle = 'solid';
                            ctx.save();
                            while (token) {
            //                    debug('processing token ' + token);
                                switch (token) {
                                    case 'E': // filled ellipse
                                    case 'e': // unfilled ellipse
                                        var filled = ('E' == token);
                                        var cx = tokenizer.takeNumber();
                                        var cy = this.canviz.height - tokenizer.takeNumber();
                                        var rx = tokenizer.takeNumber();
                                        var ry = tokenizer.takeNumber();
                                        var path = new Ellipse(cx, cy, rx, ry);
                                        break;
                                    case 'P': // filled polygon
                                    case 'p': // unfilled polygon
                                    case 'L': // polyline
                                        var filled = ('P' == token);
                                        var closed = ('L' != token);
                                        var numPoints = tokenizer.takeNumber();
                                        tokens = tokenizer.takeNumber(2 * numPoints); // points
                                        var path = new Path();
                                        for (i = 2; i < 2 * numPoints; i += 2) {
                                            path.addBezier([
                                                new Point(tokens[i - 2], this.canviz.height - tokens[i - 1]),
                                                new Point(tokens[i],     this.canviz.height - tokens[i + 1])
                                            ]);
                                        }
                                        if (closed) {
                                            path.addBezier([
                                                new Point(tokens[2 * numPoints - 2], this.canviz.height - tokens[2 * numPoints - 1]),
                                                new Point(tokens[0],                  this.canviz.height - tokens[1])
                                            ]);
                                        }
                                        break;
                                    case 'B': // unfilled b-spline
                                    case 'b': // filled b-spline
                                        var filled = ('b' == token);
                                        var numPoints = tokenizer.takeNumber();
                                        tokens = tokenizer.takeNumber(2 * numPoints); // points
                                        var path = new Path();
                                        for (i = 2; i < 2 * numPoints; i += 6) {
                                            path.addBezier([
                                                new Point(tokens[i - 2], this.canviz.height - tokens[i - 1]),
                                                new Point(tokens[i],     this.canviz.height - tokens[i + 1]),
                                                new Point(tokens[i + 2], this.canviz.height - tokens[i + 3]),
                                                new Point(tokens[i + 4], this.canviz.height - tokens[i + 5])
                                            ]);
                                        }
                                        break;
                                    case 'I': // image
                                        var l = tokenizer.takeNumber();
                                        var b = this.canviz.height - tokenizer.takeNumber();
                                        var w = tokenizer.takeNumber();
                                        var h = tokenizer.takeNumber();
                                        var src = tokenizer.takeString();
                                        if (!this.canviz.images[src]) {
                                            this.canviz.images[src] = new CanvizImage(this.canviz, src);
                                        }
                                        this.canviz.images[src].draw(ctx, l, b - h, w, h);
                                        break;
                                    case 'T': // text
                                        var l = Math.round(ctxScale * tokenizer.takeNumber() + this.canviz.padding);
                                        var t = Math.round(ctxScale * this.canviz.height + 2 * this.canviz.padding - (ctxScale * (tokenizer.takeNumber() + this.canviz.bbScale * fontSize) + this.canviz.padding));
                                        var textAlign = tokenizer.takeNumber();
                                        var textWidth = Math.round(ctxScale * tokenizer.takeNumber());
                                        var str = tokenizer.takeString();
                                        if (!redrawCanvasOnly && !/^\s*$/.test(str)) {
            //                                debug('draw text ' + str + ' ' + l + ' ' + t + ' ' + textAlign + ' ' + textWidth);
                                            str = str.escapeHTML();
                                            do {
                                                matches = str.match(/ ( +)/);
                                                if (matches) {
                                                    var spaces = ' ';
                                                    matches[1].length.times(function() {
                                                        spaces += '&nbsp;';
                                                    });
                                                    str = str.replace(/  +/, spaces);
                                                }
                                            } while (matches);
                                            var text;
                                            var href = this.getAttr('URL', true) || this.getAttr('href', true);
                                            if (href) {
                                                var target = this.getAttr('target', true) || '_self';
                                                var tooltip = this.getAttr('tooltip', true) || this.getAttr('label', true);
            //                                    debug(this.name + ', href ' + href + ', target ' + target + ', tooltip ' + tooltip);
                                                text = new Element('a', {href: href, target: target, title: tooltip});
                                                // modified here to pass through an ID for the <a> element
                                                ['id', 'onclick', 'onmousedown', 'onmouseup', 'onmouseover', 'onmousemove', 'onmouseout'].each(function(attrName) {
                                                    var attrValue = this.getAttr(attrName, true);
                                                    if (attrValue) {
                                                        text.writeAttribute(attrName, attrValue);
                                                    }
                                                }.bind(this));
                                                text.setStyle({
                                                    textDecoration: 'none'
                                                });
                                            } else {
                                                text = new Element('span');
                                            }
                                            text.update(str);
                                            text.setStyle({
                                                fontSize: Math.round(fontSize * ctxScale * this.canviz.bbScale) + 'px',
                                                fontFamily: fontFamily,
                                                color: strokeColor.textColor,
                                                position: 'absolute',
                                                textAlign: (-1 == textAlign) ? 'left' : (1 == textAlign) ? 'right' : 'center',
                                                left: (l - (1 + textAlign) * textWidth) + 'px',
                                                top: t + 'px',
                                                width: (2 * textWidth) + 'px'
                                            });
                                            if (1 != strokeColor.opacity) text.setOpacity(strokeColor.opacity);
                                            this.canviz.elements.appendChild(text);
                                        }
                                        break;
                                    case 'C': // set fill color
                                    case 'c': // set pen color
                                        var fill = ('C' == token);
                                        var color = this.parseColor(tokenizer.takeString());
                                        if (fill) {
                                            fillColor = color;
                                            ctx.fillStyle = color.canvasColor;
                                        } else {
                                            strokeColor = color;
                                            ctx.strokeStyle = color.canvasColor;
                                        }
                                        break;
                                    case 'F': // set font
                                        fontSize = tokenizer.takeNumber();
                                        fontFamily = tokenizer.takeString();
                                        switch (fontFamily) {
                                            case 'Times-Roman':
                                                fontFamily = 'Times New Roman';
                                                break;
                                            case 'Courier':
                                                fontFamily = 'Courier New';
                                                break;
                                            case 'Helvetica':
                                                fontFamily = 'Arial';
                                                break;
                                            default:
                                                // nothing
                                        }
            //                            debug('set font ' + fontSize + 'pt ' + fontFamily);
                                        break;
                                    case 'S': // set style
                                        var style = tokenizer.takeString();
                                        switch (style) {
                                            case 'solid':
                                            case 'filled':
                                                // nothing
                                                break;
                                            case 'dashed':
                                            case 'dotted':
                                                dashStyle = style;
                                                break;
                                            case 'bold':
                                                ctx.lineWidth = 2;
                                                break;
                                            default:
                                                matches = style.match(/^setlinewidth\((.*)\)$/);
                                                if (matches) {
                                                    ctx.lineWidth = Number(matches[1]);
                                                } else {
                                                    debug('unknown style ' + style);
                                                }
                                        }
                                        break;
                                    default:
                                        debug('unknown token ' + token);
                                        return;
                                }
                                if (path) {
                                    this.canviz.drawPath(ctx, path, filled, dashStyle);
                                    if (!redrawCanvasOnly) this.bbRect.expandToInclude(path.getBB());
                                    // store edge paths so they can be redrawn
                                    if ( drawAttr.key == '_draw_' )
                                        edgePaths[this.getAttr("eid")] = path;
                                    if ( drawAttr.key == '_hdraw_' )
                                        edgeHeads[this.getAttr("eid")] = path;
                                    path = undefined;
                                }
                                token = tokenizer.takeChars();
                            }
                            if (!redrawCanvasOnly) {
                                bbDiv.setStyle({
                                    position: 'absolute',
                                    left:   Math.round(ctxScale * this.bbRect.l + this.canviz.padding) + 'px',
                                    top:    Math.round(ctxScale * this.bbRect.t + this.canviz.padding) + 'px',
                                    width:  Math.round(ctxScale * this.bbRect.getWidth()) + 'px',
                                    height: Math.round(ctxScale * this.bbRect.getHeight()) + 'px'
                                });
                            }
                            ctx.restore();
                        }
                    }.bind(this));
                },
                parseColor: function(color) {
                    var parsedColor = {opacity: 1};
                    // rgb/rgba
                    if (/^#(?:[0-9a-f]{2}\s*){3,4}$/i.test(color)) {
                        return this.canviz.parseHexColor(color);
                    }
                    // hsv
                    var matches = color.match(/^(\d+(?:\.\d+)?)[\s,]+(\d+(?:\.\d+)?)[\s,]+(\d+(?:\.\d+)?)$/);
                    if (matches) {
                        parsedColor.canvasColor = parsedColor.textColor = this.canviz.hsvToRgbColor(matches[1], matches[2], matches[3]);
                        return parsedColor;
                    }
                    // named color
                    var colorScheme = this.getAttr('colorscheme') || 'X11';
                    var colorName = color;
                    matches = color.match(/^\/(.*)\/(.*)$/);
                    if (matches) {
                        if (matches[1]) {
                            colorScheme = matches[1];
                        }
                        colorName = matches[2];
                    } else {
                        matches = color.match(/^\/(.*)$/);
                        if (matches) {
                            colorScheme = 'X11';
                            colorName = matches[1];
                        }
                    }
                    colorName = colorName.toLowerCase();
                    var colorSchemeName = colorScheme.toLowerCase();
                    var colorSchemeData = Canviz.prototype.colors.get(colorSchemeName);
                    if (colorSchemeData) {
                        var colorData = colorSchemeData[colorName];
                        if (colorData) {
                            return this.canviz.parseHexColor('#' + colorData);
                        }
                    }
                    colorData = Canviz.prototype.colors.get('fallback')[colorName];
                    if (colorData) {
                        return this.canviz.parseHexColor('#' + colorData);
                    }
                    if (!colorSchemeData) {
                        debug('unknown color scheme ' + colorScheme);
                    }
                    // unknown
                    debug('unknown color ' + color + '; color scheme is ' + colorScheme);
                    parsedColor.canvasColor = parsedColor.textColor = '#000000';
                    return parsedColor;
                }
            });

            var CanvizNode = Class.create(CanvizEntity, {
                initialize: function($super, name, canviz, rootGraph, parentGraph) {
                    $super('nodeAttrs', name, canviz, rootGraph, parentGraph, parentGraph);
                }
            });
            Object.extend(CanvizNode.prototype, {
                escStringMatchRe: /\\([NGL])/g
            });

            var CanvizEdge = Class.create(CanvizEntity, {
                initialize: function($super, name, canviz, rootGraph, parentGraph, tailNode, headNode) {
                    $super('edgeAttrs', name, canviz, rootGraph, parentGraph, parentGraph);
                    this.tailNode = tailNode;
                    this.headNode = headNode;
                }
            });
            Object.extend(CanvizEdge.prototype, {
                escStringMatchRe: /\\([EGTHL])/g
            });

            var CanvizGraph = Class.create(CanvizEntity, {
                initialize: function($super, name, canviz, rootGraph, parentGraph) {
                    $super('attrs', name, canviz, rootGraph, parentGraph, this);
                    this.nodeAttrs = $H();
                    this.edgeAttrs = $H();
                    this.nodes = $A();
                    this.edges = $A();
                    this.subgraphs = $A();
                },
                initBB: function() {
                    var coords = this.getAttr('bb').split(',');
                    this.bbRect = new Rect(coords[0], this.canviz.height - coords[1], coords[2], this.canviz.height - coords[3]);
                },
                draw: function($super, ctx, ctxScale, redrawCanvasOnly) {
                    $super(ctx, ctxScale, redrawCanvasOnly);
            // modifed, was:
            //        [this.subgraphs, this.nodes, this.edges].each(function(type) {
                    [this.subgraphs, this.edges, this.nodes].each(function(type) {
                        type.each(function(entity) {
                            entity.draw(ctx, ctxScale, redrawCanvasOnly);
                        });
                    });
                }
            });
            Object.extend(CanvizGraph.prototype, {
                escStringMatchRe: /\\([GL])/g
            });

            var Canviz = Class.create({
                maxXdotVersion: '1.2',
                colors: $H({
                    fallback:{
                        black:'000000',
                        lightgrey:'d3d3d3',
                        white:'ffffff'
                    }
                }),
                initialize: function(container, url, urlParams) {
                    // excanvas can't init the element if we use new Element()
                    this.canvas = document.createElement('canvas');
                    Element.setStyle(this.canvas, {
                        position: 'absolute'
                    });
                    if (!Canviz.canvasCounter) Canviz.canvasCounter = 0;
                    this.canvas.id = 'canviz_canvas_' + ++Canviz.canvasCounter;
                    this.elements = new Element('div');
                    this.elements.setStyle({
                        position: 'absolute'
                    });
                    this.container = $(container);
                    this.container.setStyle({
                        position: 'relative'
                    });
                    this.container.appendChild(this.canvas);
                    if (Prototype.Browser.IE) {
                        G_vmlCanvasManager.initElement(this.canvas);
                        this.canvas = $(this.canvas.id);
                    }
                    this.container.appendChild(this.elements);
                    this.ctx = this.canvas.getContext('2d');
                    this.scale = 1;
                    this.padding = 8;
                    this.dashLength = 6;
                    this.dotSpacing = 4;
                    this.graphs = $A();
                    this.images = new Hash();
                    this.numImages = 0;
                    this.numImagesFinished = 0;
                    if (url) {
                        this.load(url, urlParams);
                    }
                },
                setScale: function(scale) {
                    this.scale = scale;
                },
                setImagePath: function(imagePath) {
                    this.imagePath = imagePath;
                },
                load: function(url, urlParams) {
                    $('debug_output').innerHTML = '';
                    new Ajax.Request(url, {
                        method: 'get',
                        parameters: urlParams,
                        onComplete: function(response) {
                            this.parse(response.responseText);
                        }.bind(this)
                    });
                },
                parse: function(xdot) {
                    this.graphs = $A();
                    this.width = 0;
                    this.height = 0;
                    this.maxWidth = false;
                    this.maxHeight = false;
                    this.bbEnlarge = false;
                    this.bbScale = 1;
                    this.dpi = 96;
                    this.bgcolor = {opacity: 1};
                    this.bgcolor.canvasColor = this.bgcolor.textColor = '#ffffff';
                    var lines = xdot.split(/\r?\n/);
                    var i = 0;
                    var line, lastChar, matches, rootGraph, isGraph, entity, entityName, attrs, attrName, attrValue, attrHash, drawAttrHash;
                    var containers = $A();
                    while (i < lines.length) {
                        line = lines[i++].replace(/^\s+/, '');
                        if ('' != line && '#' != line.substr(0, 1)) {
                            while (i < lines.length && ';' != (lastChar = line.substr(line.length - 1, line.length)) && '{' != lastChar && '}' != lastChar) {
                                if ('\\' == lastChar) {
                                    line = line.substr(0, line.length - 1);
                                }
                                line += lines[i++];
                            }
            //                debug(line);
                            if (0 == containers.length) {
                                matches = line.match(this.graphMatchRe);
                                if (matches) {
                                    rootGraph = new CanvizGraph(matches[3], this);
                                    containers.unshift(rootGraph);
                                    containers[0].strict = !Object.isUndefined(matches[1]);
                                    containers[0].type = ('graph' == matches[2]) ? 'undirected' : 'directed';
                                    containers[0].attrs.set('xdotversion', '1.0');
                                    this.graphs.push(containers[0]);
            //                        debug('graph: ' + containers[0].name);
                                }
                            } else {
                                matches = line.match(this.subgraphMatchRe);
                                if (matches) {
                                    containers.unshift(new CanvizGraph(matches[1], this, rootGraph, containers[0]));
                                    containers[1].subgraphs.push(containers[0]);
            //                        debug('subgraph: ' + containers[0].name);
                                }
                            }
                            if (matches) {
            //                    debug('begin container ' + containers[0].name);
                            } else if ('}' == line) {
            //                    debug('end container ' + containers[0].name);
                                containers.shift();
                                if (0 == containers.length) {
                                    break;
                                }
                            } else {
                                matches = line.match(this.nodeMatchRe);
                                if (matches) {
                                    entityName = matches[2];
                                    attrs = matches[5];
                                    drawAttrHash = containers[0].drawAttrs;
                                    isGraph = false;
                                    switch (entityName) {
                                        case 'graph':
                                            attrHash = containers[0].attrs;
                                            isGraph = true;
                                            break;
                                        case 'node':
                                            attrHash = containers[0].nodeAttrs;
                                            break;
                                        case 'edge':
                                            attrHash = containers[0].edgeAttrs;
                                            break;
                                        default:
                                            entity = new CanvizNode(entityName, this, rootGraph, containers[0]);
                                            attrHash = entity.attrs;
                                            drawAttrHash = entity.drawAttrs;
                                            containers[0].nodes.push(entity);
                                    }
            //                        debug('node: ' + entityName);
                                } else {
                                    matches = line.match(this.edgeMatchRe);
                                    if (matches) {
                                        entityName = matches[1];
                                        attrs = matches[8];
                                        entity = new CanvizEdge(entityName, this, rootGraph, containers[0], matches[2], matches[5]);
                                        attrHash = entity.attrs;
                                        drawAttrHash = entity.drawAttrs;
                                        containers[0].edges.push(entity);
            //                            debug('edge: ' + entityName);
                                    }
                                }
                                if (matches) {
                                    do {
                                        if (0 == attrs.length) {
                                            break;
                                        }
                                        matches = attrs.match(this.attrMatchRe);
                                        if (matches) {
                                            attrs = attrs.substr(matches[0].length);
                                            attrName = matches[1];
                                            attrValue = this.unescape(matches[2]);
                                            if (/^_.*draw_$/.test(attrName)) {
                                                drawAttrHash.set(attrName, attrValue);
                                            } else {
                                                attrHash.set(attrName, attrValue);
                                            }
            //                                debug(attrName + ' ' + attrValue);
                                            if (isGraph && 1 == containers.length) {
                                                switch (attrName) {
                                                    case 'bb':
                                                        var bb = attrValue.split(/,/);
                                                        this.width  = Number(bb[2]);
                                                        this.height = Number(bb[3]);
                                                        break;
                                                    case 'bgcolor':
                                                        this.bgcolor = rootGraph.parseColor(attrValue);
                                                        break;
                                                    case 'dpi':
                                                        this.dpi = attrValue;
                                                        break;
                                                    case 'size':
                                                        var size = attrValue.match(/^(\d+|\d*(?:\.\d+)),\s*(\d+|\d*(?:\.\d+))(!?)$/);
                                                        if (size) {
                                                            this.maxWidth  = 72 * Number(size[1]);
                                                            this.maxHeight = 72 * Number(size[2]);
                                                            this.bbEnlarge = ('!' == size[3]);
                                                        } else {
                                                            debug('can\'t parse size');
                                                        }
                                                        break;
                                                    case 'xdotversion':
                                                        if (0 > this.versionCompare(this.maxXdotVersion, attrHash.get('xdotversion'))) {
                                                            debug('unsupported xdotversion ' + attrHash.get('xdotversion') + '; this script currently supports up to xdotversion ' + this.maxXdotVersion);
                                                        }
                                                        break;
                                                }
                                            }
                                        } else {
                                            debug('can\'t read attributes for entity ' + entityName + ' from ' + attrs);
                                        }
                                    } while (matches);
                                }
                            }
                        }
                    }
            /*
                    if (this.maxWidth && this.maxHeight) {
                        if (this.width > this.maxWidth || this.height > this.maxHeight || this.bbEnlarge) {
                            this.bbScale = Math.min(this.maxWidth / this.width, this.maxHeight / this.height);
                            this.width  = Math.round(this.width  * this.bbScale);
                            this.height = Math.round(this.height * this.bbScale);
                        }
                    }
            */
            //        debug('done');
                    this.draw();
                },
                draw: function(redrawCanvasOnly) {
                    if (Object.isUndefined(redrawCanvasOnly)) redrawCanvasOnly = false;
                    var ctxScale = this.scale * this.dpi / 72;
                    var width  = Math.round(ctxScale * this.width  + 2 * this.padding);
                    var height = Math.round(ctxScale * this.height + 2 * this.padding);
                    if (!redrawCanvasOnly) {
                        this.canvas.width  = width;
                        this.canvas.height = height;
                        this.canvas.setStyle({
                            width:  width  + 'px',
                            height: height + 'px'
                        });
                        this.container.setStyle({
                            width:  width  + 'px'
                        });
                        while (this.elements.firstChild) {
                            this.elements.removeChild(this.elements.firstChild);
                        }
                    }
                    this.ctx.save();
                    this.ctx.lineCap = 'round';
                    this.ctx.fillStyle = this.bgcolor.canvasColor;
                    this.ctx.fillRect(0, 0, width, height);
                    this.ctx.translate(this.padding, this.padding);
                    this.ctx.scale(ctxScale, ctxScale);
                    this.graphs[0].draw(this.ctx, ctxScale, redrawCanvasOnly);
                    this.ctx.restore();
                },
                drawPath: function(ctx, path, filled, dashStyle) {
                    if (filled) {
                        ctx.beginPath();
                        path.makePath(ctx);
                        ctx.fill();
                    }
                    if (ctx.fillStyle != ctx.strokeStyle || !filled) {
                        switch (dashStyle) {
                            case 'dashed':
                                ctx.beginPath();
                                path.makeDashedPath(ctx, this.dashLength);
                                break;
                            case 'dotted':
                                var oldLineWidth = ctx.lineWidth;
                                ctx.lineWidth *= 2;
                                ctx.beginPath();
                                path.makeDottedPath(ctx, this.dotSpacing);
                                break;
                            case 'solid':
                            default:
                                if (!filled) {
                                    ctx.beginPath();
                                    path.makePath(ctx);
                                }
                        }
                        ctx.stroke();
                        if (oldLineWidth) ctx.lineWidth = oldLineWidth;
                    }
                },
                unescape: function(str) {
                    var matches = str.match(/^"(.*)"$/);
                    if (matches) {
                        return matches[1].replace(/\\"/g, '"');
                    } else {
                        return str;
                    }
                },
                parseHexColor: function(color) {
                    var matches = color.match(/^#([0-9a-f]{2})\s*([0-9a-f]{2})\s*([0-9a-f]{2})\s*([0-9a-f]{2})?$/i);
                    if (matches) {
                        var canvasColor, textColor = '#' + matches[1] + matches[2] + matches[3], opacity = 1;
                        if (matches[4]) { // rgba
                            opacity = parseInt(matches[4], 16) / 255;
                            canvasColor = 'rgba(' + parseInt(matches[1], 16) + ',' + parseInt(matches[2], 16) + ',' + parseInt(matches[3], 16) + ',' + opacity + ')';
                        } else { // rgb
                            canvasColor = textColor;
                        }
                    }
                    return {canvasColor: canvasColor, textColor: textColor, opacity: opacity};
                },
                hsvToRgbColor: function(h, s, v) {
                    var i, f, p, q, t, r, g, b;
                    h *= 360;
                    i = Math.floor(h / 60) % 6;
                    f = h / 60 - i;
                    p = v * (1 - s);
                    q = v * (1 - f * s);
                    t = v * (1 - (1 - f) * s);
                    switch (i) {
                        case 0: r = v; g = t; b = p; break;
                        case 1: r = q; g = v; b = p; break;
                        case 2: r = p; g = v; b = t; break;
                        case 3: r = p; g = q; b = v; break;
                        case 4: r = t; g = p; b = v; break;
                        case 5: r = v; g = p; b = q; break;
                    }
                    return 'rgb(' + Math.round(255 * r) + ',' + Math.round(255 * g) + ',' + Math.round(255 * b) + ')';
                },
                versionCompare: function(a, b) {
                    a = a.split('.');
                    b = b.split('.');
                    var a1, b1;
                    while (a.length || b.length) {
                        a1 = a.length ? a.shift() : 0;
                        b1 = b.length ? b.shift() : 0;
                        if (a1 < b1) return -1;
                        if (a1 > b1) return 1;
                    }
                    return 0;
                },
                // an alphanumeric string or a number or a double-quoted string or an HTML string
                idMatch: '([a-zA-Z\u0080-\uFFFF_][0-9a-zA-Z\u0080-\uFFFF_]*|-?(?:\\.\\d+|\\d+(?:\\.\\d*)?)|"(?:\\\\"|[^"])*"|<(?:<[^>]*>|[^<>]+?)+>)'
            });
            Object.extend(Canviz.prototype, {
                // ID or ID:port or ID:compassPoint or ID:port:compassPoint
                nodeIdMatch: Canviz.prototype.idMatch + '(?::' + Canviz.prototype.idMatch + ')?(?::' + Canviz.prototype.idMatch + ')?'
            });
            Object.extend(Canviz.prototype, {
                graphMatchRe: new RegExp('^(strict\\s+)?(graph|digraph)(?:\\s+' + Canviz.prototype.idMatch + ')?\\s*{$', 'i'),
                subgraphMatchRe: new RegExp('^(?:subgraph\\s+)?' + Canviz.prototype.idMatch + '?\\s*{$', 'i'),
                nodeMatchRe: new RegExp('^(' + Canviz.prototype.nodeIdMatch + ')\\s+\\[(.+)\\];$'),
                edgeMatchRe: new RegExp('^(' + Canviz.prototype.nodeIdMatch + '\\s*-[->]\\s*' + Canviz.prototype.nodeIdMatch + ')\\s+\\[(.+)\\];$'),
                attrMatchRe: new RegExp('^' + Canviz.prototype.idMatch + '=' + Canviz.prototype.idMatch + '(?:[,\\s]+|$)')
            });

            var CanvizImage = Class.create({
                initialize: function(canviz, src) {
                    this.canviz = canviz;
                    ++this.canviz.numImages;
                    this.finished = this.loaded = false;
                    this.img = new Image();
                    this.img.onload = this.onLoad.bind(this);
                    this.img.onerror = this.onFinish.bind(this);
                    this.img.onabort = this.onFinish.bind(this);
                    this.img.src = this.canviz.imagePath + src;
                },
                onLoad: function() {
                    this.loaded = true;
                    this.onFinish();
                },
                onFinish: function() {
                    this.finished = true;
                    ++this.canviz.numImagesFinished;
                    if (this.canviz.numImages == this.canviz.numImagesFinished) {
                        this.canviz.draw(true);
                    }
                },
                draw: function(ctx, l, t, w, h) {
                    if (this.finished) {
                        if (this.loaded) {
                            ctx.drawImage(this.img, l, t, w, h);
                        } else {
                            debug('can\'t load image ' + this.img.src);
                            this.drawBrokenImage(ctx, l, t, w, h);
                        }
                    }
                },
                drawBrokenImage: function(ctx, l, t, w, h) {
                    ctx.save();
                    ctx.beginPath();
                    new Rect(l, t, l + w, t + w).draw(ctx);
                    ctx.moveTo(l, t);
                    ctx.lineTo(l + w, t + w);
                    ctx.moveTo(l + w, t);
                    ctx.lineTo(l, t + h);
                    ctx.strokeStyle = '#f00';
                    ctx.lineWidth = 1;
                    ctx.stroke();
                    ctx.restore();
                }
            });

            function debug(str, escape) {
                str = String(str);
                if (Object.isUndefined(escape)) {
                    escape = true;
                }
                if (escape) {
                    str = str.escapeHTML();
                }
                $('debug_output').innerHTML += '&raquo;' + str + '&laquo;<br />';
            }
            """#,

        "canviz.css": #"""
            /*
             * This file is part of Canviz. See http://www.canviz.org/
             * $Id: //depot/siteify/siteify/Resources.swift#39 $
             */

            body {
                background: #eee;
                margin: 0;
                padding: 0;
            }
            #busy {
                position: fixed;
                z-index: 1;
                left: 50%;
                top: 50%;
                width: 10em;
                height: 2em;
                margin: -1em 0 0 -5em;
                line-height: 2em;
                text-align: center;
                background: #333;
                color: #fff;
                opacity: 0.95;
            }
            #graph_form {
                position: fixed;
                z-index: 2;
                left: 0;
                top: 0;
                background: #eee;
                border: solid #ccc;
                border-width: 0 1px 1px 0;
                opacity: 0.95;
            }
            #graph_form,
            #graph_form input,
            #graph_form select {
                font: 12px "Lucida Grande", Arial, Helvetica, sans-serif;
            }
            #graph_form fieldset {
                margin: 0.5em;
                padding: 0.5em 0;
                text-align: center;
                border: solid #ccc;
                border-width: 1px 0 0 0;
            }
            #graph_form legend {
                padding: 0 0.5em 0 0;
            }
            #graph_form input.little_button {
                width: 3em;
            }
            #graph_form select,
            #graph_form input.big_button {
                width: 15em;
            }
            #graph_container {
                background: #fff;
                margin: 0 auto;
            }
            #debug_output {
                margin: 1em;
            }
            """#,

        "README.txt": """
            CANVIZ
            ======


            Introduction
            ------------

            Canviz is a library for drawing Graphviz graphs to a web browser canvas. It is
            designed to be used by web applications that need to display or edit graphs, as
            a replacement for sending graphs as bitmapped images and image maps.

            For more information, please visit the Canviz web site at http://canviz.org/ .


            License
            -------

            Canviz is provided under the terms of the MIT license. See the file LICENSE.txt.

            This product includes color specifications and designs developed by Cynthia
            Brewer (http://colorbrewer.org/). Use of the ColorBrewer color schemes is
            subject to a separate license. See the file LICENSE-ColorBrewer.txt.

            Canviz requires the use of some other software, including the Path, Prototype
            and Excanvas libraries, and the Graphviz software, which have licenses of their
            own.
            """,
        
        "LICENSE.txt": """
            MIT-style software license for Canviz library

            Copyright (c) 2006-2009 Ryan Schmidt

            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in
            all copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
            THE SOFTWARE.
            """,
    ]
}
