
#import "DownloadPeer.h"

@implementation DownloadPeer

-(id)init:(DownloadTask*)task host:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object
{
    if (self=[super init]) {
        self.pTask=task;
        self.strHost=host;
        self.strBucket=bucket;
        self.strObject=object;
        self.strHeader=@"";
        self.bStart=NO;
        self.bStop=NO;
        self.nIndex=0;
        self.ullPos=0;
        self.ullSize=0;
    }
    return self;
}
-(void)StartDownload:(ULONGLONG)pos size:(ULONGLONG)size
{
    self.ullPos=pos;
    self.ullSize=size;
    self.bStart=YES;
}

-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        if (request.responseStatusCode>=200&&request.responseStatusCode<400&&!self.bStop&&data.length>0) {
            if(self.pTask==nil)
                [request cancel];
            else {
                if (self.pTask&&[self.pTask WriteFile:(char*)(data.bytes) pos:self.ullPos size:data.length]) {
                }
                else {
                    [request cancel];
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
        [pool release];
    }
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    self.bStart=NO;
 //   self.bRequestStart=NO;
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
 //   self.bRequestStart=NO;
    self.bStart=NO;
}

-(void)main{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try
    {
/*        self.pRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.strUrl]];
        while (!self.bStop&&!self.bBad) {
            [self.pLockcs lock];
            if ([self checkdownloadindex]) {
                if (!self.bRequestStart) {
                    [self.pRequest addRequestHeader:@"User-Agent" value:@"client_gokuai"];
                    NSString *range=[self getRange];
                    if (range.length!=0) {
                        [self.pRequest addRequestHeader:@"Range" value:range];
                    }
                    [self.pRequest setDelegate:self];
                    [self.pRequest setDownloadProgressDelegate:self];
                    [self.pRequest setTimeOutSeconds:60];
                    [self.pRequest setShouldAttemptPersistentConnection:NO];
                    self.bRequestStart=YES;
                    self.ullOffset=0;
                    [self.pLockcs unlock];
                    [self.pRequest startAsynchronous];
                }
                else {
                    [self.pLockcs unlock];
                    [NSThread sleepForTimeInterval:1];
                }
            }
            else {
                [self.pLockcs unlock];
                break;
            }
        }*/
    }
    @catch (NSException *ex) {
    }
//    self.bRequestStart=NO;
    self.bStart=NO;
    [pool release];
}

@end
