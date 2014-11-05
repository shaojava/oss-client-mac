
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GKWebview : WebView {
    NSString* jsonInfo;
    void (^dropEvent)(void);
    void (^dragfinishEvent)(void);
    
    NSPoint rpoint;
    
    BOOL _out;
    NSString* outstr;
}

@property(nonatomic,assign) NSPoint rpoint;
@property(nonatomic,retain) NSString* jsonInfo;
@property(nonatomic,copy) void (^dropEvent)(void);
@property(nonatomic,copy) void (^dragfinishEvent)(void);

@property(nonatomic,assign) BOOL _out;
@property(nonatomic,retain) NSString* outstr;

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////