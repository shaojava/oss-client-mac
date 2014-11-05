#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface OSSRet : NSObject
{
    GDataXMLElement *rootElement;
    NSString* strCode;
    NSString* strMessage;
    NSString* strRequestId;
    NSString* strHostId;
    NSString* strBucketName;
}

@property(nonatomic,retain)NSString* strCode;
@property(nonatomic,retain)NSString* strMessage;
@property(nonatomic,retain)NSString* strRequestId;
@property(nonatomic,retain)NSString* strHostId;
@property(nonatomic,retain)NSString* strBucketName;

-(BOOL) SetValueWithData:(NSData*)data;
-(BOOL) Load:(NSString*)content;
-(BOOL) Parse;
-(void) ParseError;

@end

@interface OSSCopyRet : OSSRet
{
    NSString* strEtag;
    NSString* strLastModified;
}

@property(nonatomic,retain)NSString* strEtag;
@property(nonatomic,retain)NSString* strLastModified;

-(BOOL) Parse;

@end

@interface OSSPostRet : OSSRet
{
    NSString* strBucket;
    NSString* strEtag;
    NSString* strKey;
    NSString* strLocation;
}

@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strEtag;
@property(nonatomic,retain)NSString* strKey;
@property(nonatomic,retain)NSString* strLocation;

-(BOOL) Parse;

@end

@interface OSSInitiateMultipartUploadRet : OSSRet
{
    NSString* strBucket;
    NSString* strKey;
    NSString* strUploadId;
}

@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strKey;
@property(nonatomic,retain)NSString* strUploadId;

-(BOOL) Parse;

@end

@interface OSSCompleteMultipartUploadRet : OSSRet
{
    NSString* strBucket;
    NSString* strEtag;
    NSString* strKey;
    NSString* strLocation;
}

@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strEtag;
@property(nonatomic,retain)NSString* strKey;
@property(nonatomic,retain)NSString* strLocation;

-(BOOL) Parse;

@end

@interface OSSListMultipartUploadRet : OSSRet
{
    NSString* strBucket;
    NSString* strKeyMarker;
    NSString* strUploadIdMarker;
    NSString* strNextKeyMarker;
    NSString* strNextUploadIdMarker;
    NSString* strDelimiter;
    NSString* strPrefix;
    NSString* strMaxUploads;
    NSString* strIsTruncated;
    NSString* strLocation;
    NSMutableArray* arrayUpload;
}

@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strKeyMarker;
@property(nonatomic,retain)NSString* strUploadIdMarker;
@property(nonatomic,retain)NSString* strNextKeyMarker;
@property(nonatomic,retain)NSString* strNextUploadIdMarker;
@property(nonatomic,retain)NSString* strDelimiter;
@property(nonatomic,retain)NSString* strPrefix;
@property(nonatomic,retain)NSString* strMaxUploads;
@property(nonatomic,retain)NSString* strIsTruncated;
@property(nonatomic,retain)NSString* strLocation;
@property(nonatomic,retain)NSMutableArray* arrayUpload;

-(BOOL) Parse;

@end

@interface OSSListPartsRet : OSSRet
{
    NSString* strBucket;
    NSString* strKey;
    NSString* strUploadId;
    NSString* strPartNumberMarker;
    NSString* strNextPartNumberMarker;
    NSString* strMaxParts;
    NSString* strIsTruncated;
    NSMutableArray* arrayUpload;
}

@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strKey;
@property(nonatomic,retain)NSString* strUploadId;
@property(nonatomic,retain)NSString* strPartNumberMarker;
@property(nonatomic,retain)NSString* strNextPartNumberMarker;
@property(nonatomic,retain)NSString* strMaxParts;
@property(nonatomic,retain)NSString* strIsTruncated;
@property(nonatomic,retain)NSMutableArray* arrayUpload;

-(BOOL) Parse;

@end

@interface OSSListObjectRet : OSSRet
{
    NSString* strBucket;
    NSString* strPrefix;
    NSString* strMarker;
    NSString* strNextMarker;
    NSMutableArray* arrayContent;
}

@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strPrefix;
@property(nonatomic,retain)NSString* strMarker;
@property(nonatomic,retain)NSString* strNextMarker;
@property(nonatomic,retain)NSMutableArray* arrayContent;

-(BOOL) Parse;

@end

@interface OSSListMultipartUpload : NSObject
{
    NSString* strKey;
    NSString* strUploadId;
    NSString* strInitiated;
}

@property(nonatomic,retain)NSString* strKey;
@property(nonatomic,retain)NSString* strUploadId;
@property(nonatomic,retain)NSString* strInitiated;

@end

@interface OSSListPath : NSObject
{
    NSString* strPartNumber;
    NSString* strLastModified;
    NSString* strEtag;
    NSString* strSize;
}

@property(nonatomic,retain)NSString* strPartNumber;
@property(nonatomic,retain)NSString* strLastModified;
@property(nonatomic,retain)NSString* strEtag;
@property(nonatomic,retain)NSString* strSize;

@end

@interface OSSListObject : NSObject
{
    NSString* strKey;
    NSString* strLastModified;
    NSString* strEtag;
    NSString* strType;
    NSString* strPefix;
    NSString* strFilesize;
}

@property(nonatomic,retain)NSString* strKey;
@property(nonatomic,retain)NSString* strLastModified;
@property(nonatomic,retain)NSString* strEtag;
@property(nonatomic,retain)NSString* strType;
@property(nonatomic,retain)NSString* strPefix;
@property(nonatomic,retain)NSString* strFilesize;

@end

@interface OSSAddObject : OSSRet
{
    NSInteger nCode;
    NSString* strEtag;
}

@property(nonatomic)NSInteger nCode;
@property(nonatomic,retain)NSString* strEtag;

@end






