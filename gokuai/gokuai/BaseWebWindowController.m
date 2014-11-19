//
//  WebBaseWindowController.m
//  GoKuai
//
//  Created by GoKuai on 1/8/14.
//
//

#import "BaseWebWindowController.h"
#import "Util.h"

@implementation BaseWebWindowController

@synthesize delegate;
@synthesize strUrl;


-(void) dealloc
{
    self.strUrl=nil;
    self.delegate=nil;
    [super dealloc];
}

-(WebFrame*) mainframe
{
    return [baseWebview mainFrame];
}

-(NSString*) dragInformation
{
    return [baseWebview jsonInfo];
}

-(WebScriptObject*) windowscriptobj
{
    return [baseWebview windowScriptObject];
}

-(void) makeAble:(BOOL)ableornot
{
    WindowEve* window=(WindowEve*)self.window;
    if (ableornot) {
        [window enableWindowEx];
    }
    else {
        [window disableWindowEx];
    }
}


-(void) awakeFromNib
{
    alreadyload=NO;
    [baseWebview setUIDelegate:self.delegate];
	[baseWebview setResourceLoadDelegate: self.delegate];
    [baseWebview setPolicyDelegate:self.delegate];
    [baseWebview setDrawsBackground:YES];
    [baseWebview setFrameLoadDelegate:self.delegate];
    [baseWebview setShouldCloseWithWindow:YES];
    [baseWebview setCustomUserAgent:
     [NSString stringWithFormat:@"OSS;%@;Mac;OSS;Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36",[[Util getAppDelegate]appversion]]
     ];
    
    WebPreferences *webPrefs = [WebPreferences standardPreferences];
    NSString *cappBundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *applicationSupportFile = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
    NSString *savePath = [NSString pathWithComponents:[NSArray arrayWithObjects:applicationSupportFile, cappBundleName, @"LocalStorage", nil]];
    
    //    [webPrefs setApplicationCacheTotalQuota:DEF_CACHE_TOTAL_QUOTA];
    //    [webPrefs setApplicationCacheDefaultOriginQuota:DEF_CACHE_ORIGIN_QUOTA];
    [webPrefs _setLocalStorageDatabasePath:savePath];
    [webPrefs setLocalStorageEnabled:YES];
    [webPrefs setDatabasesEnabled:YES];
    [webPrefs setDeveloperExtrasEnabled:[[NSUserDefaults standardUserDefaults] boolForKey: @"developer"]];
    [webPrefs setOfflineWebApplicationCacheEnabled:YES];
    [webPrefs setWebGLEnabled:YES];
    [baseWebview setPreferences:webPrefs];
    
    [self reload:NO];
}

-(void) reload:(BOOL)must
{
    if ( !alreadyload && baseWebview && strUrl.length ) {//加载页面
        
        NSURL* fileurl=[NSURL URLWithString:strUrl];
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:fileurl];
        [[self mainframe] loadRequest:req];
        
        alreadyload=YES;
        return;
    }
    else if ( must ) {//刷新页面
        [baseWebview reload:nil];
    }
}

-(void) setStrUrl:(NSString *)strUrlx
{
    if (strUrlx.length) {
        [strUrl release];
        strUrl=[strUrlx retain];
        alreadyload=NO;
        [self reload:NO];
    }
}

@end
