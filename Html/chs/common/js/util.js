/**
 *项目/框架无关的工具方法
 */
var Util = {
    //检测某个方法是不是原生的本地方法
    // http://peter.michaux.ca/articles/feature-detection-state-of-the-art-browser-scripting
    isHostMethod: function(object, property) {
        var t = typeof object[property];
        return t == 'function' ||
                (!!(t == 'object' && object[property])) ||
                t == 'unknown';
    },
    getUuid: function() {
        var uuid = "";
        for (var i = 0; i < 32; i++) {
            uuid += Math.floor(Math.random() * 16).toString(16);
        }
        return uuid;
    }
};

Util.String = {
    getExt: function(filename) {
        var ext = filename.slice(filename.lastIndexOf('.') + 1).toLowerCase();
        return ext;
    },
    baseName: function(path) {
        path = path.toString();
        return path.replace(/\\/g, '/').replace(/.*\//, '');
    },
    dirName: function(path) {
        path = path.toString();
        return path.indexOf('/') < 0 ? '' : path.replace(/\\/g, '/').replace(/\/[^\/]*$/, '');
    },
    ltrim: function(str, charlist) {
        charlist = !charlist ? ' \\s\u00A0' : (charlist + '').replace(/([\[\]\(\)\.\?\/\*\{\}\+\$\^\:])/g, '$1');
        var re = new RegExp('^[' + charlist + ']+', 'g');
        return (str + '').replace(re, '');
    },
    rtrim: function(str, charlist) {
        charlist = !charlist ? ' \\s\u00A0' : (charlist + '').replace(/([\[\]\(\)\.\?\/\*\{\}\+\$\^\:])/g, '\\$1');
        var re = new RegExp('[' + charlist + ']+$', 'g');
        return (str + '').replace(re, '');
    },
    //返回字符串的最后一个字符
    lastChar: function(str) {
        str = String(str);
        return str.charAt(str.length - 1);
    },
    //根据某个分隔符获取分隔符后面的字符
    getNextStr: function(str, separate) {
        return str.slice(str.lastIndexOf(separate) + 1);
    },
    //根据某个分隔符获取分隔符前面面的字符
    getPrevStr: function(str, separate) {
        if (str.indexOf(separate) < 0) {
            return '';
        }
        else {
            return str.slice(0, str.lastIndexOf(separate));
        }
    },
    strLen: function(str) {
        return str.replace(/[^\x00-\xff]/g, "rr").length;
    },
    subStr: function(str, n) {
        var r = /[^\x00-\xff]/g;
        if (str.replace(r, "mm").length <= n)
            return str;
        // n = n - 3;
        var m = Math.floor(n / 2);
        for (var i = m; i < str.length; i++) {
            if (str.substr(0, i).replace(r, "mm").length >= n) {
                return str.substr(0, i);
            }
        }
        return this;
    }

};
Util.RegExp = {
    Name: /^[a-zA-Z0-9_\u4e00-\u9fa5]+$/,
    HTTP: /^http(s?):\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\’:+!]*([^<>\"\"])*$/,
    Email: /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i,
    NumberandLetter: /^([A-Z]|[a-z]|[\d])*$/,
    PositiveNumber: /^[1-9]\d*$/, //正整数
    NonNegativeNum: /^(0|[1-9]\d*)$/, //非负整数，即0和正整数
    IP: /^((1?\d?\d|(2([0-4]\d|5[0-5])))\.){3}(1?\d?\d|(2([0-4]\d|5[0-5])))$/,
    URL: /^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/,
    PhoneNumber: /^((0\d{2,3})-)?(\d{7,8})(-(\d{3,}))?$|^(13|15|18)[0-9]{9}$/,
    QQ: /^\d{1,10}$/,
    Date: /^((?!0000)[0-9]{4}-((0[1-9]|1[0-2])-(0[1-9]|1[0-9]|2[0-8])|(0[13-9]|1[0-2])-(29|30)|(0[13578]|1[02])-31)|([0-9]{2}(0[48]|[2468][048]|[13579][26])|(0[48]|[2468][048]|[13579][26])00)-02-29)$/
};

Util.Validation = {
    isRegName: function(name) {
        return Util.RegExp.Name.test(name);
    },
    isHttp: function(str) {
        return Util.RegExp.HTTP.test(str);
    },
    isEmail: function(str) {
        return Util.RegExp.Email.test(str);
    },
    //是否为非负整数
    isNonNegativeNum: function(str) {
        return Util.RegExp.NonNegativeNum.test(str);
    },
    //是否为正整数
    isPositiveNumber: function(str) {
        return Util.RegExp.PositiveNumber.test(str);
    },
    isPhoneNum: function(str) {
        return Util.RegExp.PhoneNumber.test(str);
    },
    isQQNum: function(str) {
        return Util.RegExp.QQ.test(str);
    },
    isDate: function(str) {
        return Util.RegExp.Date.test(str);
    }
};

Util.Date = {
    chunks: [[1000, '秒'], [60000, '分钟'], [3600000, '小时'], [86400000, '天'], [604800000, '周'], [2592000000, '个月'], [31536000000, '年']],
    format: function(date, format) {
        var o = {
            "M+": date.getMonth() + 1, //month
            "d+": date.getDate(), //day
            "h+": date.getHours(), //hour
            "m+": date.getMinutes(), //minute
            "s+": date.getSeconds(), //second

            "q+": Math.floor((date.getMonth() + 3) / 3), //quarter
            "S": date.getMilliseconds() //millisecond
        };
        if (/(y+)/.test(format))
        {
            format = format.replace(RegExp.$1, (date.getFullYear() + "").substr(4 - RegExp.$1.length));
        }
        for (var k in o)
        {
            if (new RegExp("(" + k + ")").test(format))
            {
                format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
            }
        }
        return format;
    },
    day_diff: function(timestamp1, timestamp2) {
        var diff_time = timestamp2 - timestamp1,
                suffix = '',
                abs_diff = Math.abs(diff_time);
        if (diff_time > 0) {
            suffix = '后';
        }
        else if (diff_time < 0) {
            suffix = '前';
        }
        var day_minseconds = 86400000;
        var v = Math.floor(abs_diff / day_minseconds);
        if (v == 0) {
            return '今天'
        } else {
            return v + '天' + suffix;
        }
    },
    timeTohhmmss: function(seconds) {
        var hh;
        var mm;
        var ss;
        //传入的时间为空或小于0
        if (seconds == null || seconds < 0) {
            return '';
        }
        //得到小时
        hh = seconds / 3600 | 0;
        seconds = parseInt(seconds) - hh * 3600;
        if (parseInt(hh) < 10) {
            hh = "0" + hh;
        }
        //得到分
        mm = seconds / 60 | 0;
        //得到秒
        ss = parseInt(seconds) - mm * 60;
        if (parseInt(mm) < 10) {
            mm = "0" + mm;
        }
        if (ss < 10) {
            ss = "0" + ss;
        }
        return hh + "小时" + mm + "分" + ss + "秒";
    }
};

Util.Browser = {
    /*
     *检测浏览器是否安装了flash
     **/
    isInstallFlash: function() {

        var name = "Shockwave Flash", mimeType = "application/x-shockwave-flash";
        var flashVersion = 0;
        if (typeof navigator.plugins !== 'undefined' && typeof navigator.plugins[name] == "object") {
            // adapted from the swfobject code
            var description = navigator.plugins[name].description;
            if (description && typeof navigator.mimeTypes !== 'undefined' && navigator.mimeTypes[mimeType] && navigator.mimeTypes[mimeType].enabledPlugin) {
                flashVersion = description.match(/\d+/g);
            }
        }
        if (!flashVersion) {
            var flash;
            try {
                flash = new ActiveXObject("ShockwaveFlash.ShockwaveFlash");
                flashVersion = Array.prototype.slice.call(flash.GetVariable("$version").match(/(\d+),(\d+),(\d+),(\d+)/), 1);
                flash = null;
            }
            catch (notSupportedException) {
            }
        }
        if (!flashVersion) {
            return false;
        }
        var major = parseInt(flashVersion[0], 10), minor = parseInt(flashVersion[1], 10);
        HAS_FLASH_THROTTLED_BUG = major > 9 && minor > 0;
        return true;
    }
};


Util.Input = {
    getInputPositon: function(elem) {
        if (document.selection) {   //IE Support
            elem.focus();
            var Sel = document.selection.createRange();
            return {
                left: Sel.boundingLeft + $(document).scrollLeft() + 5,
                top: Sel.boundingTop + $(document).scrollTop() + 4
            };
        } else {
            var that = this;
            var cloneDiv = '{$clone_div}', cloneLeft = '{$cloneLeft}', cloneFocus = '{$cloneFocus}', cloneRight = '{$cloneRight}';
            var none = '<span style="white-space:pre-wrap;"> </span>';
            var div = elem[cloneDiv] || document.createElement('div'), focus = elem[cloneFocus] || document.createElement('span');
            var text = elem[cloneLeft] || document.createElement('span');
            var offset = that._offset(elem), index = this._getFocus(elem), focusOffset = {
                left: 0,
                top: 0
            };

            if (!elem[cloneDiv]) {
                elem[cloneDiv] = div, elem[cloneFocus] = focus;
                elem[cloneLeft] = text;
                div.appendChild(text);
                div.appendChild(focus);
                document.body.appendChild(div);
                focus.innerHTML = '|';
                focus.style.cssText = 'display:inline-block;width:0px;overflow:hidden;z-index:-100;word-wrap:break-word;word-break:break-all;';
                div.className = this._cloneStyle(elem);
                div.style.cssText = 'visibility:hidden;display:inline-block;position:absolute;z-index:-100;word-wrap:break-word;word-break:break-all;overflow:hidden;';
            }
            ;
            div.style.left = this._offset(elem).left + "px";
            div.style.top = this._offset(elem).top + "px";
            var strTmp = elem.value.substring(0, index).replace(/</g, '<').replace(/>/g, '>').replace(/\n/g, '<br/>').replace(/\s/g, none);
            text.innerHTML = strTmp;

            focus.style.display = 'inline-block';
            try {
                focusOffset = this._offset(focus);
            } catch (e) {
            }
            ;
            focus.style.display = 'none';
            return {
                left: focusOffset.left,
                top: focusOffset.top,
                bottom: focusOffset.bottom
            };
        }
    },
    // 克隆元素样式并返回类
    _cloneStyle: function(elem, cache) {
        if (!cache && elem['${cloneName}'])
            return elem['${cloneName}'];
        var className, name, rstyle = /^(number|string)$/;
        var rname = /^(content|outline|outlineWidth)$/; //Opera: content; IE8:outline && outlineWidth
        var cssText = [], sStyle = elem.style;

        for (name in sStyle) {
            if (!rname.test(name)) {
                val = this._getStyle(elem, name);
                if (val !== '' && rstyle.test(typeof val)) { // Firefox 4
                    name = name.replace(/([A-Z])/g, "-$1").toLowerCase();
                    cssText.push(name);
                    cssText.push(':');
                    cssText.push(val);
                    cssText.push(';');
                }
                ;
            }
            ;
        }
        ;
        cssText = cssText.join('');
        elem['${cloneName}'] = className = 'clone' + (new Date).getTime();
        this._addHeadStyle('.' + className + '{' + cssText + '}');
        return className;
    },
    // 向页头插入样式
    _addHeadStyle: function(content) {
        var style = this._style[document];
        if (!style) {
            style = this._style[document] = document.createElement('style');
            document.getElementsByTagName('head')[0].appendChild(style);
        }
        ;
        style.styleSheet && (style.styleSheet.cssText += content) || style.appendChild(document.createTextNode(content));
    },
    _style: {},
    // 获取最终样式
    _getStyle: 'getComputedStyle' in window ? function(elem, name) {
        return getComputedStyle(elem, null)[name];
    } : function(elem, name) {
        return elem.currentStyle[name];
    },
    // 获取光标在文本框的位置
    _getFocus: function(elem) {
        var index = 0;
        if (document.selection) {// IE Support
            elem.focus();
            var Sel = document.selection.createRange();
            if (elem.nodeName === 'TEXTAREA') {//textarea
                var Sel2 = Sel.duplicate();
                Sel2.moveToElementText(elem);
                var index = -1;
                while (Sel2.inRange(Sel)) {
                    Sel2.moveStart('character');
                    index++;
                }
                ;
            }
            else if (elem.nodeName === 'INPUT') {// input
                Sel.moveStart('character', -elem.value.length);
                index = Sel.text.length;
            }
        }
        else if (elem.selectionStart || elem.selectionStart == '0') { // Firefox support
            index = elem.selectionStart;
        }
        return (index);
    },
    // 获取元素在页面中位置
    _offset: function(elem) {
        var box = elem.getBoundingClientRect(), doc = elem.ownerDocument, body = doc.body, docElem = doc.documentElement;
        var clientTop = docElem.clientTop || body.clientTop || 0, clientLeft = docElem.clientLeft || body.clientLeft || 0;
        var top = box.top + (self.pageYOffset || docElem.scrollTop) - clientTop, left = box.left + (self.pageXOffset || docElem.scrollLeft) - clientLeft;
        return {
            left: left,
            top: top,
            right: left + box.width,
            bottom: top + box.height
        };
    },
    getCurSor: function(obj) {
        var val = obj.value != undefined ? obj.value : obj.innerHTML;
        var result = 0;
        if (obj.selectionStart != undefined) {
            result = obj.selectionStart + "|" + obj.selectionEnd;
        } else {
            var rng;
            if (obj.tagName == "TEXTAREA") {
                var range = obj.ownerDocument.selection.createRange();
                var range_all = obj.ownerDocument.body.createTextRange();
                range_all.moveToElementText(obj);
                for (var start = 0; range_all.compareEndPoints("StartToStart", range) < 0; start++) {
                    range_all.moveStart('character', 1);
                }
                for (var i = 0; i <= start; i++) {
                    if (val.charAt(i) == '\n')
                        start++;
                }
                //var range_all=obj.ownerDocument.body.createTextRange();
                range_all.moveToElementText(obj);
                for (var end = 0; range_all.compareEndPoints('StartToEnd', range) < 0; end++) {
                    range_all.moveStart('character', 1);
                }
                for (var i = 0; i <= end; i++) {
                    if (val.charAt(i) == '\n')
                        end++;
                }
                return start + "|" + end;
            } else {
                rng = document.selection.createRange();
            }
            rng.moveStart("character", -val.length);
            result = rng.text.length;
            result = result + "|" + result;
        }
        return result;
    },
    moveCur: function(obj, n) {
        if (obj.selectionStart != undefined) {
            obj.selectionStart = n;
            obj.selectionEnd = n;
        } else {
            var pn = parseInt(n);
            if (isNaN(pn))
                return;
            var rng = obj.createTextRange();
            var note = 0;
            for (var i = 0; i <= pn; i++) {
                if (rng.text.charAt(i) == '\n')
                    note++;
            }
            pn -= note;
            rng.moveStart("character", pn);
            rng.collapse(true);
            rng.select();
        }
    }
};

Util.Email = {
    getSMTPByEmail: function(email) {
        var temp = email.split('@');
        var host = temp[1].toLowerCase();
        if (host == 'gmail.com') {
            return 'gmail.google.com';
        }
        return 'mail.' + host;
    }
};

Util.Clock = {
    week: ['星期天', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'],
    set_date: function(date) {
        var scope = this.scope;
        $('.clock_week', scope).text(this.week[date.getDay()]);
        $('.clock_month', scope).text(this.set_double(date.getMonth() + 1));
        $('.clock_date', scope).text(this.set_double(date.getDate()));
        $('.clock_year', scope).text(date.getFullYear());
    },
    set_time: function(date) {
        var scope = this.scope;
        this.seconds = date.getSeconds();
        this.minutes = date.getMinutes();

        $('.clock_seconds', scope).text(this.set_double(date.getSeconds()));
        $('.clock_hours', scope).text(this.set_double(date.getHours()));
        $('.clock_minutes', scope).text(this.set_double(date.getMinutes()));
    },
    set_double: function(value) {
        return (value < 10 ? "0" : "") + value;
    },
    init: function(scope) {
        var date = new Date();
        this.scope = scope;
        this.set_date(date);
        this.set_time(date);

        var ths = this;
        setInterval(function() {
            var seconds = ++ths.seconds;

            if (seconds === 60) {
                ths.seconds = seconds = 0;
                var minutes = ++ths.minutes;
                minutes = minutes === 60 ? 0 : minutes;
                $('.clock_minutes', scope).text(ths.set_double(minutes));

                if (minutes === 0) {
                    ths.minutes = 0;
                    var date = new Date();
                    var hours = date.getHours();
                    $('.clock_hours', scope).text(ths.set_double(hours));

                    if (!hours) {
                        ths.set_date(date);
                    }
                }
            }

            $('.clock_seconds', scope).text(ths.set_double(seconds));
        }, 1000);
    }
};

Util.Number = {
    bitSize: function(num) {
        if (typeof(num) != 'number') {
            num = Number(num);
        }
        if (num < 0) {
            return '';
        }
        var type = new Array('B', 'KB', 'MB', 'GB', 'TB', 'PB');
        var j = 0;
        while (num >= 1024) {
            if (j >= 5)
                return num + type[j];
            num = num / 1024;
            j++;
        }
        if (num == 0) {
            return num;
        } else {
            return Math.round(num * 100) / 100 + type[j];
        }
    }
};

//够快客户端（pc，mac客户端及企业套件）函数通用js函数
var gkClientCommon = {
    disableDefaultEvent: function() {
        $('body').on({
            dragstart: function(e) {
                e.preventDefault();
            },
            drop: function(e) {
                e.preventDefault();
            }
        });

        //处理键盘事件 禁止后退键（Backspace）密码或单行、多行文本框除外  
        var banBackSpace = function(e) {
            //console.log(1);
            var ev = e || window.event;//获取event对象     
            var obj = ev.target || ev.srcElement;//获取事件源     

            var t = obj.type || obj.getAttribute('type');//获取事件源类型    
            //console.log(t);
            //获取作为判断条件的事件类型  
            var vReadOnly = obj.getAttribute('readonly');
            var vEnabled = obj.getAttribute('enabled');
            //处理null值情况  
            vReadOnly = (vReadOnly == null) ? false : vReadOnly;
            vEnabled = (vEnabled == null) ? true : vEnabled;
            //console.log(vReadOnly);
            //console.log(ev.keyCode);
            //当敲Backspace键时，事件源类型为密码或单行、多行文本的，  
            //并且readonly属性为true或enabled属性为false的，则退格键失效  
            var flag1 = (ev.keyCode == 8 && (t == "password" || t == "text" || t == "textarea")
                    && (vReadOnly == "readonly" || vEnabled != true)) ? true : false;
            //当敲Backspace键时，事件源类型非密码或单行、多行文本的，则退格键失效  
            var flag2 = (ev.keyCode == 8 && t != "password" && t != "text" && t != "textarea")
                    ? true : false;

            //判断  
            if (flag2) {
                return false;
            }
            if (flag1) {
                return false;
            }
        };

        //禁止后退键 作用于Firefox、Opera  
        document.onkeypress = banBackSpace;
        //禁止后退键  作用于IE、Chrome  
        document.onkeydown = banBackSpace;
    }
};
