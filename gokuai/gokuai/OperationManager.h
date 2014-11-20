
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface drag_item : NSObject {
    NSInteger mountid;
    NSString *webpath;
    NSString *filehash;
    
    BOOL cached;
    NSString *fullpath;
}

@property(assign,nonatomic)NSInteger mountid;
@property(retain,nonatomic)NSString *webpath;
@property(retain,nonatomic)NSString *filehash;

@property(assign,nonatomic)BOOL cached;
@property(retain,nonatomic)NSString *fullpath;

-(id) initWithDictionary:(NSDictionary *)dictionary;

@end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface OperPackage : NSOperation
{
    NSString* _operName;
    NSString* _jsonInfo;
    WebFrame* _webframe;
    WebScriptObject* _cb;
    NSWindow* _window;
    NSArray*  _array;
}

@property(retain,nonatomic) NSString* _operName;
@property(retain,nonatomic) NSString* _jsonInfo;
@property(retain,nonatomic) WebFrame* _webframe;
@property(retain,nonatomic) WebScriptObject* _cb;
@property(retain,nonatomic) NSWindow* _window;
@property(retain,nonatomic) NSArray* _array;

@end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface OperationManager : NSObject {
    NSOperationQueue* _operQueue;
}

+ (OperationManager*) sharedInstance;

+(void) addFile:(OperPackage*)tran;
+(void) saveFile:(OperPackage*)tran;
+(void) startUpload:(OperPackage*)tran;
+(void) startDownload:(OperPackage*)tran;
+(void) stopUpload:(OperPackage*)tran;
+(void) stopDownload:(OperPackage*)tran;
+(void) deleteUpload:(OperPackage*)tran;
+(void) deleteDownload:(OperPackage*)tran;
+(void) loginByKey:(OperPackage*)tran;
+(void) loginByFile:(OperPackage*)tran;
+(void) setPassword:(OperPackage*)tran;
+(void) loginPassword:(OperPackage*)tran;
+(void) setServerLocation:(OperPackage*)tran;

- (void) pack:(NSString*)name
     jsoninfo:(NSString*)jsonInfo
     webframe:(WebFrame*)webframe
           cb:(WebScriptObject*)cb
retController:(NSWindowController*)retController
        array:(NSArray*)array;
+(void) callbackonmain:(id)info;
+(void) operateCallback:(WebScriptObject*)_obj webFrame:(WebFrame*)_webFrame jsonString:(NSString*)_jsonString;

@end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////