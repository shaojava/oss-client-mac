#import "DownloadManager.h"
#import "TransPortDB.h"
#import "Util.h"
#import "DownloadTask.h"

@implementation DownloadManager

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
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            if (![Util getAppDelegate].bLogin) {
                [NSThread sleepForTimeInterval:2];
                continue;
            }
            if (![Util getAppDelegate].bLink) {
                [NSThread sleepForTimeInterval:2];
                continue;
            }
            [self CheckFinishorError];
            if (self.bFinish) {
                [NSThread sleepForTimeInterval:2];
                [self CheckFinish];
                continue;
            }
            if (self.nAdding>0) {
                [NSThread sleepForTimeInterval:1];
                continue;
            }
            [self.pLock lock];
            NSInteger num=[self.pArray count];
            [self.pLock unlock];
            while (num<self.nMax) {
                if (self.bOut) {
                    return;
                }
                TransTaskItem *item=[[TransPortDB shareTransPortDB] Get_Download];
                if (item.strBucket.length) {
                    DownloadTask *pTask=[[[DownloadTask alloc] init:item]autorelease];
                    [[TransPortDB shareTransPortDB] Update_DownloadStartActlast:item.strFullpath];
                    [self.pLock lock];
                    [self.pQueue addOperation:pTask];
                    [self.pArray addObject:pTask];
                    num=[self.pArray count];
                    [self.pLock unlock];
                }
                else {
                    [self CheckFinish];
                    [NSThread sleepForTimeInterval:0.1];
                    ULONGLONG time = (ULONGLONG)[[NSDate date] timeIntervalSince1970];
                    if (time-self.ullResetTime>600) {
                        [[TransPortDB shareTransPortDB] ResetDownloadError];
                        self.ullResetTime=time;
                    }
                    break;
                }
            }
            [NSThread sleepForTimeInterval:0.1];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [pool release];
        }
        
    }
}

-(void)Stop:(NSString*)fullpath
{
    [self.pLock lock];
    for (TaskBask * item in self.pArray) {
        if ([item.pItem.strFullpath isEqualToString:fullpath]) {
            [item Stop:NO];
        }
    }
    [self.pLock unlock];
}

-(void)Delete:(NSString*)fullpath
{
    [self.pLock lock];
    for (TaskBask* item in self.pArray) {
        if ([item.pItem.strFullpath isEqualToString:fullpath]) {
            [item Stop:YES];
        }
    }
    [self.pLock unlock];
}

-(void)CheckFinish
{
    self.bFinish=[[TransPortDB shareTransPortDB] Check_DownloadFinish];
}

@end
