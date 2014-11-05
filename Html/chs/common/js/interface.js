var gkClientFileState = {
    DEFAULT_STATE: 0,
    NORMAL_STATE: 1,
    FINISH_STATE: 2,
    LOCK_STATE: 3,
    LOCAL_STATE: 4,
    EDIT_STATE: 5
};

var gkClientInterface = {
 /*注销登录*/
    logoOut:function(){
	  gkClient.gLogoff();
	},
//设置客户端消息
    setClientInfo:function(params){
	    gkClient.gSetClientInfo(params);
	},
   //清除缓存
    clearCache:function(){
	   gkClient.gClearCache();
	},
	//设置代理
	setConfigDl:function(){
	  gkClient.gSettings();
	},
	//移动文件
	moveFile:function(path){
	   return gkClient.gSelectPath(path);
	},
    getClientInfo:function(){
        try {
            return JSON.parse(gkClient.gGetClientInfo());
        } catch (e) {
            throw e;
        }

    },
    setFileStatus: function(path, dir, state) {
        var params = JSON.stringify({
            webpath: path,
            status: state,
            dir: dir
        });
        gkClient.gSetFileStatus(params);
    },
    closeWindow: function() {
        try {
            gkClient.gClose();
        } catch (e) {
            throw e;
        }
    },
    login: function(param) {
        try {
            param = JSON.stringify(param);
            gkClient.gLogin(param);
        } catch (e) {
            throw e;
        }
    },
    loginByKey: function() {
        try {
            gkClient.gLoginByKey();
        } catch (e) {
            throw e;
        }
    },
    openURL: function(param) {
        try {
            if (!param.sso && param.url && /^(http:\/\/|https:\/\/).+/.test(param.url)) {
                param.url = param.url.replace(/^http:\/\/|^https:\/\//, '');
            }
            param = JSON.stringify(param);
            gkClient.gOpenUrl(param);
        } catch (e) {
            throw e;
        }
    },
    settings: function() {
        try {
            gkClient.gSettings();
        } catch (e) {
            throw e;
        }
    },
    checkLastPath: function() {
        try {
            return gkClient.gCheckLastPath();
        } catch (e) {
            throw e;
        }
    },
    checkIsEmptyPath: function(path) {
        try {
            return gkClient.gCheckEmpty(path);
        } catch (e) {
            throw e;
        }
    },
    showError: function(errorMsg, errorCode) {
        if (!errorMsg.length) {
            return;
        }
        alert(errorMsg);
    },
    finishSettings: function(param) {
        try {
            param = JSON.stringify(param);
            gkClient.gStart(param);
        } catch (e) {
            throw e;
        }
    },
    toogleArrow: function(state) {
        try {
            state = JSON.stringify(state);
            gkClient.gShowArrow(state);
        } catch (e) {
            throw e;
        }

    },
    setMenus: function(menus) {
        try {
            menus = JSON.stringify(menus);
            gkClient.gSetMenu(menus);
        } catch (e) {
            throw e;
        }
    },
    getNormalPath: function() {
        try {
            return gkClient.gNormalPath();
        } catch (e) {
            throw e;
        }
    },
    getBindPath: function() {
        try {
            return gkClient.gBindPath();
        } catch (e) {
            throw e;
        }
    },
    getSelectPaths: function() {
        try {
            return gkClient.gSelectSyncPath();
        } catch (e) {
            throw e;
        }
    },
    openWindow: function(params) {
        try {
            if (!params.sso && params.url && /^(http:\/\/|https:\/\/).+/.test(params.url)) {
                params.url = params.url.replace(/^http:\/\/|^https:\/\//, '');
            }
            params = JSON.stringify(params);
            gkClient.gMain(params);
        } catch (e) {
            throw e;
        }
    },
    openSingleWindow: function(params) {
        try {
            params = JSON.stringify(params);
            gkClient.gSoleMain(params);
        } catch (e) {
            throw e;
        }
    },
    openSyncDir: function(path) {
        try {
            if (path !== undefined) {
                gkClient.gOpenPath(path);
            } else {
                gkClient.gOpenPath();
            }
        } catch (e) {
            throw e;
        }
    },
    openPathWithSelect: function(path) {
        try {
            if (!path && !path.length) {
                return;
            }
            gkClient.gOpenPathWithSelect(path);
        } catch (e) {
            throw e;
        }
    },
    selectSyncFile: function() {
        try {
            gkClient.gSelectSyncPath();
        } catch (e) {
            throw e;
        }
    },
    getUserInfo: function() {
        try {
            return JSON.parse(gkClient.gUserInfo());
        } catch (e) {
            throw e;
        }
    },
    toggleLock: function(path) {
        try {
            if (!path.length) {
                return;
            }
            gkClient.gLock(path);
        } catch (e) {
            throw e;
        }
    },
    add2Favorite: function(path) {
        try {
            if (!path.length) {
                return;
            }
            gkClient.gFavorite(path);
        } catch (e) {
            throw e;
        }
    },
    launchpad: function() {
        try {
            gkClient.gLaunchpad();
        } catch (e) {
            throw e;
        }
    },
    getOauthKey: function() {
        try {
            return gkClient.gOAuthKey();
        } catch (e) {
            throw e;
        }
    },
    compareVersion: function(params) {
        params = JSON.stringify(params);
        gkClient.gCompare(params);
    },
    getMessage: function() {
        return JSON.parse(gkClient.gGetMessage());
    },
    clearUpdateCount: function() {
        gkClient.gClearUpdateCount();
    },
    getSiteDomain: function() {
        return gkClient.gSiteDomain();
    },
    setClipboardData: function(text) {
        gkClient.gSetClipboardData(text);
    }
};
var gkClientAjax = {};
gkClientAjax.Exception = {
    getErrorMsg: function(request, textStatus, errorThrown) {
        var errorMsg = '';
        if (request.responseText) {
            var result = $.parseJSON(request.responseText);
            errorMsg = result.error_msg ? result.error_msg : request.responseText;
        } else {
            switch (request.status) {
                case 0:
                    errorMsg = '';
                    break;
                case 401:
                    errorMsg = L('ERROR_MSG_401');
                    break;
                case 501:
                case 502:
                    errorMsg = L('ERROR_MSG_502');
                    break;
                case 503:
                    errorMsg = L('ERROR_MSG_503');
                    break;
                case 504:
                    errorMsg = L('ERROR_MSG_504');
                    break;
                default:
                    errorMsg = request.status + ':' + request.statusText;
                    break;
            }
        }
        return errorMsg;
    }
};

function initWebHref() {
    $('body').on('click', 'a', function(e) {
        var href = $(this).attr('href');
        if (/\/storage#!files:(0|1):(.*?)(:(.*):.*)??$/.test(href)) {
            if (!RegExp.$2 && !RegExp.$2.length && !RegExp.$4 && !RegExp.$4.length) {
                gkClientInterface.openSyncDir();
            } else {
                var dir = 0, path = '', uppath = '', file = '';
                if (RegExp.$2 && RegExp.$2.length) {
                    uppath = decodeURIComponent(RegExp.$2);
                }
                if (RegExp.$4 && RegExp.$4.length) {
                    file = decodeURIComponent(RegExp.$4);
                    if (Util.String.lastChar(file) === '/') {
                        dir = 1;
                    }
                    file = Util.String.rtrim(file, '/');
                } else {
                    dir = 1;
                }
                path = (uppath.length ? uppath + '/' : '') + file;
                if (dir) {
                    gkClientInterface.openSyncDir(path + '/');
                } else {
                    gkClientInterface.openPathWithSelect(path);
                }
            }
            return false;
        } else if ($.trim(href) != '' && $.trim(href).indexOf('#') != 0 && !/^javascript:.*?$/.test(href)) {
            var param = {
                url: href,
                sso: 0
            };
            if (parseInt(PAGE_CONFIG.memberId)) {
                param.sso = 1;
            }
            gkClientInterface.openURL(param);
            return false;
        }
    });
};