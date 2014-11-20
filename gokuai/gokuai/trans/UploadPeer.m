#import "UploadPeer.h"
#import "OSSApi.h"
#import "NSDataExpand.h"
#import "UploadTask.h"
#import "Util.h"
#import "NSStringExpand.h"

@implementation UploadPeer

@synthesize pFileHandle;
@synthesize strUploadID;
@synthesize ullRead;
@synthesize retData;
@synthesize strDateMd5;

-(id)init:(UploadTask *)task host:(NSString *)host bucket:(NSString *)bucket object:(NSString *)object
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
        self.pFileHandle=nil;
        self.strUploadID=@"";
        self.ullRead=0;
        self.retData=[NSMutableData dataWithLength:0];
    }
    return self;
}

-(void)dealloc
{
    pFileHandle=nil;
    strUploadID=nil;
    retData=nil;
    strDateMd5=nil;
    [super dealloc];
}

-(BOOL)OpenFile:(NSString*)uploadid fullpath:(NSString*)fullpath
{
    self.strUploadID=uploadid;
    self.pFileHandle=[NSFileHandle fileHandleForReadingAtPath:fullpath];
    if (self.pFileHandle==nil) {
        return NO;
    }
    return YES;
}

-(void)StartUpload:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size
{
    [self.retData setLength:0];
    self.nIndex=index;
    self.ullPos=pos;
    self.ullSize=size;
    [self.pFileHandle seekToFileOffset:self.ullPos];
    self.bStart=YES;
    self.ullRead=0;
    NSString* date=[Util getGMTDate];
    [self.pFileHandle seekToFileOffset:self.ullPos];
    NSData * data=[self.pFileHandle readDataOfLength:self.ullSize];
    self.strDateMd5=[NSString stringWithFormat:@"\"%@\"",[data md5Data2String]];
    NSString* method=@"PUT";
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* resource;
    NSString* strUrl;
    if (self.strUploadID.length==0) {
        resource=[NSString stringWithFormat:@"/%@/%@",self.strBucket,self.strObject];
        strUrl=[OSSApi AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@",self.strBucket,self.strHost,[self.strObject urlEncoded]]];
    }
    else {
        resource=[NSString stringWithFormat:@"/%@/%@?partNumber=%ld&uploadId=%@",self.strBucket,self.strObject,self.nIndex,self.strUploadID];
        strUrl=[OSSApi AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@?partNumber=%ld&uploadId=%@",self.strBucket,self.strHost,[self.strObject urlEncoded],self.nIndex,self.strUploadID]];
    }
    NSString* contenttype=[OSSApi GetContentType:self.strObject];
    NSString* retsign=[OSSApi Authorization:method contentmd5:@"" contenttype:contenttype date:date keys:array resource:resource];
    self.pRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUrl]];
    [self.pRequest setRequestMethod:method];
    [self.pRequest addRequestHeader:@"Content-Type" value:contenttype];
    [self.pRequest addRequestHeader:@"Date" value:date];
    [self.pRequest addRequestHeader:@"Authorization" value:retsign];
    [self.pRequest setDelegate:self];
    [self.pRequest setUploadProgressDelegate:self];
    [self.pRequest setTimeOutSeconds:60];
    [self.pRequest appendPostData:data];
    [self.pRequest startAsynchronous];
}

-(void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    [((UploadTask*)self.pTask).pFilesc lock];
    ((UploadTask*)self.pTask).ullTranssize+=bytes;
    ((UploadTask*)self.pTask).pItem.ullOffset+=bytes;
    self.ullRead+=bytes;
    [((UploadTask*)self.pTask).pFilesc unlock];
}

-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    [self.retData appendData:data];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [((UploadTask*)self.pTask).pFilesc lock];
    ((UploadTask*)self.pTask).ullTranssize+=self.ullSize-self.ullRead;
    ((UploadTask*)self.pTask).pItem.ullOffset+=self.ullSize-self.ullRead;
    [((UploadTask*)self.pTask).pFilesc unlock];
    OSSAddObject *ret =[[[OSSAddObject alloc]init]autorelease];
    ret.nHttpCode=request.responseStatusCode;
    [ret SetValueWithData:self.retData];
    if (ret.nHttpCode==200) {
        NSDictionary* retheader=[request responseHeaders];
        if ([retheader isKindOfClass:[NSDictionary class]]) {
            NSString * etag=[retheader valueForKey:@"ETag"];
            if (etag.length) {
                ret.strEtag=etag;
            }
            NSString * request=[retheader valueForKey:@"x-oss-request-id"];
            if (request.length) {
                ret.strRequestId=request;
            }
        }
        NSString * retetag=ret.strEtag;
        if (self.strUploadID.length==0) {
            if ([self.strDateMd5 isEqualToString:retetag]) {
                [((UploadTask*)self.pTask) FinishIndex:self.nIndex pos:self.ullPos size:self.ullSize etag:self.strDateMd5];
            }
            else {
                NSString * message=[NSString stringWithFormat:@"md5 error:%@ %@",self.strDateMd5,retetag];
                [((UploadTask*)self.pTask) TaskError:TRANSERROR_MD5ERROR msg:message];
            }
        }
        else {
            if ([self.strDateMd5 isEqualToString:retetag]) {
                [((UploadTask*)self.pTask) FinishIndex:self.nIndex pos:self.ullPos size:self.ullSize etag:self.strDateMd5];
            }
            else {
                NSString * message=[NSString stringWithFormat:@"md5 error:%@ %@",self.strDateMd5,retetag];
                [((UploadTask*)self.pTask) ErrorIndex:self.nIndex pos:self.ullPos size:self.ullSize error:TRANSERROR_MD5ERROR msg:message];
            }
        }
    }
    else {
        if (self.strUploadID.length==0) {
            [((UploadTask*)self.pTask) TaskError:ret.nHttpCode msg:@"http code"];
        }
        else {
            if ([ret.strCode isEqualToString:@"NoSuchUpload"]) {
                [((UploadTask*)self.pTask) ResetUploadId];
            }
            [((UploadTask*)self.pTask) ErrorIndex:self.nIndex pos:self.ullPos size:self.ullSize error:ret.nHttpCode msg:@"http code"];
        }
    }
    self.bStart=NO;
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    OSSAddObject *ret =[[[OSSAddObject alloc]init]autorelease];
    ret.nHttpCode=request.responseStatusCode;
    [ret SetValueWithData:self.retData];
    if (self.strUploadID.length==0) {
        [((UploadTask*)self.pTask) TaskError:ret.nHttpCode msg:@"http code"];
    }
    else {
        if ([ret.strCode isEqualToString:@"NoSuchUpload"]) {
            [((UploadTask*)self.pTask) ResetUploadId];
        }
        [((UploadTask*)self.pTask) ErrorIndex:self.nIndex pos:self.ullPos size:self.ullSize error:ret.nHttpCode msg:@"http code"];
    }
    self.bStart=NO;
}

@end
