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
@synthesize pRequest;

-(void)dealloc
{
    self.pTask=nil;
    self.strHost=nil;
    self.strBucket=nil;
    self.strObject=nil;
    self.strHeader=nil;
    self.pRequest=nil;
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
