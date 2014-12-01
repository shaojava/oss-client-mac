
#import "DownloadCallbackThread.h"
#import "Util.h"
#import "Network.h"
#import "JSONKit.h"
#import "TransPortDB.h"

@implementation DownloadCallbackThread

-(id)init
{
    if (self=[super init]) {
        self.pThread = [[[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil] autorelease];
        [self.pThread start];
    }
    return self;
}

-(void)run
{
    CFAbsoluteTime timerrun = CFAbsoluteTimeGetCurrent();
    while (TRUE) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
            if (now-timerrun>1) {
                [Network shareNetwork].nDownloadSpeed=[[Network shareNetwork].dManager GetSpeed];
                [Network shareNetwork].nDownloadCount=[[TransPortDB shareTransPortDB] GetDownloadCount];
                [Network shareNetwork].nDonwloadFinish=[[TransPortDB shareTransPortDB] GetDownloadFinishCount];
                [self SendCallbackInfos];
                timerrun=now;
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            [pool release];
        }
        [NSThread sleepForTimeInterval:1];
    }
}

-(void)SendCallbackInfo:(TransTaskItem*)item
{
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    NSMutableArray* arrayRet=[NSMutableArray array];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nDownloadSpeed] forKey:@"download"];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nUploadSpeed] forKey:@"upload"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDownloadCount] forKey:@"download_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDonwloadFinish] forKey:@"download_done_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadCount] forKey:@"upload_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadFinish] forKey:@"upload_done_count"];
    NSMutableDictionary* dicRet=[NSMutableDictionary dictionary];
    [dicRet setValue:item.strPathhash forKey:@"pathhash"];
    [dicRet setValue:item.strBucket forKey:@"bucket"];
    [dicRet setValue:item.strObject forKey:@"object"];
    [dicRet setValue:item.strFullpath forKey:@"fullpath"];
    [dicRet setValue:[NSNumber numberWithLongLong:item.ullOffset] forKey:@"offset"];
    [dicRet setValue:[NSNumber numberWithLongLong:item.ullFilesize] forKey:@"filesize"];
    [dicRet setValue:[NSNumber numberWithInteger:item.nStatus] forKey:@"status"];
    [dicRet setValue:[NSNumber numberWithLongLong:item.ullSpeed] forKey:@"speed"];
    [dicRet setValue:item.strMsg forKey:@"errormsg"];
    [arrayRet addObject:dicRet];
    [dicRetlist setValue:arrayRet forKey:@"list"];
    NSString * json=[dicRetlist JSONString];
    if ([Util getAppDelegate].bFinishCallback&&self.pWebFrame!=nil&&self.pWebScriptOjbect!=nil) {
        [CallbackThread operateCallback:self.pWebScriptOjbect webFrame:self.pWebFrame jsonString:json];
    }
}

-(void)SendCallbackInfos
{
    NSMutableArray *items=[[Network shareNetwork].dManager GetAll];
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    NSMutableArray* arrayRet=[NSMutableArray array];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nDownloadSpeed] forKey:@"download"];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nUploadSpeed] forKey:@"upload"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDownloadCount] forKey:@"download_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDonwloadFinish] forKey:@"download_done_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadCount] forKey:@"upload_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadFinish] forKey:@"upload_done_count"];
    for (TransTaskItem* item in items) {
        NSMutableDictionary* dicRet=[NSMutableDictionary dictionary];
        [dicRet setValue:item.strPathhash forKey:@"pathhash"];
        [dicRet setValue:item.strBucket forKey:@"bucket"];
        [dicRet setValue:item.strObject forKey:@"object"];
        [dicRet setValue:item.strFullpath forKey:@"fullpath"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullOffset] forKey:@"offset"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullFilesize] forKey:@"filesize"];
        [dicRet setValue:[NSNumber numberWithInteger:item.nStatus] forKey:@"status"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullSpeed] forKey:@"speed"];
        [dicRet setValue:item.strMsg forKey:@"errormsg"];
        [arrayRet addObject:dicRet];
    }
    [dicRetlist setValue:arrayRet forKey:@"list"];
    NSString * json=[dicRetlist JSONString];
    if ([Util getAppDelegate].bFinishCallback&&self.pWebFrame!=nil&&self.pWebScriptOjbect!=nil) {
        [CallbackThread operateCallback:self.pWebScriptOjbect webFrame:self.pWebFrame jsonString:json];
    }
}
@end
