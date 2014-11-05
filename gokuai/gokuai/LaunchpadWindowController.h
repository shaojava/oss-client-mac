
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "Webview+Dragging.h"
#import "BaseWebWindowController.h"
////////////////////////////////////////////////////////////////////////////////////////////////

@class BrowserWebWindowController,GKWebViewDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////

@interface LaunchpadWindowController : BaseWebWindowController {
    BOOL    _bFirst;
    
    NSString* _tab;
    NSString* _jsonInfo;
    NSString* _jsonAction;
    NSString* _jsonChat;
    
    NSInteger _curMountid;
    NSString* _curWebpath;
    
    NSInteger _desktopId;
    NSArray *_dragitems;
}

@property(nonatomic)BOOL _bFirst;

@property(nonatomic,retain)NSString* _tab;
@property(nonatomic,retain)NSString* _jsonInfo;
@property(nonatomic,retain)NSString* _jsonAction;
@property(nonatomic,retain)NSString* _jsonChat;

@property(nonatomic,assign)NSInteger _curMountid;
@property(nonatomic,retain)NSString* _curWebpath;
@property(nonatomic,retain)NSArray* _dragitems;


-(void) adjustposition;


- (BOOL)windowShouldClose:(id)sender;

@end
////////////////////////////////////////////////////////////////////////////////////////////////
