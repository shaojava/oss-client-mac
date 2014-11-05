#import "ManagerBase.h"
#import "TaskBask.h"

@implementation ManagerBase

@synthesize bOut;
@synthesize bFinish;
@synthesize pLock;
@synthesize pArray;
@synthesize pQueue;
@synthesize pThread;
@synthesize nSpeed;
@synthesize ullSize;
@synthesize ullSizeTime;
@synthesize nMax;

-(id)init
{
    if (self=[super init]) {
        self.bOut=NO;
        self.bFinish = NO;
        self.pLock = [[[NSLock alloc]init]autorelease];
        self.pArray = [[[NSMutableArray alloc]init] autorelease];
        self.pQueue=[[NSOperationQueue alloc] init];
        self.nSpeed=0;
        self.ullSize=0;
        self.ullSizeTime=0;
        self.nMax=5;
        [self.pQueue setMaxConcurrentOperationCount:nMax];
    }
    return self;
}

-(void)uninit
{
    self.bOut=YES;
    [self StopAll];
    [self CheckFinishorError];
}

-(void)SetMax:(NSInteger)max
{
    self.nMax=max;
    [self.pQueue setMaxConcurrentOperationCount:nMax];
}

-(void)StopAll
{
    [self.pLock lock];
    for (TaskBask* item in self.pArray) {
        [item Stop:FALSE];
    }
    [self.pLock unlock];
}

-(void)CheckFinishorError
{
    [self.pLock lock];
    for (int i=0;i<self.pArray.count;i++) {
        TaskBask*item = [self.pArray objectAtIndex:i];
        if (item.pItem.nStatus==TRANSTASK_REMOVE) {
            [self.pArray removeObjectAtIndex:i];
        }
        else {
            i++;
        }
    }
    [self.pLock unlock];
}

-(ULONGLONG)GetSpeed
{
    ULONGLONG speed=0;
    [self.pLock lock];
    for (TaskBask* item in self.pArray) {
        speed+=[item GetSpeed];
    }
    [self.pLock unlock];
    return speed;
}

-(ULONGLONG)GetSpeed:(NSString*)bucket object:(NSString*)object
{
    ULONGLONG speed=0;
    [self.pLock lock];
    for (TaskBask* item in self.pArray) {
        if ([item.pItem.strObject isEqualToString:object]&&[item.pItem.strBucket isEqualToString:bucket]) {
            speed=[item GetSpeed];
            break;
        }
    }
    [self.pLock unlock];
    return speed;
}

-(NSMutableArray*)GetAll
{
    return nil;//zheng
}


@end
