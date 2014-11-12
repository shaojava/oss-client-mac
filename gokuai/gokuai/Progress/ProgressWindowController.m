
#import "ProgressWindowController.h"
#import "ProgressManager.h"
#import "Util.h"
#import "TransPortDB.h"
#import "LaunchpadWindowController.h"

////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ProgressPackage

@synthesize _oper;
@synthesize _obj;

-(id) initCopy:(id)obj
{
    if (self = [super init]) {
        self._oper = pc_copy;
        self._obj = obj;
    }
    return self;
}

-(id) initDelete:(id)obj
{
    if (self = [super init]) {
        self._oper = pc_delete;
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
        [[Util getAppDelegate].launchpadWindowController makeAble:YES];
        [self myclear];
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
        return;
    }
    else if (1==items.count) {
        CopyFileItem* item=[items objectAtIndex:0];
        filename=[item.strDstObject lastPathComponent];
        prompt=[NSString stringWithFormat:@"正在拷贝［%@］",filename];
    }
    else {
        prompt=[NSString stringWithFormat:@"正在拷贝0/%ld个项目", items.count];
    }
    NSLog(@"%@",prompt);
    self.window.title=@"复制中";
    _actionTarget.stringValue=prompt;
    [_progressIndicator setHidden:YES];
    _progressIndicator.doubleValue=0;
    self._cpyprogress=[[[CopyProgress alloc]initWithPaths:items type:pc_copy] autorelease];
    [self._cpyprogress setProgressCallBack:^(NSInteger v) {
        NSUInteger pos=v*100/items.count;
        [_progressIndicator setHidden:NO];
        [_progressIndicator setDoubleValue:pos];
        if (1==items.count) {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在拷贝［%@］",filename];
        }
        else {
            _actionTarget.stringValue=[NSString stringWithFormat:@"正在拷贝%ld/%ld个项目",v,items.count];
        }
        NSLog(@"%@",_actionTarget.stringValue);
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
        return;
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window center];
    [self.window setHasShadow:YES];
    
    switch (_package._oper) {
        case pc_copy:
            [self copyFiles:_package._obj];
            break;
        case pc_delete:
            [self deleteFiles:_package._obj];
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

@end
