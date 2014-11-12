
#import "LoginWebWindowController.h"
#import "Util.h"
#import "JSONKit.h"
#import "Common.h"
#import "LaunchpadWindowController.h"
#import "BrowserWebWindowController.h"
#import "AppDelegate.h"
#import "GKWebViewDelegate.h"
#import "NSStringExpand.h"
#import "NSAlert+SynchronousSheet.h"

@implementation LoginWebWindowController

@synthesize bOut;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.delegate =[[[GKWebViewDelegate alloc]initWithDelegateController:self] autorelease];
        NSString* filePath=[NSString stringWithFormat:@"%@/login.html",[Util getAppDelegate].strUIPath];
        
        self.strUrl=[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([Util getAppDelegate].bShowPassword) {
            self.strUrl=[NSString stringWithFormat:@"%@#loginByPassword",[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        self.bOut=NO;
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:
     NSWindowWillCloseNotification object:nil];
    [super dealloc];
}

- (void)window_closed:(NSNotification *)notification
{
    if (self.bOut) {
        if (self.window==[notification object]) {
            if (!self.window.isVisible) {
                [self release];
                return;
            }
            exit(0);
        }
    }
    else {
        if (self.window==[notification object])
            [self.window orderOut:nil];
    }
}

- (BOOL)windowShouldClose:(id)sender
{
    NSAlert* alert=[NSAlert alertWithMessageText:[Util localizedStringForKey:@"温馨提示" alternate:nil]
                                   defaultButton:[Util localizedStringForKey:@"确定" alternate:nil] alternateButton:[Util localizedStringForKey:@"取消" alternate:nil]
                                     otherButton:nil informativeTextWithFormat:@"%@",[Util localizedStringForKey:@"是否确定退出?" alternate:nil]];
    
    NSInteger ret=[alert runModalSheetForWindow:self.window];
    if (NSAlertFirstButtonReturn == ret) {
        self.bOut=YES;
        return YES;
    }
    else {
        return NO;
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(window_closed:) name:NSWindowWillCloseNotification object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reload:NO];
}
 
- (void) awakeFromNib 
{
    [super awakeFromNib];
    [self.window setTitle:[Util localizedStringForKey:@"登录" alternate:nil]];
}

-(void)reloadwebview
{
    
}

-(void)onJudgeDealArray
{
}

- (void)onCallWebScriptMethodNotification:(NSNotification *)notification
{
    [self onCheckWebPageInfo];
}

#pragma mark-
#pragma mark  OtherLogin View Event

//检测第三方登陆信息是否正确
-(BOOL)onCheckWebPageInfo
{
    return NO;
}

-(BOOL) loginProc
{
    return NO;
}

//检测登陆时候的信息是否正确
-(BOOL)onBtnLoginUserNameAndPW:(NSString*)userInfo
{
    
    return YES;
}

-(BOOL)onBtnLoginByKey
{
    return NO;
}

@end
