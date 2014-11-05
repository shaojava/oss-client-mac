#import "PeerBase.h"

@implementation PeerBase

@synthesize pTask;
@synthesize strHost;
@synthesize strBucket;
@synthesize strObject;
@synthesize strHeader;
@synthesize bStart;
@synthesize bStop;
@synthesize nIndex;
@synthesize ullPos;
@synthesize ullSize;

-(void)dealloc
{
    pTask=nil;
    strHost=nil;
    strBucket=nil;
    strObject=nil;
    strHeader=nil;
    [super dealloc];
}

-(void)Stop
{
    self.bStop=YES;
}

-(BOOL)IsIdle
{
    return !self.bStart;
}


@end
