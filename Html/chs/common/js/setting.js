var gkClientSetting = {
    clientInfo:null,
    init:function(){
	//初始化版本
	$(".version").html("版本："+navigator.userAgent.substring(navigator.userAgent.indexOf(";")+1,navigator.userAgent.indexOf(";W")));
	//个人信息
		 $("#layout_member_info").tmpl(this.getComputerInfo()).appendTo($(".person_message"));	     
		  //设置配置文件位置
		  $(".file_index").find("input").val(gkClientInterface.getClientInfo().configpath);
		  //设置权限
		  var baseconfig = {},gjconfig={},clientInfo = gkClientInterface.getClientInfo(); 
		  for(var k in clientInfo){
		 
			  if(k == "auto"){
			  
			  baseconfig["auto"] = {};
			  baseconfig["auto"]["k"] = k;
			     baseconfig["auto"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 baseconfig["auto"]["name"] = "软件自动开机启动";
			  }
			  if(k == "classic"){
			  baseconfig["classic"] = {};
			  baseconfig["classic"]["k"] = k;
			     baseconfig["classic"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 baseconfig["classic"]["name"] = "任务栏图标右键菜单使用经典模式";
			  }
			    if(k == "https"){
	
				  gjconfig["https"] = {};
				  gjconfig["https"]["k"] = k;
			      gjconfig["https"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				  gjconfig["https"]["name"] = "开启HTTPS安全连接";
			  }
			    if(k == "local"){
				 gjconfig["local"] = {};
				 gjconfig["local"]["k"] = k;
			     gjconfig["local"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 gjconfig["local"]["name"] = "开启局域网内高速同步";
			  }
			  
			    if(k == "prompt"){
				baseconfig["prompt"] = {};
				 baseconfig["prompt"]["k"] = k;
			     baseconfig["prompt"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 baseconfig["prompt"]["name"] = "显示消息通知";
			  }
			    if(k == "recycle"){
				baseconfig["recycle"] = {};
				 baseconfig["recycle"]["k"] = k;
			     baseconfig["recycle"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 baseconfig["recycle"]["name"] = "同步时删除文件到系统回收站";
			  }
			    if(k == "rightmenu"){
				 baseconfig["rightmenu"] = {};
				 baseconfig["rightmenu"]["k"] = k;
			     baseconfig["rightmenu"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 baseconfig["rightmenu"]["name"] = "添加到右键快捷菜单";
			  }
			    if(k == "shelltool"){
				 baseconfig["shelltool"] = {};
				 baseconfig["shelltool"]["k"] = k;
			     baseconfig["shelltool"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 baseconfig["shelltool"]["name"] = "文件浏览窗口增加侧边栏";
			  }
			    if(k == "syncicon"){
				 baseconfig["syncicon"] = {};
				 baseconfig["syncicon"]["k"] = k;
			     baseconfig["syncicon"]["checked"] = (clientInfo[k] == 1) ? "no_check_icon" : "check_icon";
				 baseconfig["syncicon"]["name"] = "文件图标上显示同步状态";
			  }
		  }
		  $("#baseconfig").tmpl({baseconfig:baseconfig}).appendTo($("#main .basic"));
		  $("#gjconfig").tmpl({gjconfig:gjconfig}).appendTo($(".advance_qx"));
		  //点击取消选项
		    $(".opt").click(function(){
                  if($(this).find("i").attr("class") == "check_icon"){
                    $(this).find("i").removeClass("check_icon").addClass("no_check_icon");
                  }else{
                   $(this).find("i").removeClass("no_check_icon").addClass("check_icon");
                  }
                })
		  //注销登录
		  $(".edit_btn").click(function(){
		    gkClientInterface.logoOut();
		  })
		  //确定
		  $(".purple_btn").click(function(){
		    var params = {},currentLi;
			for(var i = 0,len = $(".opt").length;i<len;i++){
			   currentLi = $(".opt").eq(i);
			   if(currentLi.find("i").attr("class") == "no_check_icon"){
			       params[currentLi.data("config")] = 1;
			   }else{
			     params[currentLi.data("config")] = 0;
			   }
			}
			params["configpath"] = $(".file_index").find("input").val();
			gkClientInterface.setClientInfo(JSON.stringify(params));
		    gkClientInterface.closeWindow();
		  })
		  //取消
		  $(".cancel").click(function(){
		    gkClientInterface.closeWindow();
		  });
		  //清除缓存数据
		  $(".clearCache").click(function(){
		   if(confirm("是否清除缓存数据")){
		     gkClientInterface.clearCache();
		   }
		  })
		  //设置代理
		  $(".settingDl").click(function(){
		  
		    gkClientInterface.setConfigDl();
		  })
		  //移动
		  $(".move").click(function(){
			var d = gkClientInterface.moveFile( $(".file_index").find("input").val());	
           $(".file_index").find("input").val(d);			
			
	  })
    },
    getComputerInfo:function(){
        var clientInfo=null;
        var info = gkClientInterface.getClientInfo();
		console.log(info);
        this.clientInfo = info;
		clientInfo = {
		    photourl:gkClientInterface.getUserInfo().photourl,
            computer_name:info.computername,
            username:info.username
        };
        return clientInfo;
    },
    getFeatureSetting:function(){
        if(!this.clientInfo){
            this.clientInfo =gkClientInterface.getClientInfo();
        }
        var featureSettings = {
            auto:{
                checked:this.clientInfo.auto==1,
                name:'软件自动开机启动'
            },
            rightmenu:{
                checked:this.clientInfo.rightmenu==1,
                name:'Explorer右键菜单支持'
            },
            prompt:{
               
            }
        };
        return featureSettings;
    }
};