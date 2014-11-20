
#import "ProgressWindowController.h"
#import "ProgressManager.h"
#import "Util.h"
#import "TransPortDB.h"
#import "LaunchpadWindowController.h"
#import "MoveAndPasteWindowController.h"
#import "OSSApi.h"

////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ProgressPackage

@synthesize _oper;
@synthesize _obj;

-(id) initCopy:(OperPackage*)obj
{
    if (self = [super init]) {
        self._oper = pc_copy;
        self._obj = obj;
    }
    return self;
}

-(id) initDelete:(OperPackage*)obj
{
    if (self = [super init]) {
        self._oper = pc_delete;
        self._obj = obj;
    }
    return self;
}

-(id)initDeleteBucket:(OperPackage*)obj
{
    if (self = [super init]) {
        self._oper = pc_bucket;
        self._obj = obj;
    }
    return self;
}

-(void) dealloc
{
    self._obj = nil;
    [super dealloc];
}

@end

@implementation ProgressWindowController

@synthesize _package;
@synthesize _cpyprogress;
@synthesize _strRetCallback;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(window_close:) name:NSWindowWillCloseNotification object:nil];
    }
    return self;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSWindowWillCloseNotification object:nil];
    [super dealloc];
}

-(void) window_close:(NSNotification*)notification
{
    if ([notification object]==self.window) {
        NSLog(@"close:%@",self._strRetCallback);
        if ([ProgressManager sharedInstance].strRet.length>0) {
            self._strRetCallback=[ProgressManager sharedInstance].strRet;
        }
        [OperationManager operateCallback:_package._obj._cb webFrame:_package._obj._webframe jsonString:self._strRetCallback];
        [[Util getAppDelegate].launchpadWindowController makeAble:YES];
        [self myclear];
        [ProgressManager sharedInstance].bProgressClose=YES;
        [self release];
    }
}

-(void) myshow {
    [self.window setParentWindow:[Util getAppDelegate].launchpadWindowController.window];
    [[Util getAppDelegate].launchpadWindowController makeAble:NO];
    [self.window makeKeyAndOrderFront:nil];
}

-(void) myhide {
    [self.window close];
}

-(void) myclear
{
    if (_cpyprogress) {
        if (![_cpyprogress isfinished]) {
        }
        [_cpyprogress cancel];
        self._cpyprogress=nil;
    }
    if (_package) {
        [_package release];
        _package = nil;
    }
}

-(void) copyFiles:(NSArray*)items
{
    NSString* filename=nil;
    NSString* prompt=nil;
    if (0==items.count) {
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
    else if (1==items.count) {
        CopyFileItem* item=[items objectAtIndex:0];
        filename=[item.strDstObject lastPathComponent];
        prompt=[NSString stringWithFormat:@"正在拷贝［%@］",filename];
    }
    else {
        prompt=[NSString stringWithFormat:@"正在拷贝0/%ld个项目", items.count];
    }
    self.window.title=@"复制中";
    _actionTarget.stringValue=prompt;
    [_progressIndicator setHidden:YES];
    _progressIndicator.doubleValue=0;
    self._cpyprogress=[[[CopyProgress alloc]initWithPaths:items type:pc_copy] autorelease];
    [self._cpyprogress setProgressCallBack:^(NSInteger v) {
        if (v>items.count) {
            v=items.count;
        }
        NSUInteger pos=v*100/items.count;
        [_progressIndicator setHidden:NO];
        [_progressIndicator setDoubleValue:pos];
        if (1==items.count) {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在拷贝［%@］",filename];
        }
        else {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在拷贝%ld/%ld个项目",v,items.count];
        }
        if (_cpyprogress.isfinished) {
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
        }
    }];
    [[ProgressManager sharedInstance] addProgress:_cpyprogress];
}

-(void) deleteFiles:(NSArray*)items
{
    NSString* filename=nil;
    NSString* prompt=nil;
    if (0==items.count) {
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
    else if (1==items.count) {
        DeleteFileItem* item=[items objectAtIndex:0];
        filename=[item.strObject lastPathComponent];
        prompt=[NSString stringWithFormat:@"正在删除［%@］",filename];
    }
    else {
        prompt=[NSString stringWithFormat:@"正在删除0/%ld个项目",items.count];
    }
    self.window.title=@"删除中";
    _actionTarget.stringValue=prompt;
    [_progressIndicator setHidden:YES];
    _progressIndicator.doubleValue=0;
    self._cpyprogress=[[[CopyProgress alloc]initWithPaths:items type:pc_delete] autorelease];
    [self._cpyprogress setProgressCallBack:^(NSInteger v) {
        if (v>items.count) {
            v=items.count;
        }
        NSUInteger pos=v*100/items.count;
        [_progressIndicator setHidden:NO];
        [_progressIndicator setDoubleValue:pos];
        if (1==items.count) {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除［%@］",filename];
        }
        else {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除%ld/%ld个项目",v,items.count];
        }
        if (_cpyprogress.isfinished) {
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
        }
    }];
    [[ProgressManager sharedInstance] addProgress:_cpyprogress];
}

-(void) deleteBucket:(NSArray*)items host:(NSString*)host bucket:(NSString*)bucket
{
    NSString* filename=nil;
    NSString* prompt=nil;
    if (0==items.count) {
        prompt=[NSString stringWithFormat:@"正在删除bucket［%@］",bucket];
    }
    else if (1==items.count) {
        DeleteFileItem* item=[items objectAtIndex:0];
        filename=[item.strObject lastPathComponent];
        prompt=[NSString stringWithFormat:@"正在删除文件［%@］",filename];
    }
    else {
        prompt=[NSString stringWithFormat:@"正在删除0/%ld个项目",items.count];
    }
    self.window.title=@"删除中";
    _actionTarget.stringValue=prompt;
    [_progressIndicator setHidden:YES];
    _progressIndicator.doubleValue=0;
    self._cpyprogress=[[[CopyProgress alloc]initWithPaths:items type:pc_bucket] autorelease];
    [self._cpyprogress setProgressCallBack:^(NSInteger v) {
        if (items.count==0) {
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
            return ;
        }
        if (v>items.count) {
            v=items.count;
        }
        NSUInteger pos=v*100/items.count;
        [_progressIndicator setHidden:NO];
        [_progressIndicator setDoubleValue:pos];
        if (1==items.count) {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除［%@］",filename];
        }
        else {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除%ld/%ld个项目",v,items.count];
        }
        if (_cpyprogress.isfinished) {
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
        }
    }];
    [[ProgressManager sharedInstance] addProgress:_cpyprogress];
}

- (void)windowDidLoad
{
    [ProgressManager sharedInstance].bProgressClose=NO;
    [super windowDidLoad];
    [self.window center];
    [self.window setHasShadow:YES];
    switch (_package._oper) {
        case pc_copy:
            [self parsecopy];
            break;
        case pc_delete:
            [self parsedelete];
            break;
        case pc_bucket:
            [self parsebucket];
            break;
        default:
            break;
    }
}

-(void) displayex;
{
    if ([NSThread isMainThread]) {
        [self myshow];
    }
    else {
        [self performSelectorOnMainThread:@selector(myshow) withObject:nil waitUntilDone:YES];
    }
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

-(void) parsecopy
{
    self._strRetCallback=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:_package._obj._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        self._strRetCallback=[Util errorInfoWithCode:WEB_JSONERROR];
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
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
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
    [self copyFiles:items];
}

-(void) parsedelete
{
    self._strRetCallback=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:_package._obj._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        self._strRetCallback=[Util errorInfoWithCode:WEB_JSONERROR];
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
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
                    self._strRetCallback=strRet;
                    return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
                }
            }
        }
    }
    [self deleteFiles:items];
}

-(void) parsebucket
{
    self._strRetCallback=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:_package._obj._jsonInfo];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        self._strRetCallback=[Util errorInfoWithCode:WEB_JSONERROR];
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
    NSString * keyid=[dictionary objectForKey:@"keyid"];
    NSString * keysecret=[dictionary objectForKey:@"keysecret"];
    NSString * bucket=[dictionary objectForKey:@"bucket"];
    NSString * host=[Util ChangeHost:[dictionary objectForKey:@"location"]];
    if (![[Util getAppDelegate].strAccessID isEqualToString:keyid]||![[Util getAppDelegate].strAccessKey isEqualToString:keysecret]) {
        self._strRetCallback=[Util errorInfoWithCode:WEB_ACCESSKEYERROR];
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
    NSMutableArray* items = [NSMutableArray array];
    NSString * strRet=[self GetFileList:host bucket:bucket object:@"" items:items];
    if (strRet.length>0) {
        self._strRetCallback=strRet;
        return [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
    [self deleteBucket:items host:host bucket:bucket];
}
@end
