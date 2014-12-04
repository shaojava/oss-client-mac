#import "AppDelegate.h"
#import "Util.h"
#import "JSONKit.h"
#import "NSStringExpand.h"
#import "Common.h"
#import "NSAlert+Blocks.h"
#import "AboutWindowController.h"
#import "NSDataExpand.h"
#import "SettingsDb.h"
#import "LoginWebWindowController.h"
#import "LaunchpadWindowController.h"
#import "AboutWindowController.h"
#import "MyTimer.h"
#import "BrowserWebWindowController.h"
#import "MoveAndPasteWindowController.h"
#import "GKWebViewDelegate.h"
#import "BrowserWebWindowController.h"
#import "ProgressWindowController.h"

#import "OSSRsa.h"

#import "ASIHTTPRequest.h"
#import "GKHTTPRequest.h"

@implementation AppDelegate

@synthesize strUIPath;
@synthesize strAccessID;
@synthesize strAccessKey;
@synthesize strArea;
@synthesize strHost;
@synthesize strTransCachePath;
@synthesize strUserDB;
@synthesize strTransDB;
@synthesize strLogPath;
@synthesize strConfig;

@synthesize appversion;
@synthesize serversion;
@synthesize taskqueue;
@synthesize _downloadtask;
@synthesize bIsUpdate;

@synthesize bHttps;
@synthesize bLogin;
@synthesize bShowPassword;
@synthesize bDebugMenu;
@synthesize bFinishCallback;

@synthesize loginWebWindowController;
@synthesize launchpadWindowController;
@synthesize moveAndPasteWindowController;
@synthesize browserWindowControllers;
@synthesize progressWindowControllers;
@synthesize appUpdateWindowController;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSWindowWillCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"gMain" object:nil];
    
    [mytimer release];
    
    
    [taskqueue release];
    [appversion release];
    
    if (launchpadWindowController != nil)
        [launchpadWindowController release];
    if (aboutWindowController != nil)
        [aboutWindowController release];
    if (loginWebWindowController) {
        [loginWebWindowController release];
    }
    if (appUpdateWindowController!=nil) 
        [appUpdateWindowController release];
    [super dealloc];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[ASIHTTPRequest sharedQueue] setMaxConcurrentOperationCount:100];
    self.strAccessID=@"";
    self.strAccessKey=@"";
    self.strArea=@"";
    self.strHost=@"";
    self.serversion=@"0.0.0.0";
    [self setMainMenu];
    self.bDebugMenu=NO;
    self.bFinishCallback=NO;
    self._downloadtask=nil;
    self.bIsUpdate=NO;
    self.strUIPath=[NSString stringWithFormat:@"%@/UI",[[NSBundle mainBundle] bundlePath]];
    NSString* debugpath =[NSString stringWithFormat:@"%@/debug.txt",[[NSBundle mainBundle] bundlePath]];
    if ([Util existfile:debugpath]) {
        self.bDebugMenu=YES;
        NSFileHandle* filehandle=[NSFileHandle fileHandleForUpdatingAtPath:debugpath];
        if (filehandle) {
            NSData * filedata=[filehandle readDataToEndOfFile];
            NSDictionary* dictionary=[filedata objectFromJSONData];
            if ([dictionary isKindOfClass:[NSDictionary class]]){
                NSString* uipathtmp=[dictionary objectForKey:@"uipath"];
                if (uipathtmp.length) {
                    self.strUIPath=uipathtmp;
                }
            }
        }
    }
    self.strTransCachePath=[NSString stringWithFormat:@"%@/.oss/transcache",NSHomeDirectory()];
    [Util createfolder:self.strTransCachePath];
    self.strUserDB=[NSString stringWithFormat:@"%@/.oss/user/ossuser.db",NSHomeDirectory()];
    [Util createfolder:[self.strUserDB stringByDeletingLastPathComponent]];
    self.strLogPath=[NSString stringWithFormat:@"%@/.oss/log",NSHomeDirectory()];
    [Util createfolder:self.strLogPath];
    self.browserWindowControllers=[NSMutableArray array];
    self.progressWindowControllers=[NSMutableDictionary dictionary];
    self.appversion=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
 //   int cacheSizeMemory = 4*1024*1024; // 4MB
 //   int cacheSizeDisk = 32*1024*1024; // 32MB
 //   NSURLCache *sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:[UserData shareUserData].configPath] autorelease];
 //   [NSURLCache setSharedURLCache:sharedCache];
    taskqueue=[[NSOperationQueue alloc] init];
    GetUpdateXML *task=[[GetUpdateXML alloc]init:YES];
    [taskqueue addOperation:task];
    [task release];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowClosed:) name:NSWindowWillCloseNotification object:nil];
    self.bHttps = [[SettingsDb shareSettingDb] gethttps];
    UserInfo * userinfo=[[SettingsDb shareSettingDb] getuserinfo];
    if (userinfo.strAccessID.length) {
        self.bShowPassword=YES;
    }
    else {
        self.bShowPassword=NO;
    }
    [self getLoginWebWindowController];
//    [self OpenLaunchpadWindow];
    
    mytimer=[[MyTimer alloc]init];
}

#pragma mark-
#pragma mark  Window Init

-(void)getLoginWebWindowController
{
    if (nil==loginWebWindowController) {
        loginWebWindowController = [[LoginWebWindowController alloc]initWithWindowNibName:@"LoginWebWindowController"];
        [launchpadWindowController adjustposition];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [loginWebWindowController showWindow:self];
    [loginWebWindowController becomeFirstResponder];
/*
    [NSApp activateIgnoringOtherApps:YES];
    [loginWebWindowController becomeFirstResponder];
    [loginWebWindowController.window becomeKeyWindow];
    [loginWebWindowController.window setFrameTopLeftPoint:[Util getWindowDisplayOriginPoint:loginWebWindowController.window.frame.size]];
   [loginWebWindowController showWindow:self];*/
}

-(void) setLoginWebWindowController
{
    loginWebWindowController=nil;
}

-(BrowserWebWindowController*) getBrowserWebWindowController:(NSString*)solestr
{
    BrowserWebWindowController* retBrowserController=nil;
    for (BrowserWebWindowController* browserController in browserWindowControllers) {
        if ([solestr isEqualToString:browserController.solestr]) {
            retBrowserController=browserController;
            break;
        }
    }
    
    if (nil==retBrowserController) {
        retBrowserController=[[BrowserWebWindowController alloc]initWithWindowNibName:@"BrowserWebWindowController"];
        [browserWindowControllers addObject:retBrowserController];
    }
    
//    [NSApp activateIgnoringOtherApps:YES];
//    [retBrowserController becomeFirstResponder];
//    [retBrowserController showWindow:self];
    
    return retBrowserController;
}

-(MoveAndPasteWindowController*) getMoveAndPasteWindowController
{
    if (nil==moveAndPasteWindowController) {
        moveAndPasteWindowController=[[MoveAndPasteWindowController alloc]initWithWindowNibName:@"MoveAndPasteWindowController"];
    }
    
    return moveAndPasteWindowController;
}

-(void)onStart
{
    if (loginWebWindowController != nil) {
        [loginWebWindowController.window orderOut:nil];
    }
}

#pragma mark-
#pragma mark  OtherLogin View Event

-(void)onOpenMainThreadWebWindowResult:(NSArray*)arrInfo
{
    [self getLoginWebWindowController];
}


//关闭更新窗口通知事件
- (void)_windowClosed:(NSNotification *)note
{
    NSWindow* window=(NSWindow*)[note object];
    
    if (window==loginWebWindowController.window) {
        //[loginWebWindowController release];
        //loginWebWindowController = nil;
    }
    else if(window==launchpadWindowController.window) {
//        launchpadWindowController.delegate._bWindowsCloes=YES;
//        [launchpadWindowController release];
//        launchpadWindowController = nil;
    }
    else if(window==aboutWindowController.window) {
        [aboutWindowController release];
        aboutWindowController = nil;
    }
    else if([window.windowController isKindOfClass:[BrowserWebWindowController class]]) {
        for (int i=0;i<browserWindowControllers.count;i++) {
            BrowserWebWindowController* browserController=[browserWindowControllers objectAtIndex:i];
            if (window==browserController.window) {
                [browserWindowControllers removeObject:browserController];
                break;
            }
        }
        
    }
    else {}
}

-(void)OpenLaunchpadWindow
{
    if (launchpadWindowController == nil) {
        launchpadWindowController =[[LaunchpadWindowController alloc]initWithWindowNibName:@"LaunchpadWindowController"];
        [launchpadWindowController adjustposition];
    }

    [NSApp activateIgnoringOtherApps:YES];
    [launchpadWindowController showWindow:self];
    [launchpadWindowController becomeFirstResponder];
}

-(IBAction)onMenuQuitAppClicked:(id)sender
{
    NSString *msg=[Util localizedStringForKey:@"是否确定退出?" alternate:nil];
    NSInteger ret=[NSAlert showGKSheetModalForWindow:nil
                                             message:msg
                                                text:@""
                                        buttonTitles:[NSArray arrayWithObjects:
                                                      [Util localizedStringForKey:@"确定" alternate:nil],
                                                      [Util localizedStringForKey:@"取消" alternate:nil],nil]];
    if (NSAlertFirstButtonReturn == ret) {
        [NSApp terminate:sender];
    }
}

-(void) setMainMenu
{
    NSMenu* mainMenu = [NSApp mainMenu];
    
    NSMenuItem* itemGK = [mainMenu addItemWithTitle:@"" action:nil keyEquivalent:@""];
    
    NSMenu *subMenu =[[NSMenu alloc]initWithTitle:[Util localizedStringForKey:@"" alternate:nil]];
    
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"隐藏 OSS" alternate:nil] action:@selector(hide:) keyEquivalent:@"h"];
    [[subMenu addItemWithTitle:[Util localizedStringForKey:@"隐藏 其他" alternate:nil] action:@selector(hideOtherApplications:) keyEquivalent:@"h"] setKeyEquivalentModifierMask:NSCommandKeyMask|NSAlternateKeyMask];
    [subMenu addItem:[NSMenuItem separatorItem]];
    
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"退出OSS" alternate:nil] action:@selector(onMenuQuitAppClicked:) keyEquivalent:@"q"];
    
    [itemGK setSubmenu:subMenu];
    [subMenu release];
    
    NSMenuItem* itemEt = [mainMenu addItemWithTitle:@"" action:nil keyEquivalent:@""];
    subMenu  =[[NSMenu alloc]initWithTitle:[Util localizedStringForKey:@"编辑" alternate:nil]];
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"剪切" alternate:nil] action:@selector(cut:) keyEquivalent:@"x"];
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"复制" alternate:nil] action:@selector(copy:) keyEquivalent:@"c"];
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"粘贴" alternate:nil] action:@selector(paste:) keyEquivalent:@"v"];
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"全选" alternate:nil] action:@selector(selectAll:) keyEquivalent:@"a"];
    
    [itemEt setSubmenu:subMenu];
    [subMenu release];
    
    NSMenuItem* itemWd = [mainMenu addItemWithTitle:@"" action:nil keyEquivalent:@""];
    subMenu =[[NSMenu alloc]initWithTitle:[Util localizedStringForKey:@"窗口" alternate:nil]];
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"关闭" alternate:nil] action:@selector(performClose:) keyEquivalent:@"w"];
    [subMenu addItemWithTitle:[Util localizedStringForKey:@"最小化" alternate:nil] action:@selector(performMiniaturize:) keyEquivalent:@"m"];
    [itemWd setSubmenu:subMenu];
    [subMenu release];
    [NSApp setWindowsMenu: [itemWd submenu]];
}

-(void)startCopy:(OperPackage*)item
{
    ProgressWindowController* progressWindowController=[[ProgressWindowController alloc] initWithWindowNibName:@"ProgressWindowController"];
    [progressWindowController setprogresstype:item type:pc_copy];
    [progressWindowController displayex];
}

-(void)startDelete:(OperPackage*)item
{
    ProgressWindowController* progressWindowController=[[ProgressWindowController alloc] initWithWindowNibName:@"ProgressWindowController"];
    [progressWindowController setprogresstype:item type:pc_delete];
    [progressWindowController displayex];
}

-(void)startDeleteBucket:(OperPackage*)item
{
    ProgressWindowController* progressWindowController=[[ProgressWindowController alloc] initWithWindowNibName:@"ProgressWindowController"];
    [progressWindowController setprogresstype:item type:pc_bucket];
    [progressWindowController displayex];
}

-(void)showupdate
{
    if (self.bIsUpdate) {
        return;
    }
    self.bIsUpdate=YES;
    NSString* message=[NSString stringWithFormat:@"软件最新版本已经更新到[%@]版本，是否立即更新?",[Util getAppDelegate].serversion];
    NSAlert* alert=[NSAlert alertWithMessageText:message defaultButton:@"是" alternateButton:@"否"otherButton:nil informativeTextWithFormat:@""];
    if ([alert runModal]==NSAlertDefaultReturn) {
        if (!self._downloadtask) {
            NSString* strUrl;
            if ([Util getAppDelegate].bHttps)
            {
                strUrl =[NSString stringWithFormat:
                         @"https://client.gokuai.com/interface/check_version?n=mac&v=%@",
                         [Util getAppDelegate].appversion];
            }
            else
            {
                strUrl =[NSString stringWithFormat:
                         @"http://client.gokuai.com/interface/check_version?n=mac&v=%@",
                         [Util getAppDelegate].appversion];;
            }
            GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl method:@"GET" header:nil bodyData:nil] autorelease];
            NSHTTPURLResponse* response;
            NSData* jsonData = [request connectNetSyncWithResponse:&response error:nil];
            if (jsonData!=nil) {
                NSString *jsonInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSDictionary* dictionary=[jsonInfo objectFromJSONString];
                if ([dictionary isKindOfClass:[NSDictionary class]]) {
                    NSString * downloadurl=[dictionary objectForKey:@"path"];
                    NSInteger filesize=[[dictionary objectForKey:@"size"] intValue];
                    NSString * path=[NSString stringWithFormat:@"%@/ossupdate.dmg",NSTemporaryDirectory()];
                    self._downloadtask=[[[DownloadDmgTask alloc]init:downloadurl savepath:path size:filesize]autorelease];
                    [taskqueue addOperation:self._downloadtask];
                    if (appUpdateWindowController == nil) {
                        appUpdateWindowController = [[AppUpdateWindowController alloc]initWithWindowNibName:@"AppUpdateWindowController"];
                    }
                    [appUpdateWindowController showWindow:self];
                    appUpdateWindowController.serVersion = self.serversion;
                    appUpdateWindowController.appVersion = self.appversion;
                }
            }
        }
    }
    self.bIsUpdate=NO;
}

-(void)openUpdateDmg
{
    NSString* message=[NSString stringWithFormat:@"软件已经升级到最新的[%@]版本，立即安装？",[Util getAppDelegate].serversion];
    NSAlert* alert=[NSAlert alertWithMessageText:message defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    if ([alert runModal]==NSAlertDefaultReturn) {
        NSString * path=[NSString stringWithFormat:@"%@/ossupdate.dmg",NSTemporaryDirectory()];
        NSTask *  theProcess = [[[NSTask alloc] init] autorelease];
        [theProcess setLaunchPath:@"/usr/bin/open"];
        [theProcess setArguments:[NSArray arrayWithObject:path]];
        [theProcess launch];
        [NSApp terminate:nil];
    }
}

@end
