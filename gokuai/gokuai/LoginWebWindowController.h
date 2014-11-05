#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BaseWebWindowController.h"
@class BrowserWebWindowController,GKWebViewDelegate;

@interface LoginWebWindowController : BaseWebWindowController
{
    BOOL bOut;
}
@property(nonatomic)BOOL bOut;

- (BOOL)windowShouldClose:(id)sender;
@end
