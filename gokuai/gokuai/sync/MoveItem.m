

#import "MoveItem.h"

@implementation MoveItem

@synthesize frompath;
@synthesize topath;
@synthesize dir;

-(void)dealloc
{
    [frompath release];
    [topath release];
    [super dealloc];
}

@end
