#import "UploadManager.h"
#import "TransPortDB.h"
#import "Util.h"
#import "UploadTask.h"

@implementation UploadManager

-(id)init
{
    if (self = [super init])
    {
        self.pThread = [[[NSThread alloc] initWithTarget:self selector:@selector(Run) object:nil] autorelease];
        [self.pThread start];
    }
    return self;
}

-(void)Run
{
    while (!self.bOut) {
        if (![Util getAppDelegate].bLogin) {
            [NSThread sleepForTimeInterval:2];
            continue;
        }
        [self CheckFinishorError];
        if (self.bFinish) {
            [NSThread sleepForTimeInterval:2];
            [self CheckFinish];
            continue;
        }
        [self.pLock lock];
        NSInteger num=[self.pArray count];
        [self.pLock unlock];
        while (num<self.nMax) {
            if (self.bOut) {
                return;
            }
            TransTaskItem *item=[[TransPortDB shareTransPortDB] Get_Upload];
            if (item.strBucket.length) {
                UploadTask *pTask=[[[UploadTask alloc] init:item]autorelease];
                [[TransPortDB shareTransPortDB] Update_UploadStartActlast:item.strPathhash];
                [self.pLock lock];
                [self.pQueue addOperation:pTask];
                [self.pArray addObject:pTask];
                num=[self.pArray count];
                [self.pLock unlock];
            }
            else {
                [self CheckFinish];
                [NSThread sleepForTimeInterval:0.1];
                break;
            }
        }
    }
}

-(void)Stop:(NSString*)bucket object:(NSString*)object
{
    [self.pLock lock];
    for (TaskBask* item in self.pArray) {
        if ([item.pItem.strBucket isEqualToString:bucket]&&[item.pItem.strObject isEqualToString:object]) {
            [item Stop:NO];
        }
    }
    [self.pLock unlock];
}

-(void)Delete:(NSString*)bucket object:(NSString*)object
{
    [self.pLock lock];
    for (TaskBask* item in self.pArray) {
        if ([item.pItem.strBucket isEqualToString:bucket]&&[item.pItem.strObject isEqualToString:object]) {
            [item Stop:YES];
        }
    }
    [self.pLock unlock];
}

-(void)CheckFinish
{
    self.bFinish=[[TransPortDB shareTransPortDB] Check_UploadFinish];
}

@end
