//
//  AppUpdateWindowController.m
//  gokuai
//
//  Created by GouKuai on 12-11-20.
//
//

#import "AppUpdateWindowController.h"

@interface AppUpdateWindowController ()

@end

@implementation AppUpdateWindowController
@synthesize appProgress;
@synthesize downloadProgress;
@synthesize appVersion;
@synthesize serVersion;

-(void)dealloc
{
    [appProgress release];
    [serVersion release];
    [appVersion release];
    [downloadProgress release];
    [super dealloc];
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
