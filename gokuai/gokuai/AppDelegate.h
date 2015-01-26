#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <QuartzCore/CoreAnimation.h>
#import <WebKit/WebKit.h>
#import "OperationManager.h"
#import "AppUpdateWindowController.h"
#import "MyTask.h"

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
    NSString*   strConfig;
    NSString*   strSource;
    BOOL        bHttps;
    BOOL        bLogin;
    BOOL        bShowPassword;
    BOOL        bDebugMenu;
    BOOL        bFinishCallback;
    BOOL  bLink;
    
    NSString*   appversion;
    NSString*   serversion;
    NSOperationQueue*  taskqueue;
    BOOL        bIsUpdate;
    
    DownloadDmgTask*   _downloadtask;
    
    MyTimer*         mytimer;
    
    LaunchpadWindowController *launchpadWindowController;
    LoginWebWindowController  *loginWebWindowController;
    AboutWindowController     *aboutWindowController;
    MoveAndPasteWindowController* moveAndPasteWindowController;
    AppUpdateWindowController *appUpdateWindowController;
    
    NSMutableArray* browserWindowControllers;//BrowserWebWindowController
    NSMutableDictionary* progressWindowControllers;//ProgressWindowControllers
    
    BOOL        bAddDownloadOut;
    BOOL        bAddDownloadDelete;
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
@property(nonatomic, retain) NSString* strConfig;
@property(nonatomic, retain) NSString* strSource;

@property(nonatomic)BOOL bHttps;
@property(nonatomic)BOOL bLogin;
@property(nonatomic)BOOL bShowPassword;
@property(nonatomic) BOOL bDebugMenu;
@property(nonatomic)BOOL bFinishCallback;
@property(nonatomic)BOOL bIsUpdate;
@property(nonatomic)BOOL bLink;

@property(nonatomic, retain) NSString* appversion;
@property(nonatomic, retain) NSString* serversion;
@property(nonatomic, retain) NSOperationQueue *  taskqueue;
@property(nonatomic, retain) DownloadDmgTask* _downloadtask;


@property(nonatomic,retain) LoginWebWindowController  *loginWebWindowController;
@property(nonatomic,retain) LaunchpadWindowController *launchpadWindowController;
@property(nonatomic,retain) MoveAndPasteWindowController* moveAndPasteWindowController;
@property(nonatomic,retain) AppUpdateWindowController *appUpdateWindowController;
@property(nonatomic,retain) NSMutableArray* browserWindowControllers;
@property(nonatomic,retain) NSMutableDictionary* progressWindowControllers;

@property(nonatomic)BOOL bAddDownloadOut;
@property(nonatomic)BOOL bAddDownloadDelete;

-(void)onStart;

-(void) setLoginWebWindowController;

-(BrowserWebWindowController*) getBrowserWebWindowController:(NSString*)solestr;
-(MoveAndPasteWindowController*) getMoveAndPasteWindowController;

-(void)onOpenMainThreadWebWindowResult:(NSArray*)arrInfo;

-(void)OpenLaunchpadWindow;

-(void)startCopy:(OperPackage*)item;
-(void)startDelete:(OperPackage*)item;
-(void)startDeleteBucket:(OperPackage*)item;

-(void)showupdate;
-(void)openUpdateDmg;

-(void)UpdateLoadingCount:(NSInteger)count downloadcount:(NSInteger)downloadcount;

@end
