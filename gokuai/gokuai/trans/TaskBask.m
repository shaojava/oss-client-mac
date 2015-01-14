
#import "TaskBask.h"
#import "PeerBase.h"

#define PIECESIZE   5242880

@implementation TaskBask

@synthesize pItem;
@synthesize listPeer;
@synthesize pLocksc;
@synthesize pFilesc;
@synthesize pFinish;
@synthesize pUnFinish;
@synthesize nMax;
@synthesize bStop;
@synthesize bDelete;
@synthesize ullTranssize;
@synthesize ullStarttime;
@synthesize ullRuntime;
@synthesize ullPiecesize;
@synthesize ullSpeed;


-(id)init:(TransTaskItem*)item
{
    if (self=[super init]) {
        self.pItem=item;
        self.nMax=5;
        ULONGLONG piecesize=(item.ullFilesize+4999)/5000;
        self.ullPiecesize=piecesize>PIECESIZE?piecesize:PIECESIZE;
        self.listPeer = [[[NSMutableArray alloc]init] autorelease];
        self.pLocksc = [[[NSLock alloc]init]autorelease];
        self.pFilesc = [[[NSLock alloc]init]autorelease];
        self.pFinish=[[[DataLocator alloc]init]autorelease];
        self.pUnFinish=[[[DataLocator alloc]init]autorelease];
        self.bStop=NO;
        self.bDelete=NO;
        self.ullTranssize=0;
        self.ullStarttime=0;
        self.ullRuntime=0;
        self.ullSpeed=0;
        self.pItem.nStatus=TRANSTASK_START;
    }
    return self;
}

-(void)dealloc
{
    self.pItem=nil;
    self.listPeer=nil;
    self.pLocksc=nil;
    self.pFilesc=nil;
    self.pFinish=nil;
    self.pUnFinish=nil;
    [super dealloc];
}

-(BOOL)Stop:(BOOL)bdelete
{
    if (self.pItem.nStatus==TRANSTASK_START) {
        self.pItem.nStatus=TRANSTASK_STOP;
    }
    self.bStop=YES;
    self.bDelete=bdelete;
    return YES;
}

-(ULONGLONG)GetSpeed
{
    self.ullSpeed=0;
    if (self.ullStarttime==0) {
        return 0;
    }
    if (self.ullTranssize==0) {
        return 0;
    }
    ULONGLONG now=CFAbsoluteTimeGetCurrent();
    if (now<=self.ullStarttime) {
        return 0;
    }
    else {
        self.ullSpeed=self.ullTranssize/(now-self.ullStarttime);
        self.ullTranssize=0;
        self.ullStarttime=now;
        return self.ullSpeed;
    }
}

-(BOOL)CheckFinish
{
    [self.pFilesc lock];
    ULONGLONG filesize=[self.pFinish Size];
    [self.pFilesc unlock];
    if (self.pItem.ullFilesize==filesize) {
        return YES;
    }
    else {
        return NO;
    }
}

-(NSInteger)GetPeerNum
{
    NSInteger num=0;
    [self.pLocksc lock];
    for (PeerBase * peer in self.listPeer) {
        if (![peer IsIdle]) {
            num++;
        }
    }
    [self.pLocksc unlock];
    return num;
}

@end
