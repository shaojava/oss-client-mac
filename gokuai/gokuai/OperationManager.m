
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


-(id) init {
    if (self=[super init]) {
        self._operName=nil;
        self._cb=nil;
        self._jsonInfo=nil;
        self._webframe=nil;
        self._window=nil;
    }
    return self;
}

-(void) dealloc {
    self._operName=nil;
    self._cb=nil;
    self._jsonInfo=nil;
    self._webframe=nil;
    self._window=nil;
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
        if ([self._operName isEqualToString:@"saveAuthorization"]) {
            [OperationManager saveAuthorization:self];
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
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
    retString=[Util errorInfoWithCode:MY_NO_ERROR];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) saveFile:(OperPackage*)tran {
    //zheng
}
+(void) startUpload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
    retString=[Util errorInfoWithCode:MY_NO_ERROR];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) startDownload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
    retString=[Util errorInfoWithCode:MY_NO_ERROR];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) stopUpload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
    retString=[Util errorInfoWithCode:MY_NO_ERROR];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) stopDownload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
    retString=[Util errorInfoWithCode:MY_NO_ERROR];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) deleteUpload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
            [[Network shareNetwork] StopUploadAll];
        }
    }
    else {
        [[Network shareNetwork] DeleteUpload:paths];
    }
    retString=[Util errorInfoWithCode:MY_NO_ERROR];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) deleteDownload:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
            [[Network shareNetwork] StopDownloadAll];
        }
    }
    else {
        [[Network shareNetwork] DeleteDownload:paths];
    }
    retString=[Util errorInfoWithCode:MY_NO_ERROR];
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) deleteObject:(OperPackage*)tran {
    //zheng
}
+(void) copyObject:(OperPackage*)tran {
    //zheng
}
+(void) loginByKey:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
        goto END;
    }
    NSString* strKeyId=[dictionary objectForKey:@"keyid"];
    NSString* strKeySecret=[dictionary objectForKey:@"keysecret"];
    BOOL bHost=[[dictionary objectForKey:@"ishost"] boolValue];
    NSString* strLocation=[dictionary objectForKey:@"location"];
    if ([OSSApi CheckIDandKey:strKeyId key:strKeySecret ishost:bHost host:strLocation]) {//zheng
        [Util getAppDelegate].strAccessID=strKeyId;
        [Util getAppDelegate].strAccessKey=strKeySecret;
        if (bHost) {
            [Util getAppDelegate].strArea=strLocation;
        }
        NSString * dbpath=[NSString stringWithFormat:@"%@/user/%@/transdb.db",[[NSBundle mainBundle] bundlePath],[strKeyId sha1HexDigest]];
        [Util createfolder:[dbpath getParent]];
        [[TransPortDB shareTransPortDB] OpenPath:dbpath];
        [Util getAppDelegate].bLogin=YES;
        retString=[Util errorInfoWithCode:MY_NO_ERROR];
    }
    else {
        retString=[Util errorInfoWithCode:WEB_ACCESSKEYERROR];
    }
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) loginByFile:(OperPackage*)tran {
    //zheng
}

+(void) setPassword:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
        retString=[Util errorInfoWithCode:MY_NO_ERROR];
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
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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
            [Util createfolder:[dbpath getParent]];
            [[TransPortDB shareTransPortDB] OpenPath:dbpath];
            [Util getAppDelegate].bLogin=YES;
            retString=[Util errorInfoWithCode:MY_NO_ERROR];
        }
        else {
            retString=[Util errorInfoWithCode:WEB_PASSWORDENCRYPTERROR];
        }
    }
    else {
        retString=[Util errorInfoWithCode:WEB_PASSWORDEROR];
    }
END:
    [self operateCallback:tran._cb webFrame:tran._webframe jsonString:retString];
}

+(void) setServerLocation:(OperPackage*)tran {
    NSString* retString=nil;
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:tran._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        retString=[Util errorInfoWithCode:MY_ERROR_JSON];
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

+(void) saveAuthorization:(OperPackage*)tran {
    //zheng
}
+(void) deleteBucket:(OperPackage*)tran {
    //zheng
}

-(void) pack:(NSString*)name jsoninfo:(NSString*)jsonInfo webframe:(WebFrame*)webframe cb:(WebScriptObject*)cb retController:(NSWindowController*)retController
{
    OperPackage* tran=[[[OperPackage alloc] init] autorelease];
    tran._operName=name;
    tran._jsonInfo=jsonInfo;
    tran._webframe=webframe;
    tran._cb=cb;
    tran._window=retController.window;
    
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
        _jsonString=[Util errorInfoWithCode:MY_NO_ERROR];
    }
    NSDictionary* info=[NSDictionary dictionaryWithObjectsAndKeys:
                        _webFrame,@"webframe", _obj,@"obj", _jsonString,@"jsonstring", nil];
    [self performSelectorOnMainThread:@selector(callbackonmain:) withObject:info waitUntilDone:NO];
}



@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
