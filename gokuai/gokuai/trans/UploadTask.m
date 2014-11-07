
#import "UploadTask.h"
#import "TransPortDB.h"
#import "OSSBody.h"
#import "Util.h"
#import "UploadPeer.h"
#import "OSSApi.h"
#import "NSDataExpand.h"
#import "Network.h"

@implementation UploadTask

@synthesize pIndexFileHandle;
@synthesize pPartList;

-(id)init:(TransTaskItem*)item
{
    if (self=[super init:item]) {
        self.pIndexFileHandle=nil;
        self.pPartList=[[[NSMutableArray alloc]init] autorelease];
        pPartBuffer=malloc(10000*UPLOADPARTSIZE);
    }
    return self;
}

-(void)dealloc
{
    pIndexFileHandle=nil;
    pPartList=nil;
    free(pPartBuffer);
    [super dealloc]; 
}

-(void)Finish
{
    if (self.bStop) {
        return;
    }
    self.bStop=YES;
    [[TransPortDB shareTransPortDB] Update_UploadStatus:self.pItem.strPathhash status:TRANSTASK_FINISH];
    [self DeleteMultipartFile];
    self.pItem.nStatus=TRANSTASK_FINISH;
    [[Network shareNetwork].uCallback SendCallbackInfo:self.pItem];
}

-(void)FinishIndex:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size etag:(NSString*)etag;
{
    if (self.bStop) {
        return;
    }
    NSLog(@"FinishIndex:%ld,%llu,%llu,%@",index,pos,size,etag);
    OSSUploadPart* item=[[[OSSUploadPart alloc]init]autorelease];
    item.nIndex=index;
    item.ullPos=pos;
    item.ullSize=size;
    item.strEtag=etag;
    [self.pPartList addObject:item];
    [self.pLocksc lock];
    [self.pFinish InsertPart:pos last:pos+size-1];
    [self.pLocksc unlock];
    self.pItem.ullOffset+=size;
    self.ullTranssize+=size;
    [[TransPortDB shareTransPortDB] Update_UploadOffset:self.pItem.strPathhash offset:self.pItem.ullOffset];
    [self SaveMultipartFile];
}

-(void)ErrorIndex:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size error:(NSInteger)error msg:(NSString*)msg
{
    [self.pLocksc lock];
    [self.pUnFinish InsertPart:pos last:pos+size-1];
    [self.pLocksc unlock];
    NSString * errormsg=[NSString stringWithFormat:@"[ErrorIndex:%@|%@][%ld,%llu,%llu,%ld,%@]",self.pItem.strBucket,self.pItem.strObject,index,pos,size,error,msg];
    NSLog(@"%@",errormsg);
}

-(BOOL)CheckMultipart
{
    if (self.pItem.ullFilesize>10485760) {
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)CreateMultipartFile
{
    NSString * path=[NSString stringWithFormat:@"%@%@",[Util getAppDelegate].strTransCachePath,self.pItem.strUploadId];
    if (![Util existfile:path]) {
        [Util createfile:path];
    }
    self.pIndexFileHandle=[NSFileHandle fileHandleForUpdatingAtPath:path];
    if (self.pIndexFileHandle) {
        NSData *data=[self.pIndexFileHandle readDataToEndOfFile];
        if (data.length!=0&&(data.length%UPLOADPARTSIZE)==0) {
            for (int i=0; i<data.length/UPLOADPARTSIZE; i++) {
                OSSUploadPart* item=[[[OSSUploadPart alloc]init]autorelease];
                NSRange pos = NSMakeRange(i*UPLOADPARTSIZE,4);
                int index=0;
                [data getBytes:&index range:pos];
                item.nIndex=index;
                pos.location=i*UPLOADPARTSIZE+4;
                pos.length=8;
                ULONGLONG temppos=0;
                [data getBytes:&temppos range:pos];
                item.ullPos=temppos;
                pos.location=i*UPLOADPARTSIZE+12;
                pos.length=8;
                [data getBytes:&temppos range:pos];
                item.ullSize=temppos;
                pos.location=i*UPLOADPARTSIZE+20;
                pos.length=34;
                NSData * etag=[data subdataWithRange:pos];
                item.strEtag=[[[NSString alloc] initWithData:etag encoding:NSUTF8StringEncoding] autorelease];
                [self.pPartList addObject:item];
                [self.pFinish InsertPart:item.ullPos last:item.ullPos+item.ullSize-1];
                [self.pUnFinish RemovePairs:item.ullPos last:item.ullPos+item.ullSize-1];
            }
        }
        else {
            [self.pPartList removeAllObjects];
        }
        self.pItem.ullOffset=[self.pFinish Size];
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)DeleteMultipartFile
{
    self.pIndexFileHandle=nil;
    NSString * path=[NSString stringWithFormat:@"%@%@",[Util getAppDelegate].strTransCachePath,self.pItem.strUploadId];
    if ([Util existfile:path])
        [Util deletefile:path];
    return YES;
}

-(void)SaveMultipartFile
{
    if (self.bStop) {
        return;
    }
    else {
        [self.pLocksc lock];
        memset(pPartBuffer, 0, 10000*UPLOADPARTSIZE);
        NSInteger length=[self.pPartList count]*UPLOADPARTSIZE;
        for (int i=0; i<[self.pPartList count]; i++) {
            char * temp=pPartBuffer+i*UPLOADPARTSIZE;
            OSSUploadPart* item=[self.pPartList objectAtIndex:i];
            int index=item.nIndex;
            memcpy(temp, &index, 4);
            ULONGLONG temppos=item.ullPos;
            memcpy(temp+4, &temppos, 8);
            temppos=item.ullSize;
            memcpy(temp+12, &temppos, 8);
            int templength=item.strEtag.length>34?34:item.strEtag.length;
            memcpy(temp+20, [item.strEtag UTF8String], templength);
        }
        if (self.pIndexFileHandle) {
            NSData * data=[[NSData alloc]initWithBytes:pPartBuffer length:length];
            [self.pIndexFileHandle writeData:data];
            [data release];
        }
        [self.pLocksc unlock];
    }
}

-(NSInteger)GetUploadIndex:(ULONGLONG *)pos size:(ULONGLONG *)size
{
    if ([self.pUnFinish Size]==0) {
        return -1;
    }
    if (self.pItem.strUploadId.length==0) {
        DataPair * item=[self.pUnFinish.arrayData objectAtIndex:0];
        *pos=item.ullFirstMark;
        *size=item.ullLastMark-item.ullFirstMark+1;
        return 0;
    }
    else {
        DataPair * item=[self.pUnFinish.arrayData objectAtIndex:0];
        *pos=item.ullFirstMark;
        *size=item.ullLastMark-item.ullFirstMark+1;
        if (*size>self.ullPiecesize) {
            *size=self.ullPiecesize;
        }
        return [self CheckIndex:*pos];
    }
    return -1;
}

-(NSInteger)CheckIndex:(ULONGLONG)pos
{
    NSInteger nIndex=-1;
    [self.pLocksc lock];
    for (UploadPeer *item in self.listPeer) {
        if (item.ullPos+item.ullSize==pos) {
            nIndex=item.nIndex+1;
            break;
        }
    }
    [self.pLocksc unlock];
    if (nIndex==-1) {
        for (OSSUploadPart* item in self.pPartList) {
            if (item.ullPos+item.ullSize==pos) {
                nIndex=item.nIndex+1;
                break;
            }
        }
    }
    if (pos==0) {
        nIndex=1;
    }
    return nIndex;
}

-(void)TaskError:(NSInteger)error msg:(NSString*)msg
{
    if (self.bStop) {
        return;
    }
    self.bStop=YES;
    NSString * errormsg=[NSString stringWithFormat:@"[TaskError:%@|%@][%ld,%@]",self.pItem.strBucket,self.pItem.strObject,error,msg];
    NSLog(@"%@",errormsg);
    [[TransPortDB shareTransPortDB] Update_UploadError:self.pItem.strPathhash error:error msg:msg];
    self.pItem.nStatus=TRANSTASK_ERROR;
    [[Network shareNetwork].uCallback SendCallbackInfo:self.pItem];
}

-(void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        self.pItem.ullOffset=0;
        if (self.pItem.ullFilesize==0) {
            OSSAddObject *ret=[[[OSSAddObject alloc]init] autorelease];
            if ([OSSApi AddObject:self.pItem.strHost bucketname:self.pItem.strBucket objectname:self.pItem.strObject filesize:self.pItem.ullFilesize filedata:nil ret:&ret]) {
                [self Finish];
            }
            else {
                [self TaskError:ret.nCode msg:@""];
            }
            return;
        }
        [self.pUnFinish InsertPart:0 last:self.pItem.ullFilesize-1];
        if ([self CheckMultipart]) {
            if (self.pItem.strUploadId.length==0) {
                OSSInitiateMultipartUploadRet* ret=[[[OSSInitiateMultipartUploadRet alloc]init ]autorelease];
                if ([OSSApi InitiateMultipartUploadObject:self.pItem.strHost bucketname:self.pItem.strBucket objectname:self.pItem.strObject ret:&ret]) {
                    self.pItem.strUploadId=ret.strUploadId;
                    [[TransPortDB shareTransPortDB] Update_UploadUploadId:self.pItem.strPathhash uploadid:self.pItem.strUploadId];
                }
                else {
                    [self TaskError:TRANSERROR_OSSERROR msg:ret.strCode];
                }
            }
            if (![self CreateMultipartFile]) {
                [self TaskError:TRANSERROR_CREATEMULTIPARTERROR msg:@"创建文件分块信息失败"];
                return;
            }
        }
        self.ullStarttime=CFAbsoluteTimeGetCurrent();
        self.ullRuntime=self.ullStarttime;
        while (YES) {
            if (self.bStop)
            {
                NSLog(@"1");
                return;
            }
            if ([self CheckFinish]) {
                if (self.pItem.strUploadId.length>0) {
                    OSSRet * ret=[[[OSSRet alloc] init] autorelease];
                    if (![OSSApi CompleteMultipartUpload:self.pItem.strHost bucketname:self.pItem.strBucket objectname:self.pItem.strObject uploadid:self.pItem.strUploadId parts:self.pPartList ret:&ret]) {
                        [self TaskError:TRANSERROR_OSSERROR msg:ret.strCode];
                        return;
                    }
                }
                [self Finish];
                NSLog(@"2");
                return;
            }
            NSInteger num=[self GetPeerNum];
            NSLog(@"%ld,%ld",num,self.nMax);
            if (num>=self.nMax) {
                [NSThread sleepForTimeInterval:0.1];
                continue;
            }
            ULONGLONG pos;
            ULONGLONG size;
            NSInteger index=[self GetUploadIndex:&pos size:&size];
            NSLog(@"%ld,%llu,%llu",index,pos,size);
            if (index<0) {
                [NSThread sleepForTimeInterval:1];
                continue;
            }
            [self.pLocksc lock];
            num=self.listPeer.count;
            [self.pLocksc unlock];
            if (num<nMax) {
                UploadPeer * peer=[[[UploadPeer alloc] init:self host:self.pItem.strHost bucket:self.pItem.strBucket object:self.pItem.strObject] autorelease];
                if ([peer OpenFile:self.pItem.strUploadId fullpath:self.pItem.strFullpath]) {
                    [self.pFilesc lock];
                    [self.pUnFinish RemovePairs:pos last:pos+size-1];
                    [self.pFilesc unlock];
                    [self.pLocksc lock];
                    [self.listPeer addObject:peer];
                    [self.pLocksc unlock];
                    [peer StartUpload:index pos:pos size:size];
                    [self.pQueue addOperation:peer];
                }
                else {
                    if (self.pItem.strUploadId.length==0) {
                        [self TaskError:TRANSERROR_OPENFILE msg:@"文件打开失败"];
                        NSLog(@"3");
                        return;
                    }
                }
            }
            [self CheckPeer];
     /*       BOOL bhave=NO;
            [self.pLocksc lock];
            for(UploadPeer* peer in self.listPeer) {
                if ([peer IsIdle]) {
                    [self.pFilesc lock];
                    [self.pUnFinish RemovePairs:pos last:pos+size-1];
                    [self.pFilesc unlock];
                    [peer StartUpload:index pos:pos size:size];
                    [self.pQueue addOperation:peer];
                    bhave=YES;
                }
            }
            [self.pLocksc unlock];
            if (!bhave) */
            {
                [NSThread sleepForTimeInterval:1];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        NSLog(@"4");
    }
    @finally {
        [pool release];
        self.pItem.nStatus=TRANSTASK_REMOVE;
    }
}

-(void)ResetUploadId
{
    self.pItem.strUploadId=@"";
    [[TransPortDB shareTransPortDB] Update_UploadUploadId:self.pItem.strPathhash uploadid:@""];
}

-(void)CheckPeer
{
    [self.pLocksc lock];
    for (int i=0;i<self.listPeer.count;i++) {
        UploadPeer*item = [self.listPeer objectAtIndex:i];
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
