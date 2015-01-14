#import "MyTask.h"
#import "Util.h"
#import "Common.h"
#import "GKHTTPRequest.h"
#import "AppUpdateWindowController.h"
#import "JSONKit.h"
#import "OSSApi.h"

@implementation MyTask

- (void)main{
    
}

@end

@implementation GetUpdateXML

@synthesize _bShow;

-(id)init:(BOOL)bShow
{
    if (self = [super init])
    {
        self._bShow=bShow;
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

- (void)main{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        NSData* jsonData = [OSSApi CheckServer:[Util getAppDelegate].strSource version:[Util getAppDelegate].appversion app:@"mac"];
        if (jsonData!=nil) {
            NSString *jsonInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSDictionary* dictionary=[jsonInfo objectFromJSONString];
            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                [Util getAppDelegate].serversion=[dictionary objectForKey:@"version"];
                [self performSelectorOnMainThread:@selector(showupdate) withObject:nil waitUntilDone:YES];
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
        [pool release];
    }
}

-(void)showupdate
{
    [[Util getAppDelegate] showupdate];
}

@end
@implementation DownloadDmgTask

@synthesize _url;
@synthesize _savepath;
@synthesize _size;
@synthesize _offset;

-(id)init:(NSString*)url
 savepath:(NSString*)savepath
     size:(NSInteger)size
{
    if (self = [super init])
    {
        self._url=url;
        self._savepath=savepath;
        self._size=size;
        self._offset=0;
    }
    return self;
}

-(void)dealloc
{
    [_url release];
    [_savepath release];
    if (![request isCancelled]) {
        [request setDelegate:nil];
        [request cancel];
        request = nil;
    }
    [super dealloc];
}

- (void)main{
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self._url]];
    [request setDownloadDestinationPath:self._savepath];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    [request setAllowResumeForFileDownloads:YES];
    [request startSynchronous];
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self onUpdateCloseWindow];
 //   [[Util getAppDelegate]._downloadtask release];
    [Util getAppDelegate]._downloadtask=nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[Util getAppDelegate].appUpdateWindowController.window orderOut:nil];
 //   [[Util getAppDelegate]._downloadtask release];
    [Util getAppDelegate]._downloadtask=nil;
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    _offset+=bytes;
    if (self._size!=0) {
        NSInteger pos=_offset*100/self._size;
        [self performSelectorOnMainThread:@selector(onAppProgress:) withObject:[NSNumber numberWithInteger:pos] waitUntilDone:YES];
    }
}

-(void)onUpdateCloseWindow
{
    [[Util getAppDelegate].appUpdateWindowController.window orderOut:nil];
    [NSThread sleepForTimeInterval:2];
    [[Util getAppDelegate] openUpdateDmg];
}

-(void)onAppProgress:(NSNumber*)numPos
{
    NSInteger pos = [numPos integerValue];
    [[Util getAppDelegate] appUpdateWindowController].downloadProgress = [NSString stringWithFormat:@"%ld%%",pos];
    [[[[Util getAppDelegate] appUpdateWindowController] appProgress]setDoubleValue:pos];
}
@end
