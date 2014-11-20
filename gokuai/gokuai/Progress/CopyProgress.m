#import "CopyProgress.h"
#import "Util.h"
#import "NetworkDef.h"
#import "OSSApi.h"
#import "ProgressWindowController.h"
#import "ProgressManager.h"

#define COPY_MAX    1073741824

@implementation CopyAll

@synthesize array;
@synthesize nCount;
@synthesize nIndex;

-(void) dealloc
{
    array=nil;
    [super dealloc];
}

-(id) init
{
    if (self=[super init]) {
        self.nCount=0;
        self.nIndex=0;
    }
    return self;
}

-(BOOL) isfinished
{
    return (nIndex>=nCount);
}

@end

@implementation CopyProgress

@synthesize progressCallBack;
@synthesize nType;
@synthesize nTempIndex;
@synthesize _strHost;
@synthesize _strBucket;

-(void) dealloc
{
    [_all release];
    [progressCallBack release];
    _strHost=nil;
    _strBucket=nil;
    [super dealloc];
}

-(id) initWithPaths:(NSArray*)items type:(NSInteger)type
{
    if (self=[super init]) {
        _all=[[CopyAll alloc]init];
        _all.nCount=items.count;
        _all.nIndex=0;
        _all.array=items;
        self.nTempIndex=0;
        self.nType=type;
    }
    return self;
}

-(id) initWithPaths:(NSArray*)items host:(NSString*)host bucket:(NSString*)bucket
{
    if (self=[super init]) {
        _all=[[CopyAll alloc]init];
        _all.nCount=items.count;
        _all.nIndex=0;
        _all.array=items;
        self.nTempIndex=0;
        self.nType=pc_bucket;
        self._strHost=host;
        self._strBucket=bucket;
    }
    return self;
}

-(BOOL) isfinished
{
    return _all.isfinished;
}

- (void) timeWrite:(NSTimer *)timer
{
    _all.nIndex++;
    if (_all.nIndex>self.nTempIndex) {
        _all.nIndex=self.nTempIndex;
    }
    if (![self isCancelled]) {
        progressCallBack(_all.nIndex);
    }
}

-(void) main
{
    NSAutoreleasePool* pool=[[NSAutoreleasePool alloc]init];
    while (![self isCancelled]) {
        @try {
            if (self.nType==pc_copy) {
                for (int i=0; i<_all.array.count;i++) {
                    CopyFileItem* cpyfile=[_all.array objectAtIndex:i];
                    if (cpyfile.ullFilesize<COPY_MAX) {
                        OSSCopyRet *ret;
                        if (![OSSApi CopyObject:cpyfile.strDstHost dstbucketname:cpyfile.strDstBucket dstobjectname:cpyfile.strDstObject srcbucketname:cpyfile.strBucket srcobjectname:cpyfile.strObject ret:&ret]) {
                            NSString * message=[NSString stringWithFormat:@"%@,%@",cpyfile.strDstBucket,cpyfile.strObject];
                            [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"复制object失败" message:message ret:ret];
                            if (![self isCancelled]) {
                                progressCallBack(_all.nCount);
                            }
                            break;
                        };
                    }
                    else {
                        OSSInitiateMultipartUploadRet * ret;
                        if ([OSSApi InitiateMultipartUploadObject:cpyfile.strDstHost bucketname:cpyfile.strBucket objectname:cpyfile.strDstObject ret:&ret]) {
                            for (ULONGLONG i=0; i<(cpyfile.ullFilesize+COPY_MAX-1)/COPY_MAX; i++) {
                                ULONGLONG size=COPY_MAX;
                                if (i*COPY_MAX+size>cpyfile.ullFilesize) {
                                    size=cpyfile.ullFilesize-i*COPY_MAX;
                                }
                                OSSRet *partret;
                                if (![OSSApi UploadPartCopy:cpyfile.strDstHost dstbucketname:cpyfile.strDstBucket dstobjectname:cpyfile.strDstObject srcbucketname:cpyfile.strBucket srcobjectname:cpyfile.strObject uploadid:ret.strUploadId partnumber:i+1 pos:i*COPY_MAX size:size ret:&partret]) {
                                    NSString * message=[NSString stringWithFormat:@"%@,%@",cpyfile.strDstBucket,cpyfile.strObject];
                                    [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"复制object块失败" message:message ret:partret];
                                    if (![self isCancelled]) {
                                        progressCallBack(_all.nCount);
                                    }
                                    break;
                                }
                                if ([ProgressManager sharedInstance].strRet.length>0) {
                                    break;
                                }
                                if ([ProgressManager sharedInstance].bProgressClose) {
                                    break;
                                }
                            }
                        }
                        else {
                            NSString * message=[NSString stringWithFormat:@"%@,%@",cpyfile.strDstBucket,cpyfile.strObject];
                            [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"复制大于1G的object失败" message:message ret:ret];
                            if (![self isCancelled]) {
                                progressCallBack(_all.nCount);
                            }
                            break;
                        }
                    }
                    _all.nIndex++;
                    if (![self isCancelled]) {
                        progressCallBack(_all.nIndex);
                    }
                    if ([ProgressManager sharedInstance].bProgressClose) {
                        break;
                    }
                }
            }
            else if (self.nType==pc_delete) {
                if (_all.array.count==1) {
                    DeleteFileItem* item=[_all.array objectAtIndex:0];
                    OSSRet *ret;
                    if (![OSSApi DeleteObject:item.strHost bucketname:item.strBucket objectname:item.strObject ret:&ret]) {
                        NSString * message=[NSString stringWithFormat:@"%@,%@",item.strBucket,item.strObject];
                        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:message ret:ret];
                    }
                    _all.nIndex++;
                    if (![self isCancelled]) {
                        progressCallBack(_all.nIndex);
                    }
                }
                else {
                    for (int i=0; i<(_all.array.count+999)/1000;i++) {
                        DeleteFileItem* item;
                        pTimer=[NSTimer scheduledTimerWithTimeInterval:0.05
                                                                target:self
                                                              selector:@selector(timeWrite:)
                                                              userInfo:nil
                                                               repeats:YES];
                        NSMutableArray* array=[NSMutableArray arrayWithCapacity:1000];
                        for (int j=0; j<1000&&i*1000+j<_all.array.count; j++) {
                            item=[_all.array objectAtIndex:(i*1000+j)];
                            [array addObject:item.strObject];
                        }
                        OSSRet *ret;
                        if (![OSSApi DeleteObject:item.strHost bucketname:item.strBucket objectnames:array quiet:YES ret:&ret]) {
                            NSString * message=[NSString stringWithFormat:@"%@,%@",item.strBucket,item.strObject];
                            [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:message ret:ret];
                            [pTimer invalidate];
                            pTimer=nil;
                            if (![self isCancelled]) {
                                progressCallBack(_all.nCount);
                            }
                            break;
                        }
                        _all.nIndex=i*1000+1000;
                        [pTimer invalidate];
                        pTimer=nil;
                        if (![self isCancelled]) {
                            progressCallBack(_all.nIndex);
                        }
                        if ([ProgressManager sharedInstance].bProgressClose) {
                            break;
                        }
                    }
                }
            }
            else if (self.nType==pc_bucket) {
                if (_all.array.count==1) {
                    DeleteFileItem* item=[_all.array objectAtIndex:0];
                    OSSRet *ret;
                    if (![OSSApi DeleteObject:item.strHost bucketname:item.strBucket objectname:item.strObject ret:&ret]) {
                        NSString * message=[NSString stringWithFormat:@"%@,%@",item.strBucket,item.strObject];
                        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:message ret:ret];
                    }
                    _all.nIndex++;
                    if (![self isCancelled]) {
                        progressCallBack(_all.nIndex);
                    }
                }
                else {
                    for (int i=0; i<(_all.array.count+999)/1000;i++) {
                        DeleteFileItem* item;
                        pTimer=[NSTimer scheduledTimerWithTimeInterval:0.05
                                                                target:self
                                                              selector:@selector(timeWrite:)
                                                              userInfo:nil
                                                               repeats:YES];
                        NSMutableArray* array=[NSMutableArray arrayWithCapacity:1000];
                        for (int j=0; j<1000&&i*1000+j<_all.array.count; j++) {
                            item=[_all.array objectAtIndex:(i*1000+j)];
                            [array addObject:item.strObject];
                        }
                        OSSRet *ret;
                        if (![OSSApi DeleteObject:item.strHost bucketname:item.strBucket objectnames:array quiet:YES ret:&ret]) {
                            NSString * message=[NSString stringWithFormat:@"%@,%@",item.strBucket,item.strObject];
                            [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:message ret:ret];
                            [pTimer invalidate];
                            pTimer=nil;
                            if (![self isCancelled]) {
                                progressCallBack(_all.nCount);
                            }
                            break;
                        }
                        _all.nIndex=i*1000+1000;
                        [pTimer invalidate];
                        pTimer=nil;
                        if (![self isCancelled]) {
                            progressCallBack(_all.nIndex);
                        }
                        if ([ProgressManager sharedInstance].bProgressClose) {
                            break;
                        }
                    }
                }
                OSSListMultipartUploadRet *ret;
                if([OSSApi ListMultipartUploads:self._strHost bucketname:self._strBucket reet:&ret])
                {
                    for (OSSListMultipartUpload *item in ret.arrayUpload) {
                        OSSRet * abort;
                        if (![OSSApi AbortMultipartUpload:self._strHost bucketname:self._strBucket objectname:item.strKey uploadid:item.strUploadId ret:&abort]) {
                            NSString * message=[NSString stringWithFormat:@"%@,%@",self._strBucket,item.strKey];
                            [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除碎片信息失败" message:message ret:ret];
                            if (![self isCancelled]) {
                                progressCallBack(_all.nCount);
                            }
                            break;
                        }
                    }
                }
                else {
                    [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"获取碎片信息失败" message:self._strBucket ret:ret];
                    if (![self isCancelled]) {
                        progressCallBack(_all.nCount);
                    }
                    break;
                }
                OSSRet * ossret;
                if (![OSSApi DeleteBucket:self._strHost bucketname:self._strBucket ret:&ossret]) {
                    [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除bucket失败" message:self._strBucket ret:ret];
                    
                }
                else {
                    [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_SUCCESS];
                }
                if (![self isCancelled]) {
                    progressCallBack(_all.nCount);
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"COPY MAIN [ exception : %@]", [exception reason]);
        }
        @finally {
        }
    }
    [pool release];
}

@end
