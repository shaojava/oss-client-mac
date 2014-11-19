
#import <Cocoa/Cocoa.h>
#import "BaseWebWindowController.h"

@class GKWebViewDelegate;

@interface BrowserWebWindowController : BaseWebWindowController {
    IBOutlet NSTextField *lblAlert;
    NSString* solestr;
    BOOL bClose;
    BOOL bAdjusted;
}

@property(nonatomic,assign)NSTextField *lblAlert;
@property(nonatomic,retain)NSString *solestr;
@property(nonatomic,assign)BOOL bClose;
@property(nonatomic,assign)BOOL bAdjusted;

-(void)setAlertFrame;
-(void)adjustframe:(NSSize)size;

@end