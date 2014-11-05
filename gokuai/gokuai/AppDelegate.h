#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <QuartzCore/CoreAnimation.h>
#import <WebKit/WebKit.h>

@class HTTPEngine,LoginWebWindowController,
LaunchpadWindowController,BrowserWebWindowController,ASIHTTPRequest,AboutWindowController,MyTimer,MoveAndPasteWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate>
{
    NSString*   strAccessID;
    NSString*   strAccessKey;
    NSString*   strArea;
    NSString*   strHost;
    NSString*   strUIPath;
    NSString*   strTransCachePath;
    NSString*   strUserDB;
    NSString*   strTransDB;
    NSString*   strLogPath;
    BOOL        bHttps;
    BOOL        bLogin;
    BOOL        bShowPassword;

    
    NSString*   appversion;
    
    
    MyTimer*         mytimer;
    
    LaunchpadWindowController *launchpadWindowController;
    LoginWebWindowController  *loginWebWindowController;
    AboutWindowController     *aboutWindowController;
    MoveAndPasteWindowController* moveAndPasteWindowController;
    
    NSMutableArray* browserWindowControllers;//BrowserWebWindowController
    NSMutableDictionary* progressWindowControllers;//ProgressWindowControllers
}

@property(nonatomic, retain) NSString* strUIPath;
@property(nonatomic, retain) NSString* strAccessID;
@property(nonatomic, retain) NSString* strAccessKey;
@property(nonatomic, retain) NSString* strArea;
@property(nonatomic, retain) NSString* strHost;
@property(nonatomic, retain) NSString* strTransCachePath;
@property(nonatomic, retain) NSString* strUserDB;
@property(nonatomic, retain) NSString* strTransDB;
@property(nonatomic, retain) NSString* strLogPath;

@property(nonatomic)BOOL bHttps;
@property(nonatomic)BOOL bLogin;
@property(nonatomic)BOOL bShowPassword;

@property(nonatomic, retain) NSString* appversion;


@property(nonatomic,retain) LoginWebWindowController  *loginWebWindowController;
@property(nonatomic,retain) LaunchpadWindowController *launchpadWindowController;
@property(nonatomic,retain) MoveAndPasteWindowController* moveAndPasteWindowController;
@property(nonatomic,retain) NSMutableArray* browserWindowControllers;
@property(nonatomic,retain) NSMutableDictionary* progressWindowControllers;

-(void)onStart;

-(void) setLoginWebWindowController;

-(BrowserWebWindowController*) getBrowserWebWindowController:(NSString*)solestr;
-(MoveAndPasteWindowController*) getMoveAndPasteWindowController;

-(void)onOpenMainThreadWebWindowResult:(NSArray*)arrInfo;

-(void)OpenLaunchpadWindow;

@end
