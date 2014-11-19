
#import "LaunchpadWindowController.h"

#import "Util.h"
#import "Common.h"
#import "AppDelegate.h"
#import "GKWebViewDelegate.h"
#import "BrowserWebWindowController.h"

#import "OperationManager.h"
#import "NSAlert+SynchronousSheet.h"


@implementation LaunchpadWindowController

//////////////////////////////////////////////////////////////////////////////////////////////

@synthesize _bFirst;

@synthesize _tab;
@synthesize _jsonInfo;
@synthesize _jsonAction;
@synthesize _jsonChat;

@synthesize _curMountid;
@synthesize _curWebpath;
@synthesize _dragitems;

//////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self._bFirst=YES;
        self.delegate =[[[GKWebViewDelegate alloc]initWithDelegateController:self] autorelease];
        
        NSString* filePath=[NSString stringWithFormat:@"%@/index.html",[Util getAppDelegate].strUIPath];
        self.strUrl=[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        _desktopId = [self getdesktopid];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KeyDidLoginNotification object:nil];
    self._tab=nil;
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:KeyDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(window_closed:) name:NSWindowWillCloseNotification object:nil];
   [self.window setTitle:[Util localizedStringForKey:@"够快云库" alternate:nil]];
    [baseWebview setDragfinishEvent:^{
        [self dragfinish];
    }];
    
    [self reload:NO];
    
    if ([Util getAppDelegate].bDebugMenu) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSRect screenRect = [[NSScreen mainScreen] frame];
    CGFloat width=screenRect.size.width*2/3;
    if (width<1000.0) {
        width=1000.0;
    }
    CGFloat height=screenRect.size.height*2/3;
    if (height<600.0) {
        height=600.0;
    }
	[self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y,width,height) display:NO animate:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////////

-(void) updateUI:(NSNotification *)notification
{
    [self reload:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////////

-(NSInteger) getdesktopid
{
    NSInteger intval = 0;
    while (YES) {
        
        NSInteger windowid = [NSWindow windowNumberAtPoint:NSMakePoint(1, 1) belowWindowWithWindowNumber:intval];
        if ( 0 == windowid ) {
            break;
        }
        
        intval = windowid;
    }
    return intval;
}

//////////////////////////////////////////////////////////////////////////////////////////////

-(void) adjustposition
{
    NSPoint pt=[Util getWindowDisplayOriginPoint:self.window.frame.size];
    [self.window setFrameTopLeftPoint:pt];
}

//////////////////////////////////////////////////////////////////////////////////////////////
//drag file

-(NSPoint) absolutepointwithrelativepoint:(NSPoint) point;
{
    return NSMakePoint(self.window.frame.origin.x+point.x, self.window.frame.origin.y+point.y);
}

-(void) dragfinish
{
    if ( 0 == _dragitems.count) {
        return;
    }
    
    NSInteger targetNo = [NSWindow windowNumberAtPoint:[self absolutepointwithrelativepoint:[baseWebview rpoint]]
                           belowWindowWithWindowNumber:0];
    if ( _desktopId == targetNo ) {
        NSString *target = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [self handledrag2finder:target];
    }
    else {
        NSString *target = [Util getfindertarget:targetNo];
        if (target.length) {
            [self handledrag2finder:target];
        }
        else {
            [self handledrag2otherapps];
        }
    }
}

-(void) handledrag2finder:(NSString *)target
{
//    [[OperationManager sharedInstance] dragendinfinder:_dragitems target:target];
}

-(void) handledrag2otherapps
{
//    [[OperationManager sharedInstance] dragendinothers:_dragitems];
}

- (void)window_closed:(NSNotification *)notification
{
    if (self.window==[notification object]) {
        if (!self.window.isVisible) {
            [self release];
            return;
        }
        exit(0);
    }
}


- (BOOL)windowShouldClose:(id)sender
{
    NSAlert* alert=[NSAlert alertWithMessageText:[Util localizedStringForKey:@"温馨提示" alternate:nil]
                                   defaultButton:[Util localizedStringForKey:@"确定" alternate:nil] alternateButton:[Util localizedStringForKey:@"取消" alternate:nil]
                                     otherButton:nil informativeTextWithFormat:@"%@",[Util localizedStringForKey:@"是否确定退出?" alternate:nil]];
    
    NSInteger ret=[alert runModalSheetForWindow:self.window];
    if (NSAlertFirstButtonReturn == ret) {
        return YES;
    }
    else {
        return NO;
    }
}
@end
