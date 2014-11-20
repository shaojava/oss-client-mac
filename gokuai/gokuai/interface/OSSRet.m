#import "OSSRet.h"

@implementation OSSRet

@synthesize nHttpCode;
@synthesize strCode;
@synthesize strMessage;
@synthesize strRequestId;
@synthesize strHostId;
@synthesize strBucketName;

-(id)init
{
    if (self =[super init]) {
        self.nHttpCode=0;
        self.strCode =@"";
        self.strMessage =@"";
        self.strRequestId =@"";
        self.strHostId =@"";
        self.strBucketName =@"";
    }
    return self;
}

-(void) dealloc
{
    strCode=nil;
    strMessage=nil;
    strRequestId=nil;
    strHostId=nil;
    strBucketName=nil;
    [super dealloc];
}

-(BOOL) SetValueWithData:(NSData*)data
{
    if (data==nil)
        return NO;
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (jsonString==nil)
        return NO;
    return [self Load:jsonString];
}

-(BOOL) Load:(NSString*)content
{
    BOOL ret=NO;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:content options:0 error:nil];
    if (doc!=nil) {
        rootElement = [doc rootElement];
        ret=[self Parse];
    }
    return ret;
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

-(void) ParseError
{
    NSArray * arraycode=[rootElement elementsForName:@"Code"];
    if ([arraycode isKindOfClass:[NSArray class]]&&[arraycode count]) {
        GDataXMLElement * code=[arraycode objectAtIndex:0];
        self.strCode=[code stringValue];
    }
    NSArray * arraymessage=[rootElement elementsForName:@"Message"];
    if ([arraymessage isKindOfClass:[NSArray class]]&&[arraymessage count]) {
        GDataXMLElement * message=[arraymessage objectAtIndex:0];
        self.strMessage=[message stringValue];
    }
    NSArray * arrayrequestid=[rootElement elementsForName:@"RequestId"];
    if ([arrayrequestid isKindOfClass:[NSArray class]]&&[arrayrequestid count]) {
        GDataXMLElement * requestid=[arrayrequestid objectAtIndex:0];
        self.strRequestId=[requestid stringValue];
    }
    NSArray * arrayhostid=[rootElement elementsForName:@"HostId"];
    if ([arrayhostid isKindOfClass:[NSArray class]]&&[arrayhostid count]) {
        GDataXMLElement * hostid=[arrayhostid objectAtIndex:0];
        self.strHostId=[hostid stringValue];
    }
    NSArray * arraybucket=[rootElement elementsForName:@"BucketName"];
    if ([arraybucket isKindOfClass:[NSArray class]]&&[arraybucket count]) {
        GDataXMLElement * bucketname=[arraybucket objectAtIndex:0];
        self.strBucketName=[bucketname stringValue];
    }
}

@end

@implementation OSSCopyRet

@synthesize strEtag;
@synthesize strLastModified;

-(id)init
{
    if (self =[super init]) {
        self.strEtag =@"";
        self.strLastModified =@"";
    }
    return self;
}

-(void)dealloc
{
    strEtag=nil;
    strLastModified=nil;
    [super dealloc];
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        NSArray * arraylastmodified=[rootElement elementsForName:@"LastModified"];
        if ([arraylastmodified isKindOfClass:[NSArray class]]&&[arraylastmodified count]) {
            GDataXMLElement * lastmodified=[arraylastmodified objectAtIndex:0];
            self.strLastModified=[lastmodified stringValue];
        }
        NSArray * arrayetag=[rootElement elementsForName:@"ETag"];
        if ([arrayetag isKindOfClass:[NSArray class]]&&[arrayetag count]) {
            GDataXMLElement * etag=[arrayetag objectAtIndex:0];
            self.strEtag=[etag stringValue];
        }
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation OSSPostRet

@synthesize strBucket;
@synthesize strEtag;
@synthesize strKey;
@synthesize strLocation;

-(id)init
{
    if (self =[super init]) {
        self.strBucket =@"";
        self.strEtag =@"";
        self.strKey =@"";
        self.strLocation =@"";
    }
    return self;
}

-(void)dealloc
{
    strBucket=nil;
    strEtag=nil;
    strKey=nil;
    strLocation=nil;
    [super dealloc];
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        NSArray * arraybucket=[rootElement elementsForName:@"Bucket"];
        if ([arraybucket isKindOfClass:[NSArray class]]&&[arraybucket count]) {
            GDataXMLElement * bucket=[arraybucket objectAtIndex:0];
            self.strBucket=[bucket stringValue];
        }
        NSArray * arrayetag=[rootElement elementsForName:@"ETag"];
        if ([arrayetag isKindOfClass:[NSArray class]]&&[arrayetag count]) {
            GDataXMLElement * etag=[arrayetag objectAtIndex:0];
            self.strEtag=[etag stringValue];
        }
        NSArray * arraykey=[rootElement elementsForName:@"Key"];
        if ([arraykey isKindOfClass:[NSArray class]]&&[arraykey count]) {
            GDataXMLElement * key=[arraykey objectAtIndex:0];
            self.strKey=[key stringValue];
        }
        NSArray * arraylocation=[rootElement elementsForName:@"Location"];
        if ([arraylocation isKindOfClass:[NSArray class]]&&[arraylocation count]) {
            GDataXMLElement * location=[arraylocation objectAtIndex:0];
            self.strLocation=[location stringValue];
        }
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation OSSInitiateMultipartUploadRet

@synthesize strBucket;
@synthesize strKey;
@synthesize strUploadId;

-(id)init
{
    if (self =[super init]) {
        self.strBucket =@"";
        self.strKey =@"";
        self.strUploadId =@"";
    }
    return self;
}

-(void)dealloc
{
    strBucket=nil;
    strKey=nil;
    strUploadId=nil;
    [super dealloc];
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        NSArray * arraybucket=[rootElement elementsForName:@"Bucket"];
        if ([arraybucket isKindOfClass:[NSArray class]]&&[arraybucket count]) {
            GDataXMLElement * bucket=[arraybucket objectAtIndex:0];
            self.strBucket=[bucket stringValue];
        }
        NSArray * arrayuploadid=[rootElement elementsForName:@"UploadId"];
        if ([arrayuploadid isKindOfClass:[NSArray class]]&&[arrayuploadid count]) {
            GDataXMLElement * uploadid=[arrayuploadid objectAtIndex:0];
            self.strUploadId=[uploadid stringValue];
        }
        NSArray * arraykey=[rootElement elementsForName:@"Key"];
        if ([arraykey isKindOfClass:[NSArray class]]&&[arraykey count]) {
            GDataXMLElement * key=[arraykey objectAtIndex:0];
            self.strKey=[key stringValue];
        }
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation OSSCompleteMultipartUploadRet

@synthesize strBucket;
@synthesize strEtag;
@synthesize strKey;
@synthesize strLocation;

-(id)init
{
    if (self =[super init]) {
        self.strBucket =@"";
        self.strEtag =@"";
        self.strKey =@"";
        self.strLocation =@"";
    }
    return self;
}

-(void)dealloc
{
    strBucket=nil;
    strEtag=nil;
    strKey=nil;
    strLocation=nil;
    [super dealloc];
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        NSArray * arraybucket=[rootElement elementsForName:@"Bucket"];
        if ([arraybucket isKindOfClass:[NSArray class]]&&[arraybucket count]) {
            GDataXMLElement * bucket=[arraybucket objectAtIndex:0];
            self.strBucket=[bucket stringValue];
        }
        NSArray * arrayetag=[rootElement elementsForName:@"ETag"];
        if ([arrayetag isKindOfClass:[NSArray class]]&&[arrayetag count]) {
            GDataXMLElement * etag=[arrayetag objectAtIndex:0];
            self.strEtag=[etag stringValue];
        }
        NSArray * arraykey=[rootElement elementsForName:@"Key"];
        if ([arraykey isKindOfClass:[NSArray class]]&&[arraykey count]) {
            GDataXMLElement * key=[arraykey objectAtIndex:0];
            self.strKey=[key stringValue];
        }
        NSArray * arraylocation=[rootElement elementsForName:@"Location"];
        if ([arraylocation isKindOfClass:[NSArray class]]&&[arraylocation count]) {
            GDataXMLElement * location=[arraylocation objectAtIndex:0];
            self.strLocation=[location stringValue];
        }
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation OSSListMultipartUploadRet

@synthesize strBucket;
@synthesize strKeyMarker;
@synthesize strUploadIdMarker;
@synthesize strNextKeyMarker;
@synthesize strNextUploadIdMarker;
@synthesize strDelimiter;
@synthesize strPrefix;
@synthesize strMaxUploads;
@synthesize strIsTruncated;
@synthesize strLocation;
@synthesize arrayUpload;

-(id)init
{
    if (self =[super init]) {
        self.strBucket =@"";
        self.strKeyMarker =@"";
        self.strUploadIdMarker =@"";
        self.strNextKeyMarker =@"";
        self.strNextUploadIdMarker =@"";
        self.strDelimiter =@"";
        self.strPrefix =@"";
        self.strMaxUploads =@"";
        self.strIsTruncated =@"";
        self.strLocation =@"";
        self.arrayUpload = [[[NSMutableArray alloc]init] autorelease];
    }
    return self;
}

-(void)dealloc
{
    strBucket=nil;
    strKeyMarker=nil;
    strUploadIdMarker=nil;
    strNextKeyMarker=nil;
    strNextUploadIdMarker=nil;
    strDelimiter=nil;
    strPrefix=nil;
    strMaxUploads=nil;
    strIsTruncated=nil;
    strLocation=nil;
    arrayUpload=nil;
    [super dealloc];
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        NSArray * arraybucket=[rootElement elementsForName:@"Bucket"];
        if ([arraybucket isKindOfClass:[NSArray class]]&&[arraybucket count]) {
            GDataXMLElement * bucket=[arraybucket objectAtIndex:0];
            self.strBucket=[bucket stringValue];
        }
        NSArray * arraykeymarker=[rootElement elementsForName:@"KeyMarker"];
        if ([arraykeymarker isKindOfClass:[NSArray class]]&&[arraykeymarker count]) {
            GDataXMLElement * keymarker=[arraykeymarker objectAtIndex:0];
            self.strKeyMarker=[keymarker stringValue];
        }
        NSArray * arrayuploadidmarker=[rootElement elementsForName:@"UploadIdMarker"];
        if ([arrayuploadidmarker isKindOfClass:[NSArray class]]&&[arrayuploadidmarker count]) {
            GDataXMLElement * uploadidmarker=[arrayuploadidmarker objectAtIndex:0];
            self.strUploadIdMarker=[uploadidmarker stringValue];
        }
        NSArray * arraynextkeymarker=[rootElement elementsForName:@"NextKeyMarker"];
        if ([arraynextkeymarker isKindOfClass:[NSArray class]]&&[arraynextkeymarker count]) {
            GDataXMLElement * nextkeymarker=[arraynextkeymarker objectAtIndex:0];
            self.strKeyMarker=[nextkeymarker stringValue];
        }
        NSArray * arraynextuploadidmarker=[rootElement elementsForName:@"NextUploadIdMarker"];
        if ([arraynextuploadidmarker isKindOfClass:[NSArray class]]&&[arraynextuploadidmarker count]) {
            GDataXMLElement * nextuploadidmarker=[arraynextuploadidmarker objectAtIndex:0];
            self.strNextUploadIdMarker=[nextuploadidmarker stringValue];
        }
        NSArray * arraydelimiter=[rootElement elementsForName:@"Delimiter"];
        if ([arraydelimiter isKindOfClass:[NSArray class]]&&[arraydelimiter count]) {
            GDataXMLElement * delimiter=[arraydelimiter objectAtIndex:0];
            self.strDelimiter=[delimiter stringValue];
        }
        NSArray * arrayprefix=[rootElement elementsForName:@"Prefix"];
        if ([arrayprefix isKindOfClass:[NSArray class]]&&[arrayprefix count]) {
            GDataXMLElement * prefix=[arrayprefix objectAtIndex:0];
            self.strPrefix=[prefix stringValue];
        }
        NSArray * arraymaxuploads=[rootElement elementsForName:@"MaxUploads"];
        if ([arraymaxuploads isKindOfClass:[NSArray class]]&&[arraymaxuploads count]) {
            GDataXMLElement * maxuploads=[arraymaxuploads objectAtIndex:0];
            self.strMaxUploads=[maxuploads stringValue];
        }
        NSArray * arrayistruncated=[rootElement elementsForName:@"IsTruncated"];
        if ([arrayistruncated isKindOfClass:[NSArray class]]&&[arrayistruncated count]) {
            GDataXMLElement * istruncated=[arrayistruncated objectAtIndex:0];
            self.strIsTruncated=[istruncated stringValue];
        }
        NSArray * aupload=[rootElement elementsForName:@"Upload"];
        if ([aupload isKindOfClass:[NSArray class]]&&[aupload count]) {
            for (GDataXMLElement * eItem in aupload) {
                OSSListMultipartUpload * item =[[[OSSListMultipartUpload alloc]init]autorelease];
                
                NSArray * arrayKey=[eItem elementsForName:@"Key"];
                if ([arrayKey isKindOfClass:[NSArray class]]&&[arrayKey count]) {
                    GDataXMLElement * key=[arrayKey objectAtIndex:0];
                    item.strKey=[key stringValue];
                }
                NSArray * arraykeyuploadid=[eItem elementsForName:@"UploadId"];
                if ([arraykeyuploadid isKindOfClass:[NSArray class]]&&[arraykeyuploadid count]) {
                    GDataXMLElement * uploadid=[arraykeyuploadid objectAtIndex:0];
                    item.strUploadId=[uploadid stringValue];
                }
                NSArray * arrayinitiated=[eItem elementsForName:@"Initiated"];
                if ([arrayinitiated isKindOfClass:[NSArray class]]&&[arrayinitiated count]) {
                    GDataXMLElement * initiated=[arrayinitiated objectAtIndex:0];
                    item.strInitiated=[initiated stringValue];
                }
                if (item.strKey.length) {
                    [self.arrayUpload addObject:item];
                }
            }
        }
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation OSSListPartsRet

@synthesize strBucket;
@synthesize strKey;
@synthesize strUploadId;
@synthesize strPartNumberMarker;
@synthesize strNextPartNumberMarker;
@synthesize strMaxParts;
@synthesize strIsTruncated;
@synthesize arrayUpload;

-(id)init
{
    if (self =[super init]) {
        self.strBucket =@"";
        self.strKey =@"";
        self.strUploadId =@"";
        self.strPartNumberMarker =@"";
        self.strNextPartNumberMarker =@"";
        self.strMaxParts =@"";
        self.strIsTruncated =@"";
    }
    return self;
}

-(void)dealloc
{
    strBucket=nil;
    strKey=nil;
    strUploadId=nil;
    strPartNumberMarker=nil;
    strMaxParts=nil;
    strIsTruncated=nil;
    [super dealloc];
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        NSArray * arraybucket=[rootElement elementsForName:@"Bucket"];
        if ([arraybucket isKindOfClass:[NSArray class]]&&[arraybucket count]) {
            GDataXMLElement * bucket=[arraybucket objectAtIndex:0];
            self.strBucket=[bucket stringValue];
        }
        NSArray * arraykey=[rootElement elementsForName:@"Key"];
        if ([arraykey isKindOfClass:[NSArray class]]&&[arraykey count]) {
            GDataXMLElement * key=[arraykey objectAtIndex:0];
            self.strKey=[key stringValue];
        }
        NSArray * arrayuploadid=[rootElement elementsForName:@"UploadId"];
        if ([arrayuploadid isKindOfClass:[NSArray class]]&&[arrayuploadid count]) {
            GDataXMLElement * uploadid=[arrayuploadid objectAtIndex:0];
            self.strUploadId=[uploadid stringValue];
        }
        NSArray * arraypartnumbermarker=[rootElement elementsForName:@"PartNumberMarker"];
        if ([arraypartnumbermarker isKindOfClass:[NSArray class]]&&[arraypartnumbermarker count]) {
            GDataXMLElement * partnumbermarker=[arraypartnumbermarker objectAtIndex:0];
            self.strPartNumberMarker=[partnumbermarker stringValue];
        }
        NSArray * arraynextpartnumbermarker=[rootElement elementsForName:@"NextPartNumberMarker"];
        if ([arraynextpartnumbermarker isKindOfClass:[NSArray class]]&&[arraynextpartnumbermarker count]) {
            GDataXMLElement * nextpartnumbermarker=[arraynextpartnumbermarker objectAtIndex:0];
            self.strNextPartNumberMarker=[nextpartnumbermarker stringValue];
        }
        NSArray * arraymaxparts=[rootElement elementsForName:@"MaxParts"];
        if ([arraymaxparts isKindOfClass:[NSArray class]]&&[arraymaxparts count]) {
            GDataXMLElement * maxparts=[arraymaxparts objectAtIndex:0];
            self.strMaxParts=[maxparts stringValue];
        }
        NSArray * arrayistruncated=[rootElement elementsForName:@"IsTruncated"];
        if ([arrayistruncated isKindOfClass:[NSArray class]]&&[arrayistruncated count]) {
            GDataXMLElement * istruncated=[arrayistruncated objectAtIndex:0];
            self.strIsTruncated=[istruncated stringValue];
        }
        NSArray * arraypart=[rootElement elementsForName:@"Part"];
        if ([arraypart isKindOfClass:[NSArray class]]&&[arraypart count]) {
            for (GDataXMLElement * eItem in arraypart) {
                OSSListPath * item =[[[OSSListPath alloc]init]autorelease];
                
                NSArray * arraypartnumber=[eItem elementsForName:@"PartNumber"];
                if ([arraypartnumber isKindOfClass:[NSArray class]]&&[arraypartnumber count]) {
                    GDataXMLElement * partnumber=[arraypartnumber objectAtIndex:0];
                    item.strPartNumber=[partnumber stringValue];
                }
                NSArray * arraylastmodified=[eItem elementsForName:@"LastModified"];
                if ([arraylastmodified isKindOfClass:[NSArray class]]&&[arraylastmodified count]) {
                    GDataXMLElement * lastmodified=[arraylastmodified objectAtIndex:0];
                    item.strLastModified=[lastmodified stringValue];
                }
                NSArray * arrayetag=[eItem elementsForName:@"ETag"];
                if ([arrayetag isKindOfClass:[NSArray class]]&&[arrayetag count]) {
                    GDataXMLElement * etag=[arrayetag objectAtIndex:0];
                    item.strEtag=[etag stringValue];
                }
                NSArray * arraysize=[eItem elementsForName:@"Size"];
                if ([arraysize isKindOfClass:[NSArray class]]&&[arraysize count]) {
                    GDataXMLElement * size=[arraysize objectAtIndex:0];
                    item.strSize=[size stringValue];
                }
                if (item.strPartNumber.length) {
                    [self.arrayUpload addObject:item];
                }
            }
        }
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation OSSListObjectRet

@synthesize strBucket;
@synthesize strPrefix;
@synthesize strMarker;
@synthesize strNextMarker;
@synthesize arrayContent;

-(id)init
{
    if (self =[super init]) {
        
        self.strBucket =@"";
        self.strPrefix =@"";
        self.strMarker =@"";
        self.strNextMarker =@"";
        self.arrayContent = [[[NSMutableArray alloc]init] autorelease];
    }
    return self;
}

-(void)dealloc
{
    strBucket=nil;
    strPrefix=nil;
    strMarker=nil;
    strNextMarker=nil;
    arrayContent=nil;
    [super dealloc];
}

-(BOOL) Parse
{
    if (rootElement!=nil) {
        NSArray * arrayname=[rootElement elementsForName:@"Name"];
        if ([arrayname isKindOfClass:[NSArray class]]&&[arrayname count]) {
            GDataXMLElement * name=[arrayname objectAtIndex:0];
            self.strBucket=[name stringValue];
        }
        NSArray * arrayprefix=[rootElement elementsForName:@"Prefix"];
        if ([arrayprefix isKindOfClass:[NSArray class]]&&[arrayprefix count]) {
            GDataXMLElement * prefix=[arrayprefix objectAtIndex:0];
            self.strPrefix=[prefix stringValue];
        }
        NSArray * arraymarker=[rootElement elementsForName:@"Marker"];
        if ([arraymarker isKindOfClass:[NSArray class]]&&[arraymarker count]) {
            GDataXMLElement * marker=[arraymarker objectAtIndex:0];
            self.strMarker=[marker stringValue];
        }
        NSArray * arraynextmarker=[rootElement elementsForName:@"NextMarker"];
        if ([arraynextmarker isKindOfClass:[NSArray class]]&&[arraynextmarker count]) {
            GDataXMLElement * nextmarker=[arraynextmarker objectAtIndex:0];
            self.strNextMarker=[nextmarker stringValue];
        }
        NSArray * arraycontent=[rootElement elementsForName:@"Contents"];
        if ([arraycontent isKindOfClass:[NSArray class]]&&[arraycontent count]) {
            for (GDataXMLElement * eItem in arraycontent) {
                OSSListObject * item =[[[OSSListObject alloc]init]autorelease];
                NSArray * arrayKey=[eItem elementsForName:@"Key"];
                if ([arrayKey isKindOfClass:[NSArray class]]&&[arrayKey count]) {
                    GDataXMLElement * key=[arrayKey objectAtIndex:0];
                    item.strKey=[key stringValue];
                }
                NSArray * arraykeylastmodified=[eItem elementsForName:@"LastModified"];
                if ([arraykeylastmodified isKindOfClass:[NSArray class]]&&[arraykeylastmodified count]) {
                    GDataXMLElement * lastmodified=[arraykeylastmodified objectAtIndex:0];
                    item.strLastModified=[lastmodified stringValue];
                }
                NSArray * arrayetag=[eItem elementsForName:@"ETag"];
                if ([arrayetag isKindOfClass:[NSArray class]]&&[arrayetag count]) {
                    GDataXMLElement * etag=[arrayetag objectAtIndex:0];
                    item.strEtag=[etag stringValue];
                }
                NSArray * arraytype=[eItem elementsForName:@"Type"];
                if ([arraytype isKindOfClass:[NSArray class]]&&[arraytype count]) {
                    GDataXMLElement * type=[arraytype objectAtIndex:0];
                    item.strType=[type stringValue];
                }
                NSArray * arraysize=[eItem elementsForName:@"Size"];
                if ([arraysize isKindOfClass:[NSArray class]]&&[arraysize count]) {
                    GDataXMLElement * size=[arraysize objectAtIndex:0];
                    item.strFilesize=[size stringValue];
                }
                if (![self.strPrefix isEqualToString:item.strKey]&&item.strKey.length) {
                    [self.arrayContent addObject:item];
                }
            }
        }
        NSArray * arrayprefixes=[rootElement elementsForName:@"CommonPrefixes"];
        if ([arrayprefixes isKindOfClass:[NSArray class]]&&[arrayprefixes count]) {
            for (GDataXMLElement * eItem in arrayprefixes) {
                OSSListObject * item =[[[OSSListObject alloc]init]autorelease];
                NSArray * arrayPrefix=[eItem elementsForName:@"Prefix"];
                if ([arrayPrefix isKindOfClass:[NSArray class]]&&[arrayPrefix count]) {
                    GDataXMLElement * prefix=[arrayPrefix objectAtIndex:0];
                    item.strPefix=[prefix stringValue];
                }
                if (![self.strPrefix isEqualToString:item.strPefix]&&item.strPefix.length) {
                    [self.arrayContent addObject:item];
                }
            }
        }
        [self ParseError];
        return YES;
    }
    else {
        return NO;
    }
}

@end

@implementation OSSListMultipartUpload

@synthesize strKey;
@synthesize strUploadId;
@synthesize strInitiated;

-(id)init
{
    if (self =[super init]) {
        
        self.strKey =@"";
        self.strUploadId =@"";
        self.strInitiated =@"";
    }
    return self;
}

-(void)dealloc
{
    strKey=nil;
    strUploadId=nil;
    strInitiated=nil;
    [super dealloc];
}

@end

@implementation OSSListPath

@synthesize strPartNumber;
@synthesize strLastModified;
@synthesize strEtag;
@synthesize strSize;

-(id)init
{
    if (self =[super init]) {
        
        self.strPartNumber =@"";
        self.strLastModified =@"";
        self.strEtag =@"";
        self.strSize =@"";
    }
    return self;
}

-(void)dealloc
{
    strPartNumber=nil;
    strLastModified=nil;
    strEtag=nil;
    strSize=nil;
    [super dealloc];
}

@end

@implementation OSSListObject

@synthesize strKey;
@synthesize strLastModified;
@synthesize strEtag;
@synthesize strType;
@synthesize strPefix;
@synthesize strFilesize;

-(id)init
{
    if (self =[super init]) {
        
        self.strKey =@"";
        self.strLastModified =@"";
        self.strEtag =@"";
        self.strType =@"";
        self.strPefix =@"";
        self.strFilesize =@"";
    }
    return self;
}

-(void)dealloc
{
    strKey=nil;
    strLastModified=nil;
    strEtag=nil;
    strType=nil;
    strPefix=nil;
    strFilesize=nil;
    [super dealloc];
}

@end

@implementation OSSAddObject

@synthesize strEtag;

-(id)init
{
    if (self=[super init]) {
        self.strEtag=@"";
    }
    return self;
}

-(void)dealloc
{
    strEtag=nil;
    [super dealloc];
}

@end






