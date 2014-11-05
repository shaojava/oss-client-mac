
#import "BrowserWebWindowController.h"
#import "Util.h"
#import "NSStringExpand.h"
#import "JSONKit.h"
#import "Common.h"
#import "AppDelegate.h"
#import "GKWebViewDelegate.h"
#import "LoginWebWindowController.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BrowserWebWindowController

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@synthesize lblAlert;
@synthesize solestr;
@synthesize bClose;
@synthesize bAdjusted;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithWindow:(NSWindow *)window
{
    if ([super initWithWindow:window]) {
        bAdjusted=NO;
        bClose=NO;
        self.delegate = [[[GKWebViewDelegate alloc]initWithDelegateController:self] autorelease];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:
     NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:
     NSWindowWillCloseNotification object:nil];
    self.solestr = nil;
    [super dealloc];
}

-(void) windowDidLoad
{
    [super windowDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowResized:)
                                                 name:NSWindowDidResizeNotification
                                               object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowColsed:)
                                                 name:NSWindowWillCloseNotification
                                               object:[self window]];

  //  [lblAlert setStringValue:[Util localizedStringForKey:@"请稍候，加载中..." alternate:nil]];
}

- (void) windowColsed:(NSNotification*)notification
{
    if ([notification object]==self.window) {
        self.delegate._bWindowsCloes=YES;
        [self release];
    }
}

- (void) windowResized:(NSNotification*)notification
{
	NSWindow* window = (NSWindow*)notification.object;
	NSSize size = [window frame].size;
	[baseWebview setFrame:NSMakeRect(0, 0, size.width, size.height)];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setAlertFrame
{
  //  [lblAlert setFrame:NSMakeRect(self.window.frame.size.width/2-67,self.window.frame.size.height/2-12, 135, 23)];
}

-(void) adjustframe:(NSSize)size
{
    if (!bAdjusted) {
        
        bool bFullScreen = (self.window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask;
        
        if (!bFullScreen) {
            if (!size.width || !size.height) {
                size=NSMakeSize(800, 500);
            }
            
            NSRect frame=self.window.frame;
            frame.size=size;
            
            [self.window setFrame:frame display:NO animate:NO];
            [self.window center];
        }
        
        bAdjusted=YES;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
