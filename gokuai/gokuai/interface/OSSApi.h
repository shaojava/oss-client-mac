#import <Foundation/Foundation.h>
#import "OSSRet.h"
#import "Common.h"

@interface OssSignKey : NSObject
{
    NSString*   key;
    NSString*   value;
}
@property(nonatomic,copy)NSString*  key;
@property(nonatomic,copy)NSString*  value;

@end

@interface OSSApi : NSObject

+(BOOL)CheckIDandKey:(NSString*)sID key:(NSString*)sKey host:(NSString*)host ret:(OSSRet**)ret;
+(BOOL)DeleteBucket:(NSString*)host bucketname:(NSString*)bucketname ret:(OSSRet**)ret;
+(BOOL)GetBucketObject:(NSString*)host bucetname:(NSString*)bucketname ret:(OSSListObjectRet**)ret prefix:(NSString*)prefix marker:(NSString*)marker delimiter:(NSString*)delimiter maxkeys:(NSString*)maxkeys;

+(BOOL)CopyObject:(NSString*)host dstbucketname:(NSString*)dstbucketname dstobjectname:(NSString*)dstobjectname srcbucketname:(NSString*)srcbucketname srcobjectname:(NSString*)srcobjectname ret:(OSSCopyRet**)ret;
+(BOOL)DeleteObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname ret:(OSSRet**)ret;
+(BOOL)DeleteObject:(NSString*)host bucketname:(NSString*)bucketname objectnames:(NSArray*)objectnamss quiet:(BOOL)quiet ret:(OSSRet**)ret;
+(BOOL)HeadObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname;

+(BOOL)AddObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname filesize:(ULONGLONG)filesize filedata:(NSData*)filedata ret:(OSSAddObject**)ret;
+(BOOL)InitiateMultipartUploadObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname ret:(OSSInitiateMultipartUploadRet**)ret;
+(BOOL)UploadPartObject:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname uploadid:(NSString*)uploadid partnumber:(NSInteger)partnumber filesize:(ULONGLONG)fileszie filedata:(NSData*)filedata ret:(OSSAddObject**)ret;
+(BOOL)UploadPartCopy:(NSString*)host dstbucketname:(NSString*)dstbucketname dstobjectname:(NSString*)dstobjectname srcbucketname:(NSString*)srcbucketname srcobjectname:(NSString*)srcobjectname uploadid:(NSString*)uploadid partnumber:(NSInteger)partnumber pos:(ULONGLONG)pos size:(ULONGLONG)size ret:(OSSRet**)ret;
+(BOOL)CompleteMultipartUpload:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname uploadid:(NSString*)uploadid parts:(NSArray*)parts ret:(OSSRet**)ret;

+(BOOL)ListMultipartUploads:(NSString*)host bucketname:(NSString*)bucketname reet:(OSSListMultipartUploadRet**)ret;
+(BOOL)AbortMultipartUpload:(NSString*)host bucketname:(NSString*)bucketname objectname:(NSString*)objectname uploadid:(NSString*)uploadid ret:(OSSRet**)ret;

+(NSString*)Authorization:(NSString*)method contentmd5:(NSString*)contentmd5 contenttype:(NSString*)contenttype date:(NSString*)date keys:(NSArray*)keys resource:(NSString*)resource;
+(NSString*)Authorization:(NSString *)method contentmd5:(NSString *)contentmd5 contenttype:(NSString *)contenttype date:(NSString *)date keys:(NSArray *)keys resource:(NSString *)resource accessid:(NSString*)accessid accesskey:(NSString*)accesskey;
+(NSString*)Authorization:(NSArray*)keys;

+(NSString*)Signature:(NSString*)method contentmd5:(NSString*)contentmd5 contenttype:(NSString*)contenttype date:(ULONGLONG)date keys:(NSArray*)keys resource:(NSString*)resource;
+(NSString*)GetContentType:(NSString*)objectname;
+(NSDictionary*)GetHeader:(NSArray*)keys;
+(NSString*)AddHttpOrHttps:(NSString*)url;



+(BOOL)ReportServer:(NSString*)hash resouce:(NSString*)resouce version:(NSString*)version app:(NSString*)app;
+(NSData*)CheckServer:(NSString*)resouce version:(NSString*)version app:(NSString*)app;
+(NSString*)get_postdata:(NSArray*)keys;

@end
