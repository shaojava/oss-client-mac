
#import "OperationManager.h"

#import "Util.h"
#import "Common.h"
#import "NSAlert+Blocks.h"
#import "JSONKit.h"
#import "MyTask.h"
#import "NSStringExpand.h"
#import "NSDataExpand.h"
#import "CopyProgress.h"
#import "ProgressWindowController.h"
#import "MoveAndPasteWindowController.h"
#import "MoveItem.h"
#import "Network.h"
#import "NetworkDef.h"
#import "OSSApi.h"
#import "OSSRsa.h"
#import "SettingsDb.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation drag_item


@synthesize mountid;
@synthesize webpath;
@synthesize filehash;

@synthesize cached;
@synthesize fullpath;

-(id) initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        cached = NO;
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.mountid = [[dictionary valueForKey:@"mountid"] integerValue];
            self.webpath = [dictionary valueForKey:@"webpath"];
            self.filehash = [dictionary valueForKey:@"filehash"];
        }
    }
    return self;
}

-(void) dealloc
{
    self.webpath = nil;
    self.filehash = nil;
    self.fullpath = nil;
    [super dealloc];
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation OperPackage

@synthesize _operName;
@synthesize _jsonInfo;
@synthesize _webframe;
@synthesize _cb;
@synthesize _window;
@synthesize _array;


-(id) init {
    if (self=[super init]) {
        self._operName=nil;
        self._cb=nil;
        self._jsonInfo=nil;
        self._webframe=nil;
        self._window=nil;
        self._array=nil;
    }
    return self;
}

-(void) dealloc {
    self._operName=nil;
    self._cb=nil;
    self._jsonInfo=nil;
    self._webframe=nil;
    self._window=nil;
    self._array=nil;
    [super dealloc];
}

-(void) main
{
    NSAutoreleasePool* pool=[[NSAutoreleasePool alloc] init];
    
    @try {
        if ([self._operName isEqualToString:@"addFile"]) {
            [OperationManager addFile:self];
        }
        if ([self._operName isEqualToString:@"saveFile"]) {
            [OperationManager saveFile:self];
        }
        if ([self._operName isEqualToString:@"startUpload"]) {
            [OperationManager startUpload:self];
        }
        if ([self._operName isEqualToString:@"startDownload"]) {
            [OperationManager startDownload:self];
        }
        if ([self._operName isEqualToString:@"stopUpload"]) {
            [OperationManager stopUpload:self];
        }
        if ([self._operName isEqualToString:@"stopDownload"]) {
            [OperationManager stopDownload:self];
        }
        if ([self._operName isEqualToString:@"deleteUpload"]) {
            [OperationManager deleteUpload:self];
        }
        if ([self._operName isEqualToString:@"deleteDownload"]) {
            [OperationManager deleteDownload:self];
        }
        if ([self._operName isEqualToString:@"deleteObject"]) {
            [OperationManager deleteObject:self];
        }
        if ([self._operName isEqualToString:@"copyObject"]) {
            [OperationManager copyObject:self];
        }
        if ([self._operName isEqualToString:@"loginByKey"]) {
            [OperationManager loginByKey:self];
        }
        if ([self._operName isEqualToString:@"loginByFile"]) {
            [OperationManager loginByFile:self];
        }
        if ([self._operName isEqualToString:@"setPassword"]) {
            [OperationManager setPassword:self];
        }
        if ([self._operName isEqualToString:@"loginPassword"]) {
            [OperationManager loginPassword:self];
        }
        if ([self._operName isEqualToString:@"setServerLocation"]) {
            [OperationManager setServerLocation:self];
        }
        if ([self._operName isEqualToString:@"deleteBucket"]) {
            [OperationManager deleteBucket:self];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"OPERATION PROC [ exception: %@ ]", [exception reason]);
    }
    @finally {
    }
    
    [pool release];
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation OperationManager


-(void) dealloc
{
    [_operQueue release];
    [super dealloc];
}

-(id) init
{
    if (self=[super init]) {
        
        _operQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

+ (OperationManager*) sharedInstance
{
    static OperationManager *sharedInstance = nil;
	
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[OperationManager alloc] init];
	});
	return sharedInstance;
}

//////////////////////////////////////////////////////////////////////////////////////////

+(void) addFile:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    NSString* location=[dictionary objectForKey:@"location"];
    NSString* host=[Util ChangeHost:location];
    NSString* bucket=[dictionary objectForKey:@"bucket"];
    NSString* prefix=[dictionary objectForKey:@"prefix"];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* paths = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            NSString*path = [itemDictionary objectForKey:@"path"];
            if (path.length) {
                [paths addObject:path];
            }
        }
    }
    [[Network shareNetwork] AddFileUpload:host bucket:bucket object:prefix array:paths];
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) GetFileList:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object fullpath:(NSString*)fullpath
{
    NSString* tempobject=@"";
    NSString* tempparent=object;
    NSString* nextmarker=@"";
    while (YES) {
        OSSListObjectRet* ret;
        if ([OSSApi GetBucketObject:host bucetname:bucket ret:&ret prefix:object marker:nextmarker delimiter:@"" maxkeys:@"1000"]) {
            for (OSSListObject* item in ret.arrayContent) {
                TransTaskItem * tranitem=[[TransTaskItem alloc] init];
                
                tranitem.strHost=host;
                tranitem.strBucket=bucket;
                if (item.strPefix.length) {
                    tranitem.strObject=item.strPefix;
                }
                else {
                    tranitem.strObject=item.strKey;
                }
                tempobject=tranitem.strObject;
                if (tranitem.strObject.length>0&&[tranitem.strObject hasSuffix:@"/"]) {
                    tempobject=[tranitem.strObject substringToIndex:tranitem.strObject.length-1];
                }
                NSString * subpath=[tempobject substringFromIndex:tempparent.length]; 
                tranitem.strFullpath=[NSString stringWithFormat:@"%@/%@",fullpath,subpath];
                tranitem.ullFilesize=[item.strFilesize longLongValue];
                tranitem.strPathhash=item.strEtag;
                tranitem.nStatus=TRANSTASK_NORMAL;
                [[TransPortDB shareTransPortDB] Add_Download:tranitem];
            }
            if (ret.strNextMarker.length==0) {
                break;
            }
            nextmarker=ret.strNextMarker;
        }
        else {
            break;
        }
    }
}

+(void) saveFile:(OperPackage*)tran {
    NSString* retString=nil;
    for (SaveFileItem *item in tran._array) {
        TransTaskItem * tranitem=[[TransTaskItem alloc] init];
        tranitem.strHost=item.strHost;
        tranitem.strBucket=item.strBucket;
        tranitem.strObject=item.strObject;
        tranitem.strFullpath=item.strFullpath;
        tranitem.ullFilesize=item.ullFilesize;
        tranitem.strPathhash=item.strEtag;
        tranitem.nStatus=TRANSTASK_NORMAL;
        [[TransPortDB shareTransPortDB] Add_Download:tranitem];
        if (item.bDir) {
            [self GetFileList:tranitem.strHost bucket:tranitem.strBucket object:tranitem.strObject fullpath:tranitem.strFullpath];
        }
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) startUpload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    BOOL all=[[dictionary objectForKey:@"all"] boolValue];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* paths = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            NSString*bucket = [itemDictionary objectForKey:@"bucket"];
            NSString*object =[itemDictionary objectForKey:@"object"];
            SaveFileItem *item=[[[SaveFileItem alloc]init] autorelease];
            item.strBucket=bucket;
            item.strObject=object;
            if (item.strBucket.length&&item.strObject.length) {
                [paths addObject:item];
            }
        }
    }
    if (all) {
        [[Network shareNetwork] StartUploadAll];
    }
    else {
        [[Network shareNetwork] StartUpload:paths];
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) startDownload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    BOOL all=[[dictionary objectForKey:@"all"] boolValue];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* paths = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            NSString*fullpath = [itemDictionary objectForKey:@"fullpath"];
            if (fullpath.length) {
                [paths addObject:fullpath];
            }
        }
    }
    if (all) {
        [[Network shareNetwork] StartDownloadAll];
    }
    else {
        [[Network shareNetwork] StartDownload:paths];
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) stopUpload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    BOOL all=[[dictionary objectForKey:@"all"] boolValue];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* paths = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            NSString*bucket = [itemDictionary objectForKey:@"bucket"];
            NSString*object =[itemDictionary objectForKey:@"object"];
            SaveFileItem *item=[[[SaveFileItem alloc]init] autorelease];
            item.strBucket=bucket;
            item.strObject=object;
            if (item.strBucket.length&&item.strObject.length) {
                [paths addObject:item];
            }
        }
    }
    if (all) {
        [[Network shareNetwork] StopUploadAll];
    }
    else {
        [[Network shareNetwork] StopUpload:paths];
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) stopDownload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    BOOL all=[[dictionary objectForKey:@"all"] boolValue];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* paths = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            NSString*fullpath = [itemDictionary objectForKey:@"fullpath"];
            if (fullpath.length) {
                [paths addObject:fullpath];
            }
        }
    }
    if (all) {
        [[Network shareNetwork] StopDownloadAll];
    }
    else {
        [[Network shareNetwork] StopDownload:paths];
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) deleteUpload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    BOOL all=[[dictionary objectForKey:@"all"] boolValue];
    BOOL finish=[[dictionary objectForKey:@"finish"] boolValue];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* paths = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            NSString*bucket = [itemDictionary objectForKey:@"bucket"];
            NSString*object =[itemDictionary objectForKey:@"object"];
            SaveFileItem *item=[[[SaveFileItem alloc]init] autorelease];
            item.strBucket=bucket;
            item.strObject=object;
            if (item.strBucket.length&&item.strObject.length) {
                [paths addObject:item];
            }
        }
    }
    if (all) {
        if (finish) {
            [[TransPortDB shareTransPortDB] DeleteUploadAllFinish];
        }
        else {
            [[Network shareNetwork] DeleteUploadAll];
        }
    }
    else {
        [[Network shareNetwork] DeleteUpload:paths];
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) deleteDownload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    BOOL all=[[dictionary objectForKey:@"all"] boolValue];
    BOOL finish=[[dictionary objectForKey:@"finish"] boolValue];
    NSArray* array=[dictionary objectForKey:@"list"];
    NSMutableArray* paths = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* itemDictionary in array)
        {
            NSString*fullpath = [itemDictionary objectForKey:@"fullpath"];
            if (fullpath.length) {
                [paths addObject:fullpath];
            }
        }
    }
    if (all) {
        if (finish) {
            [[TransPortDB shareTransPortDB] DeleteDownloadAllFinish];
        }
        else {
            [[Network shareNetwork] DeleteDownloadAll];
        }
    }
    else {
        [[Network shareNetwork] DeleteDownload:paths];
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) GetFileList:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object items:(NSMutableArray*)items
{
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
            break;
        }
    }
}

+(void) deleteObject:(OperPackage*)tran {
    NSString* retString=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
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
                [self GetFileList:host bucket:bucket object:item.strObject items:items];
            }
        }
    }
    [[Util getAppDelegate] performSelectorOnMainThread:@selector(startDelete:) withObject:items waitUntilDone:NO];
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) copyObject:(OperPackage*)tran {
    NSLog(@"%@",tran._jsonInfo);
    NSString* retString=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
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
        goto END;
    }
    [[Util getAppDelegate] performSelectorOnMainThread:@selector(startCopy:) withObject:items waitUntilDone:NO];
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) loginByKey:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    NSString* strKeyId=[dictionary objectForKey:@"keyid"];
    NSString* strKeySecret=[dictionary objectForKey:@"keysecret"];
    NSString* strLocation=[dictionary objectForKey:@"location"];
    OSSRet* ret;
    if ([OSSApi CheckIDandKey:strKeyId key:strKeySecret host:[Util getAppDelegate].strHost ret:&ret]) {
        [Util getAppDelegate].strAccessID=strKeyId;
        [Util getAppDelegate].strAccessKey=strKeySecret;
        [Util getAppDelegate].strArea=strLocation;
        if ([Util getAppDelegate].strArea.length==0) {
            [Util getAppDelegate].strArea=@"";
        }
        NSString * dbpath=[NSString stringWithFormat:@"%@/user/%@/transdb.db",[[NSBundle mainBundle] bundlePath],[strKeyId sha1HexDigest]];
        [Util createfolder:[dbpath stringByDeletingLastPathComponent]];
        [[TransPortDB shareTransPortDB] OpenPath:dbpath];
        [Util getAppDelegate].bLogin=YES;
        retString=[Util errorInfoWithCode:WEB_SUCCESS];
    }
    else {
        retString=[Util errorInfoWithCode:WEB_ACCESSKEYERROR];
    }
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) loginByFile:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    NSString* path=[tran._array objectAtIndex:0];
    NSString* strLocation=[dictionary objectForKey:@"location"];
    NSFileHandle * pFile=[NSFileHandle fileHandleForUpdatingAtPath:path];
    if (pFile) {
        NSData *data=[pFile readDataToEndOfFile];
        BOOL bFileError=NO;
        if (data.length>=20&&data.length<1048576) {
            NSRange pos = NSMakeRange(0,16);
            NSData * guid=[data subdataWithRange:pos];
            NSData * check;
            NSData * key;
            NSData * secret;
            if (![guid isEqualToData:[OSSRsa GetGuid]]) {
                bFileError=YES;
            }
            else {
                pos.location=16;
                pos.length=4;
                int checklength=0;
                [data getBytes:&checklength range:pos];
                if (20+checklength>data.length) {
                    bFileError=YES;
                }
                else {
                    pos.location=20;
                    pos.length=checklength;
                    check=[data subdataWithRange:pos];
                }
                pos.location=20+checklength;
                pos.length=4;
                int keylength=0;
                [data getBytes:&keylength range:pos];
                if (24+checklength+keylength>data.length) {
                    bFileError=YES;
                }
                else {
                    pos.location=24+checklength;
                    pos.length=keylength;
                    key=[data subdataWithRange:pos];
                }
                pos.location=24+checklength+keylength;
                pos.length=4;
                int secretlength=0;
                [data getBytes:&secretlength range:pos];
                if (28+checklength+keylength+secretlength>data.length) {
                    bFileError=YES;
                }
                else {
                    pos.location=28+checklength+keylength;
                    pos.length=secretlength;
                    secret=[data subdataWithRange:pos];
                }
                if (!bFileError) {
                    OSSRsaItem *ret=[OSSRsa DecryptKey:check key:key secret:secret];
                    if (ret.ret) {
                        NSString *strKeyId=[[[NSString alloc] initWithData:ret.key encoding:NSUTF8StringEncoding] autorelease];
                        NSString *strKeySecret=[[[NSString alloc] initWithData:ret.secret encoding:NSUTF8StringEncoding] autorelease];
                        OSSRet* keyret;
                        if ([OSSApi CheckIDandKey:strKeyId key:strKeySecret host:[Util getAppDelegate].strHost ret:&keyret]) {
                            [Util getAppDelegate].strAccessID=strKeyId;
                            [Util getAppDelegate].strAccessKey=strKeySecret;
                            [Util getAppDelegate].strArea=strLocation;
                            if ([Util getAppDelegate].strArea.length==0) {
                                [Util getAppDelegate].strArea=@"";
                            }
                            NSString * dbpath=[NSString stringWithFormat:@"%@/user/%@/transdb.db",[[NSBundle mainBundle] bundlePath],[strKeyId sha1HexDigest]];
                            [Util createfolder:[dbpath stringByDeletingLastPathComponent]];
                            [[TransPortDB shareTransPortDB] OpenPath:dbpath];
                            [Util getAppDelegate].bLogin=YES;
                            retString=[Util errorInfoWithCode:WEB_SUCCESS];
                        }
                        else {
                            retString=[Util errorInfoWithCode:WEB_ACCESSKEYERROR];
                        }
                    }
                    else {
                        retString=[Util errorInfoWithCode:WEB_DECRYPTERROR];
                    }
                }
            }
        }
        else {
            bFileError=YES;
        }
        if (bFileError) {
            retString=[Util errorInfoWithCode:WEB_FILEERROR];
        }
    }
    else {
        retString=[Util errorInfoWithCode:WEB_FILEOPENERROR];
    }
END:
    NSLog(@"%@",retString);
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) setPassword:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    NSString* password=[dictionary objectForKey:@"password"];
    OSSRsaItem*ret=[OSSRsa EncryptKey:[[Util getAppDelegate].strAccessID dataUsingEncoding:NSUTF8StringEncoding] secret:[[Util getAppDelegate].strAccessKey dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret.ret) {
        UserInfo * user=[[[UserInfo alloc]init ]autorelease];
        user.strAccessID=[ret.key base64Encoded];
        user.strAccessKey=[ret.secret base64Encoded];
        user.strArea=[Util getAppDelegate].strArea;
        user.strHost=[Util getAppDelegate].strHost;
        NSString * temp=[NSString stringWithFormat:@"%@%@",[OSSRsa getcomputerid],password];
        user.strPassword=[temp md5HexDigest];
        [[SettingsDb shareSettingDb] setuserinfo:user];
        retString=[Util errorInfoWithCode:WEB_SUCCESS];
    }
    else {
        retString=[Util errorInfoWithCode:WEB_PASSWORDENCRYPTERROR];
    }
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) loginPassword:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    NSString* password=[dictionary objectForKey:@"password"];
    NSString * temp=[NSString stringWithFormat:@"%@%@",[OSSRsa getcomputerid],password];
    if ([[temp md5HexDigest] isEqualToString:[[SettingsDb shareSettingDb] getUserPassword]]) {
        UserInfo * user=[[SettingsDb shareSettingDb] getuserinfo];
        NSData* key=[NSData base64Decoded:user.strAccessID];
        NSData* secret=[NSData base64Decoded:user.strAccessKey];
        OSSRsaItem* ret=[OSSRsa DecryptKey:nil key:key secret:secret];
        if (ret.ret) {
            [Util getAppDelegate].strAccessID=[[[NSString alloc] initWithData:ret.key encoding:NSUTF8StringEncoding] autorelease];
            [Util getAppDelegate].strAccessKey=[[[NSString alloc] initWithData:ret.secret encoding:NSUTF8StringEncoding] autorelease];
            [Util getAppDelegate].strHost=user.strHost;
            [Util getAppDelegate].strArea=user.strArea;
            NSString * dbpath=[NSString stringWithFormat:@"%@/user/%@/transdb.db",[[NSBundle mainBundle] bundlePath],[[Util getAppDelegate].strAccessID sha1HexDigest]];
            [Util createfolder:[dbpath stringByDeletingLastPathComponent]];
            [[TransPortDB shareTransPortDB] OpenPath:dbpath];
            [Util getAppDelegate].bLogin=YES;
            retString=[Util errorInfoWithCode:WEB_SUCCESS];
        }
        else {
            retString=[Util errorInfoWithCode:WEB_PASSWORDENCRYPTERROR];
        }
    }
    else {
        retString=[Util errorInfoWithCode:WEB_PASSWORDERROR];
    }
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) setServerLocation:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    NSString* location=[dictionary objectForKey:@"location"];
    if (location.length) {
        [[SettingsDb shareSettingDb] setHost:location];
        [Util getAppDelegate].strHost=location;
    }
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) deleteBucket:(OperPackage*)tran {
    NSString* retString=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:WEB_JSONERROR];
        goto END;
    }
    NSString * keyid=[dictionary objectForKey:@"keyid"];
    NSString * keysecret=[dictionary objectForKey:@"keysecret"];
    NSString * bucket=[dictionary objectForKey:@"bucket"];
    NSString * host=[Util ChangeHost:[dictionary objectForKey:@"location"]];
    if (![[Util getAppDelegate].strAccessID isEqualToString:keyid]||![[Util getAppDelegate].strAccessKey isEqualToString:keysecret]) {
        retString=[Util errorInfoWithCode:WEB_ACCESSKEYERROR];
    }
    NSMutableArray* items = [NSMutableArray array];
    [self GetFileList:host bucket:bucket object:@"" items:items];
    if (items.count) {
        [[Util getAppDelegate] performSelectorOnMainThread:@selector(startDelete:) withObject:items waitUntilDone:YES];
    }
    NSLog(@"delete");
    OSSListMultipartUploadRet *ret;
    if([OSSApi ListMultipartUploads:host bucketname:bucket reet:&ret])
    {
        for (OSSListMultipartUpload *item in ret.arrayUpload) {
            if (![OSSApi AbortMultipartUpload:host bucketname:bucket objectname:item.strKey uploadid:item.strUploadId]) {
                
                goto END;
            }
        }
    }
    OSSRet * ossret;
    if ([OSSApi DeleteBucket:host bucketname:bucket ret:&ossret]) {
        retString=[Util errorInfoWithCode:WEB_SUCCESS];
    }
    else {
        //zheng
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

-(void) pack:(NSString*)name jsoninfo:(NSString*)jsonInfo webframe:(WebFrame*)webframe cb:(WebScriptObject*)cb retController:(NSWindowController*)retController array:(NSArray*)array
{
    OperPackage* tran=[[[OperPackage alloc] init] autorelease];
    tran._operName=name;
    tran._jsonInfo=jsonInfo;
    tran._webframe=webframe;
    tran._cb=cb;
    tran._window=retController.window;
    tran._array=array;
    [_operQueue addOperation:tran];
}


+(void) callbackonmain:(id)info
{
    NSDictionary* dicInfo=(NSDictionary*)info;
    JSContextRef ctx =[(WebFrame*)[dicInfo valueForKey:@"webframe"] globalContext];
    JSObjectRef func = [(WebScriptObject*)[dicInfo valueForKey:@"obj"] JSObject];
    NSString* jsonstring= [dicInfo valueForKey:@"jsonstring"];
    
    JSStringRef jsstr = JSStringCreateWithCFString((CFStringRef)jsonstring);
    JSValueRef jsvalue = JSValueMakeFromJSONString(ctx, jsstr);
    JSStringRelease(jsstr);
    
    JSObjectCallAsFunction(ctx, func, NULL, 1, &jsvalue, NULL);
}

+(void) operateCallback:(WebScriptObject*)_obj webFrame:(WebFrame*)_webFrame jsonString:(NSString*)_jsonString
{
    if (![_obj isKindOfClass:[WebScriptObject class]]
        || !JSObjectIsFunction([_webFrame globalContext],[_obj JSObject])) {
        return;
    }
    
    if (!_jsonString.length) {
        _jsonString=[Util errorInfoWithCode:WEB_SUCCESS];
    }
    NSDictionary* info=[NSDictionary dictionaryWithObjectsAndKeys:
                        _webFrame,@"webframe", _obj,@"obj", _jsonString,@"jsonstring", nil];
    [self performSelectorOnMainThread:@selector(callbackonmain:) withObject:info waitUntilDone:NO];
}



@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
