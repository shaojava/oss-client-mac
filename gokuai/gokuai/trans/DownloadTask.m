#import "DownloadTask.h"
#import "NSStringExpand.h"
#import "Util.h"
#import "TransPortDB.h"
#import "DownloadPeer.h"
#import "Network.h"
#import "FileLog.h"

@implementation DownloadTask

@synthesize pFileHandle;
@synthesize pIndexFileHandle;
@synthesize ullWriteTime;

-(id)init:(TransTaskItem*)item
{
    if (self=[super init:item]) {
        self.nMax=[Network shareNetwork].nDPeerMax;
    }
    return self;
}

-(void)dealloc
{
    pFileHandle=nil;
    pIndexFileHandle=nil;
    [super dealloc];
}

-(BOOL)CreateFile
{
    NSString *dir=[self.pItem.strFullpath stringByDeletingLastPathComponent];
    [Util createfolder:dir];
    NSString * temppath=[NSString stringWithFormat:@"%@%@",self.pItem.strFullpath,OSSEXT];
    BOOL ret=[Util createfile:temppath];
    if (ret) {
        self.pFileHandle=[NSFileHandle fileHandleForWritingAtPath:temppath];
        if (self.pFileHandle) {
            ret=YES;
        }
        if (ret) {
            NSString * temp=[self GetTmpPath];
            ret=[Util createfile:temp];
            if (ret) {
                self.pIndexFileHandle=[NSFileHandle fileHandleForUpdatingAtPath:temp];
                if (self.pIndexFileHandle) {
                    NSData * data=[self.pIndexFileHandle readDataToEndOfFile];
                    if (data.length>0) {
                        NSString * downloadtemp=[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                        [self.pFinish LoadParisFromString:downloadtemp];
                    }
                    else {
                        [self.pFinish Clear];
                    }
                    self.pItem.ullOffset=[self.pFinish Size];
                    [self.pUnFinish InsertPart:0 last:self.pItem.ullFilesize-1];
                    [self.pUnFinish RemoveDataLocatiors:self.pFinish];
                }
                else {
                    ret=NO;
                    NSLog(@"open download index error");
                }
            }
        }
    }
    return ret;
}

-(void)CloseFile
{
    [self.pFilesc lock];
    if (self.pIndexFileHandle) {
        [self.pIndexFileHandle closeFile];
    }
    if (self.pFileHandle) {
        [self.pFileHandle closeFile];
    }
    [self.pFilesc unlock];
}

-(void)CheckDeleteFile
{
    if (self.bDelete) {
        NSString * temppath=[NSString stringWithFormat:@"%@%@",self.pItem.strFullpath,OSSEXT];
        if ([Util existfile:temppath]) {
            [Util deletefile:temppath];
        }
        temppath=[self GetTmpPath];
        if ([Util existfile:temppath]) {
            [Util deletefile:temppath];
        }
    }
}

-(void)DeleteTmpFile
{
    NSString* temppath=[self GetTmpPath];
    if ([Util existfile:temppath]) {
        [Util deletefile:temppath];
    }
}

-(void)Finish
{
    if (self.bStop) {
        return;
    }
    self.bStop=YES;
    [self CloseFile];
    NSString *temppath=[NSString stringWithFormat:@"%@%@",self.pItem.strFullpath,OSSEXT];
    if (self.pItem.ullFilesize!=0) {
        if ([Util movefile:temppath newfile:self.pItem.strFullpath]) {
            [[TransPortDB shareTransPortDB] Update_DownloadOffsetFinish:self.pItem.strFullpath offset:self.pItem.ullFilesize];
            [self DeleteTmpFile];
            self.pItem.nStatus=TRANSTASK_FINISH;
        }
    }
    else {
        [[TransPortDB shareTransPortDB] Update_DownloadOffsetFinish:self.pItem.strFullpath offset:self.pItem.ullFilesize];
        [self DeleteTmpFile];
        self.pItem.nStatus=TRANSTASK_FINISH;
    }
    [[Network shareNetwork].dCallback SendCallbackInfo:self.pItem];
}

-(BOOL)WriteFile:(char *)data pos:(ULONGLONG)pos size:(NSInteger)size
{
    if (self.bStop) {
        return NO;
    }
    BOOL ret=NO;
    [self.pFilesc lock];
    self.ullRuntime=CFAbsoluteTimeGetCurrent();
    @try {
        if (self.pFileHandle) {
            [self.pFileHandle seekToFileOffset:pos];
            NSData *wdata=[NSData dataWithBytes:data length:size];
            [self.pFileHandle writeData:wdata];
            self.pItem.ullOffset+=size;
            self.ullTranssize+=size;
            unsigned long long newpos=[self.pFileHandle offsetInFile];
            if (pos+size==newpos) {
                ret=YES;
            }
            else {
                ret=NO;
            }
            if (ret) {
                [self.pFinish InsertPart:pos last:pos+size-1];
            }
            ULONGLONG now=CFAbsoluteTimeGetCurrent();
            if (now>self.ullWriteTime+2) {
                [[TransPortDB shareTransPortDB] Update_DownloadOffset:self.pItem.strFullpath offset:self.pItem.ullOffset];
                [self SaveIndexFile];
                self.ullWriteTime=now;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"writefile:%@",exception);
    }
    @finally {
    }
    [self.pFilesc unlock];
    return ret;
}

-(BOOL)GetDownloadIndex:(ULONGLONG*)pos size:(ULONGLONG*)size num:(NSInteger)num
{
    if ([self.pUnFinish Size]==0) {
        return NO;
    }
    if (num>=self.nMax) {
        return NO;
    }
    if (self.pUnFinish.arrayData.count>=self.nMax-num) {
        DataPair * item=[self.pUnFinish.arrayData objectAtIndex:0];
        *pos=item.ullFirstMark;
        *size=item.ullLastMark-item.ullFirstMark+1;
        return YES;
    }
    if (self.pUnFinish.arrayData.count==1) {
        DataPair * item=[self.pUnFinish.arrayData objectAtIndex:0];
        *pos=item.ullFirstMark;
        *size=item.ullLastMark-item.ullFirstMark+1;
        if (*size>self.ullPiecesize*2) {
            ULONGLONG temp=*size/(ULONGLONG)(self.nMax-num);
            if (temp<self.ullPiecesize) {
                *size=self.ullPiecesize;
            }
            else {
                *size=temp;
            }
        }
        return YES;
    }
    DataPair *item=[self.pUnFinish FindSmallPair];
    *pos=item.ullFirstMark;
    *size=item.ullLastMark-item.ullFirstMark+1;
    return YES;
}

-(void)TaskError:(NSInteger)error msg:(NSString*)msg
{
    if (self.bStop) {
        return;
    }
    NSString * errormsg=[NSString stringWithFormat:@"[TaskError:%@|%@][%ld,%@]",self.pItem.strBucket,self.pItem.strObject,error,msg];
    [[FileLog shareFileLog] log:errormsg add:YES];
    [[TransPortDB shareTransPortDB] Update_DownloadError:self.pItem.strFullpath error:error msg:msg];
    self.pItem.nStatus=TRANSTASK_ERROR;
    [[Network shareNetwork].dCallback SendCallbackInfo:self.pItem];
}

-(void)ErrorIndex:(ULONGLONG)pos size:(ULONGLONG)size error:(NSInteger)error msg:(NSString*)msg
{
    NSString * errormsg=[NSString stringWithFormat:@"[ErrorIndex:%@|%@][%llu,%llu,%ld,%@]",self.pItem.strBucket,self.pItem.strObject,pos,size,error,msg];
    [[FileLog shareFileLog] log:errormsg add:NO];
    [self.pLocksc lock];
    NSArray * ret=[self.pFinish GetInPairs:pos last:pos+size-1];
    [self.pUnFinish InsertParts:ret];
    [self.pLocksc unlock];
}

-(void)SaveIndexFile
{
    if (self.bStop) {
        return;
    }
    if (self.pIndexFileHandle) {
        NSString* indexdata=[self.pFinish OutPut];
        NSData * data=[indexdata dataUsingEncoding: NSUTF8StringEncoding];
        [self.pIndexFileHandle seekToFileOffset:0];
        [self.pIndexFileHandle writeData:data];
        [self.pIndexFileHandle synchronizeFile];
    }
}

-(NSString*)GetTmpPath
{
    NSString* strDir=[self.pItem.strFullpath stringByDeletingLastPathComponent];
    NSString* strFilename=[self.pItem.strFullpath lastPathComponent];
    if (self.pItem.strPathhash.length) {
        return [NSString stringWithFormat:@"%@/.%@.%@",strDir,strFilename,self.pItem.strPathhash];//zheng 删除的问题
    }
    else {
        return [NSString stringWithFormat:@"%@/.%@.%@",strDir,strFilename,OSSTMP];
    }
}

-(void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        if (self.pItem.ullFilesize==0) {
            if ([self.pItem.strObject hasSuffix:@"/"]) {
                [Util createfolder:self.pItem.strFullpath];
                if ([Util existfile:self.pItem.strFullpath]) {
                    [self Finish];
                    return;
                }
                else {
                    [self TaskError:TRANSERROR_CREATEDIF msg:@"创建文件夹失败"];
                    return;
                }
            }
            else {
                if ([Util createfile:self.pItem.strFullpath]) {
                    [self Finish];
                    return;
                }
                else {
                    [self TaskError:TRANSERROR_CREATEDIF msg:@"创建0字节文件失败"];
                    return;
                }
            }
        }
        if (![self CreateFile]) {
            [self TaskError:TRANSERROR_CREATEDIF msg:@"创建文件失败"];
            return;
        }
        self.ullStarttime=CFAbsoluteTimeGetCurrent();
        self.ullRuntime=self.ullStarttime;
        while (YES) {
            if (self.bStop) {
                return;
            }
            if ([self CheckFinish]) {
                [self Finish];
                return;
            }
            NSInteger num=[self GetPeerNum];
            ULONGLONG pos;
            ULONGLONG size;
            if ([self GetDownloadIndex:&pos size:&size num:num]) {
                [self.pLocksc lock];
                num=[self.listPeer count];
                [self.pLocksc unlock];
                if (num<self.nMax) {
                    DownloadPeer *peer=[[[DownloadPeer alloc]init:self host:self.pItem.strHost bucket:self.pItem.strBucket object:self.pItem.strObject] autorelease];
                    [self.pFilesc lock];
                    [self.pUnFinish RemovePairs:pos last:pos+size-1];
                    [self.pFilesc unlock];
                    [self.pLocksc lock];
                    [self.listPeer addObject:peer];
                    [self.pLocksc unlock];
                    [peer StartDownload:pos size:size];
                }
                [self CheckPeer];
            }
            else {
                [NSThread sleepForTimeInterval:2];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        [self CloseFile];
        [self CheckDeleteFile];
        [pool release];
        self.pItem.nStatus=TRANSTASK_REMOVE;
    }
}

-(void)CheckPeer
{
    [self.pLocksc lock];
    for (int i=0;i<self.listPeer.count;i++) {
        DownloadPeer*item = [self.listPeer objectAtIndex:i];
        if ([item IsIdle]) {
            [self.listPeer removeObjectAtIndex:i];
        }
        else {
            i++;
        }
    }
    [self.pLocksc unlock];
}

@end
