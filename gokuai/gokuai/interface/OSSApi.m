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
    strUrl=[self AddHttpOrHttps:[NSString stringWithFormat:@"%@/",host]];
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
    OSSDeleteMultipleBody *ossbody=[[[OSSDeleteMultipleBody alloc] init] autorelease];
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
    if ([Util getAppDelegate].nContentDisposition) {
        item=[[OssSignKey alloc]init];
        item.key=@"Content-Disposition";
        item.value=[self GetContentType:objectname];
        [array addObject:item];
        [item release];
    }
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
    if ([Util getAppDelegate].nContentDisposition) {
        item=[[OssSignKey alloc]init];
        item.key=@"Content-Disposition";
        item.value=[self GetContentType:objectname];
        [array addObject:item];
        [item release];
    }
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
    item.value=[NSString stringWithFormat:@"/%@/%@",srcbucketname,[srcobjectname urlEncoded]];
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
    if ([Util getAppDelegate].nContentDisposition) {
        item=[[OssSignKey alloc]init];
        item.key=@"Content-Disposition";
        item.value=[self GetContentType:dstobjectname];
        [array addObject:item];
        [item release];
    }
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
    OSSCompleteMultipartUploadBody *ossbody=[[[OSSCompleteMultipartUploadBody alloc] init] autorelease];
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
    [signString appendString:resource];
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
    [signString appendString:resource];
    const char * secretStr = [accesskey UTF8String];
    const char * signStr = [signString UTF8String];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretStr, [accesskey lengthOfBytesUsingEncoding:NSUTF8StringEncoding], signStr, [signString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] autorelease];
    return [NSString stringWithFormat:@"OSS %@:%@",accessid,[HMAC base64Encoded]];
}

+(NSString*)Authorization:(NSArray*)keys
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    NSArray *sortedArray = [keys sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableString *signString = [[[NSMutableString alloc] init] autorelease];
    for (int i=0;i<[sortedArray count];i++) {
        if (i!=0) {
            [signString appendString:@"\n"];
        }
        OssSignKey* sk=[sortedArray objectAtIndex:i];
        [signString appendString:sk.value];
    }
    NSString * strKey=@"staycloud";
    const char * secretStr = [strKey UTF8String];
    const char * signStr = [signString UTF8String];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretStr, [strKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding], signStr, [signString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] autorelease];
    return [HMAC base64Encoded]; 
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
    [signString appendString:resource];
    const char * secretStr = [[Util getAppDelegate].strAccessKey UTF8String];
    const char * signStr = [signString UTF8String];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretStr, [[Util getAppDelegate].strAccessKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding], signStr, [signString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] autorelease];
    return [NSString stringWithFormat:@"%@",[HMAC base64Encoded]];
}

+(NSString*)Signature:(NSString*)method keys:(NSArray*)keys
{
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    NSArray *sortedArray = [keys sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableString *signString = [[[NSMutableString alloc] init] autorelease];
    [signString appendString:method];
    [signString appendString:@"&"];
    [signString appendString:[self percentEncode:@"/"]];
    [signString appendString:@"&"];
    NSMutableString *signString1 = [[[NSMutableString alloc] init] autorelease];
    for (int i=0;i<[sortedArray count];i++) {
        if (i!=0) {
            [signString1 appendString:@"&"];
        }
        OssSignKey* sk=[sortedArray objectAtIndex:i];
        [signString1 appendFormat:@"%@=%@",[self percentEncode:sk.key],[self percentEncode:sk.value]];
    }
    [signString appendString:[self percentEncode:signString1]];
    NSString* temp=[NSString stringWithFormat:@"%@&",[Util getAppDelegate].strAccessKey];
    const char * secretStr = [temp UTF8String];
    const char * signStr = [signString UTF8String];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretStr, [temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding], signStr, [signString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] autorelease];
    return [NSString stringWithFormat:@"%@",[HMAC base64Encoded]];
}

+(NSString*)percentEncode:(NSString*)key
{
    NSString*ret=[key urlEncoded];
    key=[ret stringByReplacingOccurrencesOfString:@"+" withString:@"%%20"];
    ret=[key stringByReplacingOccurrencesOfString:@"*" withString:@"%%2A"];
    key=[ret stringByReplacingOccurrencesOfString:@"%%7E" withString:@"~"];
    return ret;
}
+(NSString*)getcontentdisposition:(NSString*)objectname
{
    NSString* filename=[objectname lastPathComponent];
    
    return [NSString stringWithFormat:@"attachment;filename=\"%@\"",[filename urlEncoded]];
}

+(NSString*)GetContentType:(NSString*)objectname
{
    NSString* ext=[[objectname pathExtension] lowercaseString];
	if (ext.length)
	{
        if ([ext isEqualToString:@"123"])       return @"application/vnd.lotus-1-2-3";
        if ([ext isEqualToString:@"3dml"])      return @"text/vnd.in3d.3dml";
        if ([ext isEqualToString:@"3ds"])		return @"image/x-3ds";
        if ([ext isEqualToString:@"3g2"])		return @"video/3gpp2";
        if ([ext isEqualToString:@"3gp"])		return @"video/3gpp";
        if ([ext isEqualToString:@"7z"])		return @"application/x-7z-compressed";
        if ([ext isEqualToString:@"aab"])		return @"application/x-authorware-bin";
        if ([ext isEqualToString:@"aac"])		return @"audio/x-aac";
        if ([ext isEqualToString:@"aam"])		return @"application/x-authorware-map";
        if ([ext isEqualToString:@"aas"])		return @"application/x-authorware-seg";
        if ([ext isEqualToString:@"abw"])		return @"application/x-abiword";
        if ([ext isEqualToString:@"ac"])		return @"application/pkix-attr-cert";
        if ([ext isEqualToString:@"acc"])		return @"application/vnd.americandynamics.acc";
        if ([ext isEqualToString:@"ace"])		return @"application/x-ace-compressed";
        if ([ext isEqualToString:@"acu"])		return @"application/vnd.acucobol";
        if ([ext isEqualToString:@"acutc"])		return @"application/vnd.acucorp";
        if ([ext isEqualToString:@"adp"])		return @"audio/adpcm";
        if ([ext isEqualToString:@"aep"])		return @"application/vnd.audiograph";
        if ([ext isEqualToString:@"afm"])		return @"application/x-font-type1";
        if ([ext isEqualToString:@"afp"])		return @"application/vnd.ibm.modcap";
        if ([ext isEqualToString:@"ahead"])		return @"application/vnd.ahead.space";
        if ([ext isEqualToString:@"ai"])		return @"application/postscript";
        if ([ext isEqualToString:@"aif"])		return @"audio/x-aiff";
        if ([ext isEqualToString:@"aifc"])		return @"audio/x-aiff";
        if ([ext isEqualToString:@"aiff"])		return @"audio/x-aiff";
        if ([ext isEqualToString:@"air"])		return @"application/vnd.adobe.air-application-installer-package+zip";
        if ([ext isEqualToString:@"ait"])		return @"application/vnd.dvb.ait";
        if ([ext isEqualToString:@"ami"])		return @"application/vnd.amiga.ami";
        if ([ext isEqualToString:@"apk"])		return @"application/vnd.android.package-archive";
        if ([ext isEqualToString:@"appcache"])	return @"text/cache-manifest";
        if ([ext isEqualToString:@"application"])	return @"application/x-ms-application";
        if ([ext isEqualToString:@"apr"])		return @"application/vnd.lotus-approach";
        if ([ext isEqualToString:@"arc"])		return @"application/x-freearc";
        if ([ext isEqualToString:@"asa"])		return @"text/plain";
        if ([ext isEqualToString:@"asax"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"asc"])		return @"application/pgp-signature";
        if ([ext isEqualToString:@"ascx"])		return @"text/plain";
        if ([ext isEqualToString:@"asf"])		return @"video/x-ms-asf";
        if ([ext isEqualToString:@"ashx"])		return @"text/plain";
        if ([ext isEqualToString:@"asm"])		return @"text/x-asm";
        if ([ext isEqualToString:@"asmx"])		return @"text/plain";
        if ([ext isEqualToString:@"aso"])		return @"application/vnd.accpac.simply.aso";
        if ([ext isEqualToString:@"asp"])		return @"text/plain";
        if ([ext isEqualToString:@"aspx"])		return @"text/plain";
        if ([ext isEqualToString:@"asx"])		return @"video/x-ms-asf";
        if ([ext isEqualToString:@"atc"])		return @"application/vnd.acucorp";
        if ([ext isEqualToString:@"atom"])		return @"application/atom+xml";
        if ([ext isEqualToString:@"atomcat"])	return @"application/atomcat+xml";
        if ([ext isEqualToString:@"atomsvc"])	return @"application/atomsvc+xml";
        if ([ext isEqualToString:@"atx"])		return @"application/vnd.antix.game-component";
        if ([ext isEqualToString:@"au"])		return @"audio/basic";
        if ([ext isEqualToString:@"avi"])		return @"video/x-msvideo";
        if ([ext isEqualToString:@"aw"])		return @"application/applixware";
        if ([ext isEqualToString:@"axd"])		return @"text/plain";
        if ([ext isEqualToString:@"azf"])		return @"application/vnd.airzip.filesecure.azf";
        if ([ext isEqualToString:@"azs"])		return @"application/vnd.airzip.filesecure.azs";
        if ([ext isEqualToString:@"azw"])		return @"application/vnd.amazon.ebook";
        if ([ext isEqualToString:@"bat"])		return @"application/x-msdownload";
        if ([ext isEqualToString:@"bcpio"])		return @"application/x-bcpio";
        if ([ext isEqualToString:@"bdf"])		return @"application/x-font-bdf";
        if ([ext isEqualToString:@"bdm"])		return @"application/vnd.syncml.dm+wbxml";
        if ([ext isEqualToString:@"bed"])		return @"application/vnd.realvnc.bed";
        if ([ext isEqualToString:@"bh2"])		return @"application/vnd.fujitsu.oasysprs";
        if ([ext isEqualToString:@"bin"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"blb"])		return @"application/x-blorb";
        if ([ext isEqualToString:@"blorb"])		return @"application/x-blorb";
        if ([ext isEqualToString:@"bmi"])		return @"application/vnd.bmi";
        if ([ext isEqualToString:@"bmp"])		return @"image/bmp";
        if ([ext isEqualToString:@"book"])		return @"application/vnd.framemaker";
        if ([ext isEqualToString:@"box"])		return @"application/vnd.previewsystems.box";
        if ([ext isEqualToString:@"boz"])		return @"application/x-bzip2";
        if ([ext isEqualToString:@"bpk"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"btif"])		return @"image/prs.btif";
        if ([ext isEqualToString:@"bz"])		return @"application/x-bzip";
        if ([ext isEqualToString:@"bz2"])		return @"application/x-bzip2";
        if ([ext isEqualToString:@"c"])         return @"text/x-c";
        if ([ext isEqualToString:@"c11amc"])	return @"application/vnd.cluetrust.cartomobile-config";
        if ([ext isEqualToString:@"c11amz"])	return @"application/vnd.cluetrust.cartomobile-config-pkg";
        if ([ext isEqualToString:@"c4d"])		return @"application/vnd.clonk.c4group";
        if ([ext isEqualToString:@"c4f"])		return @"application/vnd.clonk.c4group";
        if ([ext isEqualToString:@"c4g"])		return @"application/vnd.clonk.c4group";
        if ([ext isEqualToString:@"c4p"])		return @"application/vnd.clonk.c4group";
        if ([ext isEqualToString:@"c4u"])		return @"application/vnd.clonk.c4group";
        if ([ext isEqualToString:@"cab"])		return @"application/vnd.ms-cab-compressed";
        if ([ext isEqualToString:@"caf"])		return @"audio/x-caf";
        if ([ext isEqualToString:@"cap"])		return @"application/vnd.tcpdump.pcap";
        if ([ext isEqualToString:@"car"])		return @"application/vnd.curl.car";
        if ([ext isEqualToString:@"cat"])		return @"application/vnd.ms-pki.seccat";
        if ([ext isEqualToString:@"cb7"])		return @"application/x-cbr";
        if ([ext isEqualToString:@"cba"])		return @"application/x-cbr";
        if ([ext isEqualToString:@"cbr"])		return @"application/x-cbr";
        if ([ext isEqualToString:@"cbt"])		return @"application/x-cbr";
        if ([ext isEqualToString:@"cbz"])		return @"application/x-cbr";
        if ([ext isEqualToString:@"cc"])		return @"text/x-c";
        if ([ext isEqualToString:@"cct"])		return @"application/x-director";
        if ([ext isEqualToString:@"ccxml"])		return @"application/ccxml+xml";
        if ([ext isEqualToString:@"cdbcmsg"])	return @"application/vnd.contact.cmsg";
        if ([ext isEqualToString:@"cdf"])		return @"application/x-netcdf";
        if ([ext isEqualToString:@"cdkey"])		return @"application/vnd.mediastation.cdkey";
        if ([ext isEqualToString:@"cdmia"])		return @"application/cdmi-capability";
        if ([ext isEqualToString:@"cdmic"])		return @"application/cdmi-container";
        if ([ext isEqualToString:@"cdmid"])		return @"application/cdmi-domain";
        if ([ext isEqualToString:@"cdmio"])		return @"application/cdmi-object";
        if ([ext isEqualToString:@"cdmiq"])		return @"application/cdmi-queue";
        if ([ext isEqualToString:@"cdx"])		return @"chemical/x-cdx";
        if ([ext isEqualToString:@"cdxml"])		return @"application/vnd.chemdraw+xml";
        if ([ext isEqualToString:@"cdy"])		return @"application/vnd.cinderella";
        if ([ext isEqualToString:@"cer"])		return @"application/pkix-cert";
        if ([ext isEqualToString:@"cfc"])		return @"application/x-coldfusion";
        if ([ext isEqualToString:@"cfm"])		return @"application/x-coldfusion";
        if ([ext isEqualToString:@"cfs"])		return @"application/x-cfs-compressed";
        if ([ext isEqualToString:@"cgm"])		return @"image/cgm";
        if ([ext isEqualToString:@"chat"])		return @"application/x-chat";
        if ([ext isEqualToString:@"chm"])		return @"application/vnd.ms-htmlhelp";
        if ([ext isEqualToString:@"chrt"])		return @"application/vnd.kde.kchart";
        if ([ext isEqualToString:@"cif"])		return @"chemical/x-cif";
        if ([ext isEqualToString:@"cii"])		return @"application/vnd.anser-web-certificate-issue-initiation";
        if ([ext isEqualToString:@"cil"])		return @"application/vnd.ms-artgalry";
        if ([ext isEqualToString:@"cla"])		return @"application/vnd.claymore";
        if ([ext isEqualToString:@"class"])		return @"application/java-vm";
        if ([ext isEqualToString:@"clkk"])		return @"application/vnd.crick.clicker.keyboard";
        if ([ext isEqualToString:@"clkp"])		return @"application/vnd.crick.clicker.palette";
        if ([ext isEqualToString:@"clkt"])		return @"application/vnd.crick.clicker.template";
        if ([ext isEqualToString:@"clkw"])		return @"application/vnd.crick.clicker.wordbank";
        if ([ext isEqualToString:@"clkx"])		return @"application/vnd.crick.clicker";
        if ([ext isEqualToString:@"clp"])		return @"application/x-msclip";
        if ([ext isEqualToString:@"cmc"])		return @"application/vnd.cosmocaller";
        if ([ext isEqualToString:@"cmdf"])		return @"chemical/x-cmdf";
        if ([ext isEqualToString:@"cml"])		return @"chemical/x-cml";
        if ([ext isEqualToString:@"cmp"])		return @"application/vnd.yellowriver-custom-menu";
        if ([ext isEqualToString:@"cmx"])		return @"image/x-cmx";
        if ([ext isEqualToString:@"cod"])		return @"application/vnd.rim.cod";
        if ([ext isEqualToString:@"com"])		return @"application/x-msdownload";
        if ([ext isEqualToString:@"conf"])		return @"text/plain";
        if ([ext isEqualToString:@"cpio"])		return @"application/x-cpio";
        if ([ext isEqualToString:@"cpp"])		return @"text/x-c";
        if ([ext isEqualToString:@"cpt"])		return @"application/mac-compactpro";
        if ([ext isEqualToString:@"crd"])		return @"application/x-mscardfile";
        if ([ext isEqualToString:@"crl"])		return @"application/pkix-crl";
        if ([ext isEqualToString:@"crt"])		return @"application/x-x509-ca-cert";
        if ([ext isEqualToString:@"crx"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"cryptonote"])	return @"application/vnd.rig.cryptonote";
        if ([ext isEqualToString:@"cs"])		return @"text/plain";
        if ([ext isEqualToString:@"csh"])		return @"application/x-csh";
        if ([ext isEqualToString:@"csml"])		return @"chemical/x-csml";
        if ([ext isEqualToString:@"csp"])		return @"application/vnd.commonspace";
        if ([ext isEqualToString:@"css"])		return @"text/css";
        if ([ext isEqualToString:@"cst"])		return @"application/x-director";
        if ([ext isEqualToString:@"csv"])		return @"text/csv";
        if ([ext isEqualToString:@"cu"])		return @"application/cu-seeme";
        if ([ext isEqualToString:@"curl"])		return @"text/vnd.curl";
        if ([ext isEqualToString:@"cww"])		return @"application/prs.cww";
        if ([ext isEqualToString:@"cxt"])		return @"application/x-director";
        if ([ext isEqualToString:@"cxx"])		return @"text/x-c";
        if ([ext isEqualToString:@"dae"])		return @"model/vnd.collada+xml";
        if ([ext isEqualToString:@"daf"])		return @"application/vnd.mobius.daf";
        if ([ext isEqualToString:@"dart"])		return @"application/vnd.dart";
        if ([ext isEqualToString:@"dataless"])	return @"application/vnd.fdsn.seed";
        if ([ext isEqualToString:@"davmount"])	return @"application/davmount+xml";
        if ([ext isEqualToString:@"dbk"])		return @"application/docbook+xml";
        if ([ext isEqualToString:@"dcr"])		return @"application/x-director";
        if ([ext isEqualToString:@"dcurl"])		return @"text/vnd.curl.dcurl";
        if ([ext isEqualToString:@"dd2"])		return @"application/vnd.oma.dd2+xml";
        if ([ext isEqualToString:@"ddd"])		return @"application/vnd.fujixerox.ddd";
        if ([ext isEqualToString:@"deb"])		return @"application/x-debian-package";
        if ([ext isEqualToString:@"def"])		return @"text/plain";
        if ([ext isEqualToString:@"deploy"])	return @"application/octet-stream";
        if ([ext isEqualToString:@"der"])		return @"application/x-x509-ca-cert";
        if ([ext isEqualToString:@"dfac"])		return @"application/vnd.dreamfactory";
        if ([ext isEqualToString:@"dgc"])		return @"application/x-dgc-compressed";
        if ([ext isEqualToString:@"dic"])		return @"text/x-c";
        if ([ext isEqualToString:@"dir"])		return @"application/x-director";
        if ([ext isEqualToString:@"dis"])		return @"application/vnd.mobius.dis";
        if ([ext isEqualToString:@"dist"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"distz"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"djv"])		return @"image/vnd.djvu";
        if ([ext isEqualToString:@"djvu"])		return @"image/vnd.djvu";
        if ([ext isEqualToString:@"dll"])		return @"application/x-msdownload";
        if ([ext isEqualToString:@"dmg"])		return @"application/x-apple-diskimage";
        if ([ext isEqualToString:@"dmp"])		return @"application/vnd.tcpdump.pcap";
        if ([ext isEqualToString:@"dms"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"dna"])		return @"application/vnd.dna";
        if ([ext isEqualToString:@"doc"])		return @"application/msword";
        if ([ext isEqualToString:@"docm"])		return @"application/vnd.ms-word.document.macroenabled.12";
        if ([ext isEqualToString:@"docx"])		return @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        if ([ext isEqualToString:@"dot"])		return @"application/msword";
        if ([ext isEqualToString:@"dotm"])		return @"application/vnd.ms-word.template.macroenabled.12";
        if ([ext isEqualToString:@"dotx"])		return @"application/vnd.openxmlformats-officedocument.wordprocessingml.template";
        if ([ext isEqualToString:@"dp"])		return @"application/vnd.osgi.dp";
        if ([ext isEqualToString:@"dpg"])		return @"application/vnd.dpgraph";
        if ([ext isEqualToString:@"dra"])		return @"audio/vnd.dra";
        if ([ext isEqualToString:@"dsc"])		return @"text/prs.lines.tag";
        if ([ext isEqualToString:@"dssc"])		return @"application/dssc+der";
        if ([ext isEqualToString:@"dtb"])		return @"application/x-dtbook+xml";
        if ([ext isEqualToString:@"dtd"])		return @"application/xml-dtd";
        if ([ext isEqualToString:@"dts"])		return @"audio/vnd.dts";
        if ([ext isEqualToString:@"dtshd"])		return @"audio/vnd.dts.hd";
        if ([ext isEqualToString:@"dump"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"dvb"])		return @"video/vnd.dvb.file";
        if ([ext isEqualToString:@"dvi"])		return @"application/x-dvi";
        if ([ext isEqualToString:@"dwf"])		return @"model/vnd.dwf";
        if ([ext isEqualToString:@"dwg"])		return @"image/vnd.dwg";
        if ([ext isEqualToString:@"dxf"])		return @"image/vnd.dxf";
        if ([ext isEqualToString:@"dxp"])		return @"application/vnd.spotfire.dxp";
        if ([ext isEqualToString:@"dxr"])		return @"application/x-director";
        if ([ext isEqualToString:@"ecelp4800"])	return @"audio/vnd.nuera.ecelp4800";
        if ([ext isEqualToString:@"ecelp7470"])	return @"audio/vnd.nuera.ecelp7470";
        if ([ext isEqualToString:@"ecelp9600"])	return @"audio/vnd.nuera.ecelp9600";
        if ([ext isEqualToString:@"ecma"])		return @"application/ecmascript";
        if ([ext isEqualToString:@"edm"])		return @"application/vnd.novadigm.edm";
        if ([ext isEqualToString:@"edx"])		return @"application/vnd.novadigm.edx";
        if ([ext isEqualToString:@"efif"])		return @"application/vnd.picsel";
        if ([ext isEqualToString:@"ei6"])		return @"application/vnd.pg.osasli";
        if ([ext isEqualToString:@"elc"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"emf"])		return @"application/x-msmetafile";
        if ([ext isEqualToString:@"eml"])		return @"message/rfc822";
        if ([ext isEqualToString:@"emma"])		return @"application/emma+xml";
        if ([ext isEqualToString:@"emz"])		return @"application/x-msmetafile";
        if ([ext isEqualToString:@"eol"])		return @"audio/vnd.digital-winds";
        if ([ext isEqualToString:@"eot"])		return @"application/vnd.ms-fontobject";
        if ([ext isEqualToString:@"eps"])		return @"application/postscript";
        if ([ext isEqualToString:@"epub"])		return @"application/epub+zip";
        if ([ext isEqualToString:@"es3"])		return @"application/vnd.eszigno3+xml";
        if ([ext isEqualToString:@"esa"])		return @"application/vnd.osgi.subsystem";
        if ([ext isEqualToString:@"esf"])		return @"application/vnd.epson.esf";
        if ([ext isEqualToString:@"et3"])		return @"application/vnd.eszigno3+xml";
        if ([ext isEqualToString:@"etx"])		return @"text/x-setext";
        if ([ext isEqualToString:@"eva"])		return @"application/x-eva";
        if ([ext isEqualToString:@"evy"])		return @"application/x-envoy";
        if ([ext isEqualToString:@"exe"])		return @"application/x-msdownload";
        if ([ext isEqualToString:@"exi"])		return @"application/exi";
        if ([ext isEqualToString:@"ext"])		return @"application/vnd.novadigm.ext";
        if ([ext isEqualToString:@"ez"])		return @"application/andrew-inset";
        if ([ext isEqualToString:@"ez2"])		return @"application/vnd.ezpix-album";
        if ([ext isEqualToString:@"ez3"])		return @"application/vnd.ezpix-package";
        if ([ext isEqualToString:@"f"])         return @"text/x-fortran";
        if ([ext isEqualToString:@"f4v"])		return @"video/x-f4v";
        if ([ext isEqualToString:@"f77"])		return @"text/x-fortran";
        if ([ext isEqualToString:@"f90"])		return @"text/x-fortran";
        if ([ext isEqualToString:@"fbs"])		return @"image/vnd.fastbidsheet";
        if ([ext isEqualToString:@"fcdt"])		return @"application/vnd.adobe.formscentral.fcdt";
        if ([ext isEqualToString:@"fcs"])		return @"application/vnd.isac.fcs";
        if ([ext isEqualToString:@"fdf"])		return @"application/vnd.fdf";
        if ([ext isEqualToString:@"fe_launch"])	return @"application/vnd.denovo.fcselayout-link";
        if ([ext isEqualToString:@"fg5"])		return @"application/vnd.fujitsu.oasysgp";
        if ([ext isEqualToString:@"fgd"])		return @"application/x-director";
        if ([ext isEqualToString:@"fh"])		return @"image/x-freehand";
        if ([ext isEqualToString:@"fh4"])		return @"image/x-freehand";
        if ([ext isEqualToString:@"fh5"])		return @"image/x-freehand";
        if ([ext isEqualToString:@"fh7"])		return @"image/x-freehand";
        if ([ext isEqualToString:@"fhc"])		return @"image/x-freehand";
        if ([ext isEqualToString:@"fig"])		return @"application/x-xfig";
        if ([ext isEqualToString:@"flac"])		return @"audio/x-flac";
        if ([ext isEqualToString:@"fli"])		return @"video/x-fli";
        if ([ext isEqualToString:@"flo"])		return @"application/vnd.micrografx.flo";
        if ([ext isEqualToString:@"flv"])		return @"video/x-flv";
        if ([ext isEqualToString:@"flw"])		return @"application/vnd.kde.kivio";
        if ([ext isEqualToString:@"flx"])		return @"text/vnd.fmi.flexstor";
        if ([ext isEqualToString:@"fly"])		return @"text/vnd.fly";
        if ([ext isEqualToString:@"fm"])		return @"application/vnd.framemaker";
        if ([ext isEqualToString:@"fnc"])		return @"application/vnd.frogans.fnc";
        if ([ext isEqualToString:@"for"])		return @"text/x-fortran";
        if ([ext isEqualToString:@"fpx"])		return @"image/vnd.fpx";
        if ([ext isEqualToString:@"frame"])		return @"application/vnd.framemaker";
        if ([ext isEqualToString:@"fsc"])		return @"application/vnd.fsc.weblaunch";
        if ([ext isEqualToString:@"fst"])		return @"image/vnd.fst";
        if ([ext isEqualToString:@"ftc"])		return @"application/vnd.fluxtime.clip";
        if ([ext isEqualToString:@"fti"])		return @"application/vnd.anser-web-funds-transfer-initiation";
        if ([ext isEqualToString:@"fvt"])		return @"video/vnd.fvt";
        if ([ext isEqualToString:@"fxp"])		return @"application/vnd.adobe.fxp";
        if ([ext isEqualToString:@"fxpl"])		return @"application/vnd.adobe.fxp";
        if ([ext isEqualToString:@"fzs"])		return @"application/vnd.fuzzysheet";
        if ([ext isEqualToString:@"g2w"])		return @"application/vnd.geoplan";
        if ([ext isEqualToString:@"g3"])		return @"image/g3fax";
        if ([ext isEqualToString:@"g3w"])		return @"application/vnd.geospace";
        if ([ext isEqualToString:@"gac"])		return @"application/vnd.groove-account";
        if ([ext isEqualToString:@"gam"])		return @"application/x-tads";
        if ([ext isEqualToString:@"gbr"])		return @"application/rpki-ghostbusters";
        if ([ext isEqualToString:@"gca"])		return @"application/x-gca-compressed";
        if ([ext isEqualToString:@"gdl"])		return @"model/vnd.gdl";
        if ([ext isEqualToString:@"geo"])		return @"application/vnd.dynageo";
        if ([ext isEqualToString:@"gex"])		return @"application/vnd.geometry-explorer";
        if ([ext isEqualToString:@"ggb"])		return @"application/vnd.geogebra.file";
        if ([ext isEqualToString:@"ggt"])		return @"application/vnd.geogebra.tool";
        if ([ext isEqualToString:@"ghf"])		return @"application/vnd.groove-help";
        if ([ext isEqualToString:@"gif"])		return @"image/gif";
        if ([ext isEqualToString:@"gim"])		return @"application/vnd.groove-identity-message";
        if ([ext isEqualToString:@"gml"])		return @"application/gml+xml";
        if ([ext isEqualToString:@"gmx"])		return @"application/vnd.gmx";
        if ([ext isEqualToString:@"gnumeric"])	return @"application/x-gnumeric";
        if ([ext isEqualToString:@"gph"])		return @"application/vnd.flographit";
        if ([ext isEqualToString:@"gpx"])		return @"application/gpx+xml";
        if ([ext isEqualToString:@"gqf"])		return @"application/vnd.grafeq";
        if ([ext isEqualToString:@"gqs"])		return @"application/vnd.grafeq";
        if ([ext isEqualToString:@"gram"])		return @"application/srgs";
        if ([ext isEqualToString:@"gramps"])	return @"application/x-gramps-xml";
        if ([ext isEqualToString:@"gre"])		return @"application/vnd.geometry-explorer";
        if ([ext isEqualToString:@"grv"])		return @"application/vnd.groove-injector";
        if ([ext isEqualToString:@"grxml"])		return @"application/srgs+xml";
        if ([ext isEqualToString:@"gsf"])		return @"application/x-font-ghostscript";
        if ([ext isEqualToString:@"gtar"])		return @"application/x-gtar";
        if ([ext isEqualToString:@"gtm"])		return @"application/vnd.groove-tool-message";
        if ([ext isEqualToString:@"gtw"])		return @"model/vnd.gtw";
        if ([ext isEqualToString:@"gv"])		return @"text/vnd.graphviz";
        if ([ext isEqualToString:@"gxf"])		return @"application/gxf";
        if ([ext isEqualToString:@"gxt"])		return @"application/vnd.geonext";
        if ([ext isEqualToString:@"gz"])		return @"application/x-gzip";
        if ([ext isEqualToString:@"h"])         return @"text/x-c";
        if ([ext isEqualToString:@"h261"])		return @"video/h261";
        if ([ext isEqualToString:@"h263"])		return @"video/h263";
        if ([ext isEqualToString:@"h264"])		return @"video/h264";
        if ([ext isEqualToString:@"hal"])		return @"application/vnd.hal+xml";
        if ([ext isEqualToString:@"hbci"])		return @"application/vnd.hbci";
        if ([ext isEqualToString:@"hdf"])		return @"application/x-hdf";
        if ([ext isEqualToString:@"hh"])		return @"text/x-c";
        if ([ext isEqualToString:@"hlp"])		return @"application/winhlp";
        if ([ext isEqualToString:@"hpgl"])		return @"application/vnd.hp-hpgl";
        if ([ext isEqualToString:@"hpid"])		return @"application/vnd.hp-hpid";
        if ([ext isEqualToString:@"hps"])		return @"application/vnd.hp-hps";
        if ([ext isEqualToString:@"hqx"])		return @"application/mac-binhex40";
        if ([ext isEqualToString:@"hta"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"htc"])		return @"text/html";
        if ([ext isEqualToString:@"htke"])		return @"application/vnd.kenameaapp";
        if ([ext isEqualToString:@"htm"])		return @"text/html";
        if ([ext isEqualToString:@"html"])		return @"text/html";
        if ([ext isEqualToString:@"hvd"])		return @"application/vnd.yamaha.hv-dic";
        if ([ext isEqualToString:@"hvp"])		return @"application/vnd.yamaha.hv-voice";
        if ([ext isEqualToString:@"hvs"])		return @"application/vnd.yamaha.hv-script";
        if ([ext isEqualToString:@"i2g"])		return @"application/vnd.intergeo";
        if ([ext isEqualToString:@"icc"])		return @"application/vnd.iccprofile";
        if ([ext isEqualToString:@"ice"])		return @"x-conference/x-cooltalk";
        if ([ext isEqualToString:@"icm"])		return @"application/vnd.iccprofile";
        if ([ext isEqualToString:@"ico"])		return @"image/x-icon";
        if ([ext isEqualToString:@"ics"])		return @"text/calendar";
        if ([ext isEqualToString:@"ief"])		return @"image/ief";
        if ([ext isEqualToString:@"ifb"])		return @"text/calendar";
        if ([ext isEqualToString:@"ifm"])		return @"application/vnd.shana.informed.formdata";
        if ([ext isEqualToString:@"iges"])		return @"model/iges";
        if ([ext isEqualToString:@"igl"])		return @"application/vnd.igloader";
        if ([ext isEqualToString:@"igm"])		return @"application/vnd.insors.igm";
        if ([ext isEqualToString:@"igs"])		return @"model/iges";
        if ([ext isEqualToString:@"igx"])		return @"application/vnd.micrografx.igx";
        if ([ext isEqualToString:@"iif"])		return @"application/vnd.shana.informed.interchange";
        if ([ext isEqualToString:@"imp"])		return @"application/vnd.accpac.simply.imp";
        if ([ext isEqualToString:@"ims"])		return @"application/vnd.ms-ims";
        if ([ext isEqualToString:@"in"])		return @"text/plain";
        if ([ext isEqualToString:@"ini"])		return @"text/plain";
        if ([ext isEqualToString:@"ink"])		return @"application/inkml+xml";
        if ([ext isEqualToString:@"inkml"])		return @"application/inkml+xml";
        if ([ext isEqualToString:@"install"])	return @"application/x-install-instructions";
        if ([ext isEqualToString:@"iota"])		return @"application/vnd.astraea-software.iota";
        if ([ext isEqualToString:@"ipa"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"ipfix"])		return @"application/ipfix";
        if ([ext isEqualToString:@"ipk"])		return @"application/vnd.shana.informed.package";
        if ([ext isEqualToString:@"irm"])		return @"application/vnd.ibm.rights-management";
        if ([ext isEqualToString:@"irp"])		return @"application/vnd.irepository.package+xml";
        if ([ext isEqualToString:@"iso"])		return @"application/x-iso9660-image";
        if ([ext isEqualToString:@"itp"])		return @"application/vnd.shana.informed.formtemplate";
        if ([ext isEqualToString:@"ivp"])		return @"application/vnd.immervision-ivp";
        if ([ext isEqualToString:@"ivu"])		return @"application/vnd.immervision-ivu";
        if ([ext isEqualToString:@"jad"])		return @"text/vnd.sun.j2me.app-descriptor";
        if ([ext isEqualToString:@"jam"])		return @"application/vnd.jam";
        if ([ext isEqualToString:@"jar"])		return @"application/java-archive";
        if ([ext isEqualToString:@"java"])		return @"text/x-java-source";
        if ([ext isEqualToString:@"jisp"])		return @"application/vnd.jisp";
        if ([ext isEqualToString:@"jlt"])		return @"application/vnd.hp-jlyt";
        if ([ext isEqualToString:@"jnlp"])		return @"application/x-java-jnlp-file";
        if ([ext isEqualToString:@"joda"])		return @"application/vnd.joost.joda-archive";
        if ([ext isEqualToString:@"jpe"])		return @"image/jpeg";
        if ([ext isEqualToString:@"jpeg"])		return @"image/jpeg";
        if ([ext isEqualToString:@"jpg"])		return @"image/jpeg";
        if ([ext isEqualToString:@"jpgm"])		return @"video/jpm";
        if ([ext isEqualToString:@"jpgv"])		return @"video/jpeg";
        if ([ext isEqualToString:@"jpm"])		return @"video/jpm";
        if ([ext isEqualToString:@"js"])		return @"text/javascript";
        if ([ext isEqualToString:@"json"])		return @"application/json";
        if ([ext isEqualToString:@"jsonml"])	return @"application/jsonml+json";
        if ([ext isEqualToString:@"kar"])		return @"audio/midi";
        if ([ext isEqualToString:@"karbon"])	return @"application/vnd.kde.karbon";
        if ([ext isEqualToString:@"kfo"])		return @"application/vnd.kde.kformula";
        if ([ext isEqualToString:@"kia"])		return @"application/vnd.kidspiration";
        if ([ext isEqualToString:@"kml"])		return @"application/vnd.google-earth.kml+xml";
        if ([ext isEqualToString:@"kmz"])		return @"application/vnd.google-earth.kmz";
        if ([ext isEqualToString:@"kne"])		return @"application/vnd.kinar";
        if ([ext isEqualToString:@"knp"])		return @"application/vnd.kinar";
        if ([ext isEqualToString:@"kon"])		return @"application/vnd.kde.kontour";
        if ([ext isEqualToString:@"kpr"])		return @"application/vnd.kde.kpresenter";
        if ([ext isEqualToString:@"kpt"])		return @"application/vnd.kde.kpresenter";
        if ([ext isEqualToString:@"kpxx"])		return @"application/vnd.ds-keypoint";
        if ([ext isEqualToString:@"ksp"])		return @"application/vnd.kde.kspread";
        if ([ext isEqualToString:@"ktr"])		return @"application/vnd.kahootz";
        if ([ext isEqualToString:@"ktx"])		return @"image/ktx";
        if ([ext isEqualToString:@"ktz"])		return @"application/vnd.kahootz";
        if ([ext isEqualToString:@"kwd"])		return @"application/vnd.kde.kword";
        if ([ext isEqualToString:@"kwt"])		return @"application/vnd.kde.kword";
        if ([ext isEqualToString:@"lasxml"])	return @"application/vnd.las.las+xml";
        if ([ext isEqualToString:@"latex"])		return @"application/x-latex";
        if ([ext isEqualToString:@"lbd"])		return @"application/vnd.llamagraphics.life-balance.desktop";
        if ([ext isEqualToString:@"lbe"])		return @"application/vnd.llamagraphics.life-balance.exchange+xml";
        if ([ext isEqualToString:@"les"])		return @"application/vnd.hhe.lesson-player";
        if ([ext isEqualToString:@"lha"])		return @"application/x-lzh-compressed";
        if ([ext isEqualToString:@"link66"])	return @"application/vnd.route66.link66+xml";
        if ([ext isEqualToString:@"list"])		return @"text/plain";
        if ([ext isEqualToString:@"list3820"])	return @"application/vnd.ibm.modcap";
        if ([ext isEqualToString:@"listafp"])	return @"application/vnd.ibm.modcap";
        if ([ext isEqualToString:@"lnk"])		return @"application/x-ms-shortcut";
        if ([ext isEqualToString:@"log"])		return @"text/plain";
        if ([ext isEqualToString:@"lostxml"])	return @"application/lost+xml";
        if ([ext isEqualToString:@"lrf"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"lrm"])		return @"application/vnd.ms-lrm";
        if ([ext isEqualToString:@"ltf"])		return @"application/vnd.frogans.ltf";
        if ([ext isEqualToString:@"lvp"])		return @"audio/vnd.lucent.voice";
        if ([ext isEqualToString:@"lwp"])		return @"application/vnd.lotus-wordpro";
        if ([ext isEqualToString:@"lz"])		return @"application/x-lzip";
        if ([ext isEqualToString:@"lzh"])		return @"application/x-lzh-compressed";
        if ([ext isEqualToString:@"lzma"])		return @"application/x-lzma";
        if ([ext isEqualToString:@"lzo"])		return @"application/x-lzop";
        if ([ext isEqualToString:@"m13"])		return @"application/x-msmediaview";
        if ([ext isEqualToString:@"m14"])		return @"application/x-msmediaview";
        if ([ext isEqualToString:@"m1v"])		return @"video/mpeg";
        if ([ext isEqualToString:@"m21"])		return @"application/mp21";
        if ([ext isEqualToString:@"m2a"])		return @"audio/mpeg";
        if ([ext isEqualToString:@"m2v"])		return @"video/mpeg";
        if ([ext isEqualToString:@"m3a"])		return @"audio/mpeg";
        if ([ext isEqualToString:@"m3u"])		return @"audio/x-mpegurl";
        if ([ext isEqualToString:@"m3u8"])		return @"application/vnd.apple.mpegurl";
        if ([ext isEqualToString:@"m4a"])		return @"audio/mp4";
        if ([ext isEqualToString:@"m4u"])		return @"video/vnd.mpegurl";
        if ([ext isEqualToString:@"m4v"])		return @"video/mp4";
        if ([ext isEqualToString:@"ma"])		return @"application/mathematica";
        if ([ext isEqualToString:@"mads"])		return @"application/mads+xml";
        if ([ext isEqualToString:@"mag"])		return @"application/vnd.ecowin.chart";
        if ([ext isEqualToString:@"mkd"])		return @"text/html";
        if ([ext isEqualToString:@"maker"])		return @"application/vnd.framemaker";
        if ([ext isEqualToString:@"man"])		return @"text/troff";
        if ([ext isEqualToString:@"mar"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"markdown"])	return @"text/plain";
        if ([ext isEqualToString:@"mathml"])	return @"application/mathml+xml";
        if ([ext isEqualToString:@"mb"])		return @"application/mathematica";
        if ([ext isEqualToString:@"mbk"])		return @"application/vnd.mobius.mbk";
        if ([ext isEqualToString:@"mbox"])		return @"application/mbox";
        if ([ext isEqualToString:@"mc1"])		return @"application/vnd.medcalcdata";
        if ([ext isEqualToString:@"mcd"])		return @"application/vnd.mcd";
        if ([ext isEqualToString:@"mcurl"])		return @"text/vnd.curl.mcurl";
        if ([ext isEqualToString:@"md"])		return @"text/plain";
        if ([ext isEqualToString:@"mdb"])		return @"application/x-msaccess";
        if ([ext isEqualToString:@"mdi"])		return @"image/vnd.ms-modi";
        if ([ext isEqualToString:@"me"])		return @"text/troff";
        if ([ext isEqualToString:@"mesh"])		return @"model/mesh";
        if ([ext isEqualToString:@"meta4"])		return @"application/metalink4+xml";
        if ([ext isEqualToString:@"metalink"])	return @"application/metalink+xml";
        if ([ext isEqualToString:@"mets"])		return @"application/mets+xml";
        if ([ext isEqualToString:@"mfm"])		return @"application/vnd.mfmp";
        if ([ext isEqualToString:@"mft"])		return @"application/rpki-manifest";
        if ([ext isEqualToString:@"mgp"])		return @"application/vnd.osgeo.mapguide.package";
        if ([ext isEqualToString:@"mgz"])		return @"application/vnd.proteus.magazine";
        if ([ext isEqualToString:@"mid"])		return @"audio/midi";
        if ([ext isEqualToString:@"midi"])		return @"audio/midi";
        if ([ext isEqualToString:@"mie"])		return @"application/x-mie";
        if ([ext isEqualToString:@"mif"])		return @"application/vnd.mif";
        if ([ext isEqualToString:@"mime"])		return @"message/rfc822";
        if ([ext isEqualToString:@"mj2"])		return @"video/mj2";
        if ([ext isEqualToString:@"mjp2"])		return @"video/mj2";
        if ([ext isEqualToString:@"mk3d"])		return @"video/x-matroska";
        if ([ext isEqualToString:@"mka"])		return @"audio/x-matroska";
        if ([ext isEqualToString:@"mks"])		return @"video/x-matroska";
        if ([ext isEqualToString:@"mkv"])		return @"video/x-matroska";
        if ([ext isEqualToString:@"mlp"])		return @"application/vnd.dolby.mlp";
        if ([ext isEqualToString:@"mmd"])		return @"application/vnd.chipnuts.karaoke-mmd";
        if ([ext isEqualToString:@"mmf"])		return @"application/vnd.smaf";
        if ([ext isEqualToString:@"mmr"])		return @"image/vnd.fujixerox.edmics-mmr";
        if ([ext isEqualToString:@"mng"])		return @"video/x-mng";
        if ([ext isEqualToString:@"mny"])		return @"application/x-msmoney";
        if ([ext isEqualToString:@"mobi"])		return @"application/x-mobipocket-ebook";
        if ([ext isEqualToString:@"mods"])		return @"application/mods+xml";
        if ([ext isEqualToString:@"mov"])		return @"video/quicktime";
        if ([ext isEqualToString:@"movie"])		return @"video/x-sgi-movie";
        if ([ext isEqualToString:@"mp2"])		return @"audio/mpeg";
        if ([ext isEqualToString:@"mp21"])		return @"application/mp21";
        if ([ext isEqualToString:@"mp2a"])		return @"audio/mpeg";
        if ([ext isEqualToString:@"mp3"])		return @"audio/mpeg";
        if ([ext isEqualToString:@"mp4"])		return @"video/mp4";
        if ([ext isEqualToString:@"mp4a"])		return @"audio/mp4";
        if ([ext isEqualToString:@"mp4s"])		return @"application/mp4";
        if ([ext isEqualToString:@"mp4v"])		return @"video/mp4";
        if ([ext isEqualToString:@"mpc"])		return @"application/vnd.mophun.certificate";
        if ([ext isEqualToString:@"mpe"])		return @"video/mpeg";
        if ([ext isEqualToString:@"mpeg"])		return @"video/mpeg";
        if ([ext isEqualToString:@"mpg"])		return @"video/mpeg";
        if ([ext isEqualToString:@"mpg4"])		return @"video/mp4";
        if ([ext isEqualToString:@"mpga"])		return @"audio/mpeg";
        if ([ext isEqualToString:@"mpkg"])		return @"application/vnd.apple.installer+xml";
        if ([ext isEqualToString:@"mpm"])		return @"application/vnd.blueice.multipass";
        if ([ext isEqualToString:@"mpn"])		return @"application/vnd.mophun.application";
        if ([ext isEqualToString:@"mpp"])		return @"application/vnd.ms-project";
        if ([ext isEqualToString:@"mpt"])		return @"application/vnd.ms-project";
        if ([ext isEqualToString:@"mpy"])		return @"application/vnd.ibm.minipay";
        if ([ext isEqualToString:@"mqy"])		return @"application/vnd.mobius.mqy";
        if ([ext isEqualToString:@"mrc"])		return @"application/marc";
        if ([ext isEqualToString:@"mrcx"])		return @"application/marcxml+xml";
        if ([ext isEqualToString:@"ms"])		return @"text/troff";
        if ([ext isEqualToString:@"mscml"])		return @"application/mediaservercontrol+xml";
        if ([ext isEqualToString:@"mseed"])		return @"application/vnd.fdsn.mseed";
        if ([ext isEqualToString:@"mseq"])		return @"application/vnd.mseq";
        if ([ext isEqualToString:@"msf"])		return @"application/vnd.epson.msf";
        if ([ext isEqualToString:@"msh"])		return @"model/mesh";
        if ([ext isEqualToString:@"msi"])		return @"application/x-msdownload";
        if ([ext isEqualToString:@"msl"])		return @"application/vnd.mobius.msl";
        if ([ext isEqualToString:@"msty"])		return @"application/vnd.muvee.style";
        if ([ext isEqualToString:@"mts"])		return @"model/vnd.mts";
        if ([ext isEqualToString:@"mus"])		return @"application/vnd.musician";
        if ([ext isEqualToString:@"musicxml"])	return @"application/vnd.recordare.musicxml+xml";
        if ([ext isEqualToString:@"mvb"])		return @"application/x-msmediaview";
        if ([ext isEqualToString:@"mwf"])		return @"application/vnd.mfer";
        if ([ext isEqualToString:@"mxf"])		return @"application/mxf";
        if ([ext isEqualToString:@"mxl"])		return @"application/vnd.recordare.musicxml";
        if ([ext isEqualToString:@"mxml"])		return @"application/xv+xml";
        if ([ext isEqualToString:@"mxs"])		return @"application/vnd.triscape.mxs";
        if ([ext isEqualToString:@"mxu"])		return @"video/vnd.mpegurl";
        if ([ext isEqualToString:@"n-gage"])	return @"application/vnd.nokia.n-gage.symbian.install";
        if ([ext isEqualToString:@"n3"])		return @"text/n3";
        if ([ext isEqualToString:@"nb"])		return @"application/mathematica";
        if ([ext isEqualToString:@"nbp"])		return @"application/vnd.wolfram.player";
        if ([ext isEqualToString:@"nc"])		return @"application/x-netcdf";
        if ([ext isEqualToString:@"ncx"])		return @"application/x-dtbncx+xml";
        if ([ext isEqualToString:@"nfo"])		return @"text/x-nfo";
        if ([ext isEqualToString:@"ngdat"])		return @"application/vnd.nokia.n-gage.data";
        if ([ext isEqualToString:@"nitf"])		return @"application/vnd.nitf";
        if ([ext isEqualToString:@"nlu"])		return @"application/vnd.neurolanguage.nlu";
        if ([ext isEqualToString:@"nml"])		return @"application/vnd.enliven";
        if ([ext isEqualToString:@"nnd"])		return @"application/vnd.noblenet-directory";
        if ([ext isEqualToString:@"nns"])		return @"application/vnd.noblenet-sealer";
        if ([ext isEqualToString:@"nnw"])		return @"application/vnd.noblenet-web";
        if ([ext isEqualToString:@"npx"])		return @"image/vnd.net-fpx";
        if ([ext isEqualToString:@"nsc"])		return @"application/x-conference";
        if ([ext isEqualToString:@"nsf"])		return @"application/vnd.lotus-notes";
        if ([ext isEqualToString:@"ntf"])		return @"application/vnd.nitf";
        if ([ext isEqualToString:@"nzb"])		return @"application/x-nzb";
        if ([ext isEqualToString:@"oa2"])		return @"application/vnd.fujitsu.oasys2";
        if ([ext isEqualToString:@"oa3"])		return @"application/vnd.fujitsu.oasys3";
        if ([ext isEqualToString:@"oas"])		return @"application/vnd.fujitsu.oasys";
        if ([ext isEqualToString:@"obd"])		return @"application/x-msbinder";
        if ([ext isEqualToString:@"obj"])		return @"application/x-tgif";
        if ([ext isEqualToString:@"oda"])		return @"application/oda";
        if ([ext isEqualToString:@"odb"])		return @"application/vnd.oasis.opendocument.database";
        if ([ext isEqualToString:@"odc"])		return @"application/vnd.oasis.opendocument.chart";
        if ([ext isEqualToString:@"odf"])		return @"application/vnd.oasis.opendocument.formula";
        if ([ext isEqualToString:@"odft"])		return @"application/vnd.oasis.opendocument.formula-template";
        if ([ext isEqualToString:@"odg"])		return @"application/vnd.oasis.opendocument.graphics";
        if ([ext isEqualToString:@"odi"])		return @"application/vnd.oasis.opendocument.image";
        if ([ext isEqualToString:@"odm"])		return @"application/vnd.oasis.opendocument.text-master";
        if ([ext isEqualToString:@"odp"])		return @"application/vnd.oasis.opendocument.presentation";
        if ([ext isEqualToString:@"ods"])		return @"application/vnd.oasis.opendocument.spreadsheet";
        if ([ext isEqualToString:@"odt"])		return @"application/vnd.oasis.opendocument.text";
        if ([ext isEqualToString:@"oga"])		return @"audio/ogg";
        if ([ext isEqualToString:@"ogg"])		return @"audio/ogg";
        if ([ext isEqualToString:@"ogv"])		return @"video/ogg";
        if ([ext isEqualToString:@"ogx"])		return @"application/ogg";
        if ([ext isEqualToString:@"omdoc"])		return @"application/omdoc+xml";
        if ([ext isEqualToString:@"onepkg"])	return @"application/onenote";
        if ([ext isEqualToString:@"onetmp"])	return @"application/onenote";
        if ([ext isEqualToString:@"onetoc"])	return @"application/onenote";
        if ([ext isEqualToString:@"onetoc2"])	return @"application/onenote";
        if ([ext isEqualToString:@"opf"])		return @"application/oebps-package+xml";
        if ([ext isEqualToString:@"opml"])		return @"text/x-opml";
        if ([ext isEqualToString:@"oprc"])		return @"application/vnd.palm";
        if ([ext isEqualToString:@"org"])		return @"application/vnd.lotus-organizer";
        if ([ext isEqualToString:@"osf"])		return @"application/vnd.yamaha.openscoreformat";
        if ([ext isEqualToString:@"osfpvg"])	return @"application/vnd.yamaha.openscoreformat.osfpvg+xml";
        if ([ext isEqualToString:@"otc"])		return @"application/vnd.oasis.opendocument.chart-template";
        if ([ext isEqualToString:@"otf"])		return @"application/x-font-otf";
        if ([ext isEqualToString:@"otg"])		return @"application/vnd.oasis.opendocument.graphics-template";
        if ([ext isEqualToString:@"oth"])		return @"application/vnd.oasis.opendocument.text-web";
        if ([ext isEqualToString:@"oti"])		return @"application/vnd.oasis.opendocument.image-template";
        if ([ext isEqualToString:@"otp"])		return @"application/vnd.oasis.opendocument.presentation-template";
        if ([ext isEqualToString:@"ots"])		return @"application/vnd.oasis.opendocument.spreadsheet-template";
        if ([ext isEqualToString:@"ott"])		return @"application/vnd.oasis.opendocument.text-template";
        if ([ext isEqualToString:@"oxps"])		return @"application/oxps";
        if ([ext isEqualToString:@"oxt"])		return @"application/vnd.openofficeorg.extension";
        if ([ext isEqualToString:@"p"])         return @"text/x-pascal";
        if ([ext isEqualToString:@"p10"])		return @"application/pkcs10";
        if ([ext isEqualToString:@"p12"])		return @"application/x-pkcs12";
        if ([ext isEqualToString:@"p7b"])		return @"application/x-pkcs7-certificates";
        if ([ext isEqualToString:@"p7c"])		return @"application/pkcs7-mime";
        if ([ext isEqualToString:@"p7m"])		return @"application/pkcs7-mime";
        if ([ext isEqualToString:@"p7r"])		return @"application/x-pkcs7-certreqresp";
        if ([ext isEqualToString:@"p7s"])		return @"application/pkcs7-signature";
        if ([ext isEqualToString:@"p8"])		return @"application/pkcs8";
        if ([ext isEqualToString:@"pas"])		return @"text/x-pascal";
        if ([ext isEqualToString:@"paw"])		return @"application/vnd.pawaafile";
        if ([ext isEqualToString:@"pbd"])		return @"application/vnd.powerbuilder6";
        if ([ext isEqualToString:@"pbm"])		return @"image/x-portable-bitmap";
        if ([ext isEqualToString:@"pcap"])		return @"application/vnd.tcpdump.pcap";
        if ([ext isEqualToString:@"pcf"])		return @"application/x-font-pcf";
        if ([ext isEqualToString:@"pcl"])		return @"application/vnd.hp-pcl";
        if ([ext isEqualToString:@"pclxl"])		return @"application/vnd.hp-pclxl";
        if ([ext isEqualToString:@"pct"])		return @"image/x-pict";
        if ([ext isEqualToString:@"pcurl"])		return @"application/vnd.curl.pcurl";
        if ([ext isEqualToString:@"pcx"])		return @"image/x-pcx";
        if ([ext isEqualToString:@"pdb"])		return @"application/vnd.palm";
        if ([ext isEqualToString:@"pdf"])		return @"application/pdf";
        if ([ext isEqualToString:@"pfa"])		return @"application/x-font-type1";
        if ([ext isEqualToString:@"pfb"])		return @"application/x-font-type1";
        if ([ext isEqualToString:@"pfm"])		return @"application/x-font-type1";
        if ([ext isEqualToString:@"pfr"])		return @"application/font-tdpfr";
        if ([ext isEqualToString:@"pfx"])		return @"application/x-pkcs12";
        if ([ext isEqualToString:@"pgm"])		return @"image/x-portable-graymap";
        if ([ext isEqualToString:@"pgn"])		return @"application/x-chess-pgn";
        if ([ext isEqualToString:@"pgp"])		return @"application/pgp-encrypted";
        if ([ext isEqualToString:@"phar"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"php"])		return @"text/plain";
        if ([ext isEqualToString:@"phps"])		return @"application/x-httpd-phps";
        if ([ext isEqualToString:@"pic"])		return @"image/x-pict";
        if ([ext isEqualToString:@"pkg"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"pki"])		return @"application/pkixcmp";
        if ([ext isEqualToString:@"pkipath"])	return @"application/pkix-pkipath";
        if ([ext isEqualToString:@"plb"])		return @"application/vnd.3gpp.pic-bw-large";
        if ([ext isEqualToString:@"plc"])		return @"application/vnd.mobius.plc";
        if ([ext isEqualToString:@"plf"])		return @"application/vnd.pocketlearn";
        if ([ext isEqualToString:@"plist"])		return @"application/x-plist";
        if ([ext isEqualToString:@"pls"])		return @"application/pls+xml";
        if ([ext isEqualToString:@"pml"])		return @"application/vnd.ctc-posml";
        if ([ext isEqualToString:@"png"])		return @"image/png";
        if ([ext isEqualToString:@"pnm"])		return @"image/x-portable-anymap";
        if ([ext isEqualToString:@"portpkg"])	return @"application/vnd.macports.portpkg";
        if ([ext isEqualToString:@"pot"])		return @"application/vnd.ms-powerpoint";
        if ([ext isEqualToString:@"potm"])		return @"application/vnd.ms-powerpoint.template.macroenabled.12";
        if ([ext isEqualToString:@"potx"])		return @"application/vnd.openxmlformats-officedocument.presentationml.template";
        if ([ext isEqualToString:@"ppam"])		return @"application/vnd.ms-powerpoint.addin.macroenabled.12";
        if ([ext isEqualToString:@"ppd"])		return @"application/vnd.cups-ppd";
        if ([ext isEqualToString:@"ppm"])		return @"image/x-portable-pixmap";
        if ([ext isEqualToString:@"pps"])		return @"application/vnd.ms-powerpoint";
        if ([ext isEqualToString:@"ppsm"])		return @"application/vnd.ms-powerpoint.slideshow.macroenabled.12";
        if ([ext isEqualToString:@"ppsx"])		return @"application/vnd.openxmlformats-officedocument.presentationml.slideshow";
        if ([ext isEqualToString:@"ppt"])		return @"application/vnd.ms-powerpoint";
        if ([ext isEqualToString:@"pptm"])		return @"application/vnd.ms-powerpoint.presentation.macroenabled.12";
        if ([ext isEqualToString:@"pptx"])		return @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
        if ([ext isEqualToString:@"pqa"])		return @"application/vnd.palm";
        if ([ext isEqualToString:@"prc"])		return @"application/x-mobipocket-ebook";
        if ([ext isEqualToString:@"pre"])		return @"application/vnd.lotus-freelance";
        if ([ext isEqualToString:@"prf"])		return @"application/pics-rules";
        if ([ext isEqualToString:@"ps"])		return @"application/postscript";
        if ([ext isEqualToString:@"psb"])		return @"application/vnd.3gpp.pic-bw-small";
        if ([ext isEqualToString:@"psd"])		return @"image/vnd.adobe.photoshop";
        if ([ext isEqualToString:@"psf"])		return @"application/x-font-linux-psf";
        if ([ext isEqualToString:@"pskcxml"])	return @"application/pskc+xml";
        if ([ext isEqualToString:@"ptid"])		return @"application/vnd.pvi.ptid1";
        if ([ext isEqualToString:@"pub"])		return @"application/x-mspublisher";
        if ([ext isEqualToString:@"pvb"])		return @"application/vnd.3gpp.pic-bw-var";
        if ([ext isEqualToString:@"pwn"])		return @"application/vnd.3m.post-it-notes";
        if ([ext isEqualToString:@"pya"])		return @"audio/vnd.ms-playready.media.pya";
        if ([ext isEqualToString:@"pyv"])		return @"video/vnd.ms-playready.media.pyv";
        if ([ext isEqualToString:@"qam"])		return @"application/vnd.epson.quickanime";
        if ([ext isEqualToString:@"qbo"])		return @"application/vnd.intu.qbo";
        if ([ext isEqualToString:@"qfx"])		return @"application/vnd.intu.qfx";
        if ([ext isEqualToString:@"qps"])		return @"application/vnd.publishare-delta-tree";
        if ([ext isEqualToString:@"qt"])		return @"video/quicktime";
        if ([ext isEqualToString:@"qwd"])		return @"application/vnd.quark.quarkxpress";
        if ([ext isEqualToString:@"qwt"])		return @"application/vnd.quark.quarkxpress";
        if ([ext isEqualToString:@"qxb"])		return @"application/vnd.quark.quarkxpress";
        if ([ext isEqualToString:@"qxd"])		return @"application/vnd.quark.quarkxpress";
        if ([ext isEqualToString:@"qxl"])		return @"application/vnd.quark.quarkxpress";
        if ([ext isEqualToString:@"qxt"])		return @"application/vnd.quark.quarkxpress";
        if ([ext isEqualToString:@"ra"])		return @"audio/x-pn-realaudio";
        if ([ext isEqualToString:@"ram"])		return @"audio/x-pn-realaudio";
        if ([ext isEqualToString:@"rar"])		return @"application/x-rar-compressed";
        if ([ext isEqualToString:@"ras"])		return @"image/x-cmu-raster";
        if ([ext isEqualToString:@"rb"])		return @"text/plain";
        if ([ext isEqualToString:@"rcprofile"])	return @"application/vnd.ipunplugged.rcprofile";
        if ([ext isEqualToString:@"rdf"])		return @"application/rdf+xml";
        if ([ext isEqualToString:@"rdz"])		return @"application/vnd.data-vision.rdz";
        if ([ext isEqualToString:@"rep"])		return @"application/vnd.businessobjects";
        if ([ext isEqualToString:@"res"])		return @"application/x-dtbresource+xml";
        if ([ext isEqualToString:@"resx"])		return @"text/xml";
        if ([ext isEqualToString:@"rgb"])		return @"image/x-rgb";
        if ([ext isEqualToString:@"rif"])		return @"application/reginfo+xml";
        if ([ext isEqualToString:@"rip"])		return @"audio/vnd.rip";
        if ([ext isEqualToString:@"ris"])		return @"application/x-research-info-systems";
        if ([ext isEqualToString:@"rl"])		return @"application/resource-lists+xml";
        if ([ext isEqualToString:@"rlc"])		return @"image/vnd.fujixerox.edmics-rlc";
        if ([ext isEqualToString:@"rld"])		return @"application/resource-lists-diff+xml";
        if ([ext isEqualToString:@"rm"])		return @"application/vnd.rn-realmedia";
        if ([ext isEqualToString:@"rmi"])		return @"audio/midi";
        if ([ext isEqualToString:@"rmp"])		return @"audio/x-pn-realaudio-plugin";
        if ([ext isEqualToString:@"rms"])		return @"application/vnd.jcp.javame.midlet-rms";
        if ([ext isEqualToString:@"rmvb"])		return @"application/vnd.rn-realmedia-vbr";
        if ([ext isEqualToString:@"rnc"])		return @"application/relax-ng-compact-syntax";
        if ([ext isEqualToString:@"roa"])		return @"application/rpki-roa";
        if ([ext isEqualToString:@"roff"])		return @"text/troff";
        if ([ext isEqualToString:@"rp9"])		return @"application/vnd.cloanto.rp9";
        if ([ext isEqualToString:@"rpm"])		return @"application/x-rpm";
        if ([ext isEqualToString:@"rpss"])		return @"application/vnd.nokia.radio-presets";
        if ([ext isEqualToString:@"rpst"])		return @"application/vnd.nokia.radio-preset";
        if ([ext isEqualToString:@"rq"])		return @"application/sparql-query";
        if ([ext isEqualToString:@"rs"])		return @"application/rls-services+xml";
        if ([ext isEqualToString:@"rsd"])		return @"application/rsd+xml";
        if ([ext isEqualToString:@"rss"])		return @"application/rss+xml";
        if ([ext isEqualToString:@"rtf"])		return @"application/rtf";
        if ([ext isEqualToString:@"rtx"])		return @"text/richtext";
        if ([ext isEqualToString:@"s"])         return @"text/x-asm";
        if ([ext isEqualToString:@"s3m"])		return @"audio/s3m";
        if ([ext isEqualToString:@"s7z"])		return @"application/x-7z-compressed";
        if ([ext isEqualToString:@"saf"])		return @"application/vnd.yamaha.smaf-audio";
        if ([ext isEqualToString:@"safariextz"])    return @"application/octet-stream";
        if ([ext isEqualToString:@"sass"])		return @"text/x-sass";
        if ([ext isEqualToString:@"sbml"])		return @"application/sbml+xml";
        if ([ext isEqualToString:@"sc"])		return @"application/vnd.ibm.secure-container";
        if ([ext isEqualToString:@"scd"])		return @"application/x-msschedule";
        if ([ext isEqualToString:@"scm"])		return @"application/vnd.lotus-screencam";
        if ([ext isEqualToString:@"scq"])		return @"application/scvp-cv-request";
        if ([ext isEqualToString:@"scs"])		return @"application/scvp-cv-response";
        if ([ext isEqualToString:@"scss"])		return @"text/x-scss";
        if ([ext isEqualToString:@"scurl"])		return @"text/vnd.curl.scurl";
        if ([ext isEqualToString:@"sda"])		return @"application/vnd.stardivision.draw";
        if ([ext isEqualToString:@"sdc"])		return @"application/vnd.stardivision.calc";
        if ([ext isEqualToString:@"sdd"])		return @"application/vnd.stardivision.impress";
        if ([ext isEqualToString:@"sdkd"])		return @"application/vnd.solent.sdkm+xml";
        if ([ext isEqualToString:@"sdkm"])		return @"application/vnd.solent.sdkm+xml";
        if ([ext isEqualToString:@"sdp"])		return @"application/sdp";
        if ([ext isEqualToString:@"sdw"])		return @"application/vnd.stardivision.writer";
        if ([ext isEqualToString:@"see"])		return @"application/vnd.seemail";
        if ([ext isEqualToString:@"seed"])		return @"application/vnd.fdsn.seed";
        if ([ext isEqualToString:@"sema"])		return @"application/vnd.sema";
        if ([ext isEqualToString:@"semd"])		return @"application/vnd.semd";
        if ([ext isEqualToString:@"semf"])		return @"application/vnd.semf";
        if ([ext isEqualToString:@"ser"])		return @"application/java-serialized-object";
        if ([ext isEqualToString:@"setpay"])	return @"application/set-payment-initiation";
        if ([ext isEqualToString:@"setreg"])	return @"application/set-registration-initiation";
        if ([ext isEqualToString:@"sfd-hdstx"])	return @"application/vnd.hydrostatix.sof-data";
        if ([ext isEqualToString:@"sfs"])		return @"application/vnd.spotfire.sfs";
        if ([ext isEqualToString:@"sfv"])		return @"text/x-sfv";
        if ([ext isEqualToString:@"sgi"])		return @"image/sgi";
        if ([ext isEqualToString:@"sgl"])		return @"application/vnd.stardivision.writer-global";
        if ([ext isEqualToString:@"sgm"])		return @"text/sgml";
        if ([ext isEqualToString:@"sgml"])		return @"text/sgml";
        if ([ext isEqualToString:@"sh"])		return @"application/x-sh";
        if ([ext isEqualToString:@"shar"])		return @"application/x-shar";
        if ([ext isEqualToString:@"shf"])		return @"application/shf+xml";
        if ([ext isEqualToString:@"sid"])		return @"image/x-mrsid-image";
        if ([ext isEqualToString:@"sig"])		return @"application/pgp-signature";
        if ([ext isEqualToString:@"sil"])		return @"audio/silk";
        if ([ext isEqualToString:@"silo"])		return @"model/mesh";
        if ([ext isEqualToString:@"sis"])		return @"application/vnd.symbian.install";
        if ([ext isEqualToString:@"sisx"])		return @"application/vnd.symbian.install";
        if ([ext isEqualToString:@"sit"])		return @"application/x-stuffit";
        if ([ext isEqualToString:@"sitx"])		return @"application/x-stuffitx";
        if ([ext isEqualToString:@"skd"])		return @"application/vnd.koan";
        if ([ext isEqualToString:@"skm"])		return @"application/vnd.koan";
        if ([ext isEqualToString:@"skp"])		return @"application/vnd.koan";
        if ([ext isEqualToString:@"skt"])		return @"application/vnd.koan";
        if ([ext isEqualToString:@"sldm"])		return @"application/vnd.ms-powerpoint.slide.macroenabled.12";
        if ([ext isEqualToString:@"sldx"])		return @"application/vnd.openxmlformats-officedocument.presentationml.slide";
        if ([ext isEqualToString:@"slt"])		return @"application/vnd.epson.salt";
        if ([ext isEqualToString:@"sm"])		return @"application/vnd.stepmania.stepchart";
        if ([ext isEqualToString:@"smf"])		return @"application/vnd.stardivision.math";
        if ([ext isEqualToString:@"smi"])		return @"application/smil+xml";
        if ([ext isEqualToString:@"smil"])		return @"application/smil+xml";
        if ([ext isEqualToString:@"smv"])		return @"video/x-smv";
        if ([ext isEqualToString:@"smzip"])		return @"application/vnd.stepmania.package";
        if ([ext isEqualToString:@"snd"])		return @"audio/basic";
        if ([ext isEqualToString:@"snf"])		return @"application/x-font-snf";
        if ([ext isEqualToString:@"so"])		return @"application/octet-stream";
        if ([ext isEqualToString:@"spc"])		return @"application/x-pkcs7-certificates";
        if ([ext isEqualToString:@"spf"])		return @"application/vnd.yamaha.smaf-phrase";
        if ([ext isEqualToString:@"spl"])		return @"application/x-futuresplash";
        if ([ext isEqualToString:@"spot"])		return @"text/vnd.in3d.spot";
        if ([ext isEqualToString:@"spp"])		return @"application/scvp-vp-response";
        if ([ext isEqualToString:@"spq"])		return @"application/scvp-vp-request";
        if ([ext isEqualToString:@"spx"])		return @"audio/ogg";
        if ([ext isEqualToString:@"sql"])		return @"application/x-sql";
        if ([ext isEqualToString:@"src"])		return @"application/x-wais-source";
        if ([ext isEqualToString:@"srt"])		return @"application/x-subrip";
        if ([ext isEqualToString:@"sru"])		return @"application/sru+xml";
        if ([ext isEqualToString:@"srx"])		return @"application/sparql-results+xml";
        if ([ext isEqualToString:@"ssdl"])		return @"application/ssdl+xml";
        if ([ext isEqualToString:@"sse"])		return @"application/vnd.kodak-descriptor";
        if ([ext isEqualToString:@"ssf"])		return @"application/vnd.epson.ssf";
        if ([ext isEqualToString:@"ssml"])		return @"application/ssml+xml";
        if ([ext isEqualToString:@"st"])		return @"application/vnd.sailingtracker.track";
        if ([ext isEqualToString:@"stc"])		return @"application/vnd.sun.xml.calc.template";
        if ([ext isEqualToString:@"std"])		return @"application/vnd.sun.xml.draw.template";
        if ([ext isEqualToString:@"stf"])		return @"application/vnd.wt.stf";
        if ([ext isEqualToString:@"sti"])		return @"application/vnd.sun.xml.impress.template";
        if ([ext isEqualToString:@"stk"])		return @"application/hyperstudio";
        if ([ext isEqualToString:@"stl"])		return @"application/vnd.ms-pki.stl";
        if ([ext isEqualToString:@"str"])		return @"application/vnd.pg.format";
        if ([ext isEqualToString:@"stw"])		return @"application/vnd.sun.xml.writer.template";
        if ([ext isEqualToString:@"styl"])		return @"text/x-styl";
        if ([ext isEqualToString:@"sub"])		return @"image/vnd.dvb.subtitle";
        if ([ext isEqualToString:@"sus"])		return @"application/vnd.sus-calendar";
        if ([ext isEqualToString:@"susp"])		return @"application/vnd.sus-calendar";
        if ([ext isEqualToString:@"sv4cpio"])	return @"application/x-sv4cpio";
        if ([ext isEqualToString:@"sv4crc"])	return @"application/x-sv4crc";
        if ([ext isEqualToString:@"svc"])		return @"application/vnd.dvb.service";
        if ([ext isEqualToString:@"svd"])		return @"application/vnd.svd";
        if ([ext isEqualToString:@"svg"])		return @"image/svg+xml";
        if ([ext isEqualToString:@"svgz"])		return @"image/svg+xml";
        if ([ext isEqualToString:@"swa"])		return @"application/x-director";
        if ([ext isEqualToString:@"swf"])		return @"application/x-shockwave-flash";
        if ([ext isEqualToString:@"swi"])		return @"application/vnd.aristanetworks.swi";
        if ([ext isEqualToString:@"sxc"])		return @"application/vnd.sun.xml.calc";
        if ([ext isEqualToString:@"sxd"])		return @"application/vnd.sun.xml.draw";
        if ([ext isEqualToString:@"sxg"])		return @"application/vnd.sun.xml.writer.global";
        if ([ext isEqualToString:@"sxi"])		return @"application/vnd.sun.xml.impress";
        if ([ext isEqualToString:@"sxm"])		return @"application/vnd.sun.xml.math";
        if ([ext isEqualToString:@"sxw"])		return @"application/vnd.sun.xml.writer";
        if ([ext isEqualToString:@"t"])         return @"text/troff";
        if ([ext isEqualToString:@"t3"])		return @"application/x-t3vm-image";
        if ([ext isEqualToString:@"taglet"])	return @"application/vnd.mynfc";
        if ([ext isEqualToString:@"tao"])		return @"application/vnd.tao.intent-module-archive";
        if ([ext isEqualToString:@"tar"])		return @"application/x-tar";
        if ([ext isEqualToString:@"tcap"])		return @"application/vnd.3gpp2.tcap";
        if ([ext isEqualToString:@"tcl"])		return @"application/x-tcl";
        if ([ext isEqualToString:@"teacher"])	return @"application/vnd.smart.teacher";
        if ([ext isEqualToString:@"tei"])		return @"application/tei+xml";
        if ([ext isEqualToString:@"teicorpus"])	return @"application/tei+xml";
        if ([ext isEqualToString:@"tex"])		return @"application/x-tex";
        if ([ext isEqualToString:@"texi"])		return @"application/x-texinfo";
        if ([ext isEqualToString:@"texinfo"])	return @"application/x-texinfo";
        if ([ext isEqualToString:@"text"])		return @"text/plain";
        if ([ext isEqualToString:@"tfi"])		return @"application/thraud+xml";
        if ([ext isEqualToString:@"tfm"])		return @"application/x-tex-tfm";
        if ([ext isEqualToString:@"tga"])		return @"image/x-tga";
        if ([ext isEqualToString:@"tgz"])		return @"application/x-gzip";
        if ([ext isEqualToString:@"thmx"])		return @"application/vnd.ms-officetheme";
        if ([ext isEqualToString:@"tif"])		return @"image/tiff";
        if ([ext isEqualToString:@"tiff"])		return @"image/tiff";
        if ([ext isEqualToString:@"tmo"])		return @"application/vnd.tmobile-livetv";
        if ([ext isEqualToString:@"torrent"])	return @"application/x-bittorrent";
        if ([ext isEqualToString:@"tpl"])		return @"application/vnd.groove-tool-template";
        if ([ext isEqualToString:@"tpt"])		return @"application/vnd.trid.tpt";
        if ([ext isEqualToString:@"tr"])		return @"text/troff";
        if ([ext isEqualToString:@"tra"])		return @"application/vnd.trueapp";
        if ([ext isEqualToString:@"trm"])		return @"application/x-msterminal";
        if ([ext isEqualToString:@"tsd"])		return @"application/timestamped-data";
        if ([ext isEqualToString:@"tsv"])		return @"text/tab-separated-values";
        if ([ext isEqualToString:@"ttc"])		return @"application/x-font-ttf";
        if ([ext isEqualToString:@"ttf"])		return @"application/x-font-ttf";
        if ([ext isEqualToString:@"ttl"])		return @"text/turtle";
        if ([ext isEqualToString:@"twd"])		return @"application/vnd.simtech-mindmapper";
        if ([ext isEqualToString:@"twds"])		return @"application/vnd.simtech-mindmapper";
        if ([ext isEqualToString:@"txd"])		return @"application/vnd.genomatix.tuxedo";
        if ([ext isEqualToString:@"txf"])		return @"application/vnd.mobius.txf";
        if ([ext isEqualToString:@"txt"])		return @"text/plain";
        if ([ext isEqualToString:@"u32"])		return @"application/x-authorware-bin";
        if ([ext isEqualToString:@"udeb"])		return @"application/x-debian-package";
        if ([ext isEqualToString:@"ufd"])		return @"application/vnd.ufdl";
        if ([ext isEqualToString:@"ufdl"])		return @"application/vnd.ufdl";
        if ([ext isEqualToString:@"ulx"])		return @"application/x-glulx";
        if ([ext isEqualToString:@"umj"])		return @"application/vnd.umajin";
        if ([ext isEqualToString:@"unityweb"])	return @"application/vnd.unity";
        if ([ext isEqualToString:@"uoml"])		return @"application/vnd.uoml+xml";
        if ([ext isEqualToString:@"uri"])		return @"text/uri-list";
        if ([ext isEqualToString:@"uris"])		return @"text/uri-list";
        if ([ext isEqualToString:@"urls"])		return @"text/uri-list";
        if ([ext isEqualToString:@"ustar"])		return @"application/x-ustar";
        if ([ext isEqualToString:@"utz"])		return @"application/vnd.uiq.theme";
        if ([ext isEqualToString:@"uu"])		return @"text/x-uuencode";
        if ([ext isEqualToString:@"uva"])		return @"audio/vnd.dece.audio";
        if ([ext isEqualToString:@"uvd"])		return @"application/vnd.dece.data";
        if ([ext isEqualToString:@"uvf"])		return @"application/vnd.dece.data";
        if ([ext isEqualToString:@"uvg"])		return @"image/vnd.dece.graphic";
        if ([ext isEqualToString:@"uvh"])		return @"video/vnd.dece.hd";
        if ([ext isEqualToString:@"uvi"])		return @"image/vnd.dece.graphic";
        if ([ext isEqualToString:@"uvm"])		return @"video/vnd.dece.mobile";
        if ([ext isEqualToString:@"uvp"])		return @"video/vnd.dece.pd";
        if ([ext isEqualToString:@"uvs"])		return @"video/vnd.dece.sd";
        if ([ext isEqualToString:@"uvt"])		return @"application/vnd.dece.ttml+xml";
        if ([ext isEqualToString:@"uvu"])		return @"video/vnd.uvvu.mp4";
        if ([ext isEqualToString:@"uvv"])		return @"video/vnd.dece.video";
        if ([ext isEqualToString:@"uvva"])		return @"audio/vnd.dece.audio";
        if ([ext isEqualToString:@"uvvd"])		return @"application/vnd.dece.data";
        if ([ext isEqualToString:@"uvvf"])		return @"application/vnd.dece.data";
        if ([ext isEqualToString:@"uvvg"])		return @"image/vnd.dece.graphic";
        if ([ext isEqualToString:@"uvvh"])		return @"video/vnd.dece.hd";
        if ([ext isEqualToString:@"uvvi"])		return @"image/vnd.dece.graphic";
        if ([ext isEqualToString:@"uvvm"])		return @"video/vnd.dece.mobile";
        if ([ext isEqualToString:@"uvvp"])		return @"video/vnd.dece.pd";
        if ([ext isEqualToString:@"uvvs"])		return @"video/vnd.dece.sd";
        if ([ext isEqualToString:@"uvvt"])		return @"application/vnd.dece.ttml+xml";
        if ([ext isEqualToString:@"uvvu"])		return @"video/vnd.uvvu.mp4";
        if ([ext isEqualToString:@"uvvv"])		return @"video/vnd.dece.video";
        if ([ext isEqualToString:@"uvvx"])		return @"application/vnd.dece.unspecified";
        if ([ext isEqualToString:@"uvvz"])		return @"application/vnd.dece.zip";
        if ([ext isEqualToString:@"uvx"])		return @"application/vnd.dece.unspecified";
        if ([ext isEqualToString:@"uvz"])		return @"application/vnd.dece.zip";
        if ([ext isEqualToString:@"vcard"])		return @"text/vcard";
        if ([ext isEqualToString:@"vcd"])		return @"application/x-cdlink";
        if ([ext isEqualToString:@"vcf"])		return @"text/x-vcard";
        if ([ext isEqualToString:@"vcg"])		return @"application/vnd.groove-vcard";
        if ([ext isEqualToString:@"vcs"])		return @"text/x-vcalendar";
        if ([ext isEqualToString:@"vcx"])		return @"application/vnd.vcx";
        if ([ext isEqualToString:@"vis"])		return @"application/vnd.visionary";
        if ([ext isEqualToString:@"viv"])		return @"video/vnd.vivo";
        if ([ext isEqualToString:@"vob"])		return @"video/x-ms-vob";
        if ([ext isEqualToString:@"vor"])		return @"application/vnd.stardivision.writer";
        if ([ext isEqualToString:@"vox"])		return @"application/x-authorware-bin";
        if ([ext isEqualToString:@"vrml"])		return @"model/vrml";
        if ([ext isEqualToString:@"vsd"])		return @"application/vnd.visio";
        if ([ext isEqualToString:@"vsf"])		return @"application/vnd.vsf";
        if ([ext isEqualToString:@"vss"])		return @"application/vnd.visio";
        if ([ext isEqualToString:@"vst"])		return @"application/vnd.visio";
        if ([ext isEqualToString:@"vsw"])		return @"application/vnd.visio";
        if ([ext isEqualToString:@"vtu"])		return @"model/vnd.vtu";
        if ([ext isEqualToString:@"vxml"])		return @"application/voicexml+xml";
        if ([ext isEqualToString:@"w3d"])		return @"application/x-director";
        if ([ext isEqualToString:@"wad"])		return @"application/x-doom";
        if ([ext isEqualToString:@"wav"])		return @"audio/x-wav";
        if ([ext isEqualToString:@"wax"])		return @"audio/x-ms-wax";
        if ([ext isEqualToString:@"wbmp"])		return @"image/vnd.wap.wbmp";
        if ([ext isEqualToString:@"wbs"])		return @"application/vnd.criticaltools.wbs+xml";
        if ([ext isEqualToString:@"wbxml"])		return @"application/vnd.wap.wbxml";
        if ([ext isEqualToString:@"wcm"])		return @"application/vnd.ms-works";
        if ([ext isEqualToString:@"wdb"])		return @"application/vnd.ms-works";
        if ([ext isEqualToString:@"wdp"])		return @"image/vnd.ms-photo";
        if ([ext isEqualToString:@"weba"])		return @"audio/webm";
        if ([ext isEqualToString:@"webm"])		return @"video/webm";
        if ([ext isEqualToString:@"webp"])		return @"image/webp";
        if ([ext isEqualToString:@"wg"])		return @"application/vnd.pmi.widget";
        if ([ext isEqualToString:@"wgt"])		return @"application/widget";
        if ([ext isEqualToString:@"wks"])		return @"application/vnd.ms-works";
        if ([ext isEqualToString:@"wm"])		return @"video/x-ms-wm";
        if ([ext isEqualToString:@"wma"])		return @"audio/x-ms-wma";
        if ([ext isEqualToString:@"wmd"])		return @"application/x-ms-wmd";
        if ([ext isEqualToString:@"wmf"])		return @"application/x-msmetafile";
        if ([ext isEqualToString:@"wml"])		return @"text/vnd.wap.wml";
        if ([ext isEqualToString:@"wmlc"])		return @"application/vnd.wap.wmlc";
        if ([ext isEqualToString:@"wmls"])		return @"text/vnd.wap.wmlscript";
        if ([ext isEqualToString:@"wmlsc"])		return @"application/vnd.wap.wmlscriptc";
        if ([ext isEqualToString:@"wmv"])		return @"video/x-ms-wmv";
        if ([ext isEqualToString:@"wmx"])		return @"video/x-ms-wmx";
        if ([ext isEqualToString:@"wmz"])		return @"application/x-ms-wmz";
        if ([ext isEqualToString:@"woff"])		return @"application/x-font-woff";
        if ([ext isEqualToString:@"woff2"])		return @"application/x-font-woff";
        if ([ext isEqualToString:@"wpd"])		return @"application/vnd.wordperfect";
        if ([ext isEqualToString:@"wpl"])		return @"application/vnd.ms-wpl";
        if ([ext isEqualToString:@"wps"])		return @"application/vnd.ms-works";
        if ([ext isEqualToString:@"wqd"])		return @"application/vnd.wqd";
        if ([ext isEqualToString:@"wri"])		return @"application/x-mswrite";
        if ([ext isEqualToString:@"wrl"])		return @"model/vrml";
        if ([ext isEqualToString:@"wsdl"])		return @"application/wsdl+xml";
        if ([ext isEqualToString:@"wspolicy"])	return @"application/wspolicy+xml";
        if ([ext isEqualToString:@"wtb"])		return @"application/vnd.webturbo";
        if ([ext isEqualToString:@"wvx"])		return @"video/x-ms-wvx";
        if ([ext isEqualToString:@"x32"])		return @"application/x-authorware-bin";
        if ([ext isEqualToString:@"x3d"])		return @"model/x3d+xml";
        if ([ext isEqualToString:@"x3db"])		return @"model/x3d+binary";
        if ([ext isEqualToString:@"x3dbz"])		return @"model/x3d+binary";
        if ([ext isEqualToString:@"x3dv"])		return @"model/x3d+vrml";
        if ([ext isEqualToString:@"x3dvz"])		return @"model/x3d+vrml";
        if ([ext isEqualToString:@"x3dz"])		return @"model/x3d+xml";
        if ([ext isEqualToString:@"xaml"])		return @"application/xaml+xml";
        if ([ext isEqualToString:@"xap"])		return @"application/x-silverlight-app";
        if ([ext isEqualToString:@"xar"])		return @"application/vnd.xara";
        if ([ext isEqualToString:@"xbap"])		return @"application/x-ms-xbap";
        if ([ext isEqualToString:@"xbd"])		return @"application/vnd.fujixerox.docuworks.binder";
        if ([ext isEqualToString:@"xbm"])		return @"image/x-xbitmap";
        if ([ext isEqualToString:@"xdf"])		return @"application/xcap-diff+xml";
        if ([ext isEqualToString:@"xdm"])		return @"application/vnd.syncml.dm+xml";
        if ([ext isEqualToString:@"xdp"])		return @"application/vnd.adobe.xdp+xml";
        if ([ext isEqualToString:@"xdssc"])		return @"application/dssc+xml";
        if ([ext isEqualToString:@"xdw"])		return @"application/vnd.fujixerox.docuworks";
        if ([ext isEqualToString:@"xenc"])		return @"application/xenc+xml";
        if ([ext isEqualToString:@"xer"])		return @"application/patch-ops-error+xml";
        if ([ext isEqualToString:@"xfdf"])		return @"application/vnd.adobe.xfdf";
        if ([ext isEqualToString:@"xfdl"])		return @"application/vnd.xfdl";
        if ([ext isEqualToString:@"xht"])		return @"application/xhtml+xml";
        if ([ext isEqualToString:@"xhtml"])		return @"application/xhtml+xml";
        if ([ext isEqualToString:@"xhvml"])		return @"application/xv+xml";
        if ([ext isEqualToString:@"xif"])		return @"image/vnd.xiff";
        if ([ext isEqualToString:@"xla"])		return @"application/vnd.ms-excel";
        if ([ext isEqualToString:@"xlam"])		return @"application/vnd.ms-excel.addin.macroenabled.12";
        if ([ext isEqualToString:@"xlc"])		return @"application/vnd.ms-excel";
        if ([ext isEqualToString:@"xlf"])		return @"application/x-xliff+xml";
        if ([ext isEqualToString:@"xlm"])		return @"application/vnd.ms-excel";
        if ([ext isEqualToString:@"xls"])		return @"application/vnd.ms-excel";
        if ([ext isEqualToString:@"xlsb"])		return @"application/vnd.ms-excel.sheet.binary.macroenabled.12";
        if ([ext isEqualToString:@"xlsm"])		return @"application/vnd.ms-excel.sheet.macroenabled.12";
        if ([ext isEqualToString:@"xlsx"])		return @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        if ([ext isEqualToString:@"xlt"])		return @"application/vnd.ms-excel";
        if ([ext isEqualToString:@"xltm"])		return @"application/vnd.ms-excel.template.macroenabled.12";
        if ([ext isEqualToString:@"xltx"])		return @"application/vnd.openxmlformats-officedocument.spreadsheetml.template";
        if ([ext isEqualToString:@"xlw"])		return @"application/vnd.ms-excel";
        if ([ext isEqualToString:@"xm"])		return @"audio/xm";
        if ([ext isEqualToString:@"xml"])		return @"application/xml";
        if ([ext isEqualToString:@"xo"])		return @"application/vnd.olpc-sugar";
        if ([ext isEqualToString:@"xop"])		return @"application/xop+xml";
        if ([ext isEqualToString:@"xpi"])		return @"application/x-xpinstall";
        if ([ext isEqualToString:@"xpl"])		return @"application/xproc+xml";
        if ([ext isEqualToString:@"xpm"])		return @"image/x-xpixmap";
        if ([ext isEqualToString:@"xpr"])		return @"application/vnd.is-xpr";
        if ([ext isEqualToString:@"xps"])		return @"application/vnd.ms-xpsdocument";
        if ([ext isEqualToString:@"xpw"])		return @"application/vnd.intercon.formnet";
        if ([ext isEqualToString:@"xpx"])		return @"application/vnd.intercon.formnet";
        if ([ext isEqualToString:@"xsl"])		return @"application/xml";
        if ([ext isEqualToString:@"xslt"])		return @"application/xslt+xml";
        if ([ext isEqualToString:@"xsm"])		return @"application/vnd.syncml+xml";
        if ([ext isEqualToString:@"xspf"])		return @"application/xspf+xml";
        if ([ext isEqualToString:@"xul"])		return @"application/vnd.mozilla.xul+xml";
        if ([ext isEqualToString:@"xvm"])		return @"application/xv+xml";
        if ([ext isEqualToString:@"xvml"])		return @"application/xv+xml";
        if ([ext isEqualToString:@"xwd"])		return @"image/x-xwindowdump";
        if ([ext isEqualToString:@"xyz"])		return @"chemical/x-xyz";
        if ([ext isEqualToString:@"xz"])		return @"application/x-xz";
        if ([ext isEqualToString:@"yaml"])		return @"text/yaml";
        if ([ext isEqualToString:@"yang"])		return @"application/yang";
        if ([ext isEqualToString:@"yin"])		return @"application/yin+xml";
        if ([ext isEqualToString:@"yml"])		return @"text/yaml";
        if ([ext isEqualToString:@"z"])         return @"application/x-compress";
        if ([ext isEqualToString:@"z1"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"z2"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"z3"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"z4"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"z5"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"z6"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"z7"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"z8"])		return @"application/x-zmachine";
        if ([ext isEqualToString:@"zaz"])		return @"application/vnd.zzazz.deck+xml";
        if ([ext isEqualToString:@"zip"])		return @"application/zip";
        if ([ext isEqualToString:@"zir"])		return @"application/vnd.zul";
        if ([ext isEqualToString:@"zirz"])		return @"application/vnd.zul";
        if ([ext isEqualToString:@"zmm"])		return @"application/vnd.handheld-entertainment+xml";
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
    if ([url hasPrefix:@"http"]) {
        return url;
    }
    return [NSString stringWithFormat:@"http://%@",url];
}

+(BOOL)ReportServer:(NSString*)hash resouce:(NSString*)resouce version:(NSString*)version app:(NSString*)app
{
    if (resouce.length==0) {
        resouce=@"aliyun";
    }
    ULONGLONG time = (ULONGLONG)[[NSDate date] timeIntervalSince1970];
    NSString* date=[NSString stringWithFormat:@"%llu",time];
    NSString* method=@"GET";
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"uuid";
    item.value=hash;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"res";
    item.value=resouce;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"ver";
    item.value=version;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"app";
    item.value=app;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"timespan";
    item.value=date;
    [array addObject:item];
    [item release];
    NSString * retsign=[self Authorization:array];
    item=[[OssSignKey alloc]init];
    item.key=@"sign";
    item.value=[retsign stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    [array addObject:item];
    [item release];
    
    NSString* strUrl=[NSString stringWithFormat:@"http://ossupdate.jiagouyun.com/Interface/report%@",[self get_postdata:array]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:nil
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

+(NSData*)CheckServer:(NSString*)resouce version:(NSString*)version app:(NSString*)app
{
    if (resouce.length==0) {
        resouce=@"aliyun";
    }
    ULONGLONG time = (ULONGLONG)[[NSDate date] timeIntervalSince1970];
    NSString* date=[NSString stringWithFormat:@"%llu",time];
    NSString* method=@"GET";
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"res";
    item.value=resouce;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"ver";
    item.value=version;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"app";
    item.value=app;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"timespan";
    item.value=date;
    [array addObject:item];
    [item release];
    NSString * retsign=[self Authorization:array];
    item=[[OssSignKey alloc]init];
    item.key=@"sign";
    item.value=[retsign stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    [array addObject:item];
    [item release];
    
    NSString* strUrl=[NSString stringWithFormat:@"http://ossupdate.jiagouyun.com/Interface/check_version%@",[self get_postdata:array]];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:nil
                                                        bodyData:nil] autorelease];
    NSHTTPURLResponse* response;
    NSData* data=[request connectNetSyncWithResponse:&response error:nil];
    NSInteger status=[response statusCode];
    if (status==200) {
        return data;
    }
    else {
        return nil;
    }
}

+(BOOL)CallbackInfo:(NSString*)url bucket:(NSString*)bucket object:(NSString*)object ret:(OSSRet**)ret
{
    NSString* method=@"PUT";
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    OssSignKey *item=[[OssSignKey alloc]init];
    item.key=@"bucket";
    item.value=bucket;
    [array addObject:item];
    [item release];
    item=[[OssSignKey alloc]init];
    item.key=@"object";
    item.value=object;
    [array addObject:item];
    [item release];
    NSString* strUrl=[self AddHttpOrHttps:url];
    GKHTTPRequest* request = [[[GKHTTPRequest alloc] initWithUrl:strUrl
                                                          method:method
                                                          header:nil
                                                        bodyData:[self getpostdata:array]] autorelease];
    NSHTTPURLResponse* response;
    NSData* data = [request connectNetSyncWithResponse:&response error:nil];
    *ret =[[[OSSAddObject alloc]init]autorelease];
    (*ret).nHttpCode=[response statusCode];
    if ((*ret).nHttpCode>=200&&(*ret).nHttpCode<400) {
        return YES;
    }
    else {
        (*ret).strMessage=[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return NO;
    }
    return NO;
}

+(NSString*)get_postdata:(NSArray*)keys
{
    NSMutableString *signString = [[[NSMutableString alloc] init] autorelease];
    for (int i=0;i<[keys count];i++) {
        OssSignKey* sk=[keys objectAtIndex:i];
        [signString appendFormat:@"/%@/%@",sk.key,[sk.value urlEncoded]];
    }
    return [NSString stringWithFormat:@"%@",signString];
}

+(NSData*)getpostdata:(NSMutableArray*)array
{
    NSMutableString *ret = [[[NSMutableString alloc] init] autorelease];
    for (int i=0;i<[array count];i++) {
        if (i!=0) {
            [ret appendString:@"&"];
        }
        OssSignKey* sk=[array objectAtIndex:i];
        [ret appendString:sk.key];
        [ret appendString:@"="];
        [ret appendString:[sk.value urlEncoded]];
    }
    return [ret dataUsingEncoding:NSUTF8StringEncoding];
}

@end
