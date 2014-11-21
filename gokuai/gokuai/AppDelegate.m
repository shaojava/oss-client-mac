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

@synthesize bHttps;
@synthesize bLogin;
@synthesize bShowPassword;
@synthesize bDebugMenu;

@synthesize loginWebWindowController;
@synthesize launchpadWindowController;
@synthesize moveAndPasteWindowController;
@synthesize browserWindowControllers;
@synthesize progressWindowControllers;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSWindowWillCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"gMain" object:nil];
    
    [mytimer release];
    
    
    [appversion release];
    
    if (launchpadWindowController != nil)
        [launchpadWindowController release];
    if (aboutWindowController != nil)
        [aboutWindowController release];
    if (loginWebWindowController) {
        [loginWebWindowController release];
    }
    [super dealloc];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[ASIHTTPRequest sharedQueue] setMaxConcurrentOperationCount:100];
    self.strAccessID=@"";
    self.strAccessKey=@"";
    self.strArea=@"";
    self.strHost=@"";
    [self setMainMenu];
    self.bDebugMenu=NO;
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
    self.strTransCachePath=[NSString stringWithFormat:@"%@/transcache",[[NSBundle mainBundle] bundlePath]];
    [Util createfolder:self.strTransCachePath];
    self.strUserDB=[NSString stringWithFormat:@"%@/user/ossuser.db",[[NSBundle mainBundle] bundlePath]];
    [Util createfolder:[self.strUserDB stringByDeletingLastPathComponent]];
    self.strLogPath=[NSString stringWithFormat:@"%@/log",[[NSBundle mainBundle] bundlePath]];
    [Util createfolder:self.strLogPath];
    self.browserWindowControllers=[NSMutableArray array];
    self.progressWindowControllers=[NSMutableDictionary dictionary];
    self.appversion=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
 //   int cacheSizeMemory = 4*1024*1024; // 4MB
 //   int cacheSizeDisk = 32*1024*1024; // 32MB
 //   NSURLCache *sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:[UserData shareUserData].configPath] autorelease];
 //   [NSURLCache setSharedURLCache:sharedCache];


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

-(void) setMainMenu
{
    NSMenu* mainMenu = [NSApp mainMenu];
    NSMenuItem* itemEt = [mainMenu addItemWithTitle:@"" action:nil keyEquivalent:@""];
    NSMenu *subMenu  =[[NSMenu alloc]initWithTitle:[Util localizedStringForKey:@"编辑" alternate:nil]];
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

@end
