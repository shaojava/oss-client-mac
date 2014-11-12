#import "OSSBody.h"

@implementation OSSBody

-(void)dealloc
{
    rootElement=nil;
    [super dealloc];
}

-(NSString*) GetBody
{
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:rootElement] autorelease];
    [document setVersion:@"1.0"];
    [document setCharacterEncoding:@"UTF-8"];
    NSData *data =  [document XMLData];
    NSString *content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    return content;
}

@end

@implementation OSSDeleteMultipleBody

-(void) addList:(NSArray*)array quiet:(BOOL)quiet
{
    rootElement = [GDataXMLNode elementWithName:@"Delete"];
    GDataXMLElement *quietElement = [GDataXMLNode elementWithName:@"Quiet"];
    if (quiet) {
        [quietElement setStringValue:@"true"];
    }
    else {
        [quietElement setStringValue:@"false"];
    }
    [rootElement addChild:quietElement];
    for (NSString *object in array) {
        GDataXMLElement *objectElemment=[GDataXMLNode elementWithName:@"Object"];
        GDataXMLElement *keyElemment=[GDataXMLNode elementWithName:@"Key"];
        [keyElemment setStringValue:object];
        [objectElemment addChild:keyElemment];
        [rootElement addChild:objectElemment];
    }
}

@end

@implementation OSSAddBucketBody

-(void) setLocation:(NSString*)location
{
    rootElement = [GDataXMLNode elementWithName:@"CreateBucketConfiguration"];
    GDataXMLElement *locationElement = [GDataXMLNode elementWithName:@"LocationConstraint"];
    [locationElement setStringValue:location];
    [rootElement addChild:locationElement];
}

@end

@implementation OSSADDBucketLoggingBody

-(void) setLoggin:(NSString*)bucket prefix:(NSString*)prefix
{
    rootElement = [GDataXMLNode elementWithName:@"BucketLoggingStatus"];
    if (bucket.length||prefix.length) {
        GDataXMLElement *enabledElement = [GDataXMLNode elementWithName:@"LoggingEnabled"];
        if (bucket.length) {
            GDataXMLElement *bucketElement = [GDataXMLNode elementWithName:@"TargetBucket"];
            [bucketElement setStringValue:bucket];
            [enabledElement addChild:bucketElement];
        }
        if (prefix.length) {
            GDataXMLElement *prefixElement = [GDataXMLNode elementWithName:@"TargetPrefix"];
            [prefixElement setStringValue:prefix];
            [enabledElement addChild:prefixElement];
        }
        [rootElement addChild:enabledElement];
    }
}

@end

@implementation OSSAddBucketWebsiteBody

-(void) setDocument:(NSString*)indexdoc errordoc:(NSString*)errordoc
{
    rootElement = [GDataXMLNode elementWithName:@"WebsitConfiguration"];
    GDataXMLElement *indexElement = [GDataXMLNode elementWithName:@"IndexDocument"];
    GDataXMLElement *suffixElement = [GDataXMLNode elementWithName:@"Suffix"];
    [suffixElement setStringValue:indexdoc];
    [indexElement addChild:suffixElement];
    [rootElement addChild:indexElement];
    GDataXMLElement *errorElement = [GDataXMLNode elementWithName:@"ErrorDocument"];
    GDataXMLElement *keyElement = [GDataXMLNode elementWithName:@"Key"];
    [keyElement setStringValue:errordoc];
    [errorElement addChild:keyElement];
    [rootElement addChild:errorElement];
}

@end

@implementation OSSCompleteMultipartUploadBody

-(void) setParts:(NSArray*)array
{
    rootElement = [GDataXMLNode elementWithName:@"CompleteMultipartUpload"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nIndex" ascending:YES];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    for (OSSUploadPart * item in sortedArray) {
        GDataXMLElement *partElement = [GDataXMLNode elementWithName:@"Part"];
        GDataXMLElement *partnumberElement = [GDataXMLNode elementWithName:@"PartNumber"];
        [partnumberElement setStringValue:[NSString stringWithFormat:@"%ld",item.nIndex]];
        [partElement addChild:partnumberElement];
        GDataXMLElement *etagElement = [GDataXMLNode elementWithName:@"ETag"];
        [etagElement setStringValue:item.strEtag];
        [partElement addChild:etagElement];
        [rootElement addChild:partElement];
    }
}

@end

@implementation OSSUploadPart

@synthesize nIndex;
@synthesize ullPos;
@synthesize ullSize;
@synthesize strEtag;

-(id)init
{
    if (self =[super init]) {
        
        self.nIndex = 0;
        self.ullPos = 0;
        self.ullSize = 0;
        self.strEtag =@"";
    }
    return self;
}

-(void)dealloc
{
    strEtag=nil;
    [super dealloc];
}

@end