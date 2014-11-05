jsMD5_Typ = 'Typ32';
var gkClientLogin = {
    setHash: function(ac) {
        location.hash = '#!' + ac;
    },
    fetchHash: function() {
        var hash = location.hash, ac = hash.substr(2);
        if (!ac.length) {
            ac = 'login_p2';
        }
        gkClientLogin.showPage('#' + ac);
    },
    init: function() {
        var key = gkClientInterface.getOauthKey();

        //disable浏览器的默认事件
        gkClientCommon.disableDefaultEvent();
        $(window).on('hashchange', function() {
            gkClientLogin.fetchHash();
        });
        $('input[type="radio"]:checked').parents('.from_raw').removeClass('selected').addClass('selected');
        $('input[type="radio"]').change(function() {
            var from_raw = $(this).parents('.from_raw');
            if (this.checked) {
                from_raw.siblings('.from_raw').removeClass('selected');
                from_raw.addClass('selected');
            }
        });
        $('.from_raw').click(function() {
            var _self = $(this);
            var input_radio = $(this).find('input[type="radio"]');
            if (input_radio.size()) {
                _self.siblings('.from_raw').removeClass('selected');
                _self.addClass('selected');
                input_radio[0].checked = true;
            }
        });
        var hash = location.hash;
        var ac = hash.substr(2);

        if (!ac.length) {
            gkClientLogin.setHash('login_p2');
        } else {
            gkClientLogin.fetchHash();
        }
        //上一步
        $('.btn_prev').on('click', function() {
            history.back();
            return;
        });

        //登陆下一步
        $('#form_login_from').on('submit', function() {
            var t = $('#form_login_from input:checked').val();
            gkClientLogin.setHash(t);
            return false;
        });

        //登陆
        $('#form_login').on('submit', function() {
            var email = $.trim($(this).find('input[name="email"]').val());
            var password = $.trim($(this).find('input[name="password"]').val());
            if (!email.length) {
                alert('请输入您的够快帐号（邮箱地址）');
                return false;
            }
            if (!Util.Validation.isEmail(email)) {
                alert('请输入正确格式的邮箱地址');
                return false;
            }
            if (!password.length) {
                alert('请输入您的密码');
                return false;
            }
            var loginBtn = $(this).find('button[type="submit"]');
            var param = {
                'username': email,
                'password': MD5(password)
            };
            var spinner = new Spinner(loadingIcon).spin(loginBtn);
            loginBtn.append(spinner.el);
            loginBtn.attr('disabled', 'disabled');
            gkClientInterface.login(param);
            return false;
        });
        //企业用户登陆
        $('#ent_login_form').on('submit', function() {
            var ent_id = $.trim($(this).find('input[name="ent_id"]').val());
            if (!ent_id.length) {
                alert('请输入企业代码');
                return false;
            }
            var params = {
                url: gkClientInterface.getSiteDomain() + '/account/oauth?oauth=' + ent_id + '&key=' + key + '&gk=1',
                width: 500,
                height: 485,
                resize: 0,
                sso: 0
            };
            gkClientInterface.openWindow(params);
            return false;
        });


        //注册帐号
        $('.go2regist').on('click', function() {
            gkClientLogin.setHash('login_p9');
        });

        //找回密码
        $('#btn_findpassword').on('click', function() {
            var param = {
                url: 'www.gokuai.com/findpassword',
                sso: 0
            };
            gkClientInterface.openURL(param);
            return;
        });

        //网络设置
        $('.network_settings').on('click', function() {

            gkClientInterface.settings();
            return;
        });

        //使用第三方帐号
        $('#oauth_login_form .btn').on('click', function() {
            var oauth = $(this).attr('name');
            var oauthURL = gkClientInterface.getSiteDomain() + '/account/oauth?oauth=' + oauth + '&key=' + gkClientInterface.getOauthKey();
            gkClientInterface.openWindow({
                url: oauthURL,
                sso: 0,
                resize: 1,
                width: 700,
                height: 500
            });
            return false;
        });

        //注册
        $('.login_page #regist_form').on('submit', function() {
            var email = $.trim($(this).find('input[name="email"]').val());
            var password = $.trim($(this).find('input[name="password"]').val());
            var repassword = $.trim($(this).find('input[name="repassword"]').val());
            var agreement = $(this).find('input[name="agreement"]:checked').size();
            var verify_code_input = $(this).find('input[name="verify_code"]');
            var verify_code = verify_code_input.size() ? $.trim(verify_code_input.val()) : '';
            if (!email.length) {
                alert('请输入您的邮箱地址');
                return false;
            }
            if (!Util.Validation.isEmail(email)) {
                alert('请输入正确格式的邮箱地址');
                return false;
            }
            if (!password.length) {
                alert('请输入您的密码');
                return false;
            }
            if (password.length < 6) {
                alert('密码长度不能少于6个字符');
                return false;
            }
            if (!repassword.length) {
                alert('请确认您的密码');
                return false;
            }
            if (password !== repassword) {
                alert('两次输入的密码不一致');
                return false;
            }
            if (verify_code_input.size() && verify_code_input.is(':visible')) {
                if (!verify_code.length) {
                    alert('请输入验证码');
                    return false;
                }
            }
            var registBtn = $('#regist_form button[type="submit"]');
            var spinner = new Spinner(loadingIcon).spin(registBtn);
            registBtn.append(spinner.el);
            registBtn.attr('disabled', 'disabled');
            $.ajax({
                url: gkClientInterface.getSiteDomain() + '/regist/member',
                data: {
                    email: email,
                    password: password,
                    repassword: repassword,
                    user_license_chk: agreement,
                    verify_code: verify_code
                },
                dataType: 'json',
                type: 'POST',
                success: function() {
                    var param = {
                        username: email,
                        password: MD5(password)
                    };
                    gkClientInterface.login(param);
                    registBtn.find('.spinner').remove();
                    registBtn.removeAttr('disabled');
                },
                error: function(request, textStatus, errorThrown) {
                    var errorMsg = gkClientAjax.Exception.getErrorMsg(request, textStatus, errorThrown);
                    registBtn.removeAttr('disabled');
                    registBtn.find('.spinner').remove();
                    alert(errorMsg);
                }
            });
            return false;
        });

        //是否使用上一步同步设置
        $('#login_p13 form').on('submit', function() {
            var val = $(this).find('input[name="use_old_settings"]:checked').val();
            if (val == 1) {//使用上一次的同步设置
                var param = {
                    path: 0
                };
                gkClientInterface.finishSettings(param);
            } else {//不使用上一次的同步设置
                if ($("#login_p3 .btn_prev")) {
                    $('#login_p3 .btn_prev').remove();
                }
                var prev = $("<button type='button' class='btn_prev'>上一步</button>");
                prev.on('click', function() {
                    history.back();
                    return;
                });
                $('#login_p3 form .right').prepend(prev);

                gkClientLogin.setHash('login_p3');
            }
            return false;
        });
        $('#login_p13 form').on('click', function() {
            var val = $(this).find('input[name="use_old_settings"]:checked').val();
            if (val == 1) {
                $(this).find(':button').html('完成');
            }
            else {
                $(this).find(':button').html('下一步');
            }
        });

        //同步设置
        $('#login_p3 form').on('submit', function() {
            var _self = $(this);
            var gkSettingsType = $(this).find('input[name="chose_settings"]:checked').val();
            if (gkSettingsType == 1) {//非默认设置
                gkClientLogin.setHash('login_p11');
            } else {//默认设置z
                var defaultPath = gkClientInterface.getNormalPath();
                var isEmpty = gkClientInterface.checkIsEmptyPath(defaultPath);
                if (!parseInt(isEmpty)) {
                    var content = '<div>您选择的目录[' + defaultPath + ']含有文件，会引起本地覆盖服务器端或服务端覆盖本地文件，请选择？</div>';

                    gkClientModal.show({
                        title: '请选择',
                        content: content,
                        buttons: [
                            {
                                text: '重新选择',
                                click: function() {
                                    gkClientModal.close();
                                }
                            },
                            {
                                text: '本地覆盖服务器端',
                                click: function() {
                                    var overWriteInput = $('input[name="over_write"]');
                                    overWriteInput.val(0);
                                    gkClientModal.close();
                                    var param = {
                                        path: 1,
                                        overwrite: 0
                                    };
                                    gkClientInterface.finishSettings(param);
                                }
                            },
                            {
                                text: '服务器端覆盖本地',
                                click: function() {
                                    var overWriteInput = $('input[name="over_write"]');
                                    overWriteInput.val(1);
                                    gkClientModal.close();
                                    var param = {
                                        path: 1,
                                        overwrite: 1
                                    };
                                    gkClientInterface.finishSettings(param);
                                }
                            }
                        ]
                    });
                } else {
                    var param = {
                        path: 1
                    };
                    gkClientInterface.finishSettings(param);
                }

            }
            return false
        });
        $('#login_p3 form').on('click', function() {
            var val = $(this).find('input[name="chose_settings"]:checked').val();
            if (val == 1) {
                $(this).find('.btn_next').html('下一步');
            }
            else {
                $(this).find('.btn_next').html('完成');
            }
        });


        //选择同步目录
        $('#select_gk_sync_dir').on('click', function(e) {
            var path = gkClientInterface.getBindPath();
            if (path.length) {
                $('#gk_sync_dir').val(path).attr('title', path);
            }
            e.preventDefault();
        });

        //选择同步目录后
        $('#login_p11 form').on('submit', function() {
            var sync_dir = $(this).find('input[name="sync_dir"]:checked').val();
            var path = gkClientInterface.getNormalPath();
            if (sync_dir == 1) {
                path = $(this).find('input[name="gk_sync_dir"]').val();
            }

            var isEmpty = gkClientInterface.checkIsEmptyPath(path);
            if (!parseInt(isEmpty)) {
                var content = '<div>您选择的目录[' + path + ']含有文件，会引起本地覆盖服务器端或服务端覆盖本地文件，请选择？</div>';

                gkClientModal.show({
                    title: '请选择',
                    content: content,
                    buttons: [
                        {
                            text: '重新选择',
                            click: function() {
                                gkClientModal.close();
                            }
                        },
                        {
                            text: '本地覆盖服务器端',
                            click: function() {
                                var overWriteInput = $('input[name="over_write"]');
                                overWriteInput.val(0);
                                gkClientModal.close();
                                gkClientLogin.setHash('login_p12');
                            }
                        },
                        {
                            text: '服务器端覆盖本地',
                            click: function() {
                                var overWriteInput = $('input[name="over_write"]');
                                overWriteInput.val(1);
                                gkClientModal.close();
                                gkClientLogin.setHash('login_p12');
                            }
                        }
                    ]
                });
            } else {
                gkClientLogin.setHash('login_p12');
            }

            return false
        });

        //选择性同步
        $('#select_sync_dirs').on('click', function(e) {
            gkClientInterface.selectSyncFile();
            e.preventDefault();
        });

        //选择性同步下一步
        $('#login_p12 form').on('submit', function() {
            var path = 1, syncnode = 0;
            var sync_dir = $('input[name="sync_dir"]:checked').val();
            var chose_dir = $('input[name="chose_dir"]:checked').val();
            var overwrite = $('input[name="over_write"]').val();
            if (sync_dir == 1) {
                path = 2;
            }
            if (chose_dir == 1) {
                syncnode = 1;
            }
            var param = {
                path: path,
                syncnode: syncnode
            };
            if (overwrite.length) {
                param.overwrite = parseInt(overwrite);
            }
            //console.log(param);
            gkClientInterface.finishSettings(param);
            return false;
        });

        var qrImg = $('<img class="qrcode" alt="您的网络似乎有问题，请检查您的网络连接。" src="' + gkClientInterface.getSiteDomain() + '/account/get_login_qr?key=' + key + '&client=1" />');
        if ($('.slide_banner .qr_img').size()) {
            $('.slide_banner .qr_img').prepend(qrImg);
        }
        //幻灯片运行
        gkClientLogin.bindUI();
        //检测二维码登录 
        var checkLogin = function(key) {
            $.ajax({
                url: gkClientInterface.getSiteDomain() + '/account/check_client_qr_login',
                dataType: 'json',
                type: 'post',
                data: {
                    key: key,
                    client: 1
                },
                success: function(logined) {
                    if (logined == 1) {
                        gkClientInterface.loginByKey();
                    }
                },
                error: function() {

                }
            });
        };

//        var loginCheckTimer = setInterval(function() {
//            if (location.hash == '#!login_p2') {
//                checkLogin(key);
//            }
//        }, 5000);
        //checkLogin(key);

        //载入时菊花的参数设置
        var loadingIcon = {
            lines: 9, // The number of lines to draw
            length: 4, // The length of each line
            width: 2, // The line thickness
            radius: 3, // The radius of the inner circle
            corners: 1, // Corner roundness (0..1)
            rotate: 0, // The rotation offset
            color: '#FFF', // #rgb or #rrggbb
            speed: 1, // Rounds per second
            trail: 60, // Afterglow percentage
            shadow: false, // Whether to render a shadow
            hwaccel: false, // Whether to use hardware acceleration
            className: 'spinner', // The CSS class to assign to the spinner
            zIndex: 2e9, // The z-index (defaults to 2000000000)
            top: 'auto', // Top position relative to parent in px
            left: 'auto' // Left position relative to parent in px
        };

    },
    //绑定UI事件
    bindUI: function() {
        var banner = $('.slide_banner');
        if (!banner.size()) {
            return;
        }

        //幻灯片实例化
        banner.xslider({
            timeout: 5000,
            effect: 'fade',
            speed: 500,
            navigation: true,
            pauseOnHover: true
        });

        //slide效果
        var flag = false;
        var slide = function(scope) {
            $('h1', scope).on('click', function() {
                if (!$('i', $(this)).hasClass('fold')) {
                    return;
                }
                $(this).parent().siblings().find('.content').slideUp('fast', function() {
                    $('i', $(this).prev()).addClass('fold');
                    if ($(this).hasClass('qr_login') && flag) {
                        banner.xslider('stop');
                        banner.xslider('play');
                        flag = false;
                    }
                });
                $(this).next('.content').slideDown('fast', function() {
                    $('i', $(this).prev()).removeClass('fold');
                    if ($(this).hasClass('qr_login')) {
                        banner.xslider('goto', 3);
                        banner.xslider('stop');
                        flag = true;
                    }
                });
            });
        };
        slide($('#login_p2'));
    },
    showPage: function(target) {
        $('.login_page').hide().eq(target).show();
        $('.login_page').filter(target).show();
        if (target == '#login_p11') {
            var defaultPath = gkClientInterface.getNormalPath();
            $('#default_gk_sync_dir').text(defaultPath);
            $('#gk_sync_dir').val(defaultPath).attr('title', defaultPath);
        }
    },
    showClientGuild: function(step) {
        var steps = $('.client_guild');
        steps.eq(step).show();
        gkClientInterface.toogleArrow(0);
        if (step == 3) {
            gkClientInterface.toogleArrow(1);
        }
    },
    choseSyncType: function() {

    }
};

var gkClientModal = {
    show: function(params) {
        var _self = this;
        var settings = params;
        var overlay = $('<div class="overlay"></div>');
        var modal = $('<div class="modal"></div>');
        var content = $('<div class="modal_content"></div>');
        var close = $('<a href="javascript:void(0)" class="modal_close"></a>');
        content.append(settings.content);
        modal.append(content).append(close);
        $('body').append(overlay).append(modal);
        if (!settings.height) {
            settings.height = 200;
        }
        if (!settings.width) {
            settings.width = 400;
        }
        modal.css({
            'top': '50%',
            'left': '50%',
            'width': settings.width,
            'height': settings.height,
            'margin-top': settings.height * -0.5,
            'margin-left': settings.width * -0.5
        });
        if (settings.title && settings.title.length) {
            var top = $('<div class="modal_top">' + settings.title + '</div>');
            modal.prepend(top);
        }
        if (settings.buttons.length) {
            var bottom = $('<div class="modal_bottom"></div>');
            modal.append(bottom);
            $.each(settings.buttons, function(i, n) {
                var button = $('<button type="button">' + n.text + '</button>');
                bottom.append(button);
                button.click(function() {
                    n.click();
                });
            });
        }
        close.on('click', function() {
            _self.close();
            return;
        });
    },
    close: function() {
        $('body > .overlay').remove();
        $('body > .modal').remove();
    }
};

/*登录后客户端的回调函数*/
function gLoginResult(data) {
    var loginBtn = $('#form_login button[type="submit"]');
    loginBtn.removeAttr('disabled');
    loginBtn.find('.spinner').remove();
    if (!data) {
        gkClientInterface.showError('无数据返回');
        return;
    }
    var rep = JSON.parse(data);
    if (!rep) {
        gkClientInterface.showError('无效的数据格式');
        return;
    }
    if (rep.error != 0) {
        gkClientInterface.showError(rep.message);
        //第三方登录失败
        if (rep.type == "weblogin") {
            gkClientLogin.setHash('login_p2');
        } else {
            gkClientLogin.setHash('login_p2');
        }
        return;
    }

    if (gkClientInterface.checkLastPath()) {
        gkClientLogin.setHash('login_p13');
    } else {
        gkClientLogin.setHash('login_p3');
    }
}