
#import "OperationManager.h"
#import "TransPortDB.h"
#import "Util.h"
#import "Common.h"
#import "NSAlert+Blocks.h"
#import "JSONKit.h"
#import "NSStringExpand.h"
#import "NSDataExpand.h"
#import "CopyProgress.h"
#import "ProgressWindowController.h"
#import "MoveAndPasteWindowController.h"
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
            [[Util getAppDelegate] performSelectorOnMainThread:@selector(startDelete:) withObject:self waitUntilDone:NO];
        }
        if ([self._operName isEqualToString:@"copyObject"]) {
            [[Util getAppDelegate] performSelectorOnMainThread:@selector(startCopy:) withObject:self waitUntilDone:NO];
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
            [[Util getAppDelegate] performSelectorOnMainThread:@selector(startDeleteBucket:) withObject:self waitUntilDone:NO];
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
    NSString* retString=[Util errorInfoWithCode:WEB_SUCCESS];
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
    NSString * tempret=[[Network shareNetwork] AddFileUpload:host bucket:bucket object:prefix array:paths];
    if (tempret.length) {
        retString=tempret;
    }
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(NSString *) GetFileList:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object fullpath:(NSString*)fullpath count:(NSInteger*)count dcount:(NSInteger)dcount
{
    NSString* strRet=@"";
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
                [tranitem release];
                (*count)++;
          /*      if ((*count)>1000000) {
                    NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:1000000],@"error",
                                          @"队列已超出客户端下载能力，请使用OSS的API下载。",@"message",nil];
                    strRet=[dicRet JSONString];
                    return strRet;
                }*/
                if ([Util getAppDelegate].bAddDownloadOut) {
                    return strRet;
                }
            }
            [[Util getAppDelegate] UpdateLoadingCount:(*count) downloadcount:dcount+(*count)];
            if (ret.strNextMarker.length==0) {
                break;
            }
            nextmarker=ret.strNextMarker;
        }
        else {
            NSString *msg=[NSString stringWithFormat:@"%@,%@,%@",bucket,object,nextmarker];
            strRet=[Util errorInfoWithCode:@"保存文件夹获取列表失败" message:msg ret:ret];
            break;
        }
    }
    return strRet;
}

+(void) saveFile:(OperPackage*)tran {
    NSString* retString=[Util errorInfoWithCode:WEB_SUCCESS];
    [Util getAppDelegate].bAddDownloadOut=NO;
    [Util getAppDelegate].bAddDownloadDelete=NO;
    NSInteger dcount=[[TransPortDB shareTransPortDB] GetDownloadCount];
    NSInteger count=0;
    [[Network shareNetwork].dManager startAdding];
    [[TransPortDB shareTransPortDB] begin];
    for (SaveFileItem *item in tran._array) {
        TransTaskItem * tranitem=[[[TransTaskItem alloc] init] autorelease];
        tranitem.strHost=item.strHost;
        tranitem.strBucket=item.strBucket;
        tranitem.strObject=item.strObject;
        tranitem.strFullpath=item.strFullpath;
        tranitem.ullFilesize=item.ullFilesize;
        tranitem.strPathhash=item.strEtag;
        tranitem.nStatus=TRANSTASK_NORMAL;
        if (tranitem.strObject.length>0) {
            [[TransPortDB shareTransPortDB] Add_Download:tranitem];
            count++;
            [[Util getAppDelegate] UpdateLoadingCount:count downloadcount:dcount+count];
        }
   /*     if (count>1000000) {
            NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:1000000],@"error",
                                  @"队列已超出客户端下载能力，请使用OSS的API下载。",@"message",nil];
            retString=[dicRet JSONString];
            goto END;
        }*/
        if (item.bDir) {
            NSString * ret=[self GetFileList:tranitem.strHost bucket:tranitem.strBucket object:tranitem.strObject fullpath:tranitem.strFullpath count:&count dcount:dcount];
            if (ret.length>0) {
                retString=ret;
                goto END;
            }
        }
    }
END:
    if ([Util getAppDelegate].bAddDownloadOut) {
        if ([Util getAppDelegate].bAddDownloadDelete) {
            for (SaveFileItem *item in tran._array) {
                [[TransPortDB shareTransPortDB] Delete_Download:item.strHost bucket:item.strBucket object:item.strObject];
            }
        }
    }
    [Util getAppDelegate].bAddDownloadOut=NO;
    [Util getAppDelegate].bAddDownloadDelete=NO;
    [[TransPortDB shareTransPortDB] end];
    [[Network shareNetwork].dManager finishAdding];
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
    NSString* host=strLocation;
    if (strLocation.length) {
        host=[Util ChangeHost:strLocation];
    }
    OSSRet* ret;
    if ([OSSApi CheckIDandKey:strKeyId key:strKeySecret host:host ret:&ret]) {
        [Util getAppDelegate].strAccessID=strKeyId;
        [Util getAppDelegate].strAccessKey=strKeySecret;
        [Util getAppDelegate].strArea=strLocation;
        if ([Util getAppDelegate].strArea.length==0) {
            [Util getAppDelegate].strArea=@"";
        }
        NSString * dbpath=[NSString stringWithFormat:@"%@/.oss/user/%@/transdb.db",NSHomeDirectory(),[strKeyId sha1HexDigest]];
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
                        NSString* host=strLocation;
                        if (strLocation.length) {
                            host=[Util ChangeHost:strLocation];
                        }
                        if ([OSSApi CheckIDandKey:strKeyId key:strKeySecret host:host ret:&keyret]) {
                            [Util getAppDelegate].strAccessID=strKeyId;
                            [Util getAppDelegate].strAccessKey=strKeySecret;
                            [Util getAppDelegate].strArea=strLocation;
                            if ([Util getAppDelegate].strArea.length==0) {
                                [Util getAppDelegate].strArea=@"";
                            }
                            NSString * dbpath=[NSString stringWithFormat:@"%@/.oss/user/%@/transdb.db",NSHomeDirectory(),[strKeyId sha1HexDigest]];
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
    }
    retString=[Util errorInfoWithCode:WEB_SUCCESS];
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
            NSString * dbpath=[NSString stringWithFormat:@"%@/.oss/user/%@/transdb.db",NSHomeDirectory(),[[Util getAppDelegate].strAccessID sha1HexDigest]];
            [Util createfolder:[dbpath stringByDeletingLastPathComponent]];
            [[TransPortDB shareTransPortDB] OpenPath:dbpath];
            [Util getAppDelegate].bLogin=YES;
        }
        retString=[Util errorInfoWithCode:WEB_SUCCESS];
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
