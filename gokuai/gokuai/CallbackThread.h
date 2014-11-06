#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "NetworkDef.h"

@interface CallbackThread : NSObject
{
    NSThread*           pThread;
    WebFrame*           pWebFrame;
    WebScriptObject*    pWebScriptOjbect;
}

@property(nonatomic,retain)NSThread* pThread;
@property(nonatomic,retain)WebFrame* pWebFrame;
@property(nonatomic,retain)WebScriptObject* pWebScriptOjbect;

-(id)init;
-(void)SetCallbackStatus:(WebFrame*)webframe cb:(WebScriptObject*)cb;
+(void)callbackonmain:(id)info;
+(void)operateCallback:(WebScriptObject*)_obj webFrame:(WebFrame*)_webFrame jsonString:(NSString*)_jsonString;
@end
