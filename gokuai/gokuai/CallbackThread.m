
#import "CallbackThread.h"
#import "Util.h"
#import "Network.h"
#import "JSONKit.h"

@implementation CallbackThread

@synthesize pThread;
@synthesize pWebFrame;
@synthesize pWebScriptOjbect;

-(id)init
{
    if (self=[super init]) {
        self.pThread=nil;
        self.pWebFrame=nil;
        self.pWebScriptOjbect=nil;
    }
    return self;
}

-(void)dealloc
{
    [pThread cancel];
    [pThread release];
    pWebFrame=nil;
    pWebScriptOjbect=nil;
    [super dealloc];
}

-(void)SetCallbackStatus:(WebFrame*)webframe cb:(WebScriptObject*)cb
{
    self.pWebFrame=webframe;
    self.pWebScriptOjbect=cb;
}

+(void) callbackonmain:(id)info
{
    NSDictionary* dicInfo=(NSDictionary*)info;
    JSContextRef ctx =[(WebFrame*)[dicInfo valueForKey:@"webframe"] globalContext];
    JSObjectRef func = [(WebScriptObject*)[dicInfo valueForKey:@"obj"] JSObject];
    NSString* jsonstring= [dicInfo valueForKey:@"jsonstring"];
    JSStringRef jsstr = JSStringCreateWithCFString((CFStringRef)jsonstring);
    JSValueRef jsvalue = JSValueMakeFromJSONString(ctx, jsstr);
    JSStringRelease(jsstr);
    JSObjectCallAsFunction(ctx, func, NULL, 1, &jsvalue, NULL);
}

+(void) operateCallback:(WebScriptObject*)_obj webFrame:(WebFrame*)_webFrame jsonString:(NSString*)_jsonString
{
    if (![_obj isKindOfClass:[WebScriptObject class]]
        || !JSObjectIsFunction([_webFrame globalContext],[_obj JSObject])) {
        return;
    }
    NSDictionary* info=[NSDictionary dictionaryWithObjectsAndKeys:
                        _webFrame,@"webframe", _obj,@"obj", _jsonString,@"jsonstring", nil];
    [self performSelectorOnMainThread:@selector(callbackonmain:) withObject:info waitUntilDone:NO];
}

@end
