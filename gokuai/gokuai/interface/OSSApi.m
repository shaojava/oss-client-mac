#import "OSSApi.h"
#import "Util.h"
#import "ASIHTTPRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "ASIFormDataRequest.h"
#import "GKHTTPRequest.h"
#import "NSStringExpand.h"
#import "NSDataExpand.h"
#import "OSSBody.h"

@implementation OssSignKey

@synthesize key;
@synthesize value;

-(void)dealloc
{
    [key release];
    [value release];
    [super dealloc];
}

@end

@implementation OSSApi

+(BOOL)CheckIDandKey:(NSString*)sID key:(NSString*)sKey host:(NSString*)host ret:(OSSRet**)ret;
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"GET";
    NSString* resource=@"/";
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource accessid:sID accesskey:sKey];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl;
    if (host.length==0) {
        strUrl=[self AddHttpOrHttps:@"oss.aliyuncs.com/"];
    }
    else {
        strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@/",host]];
    }
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSRet alloc]init]autorelease];
    (*ret).nHttpCode=[response statusCode];
    [(*ret) SetValueWithData:data];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)DeleteBucket:(NSString*)host bucketname:(NSString*)bucketname ret:(OSSRet**)ret;
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"DELETE";
    NSString* resource=[NSString stringWithFormat:@"/%@/",bucketname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/",bucketname,host]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)GetBucketObject:(NSString*)host bucetname:(NSString*)bucketname ret:(OSSListObjectRet**)ret prefix:(NSString*)prefix marker:(NSString*)marker delimiter:(NSString*)delimiter maxkeys:(NSString*)maxkeys
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"GET";
    NSMutableString *resource = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *resource1 = [[[NSMutableString alloc] init] autorelease];
    [resource appendString:@"/"];
    [resource1 appendString:@"/"];
    BOOL bHave=NO;
    if (prefix.length) {
        [resource appendString:@"?prefix="];
        [resource appendString:prefix];
        [resource1 appendString:@"?prefix="];
        [resource1 appendString:[prefix urlEncoded]];
        bHave=YES;
    }
    if (marker.length) {
        if (bHave) {
            [resource appendString:@"&marker="];
            [resource appendString:marker];
            [resource1 appendString:@"&marker="];
            [resource1 appendString:[marker urlEncoded]];
        }
        else {
            [resource appendString:@"?marker="];
            [resource appendString:marker];
            [resource1 appendString:@"?marker="];
            [resource1 appendString:[marker urlEncoded]];
            bHave=YES;
        }
    }
    if (delimiter.length) {
        if (bHave) {
            [resource appendString:@"&delimiter="];
            [resource appendString:delimiter];
            [resource1 appendString:@"&delimiter="];
            [resource1 appendString:[delimiter urlEncoded]];
        }
        else {
            [resource appendString:@"?delimiter="];
            [resource appendString:delimiter];
            [resource1 appendString:@"?delimiter="];
            [resource1 appendString:[delimiter urlEncoded]];
            bHave=YES;
        }
    }
    if (maxkeys.length) {
        if (bHave) {
            [resource appendString:@"&max-keys="];
            [resource appendString:maxkeys];
            [resource1 appendString:@"&max-keys="];
            [resource1 appendString:[maxkeys urlEncoded]];
        }
        else {
            [resource appendString:@"?max-keys="];
            [resource appendString:maxkeys];
            [resource1 appendString:@"?max-keys="];
            [resource1 appendString:[maxkeys urlEncoded]];
            bHave=YES;
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString * tempresource=[NSString stringWithFormat:@"/%@/",bucketname];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:tempresource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@%@",bucketname,host,resource1]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSListObjectRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)CopyObject:(NSString*)host dstbucketname:(NSString*)dstbucketname dstobjectname:(NSString*)dstobjectname srcbucketname:(NSString*)srcbucketname srcobjectname:(NSString*)srcobjectname ret:(OSSCopyRet**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"PUT";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@",dstbucketname,dstobjectname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"x-oss-copy-source";
    item.value=[NSString stringWithFormat:@"/%@/%@",srcbucketname,[srcobjectname urlEncoded]];
    [array addObject:item];
    [item release];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource];
    item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@",dstbucketname,host,[dstobjectname urlEncoded]]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSCopyRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)DeleteObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname ret:(OSSRet**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"DELETE";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@",bucketname,objectname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@",bucketname,host,[objectname urlEncoded]]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)DeleteObject:(NSString*)host bucketname:(NSString*)bucketname objectnames:(NSArray*)objectnamss quiet:(BOOL)quiet ret:(OSSRet**)ret
{
    NSString* date=[Util getGMTDate];
    OSSDeleteMultipleBody *ossbody=[[OSSDeleteMultipleBody alloc] init];
    [ossbody addList:objectnamss quiet:quiet];
    NSString* body=[ossbody GetBody];
    NSData *bodydata=[body dataUsingEncoding:NSUTF8StringEncoding];
    NSString* md5=[bodydata md5base64Encode];
    NSString* method=@"POST";
    NSString* resource=[NSString stringWithFormat:@"/%@/?delete",bucketname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* contenttype=@"application/xml";
    NSString* retsign=[self Authorization:method contentmd5:md5 contenttype:contenttype date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Content-MD5";
    item.value=md5;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Content-Type";
    item.value=contenttype;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/?delete",bucketname,host]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:[body dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)HeadObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname;
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"HEAD";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@",bucketname,objectname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@",bucketname,host,[objectname urlEncoded]]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    [request connectNetSyncWithResponse:&response error:nil];
    NSInteger status=[response statusCode];
    if (status>=200&&status<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)AddObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname filesize:(ULONGLONG)filesize filedata:(NSData*)filedata ret:(OSSAddObject**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"PUT";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@",bucketname,objectname];
    NSString* contenttype=[self GetContentType:objectname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:contenttype date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Content-Type";
    item.value=contenttype;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@",bucketname,host,[objectname urlEncoded]]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:filedata] autorelease];
    NSHTTPURLResponse* response;
    NSData* data =[request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSAddObject alloc]init]autorelease];
    (*ret).nHttpCode=[response statusCode];
    [(*ret) SetValueWithData:data];
    if ((*ret).nHttpCode==200) {
        NSDictionary* retheader=[response allHeaderFields];
        if ([retheader isKindOfClass:[NSDictionary class]]) {
            NSString * etag=[retheader valueForKey:@"ETag"];
            if (etag.length) {
                (*ret).strEtag=etag;
            }
            NSString * request=[retheader valueForKey:@"x-oss-request-id"];
            if (request.length) {
                (*ret).strRequestId=request;
            }
        }
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)InitiateMultipartUploadObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname ret:(OSSInitiateMultipartUploadRet**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"POST";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@?uploads",bucketname,objectname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@?uploads",bucketname,host,[objectname urlEncoded]]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSInitiateMultipartUploadRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)UploadPartObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname uploadid:(NSString*)uploadid partnumber:(NSInteger)partnumber filesize:(ULONGLONG)fileszie filedata:(NSData*)filedata ret:(OSSAddObject**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"PUT";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@?partNumber=%ld&uploadId=%@",bucketname,objectname,partnumber,uploadid];
    NSString* contenttype=[self GetContentType:objectname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:contenttype date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Content-Type";
    item.value=contenttype;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@?partNumber=%ld&uploadId=%@",bucketname,host,[objectname urlEncoded],partnumber,uploadid]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:filedata] autorelease];
    NSHTTPURLResponse* response;
    NSData* data =[request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSAddObject alloc]init]autorelease];
    (*ret).nHttpCode=[response statusCode];
    [(*ret) SetValueWithData:data];
    if ((*ret).nHttpCode==200) {
        NSDictionary* retheader=[response allHeaderFields];
        if ([retheader isKindOfClass:[NSDictionary class]]) {
            NSString * etag=[retheader valueForKey:@"ETag"];
            if (etag.length) {
                (*ret).strEtag=etag;
            }
            NSString * request=[retheader valueForKey:@"x-oss-request-id"];
            if (request.length) {
                (*ret).strRequestId=request;
            }
        }
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)UploadPartCopy:(NSString*)host dstbucketname:(NSString*)dstbucketname dstobjectname:(NSString*)dstobjectname srcbucketname:(NSString*)srcbucketname srcobjectname:(NSString*)srcobjectname uploadid:(NSString*)uploadid partnumber:(NSInteger)partnumber pos:(ULONGLONG)pos size:(ULONGLONG)size ret:(OSSRet**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"PUT";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@?partNumber=%ld&uploadId=%@",dstbucketname,dstobjectname,partnumber,uploadid];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"x-oss-copy-source";
    item.value=[NSString stringWithFormat:@"/%@/%@",srcbucketname,srcobjectname];
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"x-oss-copy-source-range";
    item.value=[NSString stringWithFormat:@"%llu-%llu",pos,pos+size-1];
    [array addObject:item];
    [item release];
    NSString* contenttype=[self GetContentType:dstobjectname];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:contenttype date:date keys:array resource:resource];
    item=[[OssSignKey alloc]init];
    item.key=@"Content-Type";
    item.value=contenttype;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@?partNumber=%ld&uploadId=%@",dstbucketname,host,[dstobjectname urlEncoded],partnumber,uploadid]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSAddObject alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
    return NO;
}

+(BOOL)CompleteMultipartUpload:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname uploadid:(NSString*)uploadid parts:(NSArray*)parts ret:(OSSRet**)ret
{
    NSString* date=[Util getGMTDate];
    OSSCompleteMultipartUploadBody *ossbody=[[OSSCompleteMultipartUploadBody alloc] init];
    [ossbody setParts:parts];
    NSString* body=[ossbody GetBody];
    NSData *bodydata=[body dataUsingEncoding:NSUTF8StringEncoding];
    NSString* md5=[bodydata md5base64Encode];
    NSString* method=@"POST";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@?uploadId=%@",bucketname,objectname,uploadid];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* contenttype=@"application/xml";
    NSString* retsign=[self Authorization:method contentmd5:md5 contenttype:contenttype date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Content-MD5";
    item.value=md5;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Content-Type";
    item.value=contenttype;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@?uploadId=%@",bucketname,host,[objectname urlEncoded],uploadid]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:bodydata] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}
+(BOOL)ListMultipartUploads:(NSString*)host bucketname:(NSString*)bucketname reet:(OSSListMultipartUploadRet**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"GET";
    NSString* resource=[NSString stringWithFormat:@"/%@/?uploads",bucketname];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/?uploads",bucketname,host]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSListMultipartUploadRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}
    
+(BOOL)AbortMultipartUpload:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname uploadid:(NSString*)uploadid ret:(OSSRet**)ret
{
    NSString* date=[Util getGMTDate];
    NSString* method=@"DELETE";
    NSString* resource=[NSString stringWithFormat:@"/%@/%@?uploadId=%@",bucketname,objectname,uploadid];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString* retsign=[self Authorization:method contentmd5:@"" contenttype:@"" date:date keys:array resource:resource];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"Date";
    item.value=date;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"Authorization";
    item.value=retsign;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@.%@/%@?uploadId=%@",bucketname,host,[objectname urlEncoded],uploadid]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:[self GetHeader:array]
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSListMultipartUploadRet alloc]init]autorelease];
    [(*ret) SetValueWithData:data];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        return NO;
    }
}

+(NSString*)Authorization:(NSString*)method contentmd5:(NSString*)contentmd5 contenttype:(NSString*)contenttype date:(NSString*)date keys:(NSArray*)keys resource:(NSString*)resource
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    NSArray *sortedArray = [keys sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableString *signString = [[[NSMutableString alloc] init] autorelease];
    [signString appendString:method];
    [signString appendString:@"\n"];
    [signString appendString:contentmd5];
    [signString appendString:@"\n"];
    [signString appendString:contenttype];
    [signString appendString:@"\n"];
    [signString appendString:date];
    [signString appendString:@"\n"];
    for (int i=0;i<[sortedArray count];i++) {
        OssSignKey* sk=[sortedArray objectAtIndex:i];
        [signString appendFormat:@"%@:%@\n",sk.key,sk.value];
    }
    [signString appendFormat:resource];
    const char * secretStr = [[Util getAppDelegate].strAccessKey UTF8String];
    const char * signStr = [signString UTF8String];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretStr, [[Util getAppDelegate].strAccessKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding], signStr, [signString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] autorelease];
    return [NSString stringWithFormat:@"OSS %@:%@",[Util getAppDelegate].strAccessID,[HMAC base64Encoded]];
}

+(NSString*)Authorization:(NSString *)method contentmd5:(NSString *)contentmd5 contenttype:(NSString *)contenttype date:(NSString *)date keys:(NSArray *)keys resource:(NSString *)resource accessid:(NSString*)accessid accesskey:(NSString*)accesskey
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    NSArray *sortedArray = [keys sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableString *signString = [[[NSMutableString alloc] init] autorelease];
    [signString appendString:method];
    [signString appendString:@"\n"];
    [signString appendString:contentmd5];
    [signString appendString:@"\n"];
    [signString appendString:contenttype];
    [signString appendString:@"\n"];
    [signString appendString:date];
    [signString appendString:@"\n"];
    for (int i=0;i<[sortedArray count];i++) {
        OssSignKey* sk=[sortedArray objectAtIndex:i];
        [signString appendFormat:@"%@:%@\n",sk.key,sk.value];
    }
    [signString appendFormat:resource];
    const char * secretStr = [accesskey UTF8String];
    const char * signStr = [signString UTF8String];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretStr, [accesskey lengthOfBytesUsingEncoding:NSUTF8StringEncoding], signStr, [signString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] autorelease];
    return [NSString stringWithFormat:@"OSS %@:%@",accessid,[HMAC base64Encoded]];
}

+(NSString*)Signature:(NSString*)method contentmd5:(NSString*)contentmd5 contenttype:(NSString*)contenttype date:(ULONGLONG)date keys:(NSArray*)keys resource:(NSString*)resource
{
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    NSArray *sortedArray = [keys sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableString *signString = [[[NSMutableString alloc] init] autorelease];
    if (method.length) {
        [signString appendString:method];
    }
    [signString appendString:@"\n"];
    if (contentmd5.length) {
        [signString appendString:contentmd5];
    }
    [signString appendString:@"\n"];
    if (contenttype.length) {
        [signString appendString:contenttype];
    }
    [signString appendString:@"\n"];
    [signString appendFormat:@"%llu",date];
    [signString appendString:@"\n"];
    for (int i=0;i<[sortedArray count];i++) {
        OssSignKey* sk=[sortedArray objectAtIndex:i];
        [signString appendFormat:@"%@:%@\n",sk.key,sk.value];
    }
    [signString appendFormat:resource];
    const char * secretStr = [[Util getAppDelegate].strAccessKey UTF8String];
    const char * signStr = [signString UTF8String];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretStr, [[Util getAppDelegate].strAccessKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding], signStr, [signString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] autorelease];
    return [NSString stringWithFormat:@"%@",[HMAC base64Encoded]];
}

+(NSString*)GetContentType:(NSString*)objectname
{
    NSString* ext=[[objectname pathExtension] lowercaseString];
	if (ext.length)
	{
		if ([ext isEqualToString:@"dwf"])		return @"Model/vnd.dwf";
		if ([ext isEqualToString:@".class"])	return @"java/*";
		if ([ext isEqualToString:@".java"])		return @"java/*";
		if ([ext isEqualToString:@".907"])		return @"drawing/907";
		if ([ext isEqualToString:@".slk"])		return @"drawing/x-slk";
		if ([ext isEqualToString:@".top"])		return @"drawing/x-top";
		if ([ext isEqualToString:@".eml"])		return @"message/rfc822";
		if ([ext isEqualToString:@".mht"])		return @"message/rfc822";
		if ([ext isEqualToString:@".mhtml"])	return @"message/rfc822";
		if ([ext isEqualToString:@".nws"])		return @"message/rfc822";
		if ([ext isEqualToString:@".tif"])		return @"image/tiff";
		if ([ext isEqualToString:@".fax"])		return @"image/fax";
		if ([ext isEqualToString:@".gif"])		return @"image/gif";
		if ([ext isEqualToString:@".ico"])		return @"image/x-icon";
		if ([ext isEqualToString:@".jfif"])		return @"image/jpeg";
		if ([ext isEqualToString:@".jpe"])		return @"image/jpeg";
		if ([ext isEqualToString:@".jpeg"])		return @"image/jpeg";
		if ([ext isEqualToString:@".jpg"])		return @"image/jpeg";
		if ([ext isEqualToString:@".net"])		return @"image/pnetvue";
		if ([ext isEqualToString:@".png"])		return @"image/png";
		if ([ext isEqualToString:@".rp"])		return @"image/vnd.rn-realpix";
		if ([ext isEqualToString:@".tiff"])		return @"image/tiff";
		if ([ext isEqualToString:@".wbmp"])		return @"image/vnd.wap.wbmp";
		if ([ext isEqualToString:@".asf"])		return @"video/x-ms-asf";
		if ([ext isEqualToString:@".asx"])		return @"video/x-ms-asf";
		if ([ext isEqualToString:@".avi"])		return @"video/avi";
		if ([ext isEqualToString:@".ivf"])		return @"video/x-ivf";
		if ([ext isEqualToString:@".m1v"])		return @"video/x-mpeg";
		if ([ext isEqualToString:@".m2v"])		return @"video/x-mpeg";
		if ([ext isEqualToString:@".m4e"])		return @"video/mpeg4";
		if ([ext isEqualToString:@".movie"])	return @"video/x-sgi-movie";
		if ([ext isEqualToString:@".mp2v"])		return @"video/mpeg";
		if ([ext isEqualToString:@".mp4"])		return @"video/mpeg4";
		if ([ext isEqualToString:@".mpa"])		return @"video/x-mpg";
		if ([ext isEqualToString:@".mpe"])		return @"video/x-mpeg";
		if ([ext isEqualToString:@".mpg"])		return @"video/mpg";
		if ([ext isEqualToString:@".mpeg"])		return @"video/mpg";
		if ([ext isEqualToString:@".mps"])		return @"video/x-mpeg";
		if ([ext isEqualToString:@".mpv"])		return @"video/mpg";
		if ([ext isEqualToString:@".mpv2"])		return @"video/mpeg";
		if ([ext isEqualToString:@".wm"])		return @"video/x-ms-wm";
		if ([ext isEqualToString:@".wmv"])		return @"video/x-ms-wmv";
		if ([ext isEqualToString:@".wmx"])		return @"video/x-ms-wmx";
		if ([ext isEqualToString:@".wvx"])		return @"video/x-ms-wvx";
		if ([ext isEqualToString:@".acp"])		return @"audio/x-mei-aac";
		if ([ext isEqualToString:@".aif"])		return @"audio/aiff";
		if ([ext isEqualToString:@".aiff"])		return @"audio/aiff";
		if ([ext isEqualToString:@".aifc"])		return @"audio/aiff";
		if ([ext isEqualToString:@".au"])		return @"audio/basic";
		if ([ext isEqualToString:@".la1"])		return @"audio/x-liquid-file";
		if ([ext isEqualToString:@".lavs"])		return @"audio/x-liquid-secure";
		if ([ext isEqualToString:@".lmsff"])	return @"audio/x-la-lms";
		if ([ext isEqualToString:@".m3u"])		return @"audio/mpegur@";
		if ([ext isEqualToString:@".midi"])		return @"audio/mid";
		if ([ext isEqualToString:@".mid"])		return @"audio/mid";
		if ([ext isEqualToString:@".mp2"])		return @"audio/mp2";
		if ([ext isEqualToString:@".mp3"])		return @"audio/mp3";
		if ([ext isEqualToString:@".mp4"])		return @"audio/mp4";
		if ([ext isEqualToString:@".mnd"])		return @"audio/x-musicnet-download";
		if ([ext isEqualToString:@".mp1"])		return @"audio/mp1";
		if ([ext isEqualToString:@".mns"])		return @"audio/x-musicnet-stream";
		if ([ext isEqualToString:@".mpga"])		return @"audio/rn-mpeg";
		if ([ext isEqualToString:@".pls"])		return @"audio/scpls";
		if ([ext isEqualToString:@".ram"])		return @"audio/x-pn-realaudio";
		if ([ext isEqualToString:@".rmi"])		return @"audio/mid";
		if ([ext isEqualToString:@".rmm"])		return @"audio/x-pn-realaudio";
		if ([ext isEqualToString:@".snd"])		return @"audio/basic";
		if ([ext isEqualToString:@".wav"])		return @"audio/wav";
		if ([ext isEqualToString:@".wax"])		return @"audio/x-ms-wax";
		if ([ext isEqualToString:@".wma"])		return @"audio/x-ms-wma";
		if ([ext isEqualToString:@".323"])		return @"text/h323";
		if ([ext isEqualToString:@".biz"])		return @"text/xm@";
		if ([ext isEqualToString:@".cml"])		return @"text/xm@";
		if ([ext isEqualToString:@".asa"])		return @"text/asa";
		if ([ext isEqualToString:@".asp"])		return @"text/asp";
		if ([ext isEqualToString:@".css"])		return @"text/css";
		if ([ext isEqualToString:@".csv"])		return @"text/csv";
		if ([ext isEqualToString:@".dcd"])		return @"text/xm@";
		if ([ext isEqualToString:@".dtd"])		return @"text/xm@";
		if ([ext isEqualToString:@".ent"])		return @"text/xm@";
		if ([ext isEqualToString:@".fo"])		return @"text/xm@";
		if ([ext isEqualToString:@".htc"])		return @"text/x-component";
		if ([ext isEqualToString:@".html"])		return @"text/htm@";
		if ([ext isEqualToString:@".htx"])		return @"text/htm@";
		if ([ext isEqualToString:@".htm"])		return @"text/htm@";
		if ([ext isEqualToString:@".htt"])		return @"text/webviewhtm@";
		if ([ext isEqualToString:@".jsp"])		return @"text/htm@";
		if ([ext isEqualToString:@".math"])		return @"text/xm@";
		if ([ext isEqualToString:@".mml"])		return @"text/xm@";
		if ([ext isEqualToString:@".mtx"])		return @"text/xm@";
		if ([ext isEqualToString:@".plg"])		return @"text/htm@";
		if ([ext isEqualToString:@".rdf"])		return @"text/xm@";
		if ([ext isEqualToString:@".rt"])		return @"text/vnd.rn-realtext";
		if ([ext isEqualToString:@".sol"])		return @"text/plain";
		if ([ext isEqualToString:@".spp"])		return @"text/xm@";
		if ([ext isEqualToString:@".stm"])		return @"text/htm@";
		if ([ext isEqualToString:@".svg"])		return @"text/xm@";
		if ([ext isEqualToString:@".tld"])		return @"text/xm@";
		if ([ext isEqualToString:@".txt"])		return @"text/plain";
		if ([ext isEqualToString:@".uls"])		return @"text/iuls";
		if ([ext isEqualToString:@".vml"])		return @"text/xm@";
		if ([ext isEqualToString:@".tsd"])		return @"text/xm@";
		if ([ext isEqualToString:@".vcf"])		return @"text/x-vcard";
		if ([ext isEqualToString:@".vxml"])		return @"text/xm@";
		if ([ext isEqualToString:@".wml"])		return @"text/vnd.wap.wm@";
		if ([ext isEqualToString:@".wsdl"])		return @"text/xm@";
		if ([ext isEqualToString:@".wsc"])		return @"text/scriptlet";
		if ([ext isEqualToString:@".xdr"])		return @"text/xm@";
		if ([ext isEqualToString:@".xql"])		return @"text/xm@";
		if ([ext isEqualToString:@".xsd"])		return @"text/xm@";
		if ([ext isEqualToString:@".xslt"])		return @"text/xm@";
		if ([ext isEqualToString:@".xml"])		return @"text/xm@";
		if ([ext isEqualToString:@".xq"])		return @"text/xm@";
		if ([ext isEqualToString:@".xquery"])	return @"text/xm@";
		if ([ext isEqualToString:@".xsl"])		return @"text/xm@";
		if ([ext isEqualToString:@".xhtml"])	return @"text/htm@";
		if ([ext isEqualToString:@".odc"])		return @"text/x-ms-odc";
		if ([ext isEqualToString:@".r3t"])		return @"text/vnd.rn-realtext3d";
		if ([ext isEqualToString:@".sor"])		return @"text/plain";
		if ([ext isEqualToString:@".pdf"])		return @"application/pdf";
		if ([ext isEqualToString:@".ai"])		return @"application/postscript";
		if ([ext isEqualToString:@".js"])		return @"application/javascript";
		if ([ext isEqualToString:@".edi"])		return @"EDIFACT";
		if ([ext isEqualToString:@".json"])		return @"application/json";
		if ([ext isEqualToString:@".ogg"])		return @"application/ogg";
		if ([ext isEqualToString:@".rdf"])		return @"application/rdf+xm@";
		if ([ext isEqualToString:@".woff"])		return @"application/font-woff";
		if ([ext isEqualToString:@".xhtml"])	return @"application/xhtml+xm@";
		if ([ext isEqualToString:@".xml"])		return @"application/xm@";
		if ([ext isEqualToString:@".dtd"])		return @"application/xml-dtd";
		if ([ext isEqualToString:@".zip"])		return @"application/zip";
		if ([ext isEqualToString:@".gzip"])		return @"application/gzip";
		if ([ext isEqualToString:@".xls"])		return @"application/x-xls";
		if ([ext isEqualToString:@".001"])		return @"application/x-001";
		if ([ext isEqualToString:@".301"])		return @"application/x-301";
		if ([ext isEqualToString:@".906"])		return @"application/x-906";
		if ([ext isEqualToString:@".a11"])		return @"application/x-a11";
		if ([ext isEqualToString:@".awf"])		return @"application/vnd.adobe.workflow";
		if ([ext isEqualToString:@".bmp"])		return @"application/x-bmp";
		if ([ext isEqualToString:@".c4t"])		return @"application/x-c4t";
		if ([ext isEqualToString:@".cal"])		return @"application/x-cals";
		if ([ext isEqualToString:@".cdf"])		return @"application/x-netcdf";
		if ([ext isEqualToString:@".cel"])		return @"application/x-ce@";
		if ([ext isEqualToString:@".cg4"])		return @"application/x-g4";
		if ([ext isEqualToString:@".cit"])		return @"application/x-cit";
		if ([ext isEqualToString:@".bot"])		return @"application/x-bot";
		if ([ext isEqualToString:@".c90"])		return @"application/x-c90";
		if ([ext isEqualToString:@".cat"])		return @"application/vnd.ms-pki.seccat";
		if ([ext isEqualToString:@".cdr"])		return @"application/x-cdr";
		if ([ext isEqualToString:@".cer"])		return @"application/x-x509-ca-cert";
		if ([ext isEqualToString:@".cgm"])		return @"application/x-cgm";
		if ([ext isEqualToString:@".cmx"])		return @"application/x-cmx";
		if ([ext isEqualToString:@".crl"])		return @"application/pkix-cr@";
		if ([ext isEqualToString:@".csi"])		return @"application/x-csi";
		if ([ext isEqualToString:@".cut"])		return @"application/x-cut";
		if ([ext isEqualToString:@".dbm"])		return @"application/x-dbm";
		if ([ext isEqualToString:@".cmp"])		return @"application/x-cmp";
		if ([ext isEqualToString:@".cot"])		return @"application/x-cot";
		if ([ext isEqualToString:@".crt"])		return @"application/x-x509-ca-cert";
		if ([ext isEqualToString:@".dbf"])		return @"application/x-dbf";
		if ([ext isEqualToString:@".dbx"])		return @"application/x-dbx";
		if ([ext isEqualToString:@".dcx"])		return @"application/x-dcx";
		if ([ext isEqualToString:@".dgn"])		return @"application/x-dgn";
		if ([ext isEqualToString:@".dll"])		return @"application/x-msdownload";
		if ([ext isEqualToString:@".dot"])		return @"application/msword";
		if ([ext isEqualToString:@".der"])		return @"application/x-x509-ca-cert";
		if ([ext isEqualToString:@".dib"])		return @"application/x-dib";
		if ([ext isEqualToString:@".doc"])		return @"application/msword";
		if ([ext isEqualToString:@".drw"])		return @"application/x-drw";
		if ([ext isEqualToString:@".dwf"])		return @"application/x-dwf";
		if ([ext isEqualToString:@".dxb"])		return @"application/x-dxb";
		if ([ext isEqualToString:@".edn"])		return @"application/vnd.adobe.edn";
		if ([ext isEqualToString:@".dwg"])		return @"application/x-dwg";
		if ([ext isEqualToString:@".dxf"])		return @"application/x-dxf";
		if ([ext isEqualToString:@".emf"])		return @"application/x-emf";
		if ([ext isEqualToString:@".epi"])		return @"application/x-epi";
		if ([ext isEqualToString:@".eps"])		return @"application/postscript";
		if ([ext isEqualToString:@".exe"])		return @"application/x-msdownload";
		if ([ext isEqualToString:@".fdf"])		return @"application/vnd.fdf";
		if ([ext isEqualToString:@".eps"])		return @"application/x-ps";
		if ([ext isEqualToString:@".etd"])		return @"application/x-ebx";
		if ([ext isEqualToString:@".fif"])		return @"application/fractals";
		if ([ext isEqualToString:@".frm"])		return @"application/x-frm";
		if ([ext isEqualToString:@".gbr"])		return @"application/x-gbr";
		if ([ext isEqualToString:@".g4"])		return @"application/x-g4";
		if ([ext isEqualToString:@".gl2"])		return @"application/x-gl2";
		if ([ext isEqualToString:@".hgl"])		return @"application/x-hg@";
		if ([ext isEqualToString:@".hpg"])		return @"application/x-hpg@";
		if ([ext isEqualToString:@".hqx"])		return @"application/mac-binhex40";
		if ([ext isEqualToString:@".hta"])		return @"application/hta";
		if ([ext isEqualToString:@".gp4"])		return @"application/x-gp4";
		if ([ext isEqualToString:@".hmr"])		return @"application/x-hmr";
		if ([ext isEqualToString:@".hpl"])		return @"application/x-hp@";
		if ([ext isEqualToString:@".hrf"])		return @"application/x-hrf";
		if ([ext isEqualToString:@".icb"])		return @"application/x-icb";
		if ([ext isEqualToString:@".ico"])		return @"application/x-ico";
		if ([ext isEqualToString:@".ig4"])		return @"application/x-g4";
		if ([ext isEqualToString:@".iii"])		return @"application/x-iphone";
		if ([ext isEqualToString:@".ins"])		return @"application/x-internet-signup";
		if ([ext isEqualToString:@".iff"])		return @"application/x-iff";
		if ([ext isEqualToString:@".igs"])		return @"application/x-igs";
		if ([ext isEqualToString:@".img"])		return @"application/x-img";
		if ([ext isEqualToString:@".isp"])		return @"application/x-internet-signup";
		if ([ext isEqualToString:@".jpe"])		return @"application/x-jpe";
		if ([ext isEqualToString:@".js"])		return @"application/x-javascript";
		if ([ext isEqualToString:@".jpg"])		return @"application/x-jpg";
		if ([ext isEqualToString:@".lar"])		return @"application/x-laplayer-reg";
		if ([ext isEqualToString:@".latex"])	return @"application/x-latex";
		if ([ext isEqualToString:@".lbm"])		return @"application/x-lbm";
		if ([ext isEqualToString:@".ls"])		return @"application/x-javascript";
		if ([ext isEqualToString:@".ltr"])		return @"application/x-ltr";
		if ([ext isEqualToString:@".man"])		return @"application/x-troff-man";
		if ([ext isEqualToString:@".mdb"])		return @"application/msaccess";
		if ([ext isEqualToString:@".mac"])		return @"application/x-mac";
		if ([ext isEqualToString:@".mdb"])		return @"application/x-mdb";
		if ([ext isEqualToString:@".mfp"])		return @"application/x-shockwave-flash";
		if ([ext isEqualToString:@".mi"])		return @"application/x-mi";
		if ([ext isEqualToString:@".mil"])		return @"application/x-mi@";
		if ([ext isEqualToString:@".mocha"])	return @"application/x-javascript";
		if ([ext isEqualToString:@".mpd"])		return @"application/vnd.ms-project";
		if ([ext isEqualToString:@".mpp"])		return @"application/vnd.ms-project";
		if ([ext isEqualToString:@".mpt"])		return @"application/vnd.ms-project";
		if ([ext isEqualToString:@".mpw"])		return @"application/vnd.ms-project";
		if ([ext isEqualToString:@".mpx"])		return @"application/vnd.ms-project";
		if ([ext isEqualToString:@".mxp"])		return @"application/x-mmxp";
		if ([ext isEqualToString:@".nrf"])		return @"application/x-nrf";
		if ([ext isEqualToString:@".out"])		return @"application/x-out";
		if ([ext isEqualToString:@".p12"])		return @"application/x-pkcs12";
		if ([ext isEqualToString:@".p7c"])		return @"application/pkcs7-mime";
		if ([ext isEqualToString:@".p7r"])		return @"application/x-pkcs7-certreqresp";
		if ([ext isEqualToString:@".pc5"])		return @"application/x-pc5";
		if ([ext isEqualToString:@".pc@"])		return @"application/x-pc@";
		if ([ext isEqualToString:@".pdx"])		return @"application/vnd.adobe.pdx";
		if ([ext isEqualToString:@".pgl"])		return @"application/x-pg@";
		if ([ext isEqualToString:@".pko"])		return @"application/vnd.ms-pki.pko";
		if ([ext isEqualToString:@".p10"])		return @"application/pkcs10";
		if ([ext isEqualToString:@".p7b"])		return @"application/x-pkcs7-certificates";
		if ([ext isEqualToString:@".p7m"])		return @"application/pkcs7-mime";
		if ([ext isEqualToString:@".p7s"])		return @"application/pkcs7-signature";
		if ([ext isEqualToString:@".pci"])		return @"application/x-pci";
		if ([ext isEqualToString:@".pcx"])		return @"application/x-pcx";
		if ([ext isEqualToString:@".pdf"])		return @"application/pdf";
		if ([ext isEqualToString:@".pfx"])		return @"application/x-pkcs12";
		if ([ext isEqualToString:@".pic"])		return @"application/x-pic";
		if ([ext isEqualToString:@".pl"])		return @"application/x-per@";
		if ([ext isEqualToString:@".plt"])		return @"application/x-plt";
		if ([ext isEqualToString:@".png"])		return @"application/x-png";
		if ([ext isEqualToString:@".ppa"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@".pps"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@".ppt"])		return @"application/x-ppt";
		if ([ext isEqualToString:@".prf"])		return @"application/pics-rules";
		if ([ext isEqualToString:@".prt"])		return @"application/x-prt";
		if ([ext isEqualToString:@".ps"])		return @"application/postscript";
		if ([ext isEqualToString:@".pwz"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@".ra"])		return @"audio/vnd.rn-realaudio";
		if ([ext isEqualToString:@".ras"])		return @"application/x-ras";
		if ([ext isEqualToString:@".pot"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@".ppm"])		return @"application/x-ppm";
		if ([ext isEqualToString:@".ppt"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@".pr"])		return @"application/x-pr";
		if ([ext isEqualToString:@".prn"])		return @"application/x-prn";
		if ([ext isEqualToString:@".ps"])		return @"application/x-ps"; 
		if ([ext isEqualToString:@".ptn"])		return @"application/x-ptn";
		if ([ext isEqualToString:@".red"])		return @"application/x-red";
		if ([ext isEqualToString:@".rjs"])		return @"application/vnd.rn-realsystem-rjs";
		if ([ext isEqualToString:@".rlc"])		return @"application/x-rlc";
		if ([ext isEqualToString:@".rm"])		return @"application/vnd.rn-realmedia";
		if ([ext isEqualToString:@".rat"])		return @"application/rat-file";
		if ([ext isEqualToString:@".rec"])		return @"application/vnd.rn-recording";
		if ([ext isEqualToString:@".rgb"])		return @"application/x-rgb";
		if ([ext isEqualToString:@".rjt"])		return @"application/vnd.rn-realsystem-rjt";
		if ([ext isEqualToString:@".rle"])		return @"application/x-rle";
		if ([ext isEqualToString:@".rmf"])		return @"application/vnd.adobe.rmf";
		if ([ext isEqualToString:@".rmj"])		return @"application/vnd.rn-realsystem-rmj";
		if ([ext isEqualToString:@".rmp"])		return @"application/vnd.rn-rn_music_package";
		if ([ext isEqualToString:@".rmvb"])		return @"application/vnd.rn-realmedia-vbr";
		if ([ext isEqualToString:@".rnx"])		return @"application/vnd.rn-realplayer";
		if ([ext isEqualToString:@".rpm"])		return @"audio/x-pn-realaudio-plugin";
		if ([ext isEqualToString:@".rms"])		return @"application/vnd.rn-realmedia-secure"; 
		if ([ext isEqualToString:@".rmx"])		return @"application/vnd.rn-realsystem-rmx";
		if ([ext isEqualToString:@".rsml"])		return @"application/vnd.rn-rsm@";
		if ([ext isEqualToString:@".rtf"])		return @"application/msword";
		if ([ext isEqualToString:@".rv"])		return @"video/vnd.rn-realvideo";
		if ([ext isEqualToString:@".sat"])		return @"application/x-sat";
		if ([ext isEqualToString:@".sdw"])		return @"application/x-sdw";
		if ([ext isEqualToString:@".slb"])		return @"application/x-slb";
		if ([ext isEqualToString:@".rtf"])		return @"application/x-rtf";
		if ([ext isEqualToString:@".sam"])		return @"application/x-sam";
		if ([ext isEqualToString:@".sdp"])		return @"application/sdp";
		if ([ext isEqualToString:@".sit"])		return @"application/x-stuffit";
		if ([ext isEqualToString:@".sld"])		return @"application/x-sld";
		if ([ext isEqualToString:@".smi"])		return @"application/smi@";
		if ([ext isEqualToString:@".smk"])		return @"application/x-smk";
		if ([ext isEqualToString:@".smil"])		return @"application/smi@";
		if ([ext isEqualToString:@".spc"])		return @"application/x-pkcs7-certificates";
		if ([ext isEqualToString:@".spl"])		return @"application/futuresplash";
		if ([ext isEqualToString:@".ssm"])		return @"application/streamingmedia";
		if ([ext isEqualToString:@".stl"])		return @"application/vnd.ms-pki.st@";
		if ([ext isEqualToString:@".sst"])		return @"application/vnd.ms-pki.certstore";
		if ([ext isEqualToString:@".tdf"])		return @"application/x-tdf";
		if ([ext isEqualToString:@".tga"])		return @"application/x-tga";
		if ([ext isEqualToString:@".sty"])		return @"application/x-sty";
		if ([ext isEqualToString:@".swf"])		return @"application/x-shockwave-flash";
		if ([ext isEqualToString:@".tg4"])		return @"application/x-tg4";
		if ([ext isEqualToString:@".tif"])		return @"application/x-tif";
		if ([ext isEqualToString:@".vdx"])		return @"application/vnd.visio";
		if ([ext isEqualToString:@".vpg"])		return @"application/x-vpeg005";
		if ([ext isEqualToString:@".vsd"])		return @"application/x-vsd";
		if ([ext isEqualToString:@".vst"])		return @"application/vnd.visio";
		if ([ext isEqualToString:@".vsw"])		return @"application/vnd.visio";
		if ([ext isEqualToString:@".vtx"])		return @"application/vnd.visio";
		if ([ext isEqualToString:@".torrent"])	return @"application/x-bittorrent";
		if ([ext isEqualToString:@".vda"])		return @"application/x-vda";
		if ([ext isEqualToString:@".vsd"])		return @"application/vnd.visio";
		if ([ext isEqualToString:@".vss"])		return @"application/vnd.visio";
		if ([ext isEqualToString:@".vst"])		return @"application/x-vst";
		if ([ext isEqualToString:@".vsx"])		return @"application/vnd.visio";
		if ([ext isEqualToString:@".wb1"])		return @"application/x-wb1";
		if ([ext isEqualToString:@".wb3"])		return @"application/x-wb3";
		if ([ext isEqualToString:@".wiz"])		return @"application/msword";
		if ([ext isEqualToString:@".wk4"])		return @"application/x-wk4";
		if ([ext isEqualToString:@".wks"])		return @"application/x-wks";
		if ([ext isEqualToString:@".wb2"])		return @"application/x-wb2";
		if ([ext isEqualToString:@".wk3"])		return @"application/x-wk3";
		if ([ext isEqualToString:@".wkq"])		return @"application/x-wkq";
		if ([ext isEqualToString:@".wmf"])		return @"application/x-wmf";
		if ([ext isEqualToString:@".wmd"])		return @"application/x-ms-wmd";
		if ([ext isEqualToString:@".wp6"])		return @"application/x-wp6";
		if ([ext isEqualToString:@".wpg"])		return @"application/x-wpg";
		if ([ext isEqualToString:@".wq1"])		return @"application/x-wq1";
		if ([ext isEqualToString:@".wri"])		return @"application/x-wri";
		if ([ext isEqualToString:@".ws"])		return @"application/x-ws";
		if ([ext isEqualToString:@".wmz"])		return @"application/x-ms-wmz";
		if ([ext isEqualToString:@".wpd"])		return @"application/x-wpd";
		if ([ext isEqualToString:@".wpl"])		return @"application/vnd.ms-wp@";
		if ([ext isEqualToString:@".wr1"])		return @"application/x-wr1";
		if ([ext isEqualToString:@".wrk"])		return @"application/x-wrk";
		if ([ext isEqualToString:@".ws2"])		return @"application/x-ws";
		if ([ext isEqualToString:@".xdp"])		return @"application/vnd.adobe.xdp";
		if ([ext isEqualToString:@".xfd"])		return @"application/vnd.adobe.xfd";
		if ([ext isEqualToString:@".xfdf"])		return @"application/vnd.adobe.xfdf";
		if ([ext isEqualToString:@".xls"])		return @"application/vnd.ms-exce@";
		if ([ext isEqualToString:@".xwd"])		return @"application/x-xwd";
		if ([ext isEqualToString:@".sis"])		return @"application/vnd.symbian.instal@";
		if ([ext isEqualToString:@".x_t"])		return @"application/x-x_t";
		if ([ext isEqualToString:@".apk"])		return @"application/vnd.android.package-archive";
		if ([ext isEqualToString:@".x_b"])		return @"application/x-x_b";
		if ([ext isEqualToString:@".sisx"])		return @"application/vnd.symbian.instal@";
		if ([ext isEqualToString:@".ipa"])		return @"application/vnd.iphone";
		if ([ext isEqualToString:@".xap"])		return @"application/x-silverlight-app";
		if ([ext isEqualToString:@".xlw"])		return @"application/x-xlw";
		if ([ext isEqualToString:@".xpl"])		return @"audio/scpls";
		if ([ext isEqualToString:@".anv"])		return @"application/x-anv";
		if ([ext isEqualToString:@".uin"])		return @"application/x-icq";
		if ([ext isEqualToString:@".doc"])		return @"application/msword";
		if ([ext isEqualToString:@".dot"])		return @"application/msword";
		if ([ext isEqualToString:@".docx"])		return @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
		if ([ext isEqualToString:@".dotx"])		return @"application/vnd.openxmlformats-officedocument.wordprocessingml.template";
		if ([ext isEqualToString:@".docm"])		return @"application/vnd.ms-word.document.macroEnabled.12";
		if ([ext isEqualToString:@"dotm"])		return @"application/vnd.ms-word.template.macroEnabled.12";
		if ([ext isEqualToString:@"xls"])		return @"application/vnd.ms-exce@";
		if ([ext isEqualToString:@"xlt"])		return @"application/vnd.ms-exce@";
		if ([ext isEqualToString:@"xla"])		return @"application/vnd.ms-exce@";
		if ([ext isEqualToString:@"xlsx"])		return @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
		if ([ext isEqualToString:@"xltx"])		return @"application/vnd.openxmlformats-officedocument.spreadsheetml.template";
		if ([ext isEqualToString:@"xlsm"])		return @"application/vnd.ms-excel.sheet.macroEnabled.12";
		if ([ext isEqualToString:@"xltm"])		return @"application/vnd.ms-excel.template.macroEnabled.12";
		if ([ext isEqualToString:@"xlam"])		return @"application/vnd.ms-excel.addin.macroEnabled.12";
		if ([ext isEqualToString:@"xlsb"])		return @"application/vnd.ms-excel.sheet.binary.macroEnabled.12";
		if ([ext isEqualToString:@"ppt"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@"pot"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@"pps"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@"ppa"])		return @"application/vnd.ms-powerpoint";
		if ([ext isEqualToString:@"pptx"])		return @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
		if ([ext isEqualToString:@"potx"])		return @"application/vnd.openxmlformats-officedocument.presentationml.template";
		if ([ext isEqualToString:@"ppsx"])		return @"application/vnd.openxmlformats-officedocument.presentationml.slideshow";
		if ([ext isEqualToString:@"ppam"])		return @"application/vnd.ms-powerpoint.addin.macroEnabled.12";
		if ([ext isEqualToString:@"pptm"])		return @"application/vnd.ms-powerpoint.presentation.macroEnabled.12";
		if ([ext isEqualToString:@"potm"])		return @"application/vnd.ms-powerpoint.presentation.macroEnabled.12";
		if ([ext isEqualToString:@"ppsm"])		return @"application/vnd.ms-powerpoint.slideshow.macroEnabled.12";
	}
	return @"application/octet-stream";
}

+(NSDictionary*)GetHeader:(NSArray*)keys
{
    NSMutableArray *headerkeys = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *headerobjects = [NSMutableArray arrayWithCapacity:0];
    for (OssSignKey *key in keys) {
        [headerkeys addObject:key.key];
        [headerobjects addObject:key.value];
    }
    return [NSDictionary dictionaryWithObjects:headerobjects forKeys:headerkeys];
}

+(NSString*)AddHttpOrHttps:(NSString*)url
{
    return [NSString stringWithFormat:@"http://%@",url];
}

@end
