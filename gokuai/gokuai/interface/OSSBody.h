#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface OSSBody : NSObject {
    GDataXMLElement *rootElement;
}

-(NSString*) GetBody;

@end

@interface OSSDeleteMultipleBody : OSSBody

-(void) addList:(NSArray*)array quiet:(BOOL)quiet;

@end

@interface OSSAddBucketBody : OSSBody

-(void) setLocation:(NSString*)location;

@end

@interface OSSADDBucketLoggingBody : OSSBody

-(void) setLoggin:(NSString*)bucket prefix:(NSString*)prefix;

@end

@interface OSSAddBucketWebsiteBody : OSSBody

-(void) setDocument:(NSString*)indexdoc errordoc:(NSString*)errordoc;

@end

@interface OSSCompleteMultipartUploadBody : OSSBody

-(void) setParts:(NSArray*)array;

@end

@interface OSSUploadPart : NSObject {
    NSInteger           nIndex;
    unsigned long long  ullPos;
    unsigned long long  ullSize;
    NSString*           strEtag;
}
@property(nonatomic,assign) NSInteger nIndex;
@property(nonatomic,assign) unsigned long long ullPos;
@property(nonatomic,assign) unsigned long long ullSize;
@property(nonatomic,retain) NSString* strEtag;

@end