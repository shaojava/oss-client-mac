//
//  WebBaseWindowController.h
//  GoKuai
//
//  Created by GoKuai on 1/8/14.
//
//

#import <Cocoa/Cocoa.h>

#import "Window+Event.h"
#import "Webview+Dragging.h"
#import "GKWebViewDelegate.h"


@interface BaseWebWindowController : NSWindowController {
    IBOutlet GKWebview* baseWebview;
    GKWebViewDelegate *delegate;
    NSString* strUrl;
    BOOL alreadyload;
}

@property(nonatomic,retain)GKWebViewDelegate * delegate;
@property(nonatomic,retain)NSString* strUrl;;

-(WebFrame*) mainframe;
-(NSString*) dragInformation;
-(WebScriptObject*) windowscriptobj;
-(void) makeAble:(BOOL)ableornot;
-(void) reload:(BOOL)must;

@end
