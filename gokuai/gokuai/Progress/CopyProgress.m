#import "CopyProgress.h"
#import "Util.h"
#import "NetworkDef.h"
#import "OSSApi.h"
#import "ProgressWindowController.h"
#import "ProgressManager.h"
#import "MoveAndPasteWindowController.h"

#define COPY_MAX    1073741824

@implementation CopyProgress

@synthesize progressCallBack;
@synthesize nType;
@synthesize nTempIndex;
@synthesize nTempCount;
@synthesize _strJson;
@synthesize bTimer;

-(void) dealloc
{
    [progressCallBack release];
    _strJson=nil;
    [pTimer invalidate];
    pTimer=nil;
    [super dealloc];
}

-(id)init:(NSString*)json type:(NSInteger)type
{
    if (self=[super init]) {
        self._strJson=json;
        self.nTempIndex=0;
        self.nTempCount=0;
        self.nType=type;
        self.bTimer=NO;
        pTimer=[NSTimer scheduledTimerWithTimeInterval:0.005
                                                target:self
                                              selector:@selector(timeWrite:)
                                              userInfo:nil
                                               repeats:YES];
    }
    return self;
}

-(NSString*) GetFileList:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object items:(NSMutableArray*)items
{
    NSString* strRet=@"";
    NSString* nextmarker=@"";
    while (YES) {
        OSSListObjectRet* ret;
        if ([OSSApi GetBucketObject:host bucetname:bucket ret:&ret prefix:object marker:nextmarker delimiter:@"" maxkeys:@"1000"]) {
            for (OSSListObject* item in ret.arrayContent) {
                DeleteFileItem * ditem=[[[DeleteFileItem alloc]init]autorelease];
                if (item.strPefix.length) {
                    ditem.strObject=item.strPefix;
                }
                else {
                    ditem.strObject=item.strKey;
                }
                ditem.strHost=host;
                ditem.strBucket=bucket;
                [items addObject:ditem];
            }
            if (ret.strNextMarker.length==0) {
                break;
            }
            nextmarker=ret.strNextMarker;
        }
        else {
            NSString *msg=[NSString stringWithFormat:@"%@,%@,%@",bucket,object,nextmarker];
            strRet=[Util errorInfoWithCode:@"删除文件夹获取列表失败" message:msg ret:ret];
            break;
        }
    }
    return strRet;
}

-(void)parsecopy
{
    NSLog(@"parsecopy");
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:self._strJson];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_JSONERROR];
        if (![self isCancelled]) {
            progressCallBack(0);
        }
        return;
    }
    NSString * dstbucket=[dictionary objectForKey:@"dstbucket"];
    NSString * dsthost=[Util ChangeHost:[dictionary objectForKey:@"dstlocation"]];
    NSString * dstobject=[dictionary objectForKey:@"dstobject"];
    NSString * bucket=[dictionary objectForKey:@"bucket"];
    NSString * host=[Util ChangeHost:[dictionary objectForKey:@"location"]];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* items = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            CopyFileItem * item=[[[CopyFileItem alloc]init]autorelease];
            item.strObject = [itemDictionary objectForKey:@"object"];
            item.ullFilesize=[[itemDictionary objectForKey:@"filesize"] longLongValue];
            item.strHost=host;
            item.strBucket=bucket;
            item.strDstHost=dsthost;
            item.strDstBucket=dstbucket;
            [items addObject:item];
        }
    }
    MoveAndPasteWindowController* moveController=[[Util getAppDelegate] getMoveAndPasteWindowController];
    if (![moveController copyfiles:items dstobject:dstobject]) {
        if (![self isCancelled]) {
            progressCallBack(0);
        }
        return;
    }
    [ProgressManager sharedInstance].nCount=items.count;
    if (items.count==1) {
        CopyFileItem* cpyfile=[items objectAtIndex:0];
        [ProgressManager sharedInstance].strFilename=[cpyfile.strObject lastPathComponent];
    }
    for (int i=0; i<items.count;i++) {
        CopyFileItem* cpyfile=[items objectAtIndex:i];
        if (cpyfile.ullFilesize<COPY_MAX) {
            OSSCopyRet *ret;
            if (![OSSApi CopyObject:cpyfile.strDstHost dstbucketname:cpyfile.strDstBucket dstobjectname:cpyfile.strDstObject srcbucketname:cpyfile.strBucket srcobjectname:cpyfile.strObject ret:&ret]) {
                NSString * message=[NSString stringWithFormat:@"%@,%@",cpyfile.strDstBucket,cpyfile.strObject];
                [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"复制object失败" message:message ret:ret];
                if (![self isCancelled]) {
                    progressCallBack(0);
                }
                return;
            }
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
                            progressCallBack(0);
                        }
                        return;
                    }
                    if ([ProgressManager sharedInstance].bProgressClose) {
                        return;
                    }
                }
            }
            else {
                NSString * message=[NSString stringWithFormat:@"%@,%@",cpyfile.strDstBucket,cpyfile.strObject];
                [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"复制大于1G的object失败" message:message ret:ret];
                if (![self isCancelled]) {
                    progressCallBack(0);
                }
                return;
            }
        }
        if (![self isCancelled]) {
            progressCallBack(i+1);
        }
        if ([ProgressManager sharedInstance].bProgressClose) {
            return;
        }
    }
    [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_SUCCESS];
    if (![self isCancelled]) {
        progressCallBack(0);
    }
}

-(void)parsedelete
{
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:self._strJson];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_JSONERROR];
        if (![self isCancelled]) {
            progressCallBack(0);
        }
        return;
    }
    NSString * bucket=[dictionary objectForKey:@"bucket"];
    NSString * host=[Util ChangeHost:[dictionary objectForKey:@"location"]];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* items = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            DeleteFileItem * item=[[[DeleteFileItem alloc]init]autorelease];
            item.strObject = [itemDictionary objectForKey:@"object"];
            item.strHost=host;
            item.strBucket=bucket;
            if (item.strObject.length) {
                [items addObject:item];
            }
            if ([item.strObject hasSuffix:@"/"]) {
                NSString * strRet=[self GetFileList:host bucket:bucket object:item.strObject items:items];
                if (strRet.length>0) {
                    [ProgressManager sharedInstance].strRet=strRet;
                    if (![self isCancelled]) {
                        progressCallBack(0);
                    }
                    return;
                }
            }
        }
    }
    [ProgressManager sharedInstance].nCount=items.count;
    if (items.count==1) {
        DeleteFileItem* item=[items objectAtIndex:0];
        [ProgressManager sharedInstance].strFilename=[item.strObject lastPathComponent];
        OSSRet *ret;
        if (![OSSApi DeleteObject:host bucketname:bucket objectname:item.strObject ret:&ret]) {
            NSString * message=[NSString stringWithFormat:@"%@,%@",item.strBucket,item.strObject];
            [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:message ret:ret];
        }
        if (![self isCancelled]) {
            progressCallBack(1);
        }
    }
    else {
        for (int i=0; i<(items.count+999)/1000;i++) {
            DeleteFileItem* item;
            self.bTimer=YES;
            NSMutableArray* array=[NSMutableArray arrayWithCapacity:1000];
            self.nTempIndex=i*1000;
            self.nTempCount=i*1000+1000>items.count?items.count:i*1000+1000;
            for (int j=0; j<1000&&i*1000+j<items.count; j++) {
                item=[items objectAtIndex:(i*1000+j)];
                [array addObject:item.strObject];
            }
            OSSRet *ret;
            if (![OSSApi DeleteObject:host bucketname:bucket objectnames:array quiet:YES ret:&ret]) {
                [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:@"" ret:ret];
                self.bTimer=NO;
                if (![self isCancelled]) {
                    progressCallBack(0);
                }
                return;
            }
            self.bTimer=NO;
            if (![self isCancelled]) {
                progressCallBack(i*1000+1000);
            }
            if ([ProgressManager sharedInstance].bProgressClose) {
                return;
            }
        }
    }
    [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_SUCCESS];
    if (![self isCancelled]) {
        progressCallBack(0);
    }
}

-(void)parsebucket
{
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:self._strJson];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_JSONERROR];
        if (![self isCancelled]) {
            progressCallBack(0);
        }
        return;
    }
    NSString * keyid=[dictionary objectForKey:@"keyid"];
    NSString * keysecret=[dictionary objectForKey:@"keysecret"];
    NSString * bucket=[dictionary objectForKey:@"bucket"];
    NSString * host=[Util ChangeHost:[dictionary objectForKey:@"location"]];
    if (![[Util getAppDelegate].strAccessID isEqualToString:keyid]||![[Util getAppDelegate].strAccessKey isEqualToString:keysecret]) {
        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_ACCESSKEYERROR];
        if (![self isCancelled]) {
            progressCallBack(0);
        }
        return;
    }
    NSMutableArray* items = [NSMutableArray array];
    NSString * strRet=[self GetFileList:host bucket:bucket object:@"" items:items];
    if (strRet.length>0) {
        [ProgressManager sharedInstance].strRet=strRet;
        if (![self isCancelled]) {
            progressCallBack(0);
        }
        return;
    }
    [ProgressManager sharedInstance].nCount=items.count;
    if (items.count==1) {
        DeleteFileItem* item=[items objectAtIndex:0];
        [ProgressManager sharedInstance].strFilename=[item.strObject lastPathComponent];
        OSSRet *ret;
        if (![OSSApi DeleteObject:host bucketname:bucket objectname:item.strObject ret:&ret]) {
            NSString * message=[NSString stringWithFormat:@"%@,%@",item.strBucket,item.strObject];
            [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:message ret:ret];
        }
        if (![self isCancelled]) {
            progressCallBack(1);
        }
    }
    else {
        for (int i=0; i<(items.count+999)/1000;i++) {
            DeleteFileItem* item;
            NSMutableArray* array=[NSMutableArray arrayWithCapacity:1000];
            self.nTempIndex=i*1000;
            self.nTempCount=i*1000+1000>items.count?items.count:i*1000+1000;
            self.bTimer=YES;
            for (int j=0; j<1000&&i*1000+j<items.count; j++) {
                item=[items objectAtIndex:(i*1000+j)];
                [array addObject:item.strObject];
            }
            OSSRet *ret;
            if (![OSSApi DeleteObject:host bucketname:bucket objectnames:array quiet:YES ret:&ret]) {
                [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除object失败" message:@"" ret:ret];
                self.bTimer=NO;
                if (![self isCancelled]) {
                    progressCallBack(0);
                }
                return;
            }
            self.bTimer=NO;
            if (![self isCancelled]) {
                progressCallBack(i*1000+1000);
            }
            if ([ProgressManager sharedInstance].bProgressClose) {
                return;
            }
        }
    }
    
    OSSListMultipartUploadRet *ret;
    if([OSSApi ListMultipartUploads:host bucketname:bucket reet:&ret])
    {
        for (OSSListMultipartUpload *item in ret.arrayUpload) {
            OSSRet * abort;
            if (![OSSApi AbortMultipartUpload:host bucketname:bucket objectname:item.strKey uploadid:item.strUploadId ret:&abort]) {
                NSString * message=[NSString stringWithFormat:@"%@,%@",bucket,item.strKey];
                [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除碎片信息失败" message:message ret:ret];
                if (![self isCancelled]) {
                    progressCallBack(0);
                }
                return;
            }
        }
    }
    else {
        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"获取碎片信息失败" message:bucket ret:ret];
        if (![self isCancelled]) {
            progressCallBack(0);
        }
        return;
    }
    OSSRet * ossret;
    if (![OSSApi DeleteBucket:host bucketname:bucket ret:&ossret]) {
        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:@"删除bucket失败" message:bucket ret:ret];
        
    }
    else {
        [ProgressManager sharedInstance].strRet=[Util errorInfoWithCode:WEB_SUCCESS];
    }
    if (![self isCancelled]) {
        progressCallBack(0);
    }
}
- (void) timeWrite:(NSTimer *)timer
{
    if (self.bTimer) {
        self.nTempIndex+=5;
        if (self.nTempIndex>self.nTempCount) {
            self.nTempIndex=self.nTempCount;
        }
        if (![self isCancelled]) {
            progressCallBack(self.nTempIndex);
        }
    }
}

-(void) main
{
    NSAutoreleasePool* pool=[[NSAutoreleasePool alloc]init];
    while (![self isCancelled]) {
        @try {
            if (self.nType==pc_copy) {
                [self parsecopy];
            }
            else if (self.nType==pc_delete) {
                [self parsedelete];
            }
            else if (self.nType==pc_bucket) {
                [self parsebucket];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    [pool release];
}

@end
