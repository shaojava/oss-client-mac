//
//  PasteWindowController.h
//  GoKuai
//
//  Created by GoKuai on 13-12-30.
//
//

#import <Cocoa/Cocoa.h>
#import "NSTextField+Resizable.h"

@interface MoveAndPasteWindowController : NSWindowController {
    
    GKResizableTextField* _copyinfo;
    
    NSImageView* _icon;
    NSButton* _applytoall;
    NSButton* _keepboth;
    NSButton* _stop;
    NSButton* _replace;
    
    //0:keep 1:stop 2:rpl;
    NSInteger _applyflag;
}

-(BOOL) copyfiles:(NSArray*)srcfiles dstobject:(NSString*)dstobject;
-(BOOL) savefiles:(NSArray*)srcfiles savepath:(NSString*)savepath;
-(IBAction) buttonApplyToAllClicked:(id)sender;
-(IBAction)buttonNotReplaceClicked:(id)sender;

@end
