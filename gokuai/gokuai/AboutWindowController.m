#import "AboutWindowController.h"
#import "Util.h"
#import "Common.h"


@implementation AboutWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib
{
    [lblPrompt setStringValue:[Util localizedStringForKey:@"够快科技" alternate:nil]];
    [lblVersion setStringValue:[NSString stringWithFormat:[Util localizedStringForKey:@"版本号：%@" alternate:nil],[Util getAppDelegate].appversion]];
}

-(IBAction) onOpenGoKuaiWebClicked:(id)sender
{
    [Util openWebUrl:@"http://www.gokuai.com"];
}

@end