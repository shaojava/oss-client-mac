
#import "DownloadPeer.h"
#import "Util.h"
#import "OSSApi.h"
#import "NSStringExpand.h"

@implementation DownloadPeer

@synthesize pRequest;
@synthesize bRequestStart;

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

-(void)dealloc
{
    self.pRequest=nil;
    [super dealloc];
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
                    self.ullPos+=data.length;
                    self.ullSize-=data.length;
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
    self.bRequestStart=NO;
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    self.bStart=NO;
    self.bRequestStart=NO;
    [self.pTask ErrorIndex:self.ullPos size:self.ullSize error:request.responseStatusCode msg:@"asi error"];
}

-(void)main{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try
    {
        NSString* date=[Util getGMTDate];
        NSString* method=@"GET";
        NSString* resource=[NSString stringWithFormat:@"/%@/%@",self.strBucket,self.strObject];
        NSString* contenttype=[OSSApi GetContentType:self.strObject];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        NSString* retsign=[OSSApi Authorization:method contentmd5:@"" contenttype:contenttype date:date keys:array resource:resource];
        NSString* strUrl=[OSSApi AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@",self.strBucket,self.strHost,[self.strObject urlEncoded]]];
        self.pRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUrl]];
        while (!self.bStop&&self.bStart) {
            if (!self.bRequestStart) {
                [self.pRequest addRequestHeader:@"Content-Type" value:contenttype];
                [self.pRequest addRequestHeader:@"Date" value:date];
                [self.pRequest addRequestHeader:@"Authorization" value:retsign];
                NSString *range=[NSString stringWithFormat:@"bytes=%lld-%lld",self.ullPos,self.ullPos+self.ullSize-1];
                NSLog(@"%@",range);
                [self.pRequest addRequestHeader:@"Range" value:range];
                [self.pRequest setDelegate:self];
                [self.pRequest setDownloadProgressDelegate:self];
                [self.pRequest setTimeOutSeconds:60];
                [self.pRequest setShouldAttemptPersistentConnection:NO];
                self.bRequestStart=YES;
                [self.pRequest startAsynchronous];
            }
            else {
                [NSThread sleepForTimeInterval:1];
            }
        }
    }
    @catch (NSException *ex) {
    }
    self.bRequestStart=NO;
    self.bStart=NO;
    [pool release];
}

@end
