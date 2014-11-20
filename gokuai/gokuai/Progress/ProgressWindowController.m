
#import "ProgressWindowController.h"
#import "ProgressManager.h"
#import "Util.h"
#import "TransPortDB.h"
#import "LaunchpadWindowController.h"
#import "MoveAndPasteWindowController.h"
#import "OSSApi.h"

@implementation ProgressWindowController

@synthesize _oper;
@synthesize _obj;
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
    _obj = nil;
    [super dealloc];
}

-(void) window_close:(NSNotification*)notification
{
    if ([notification object]==self.window) {
        [OperationManager operateCallback:_obj._cb webFrame:_obj._webframe jsonString:[ProgressManager sharedInstance].strRet];
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
        [_cpyprogress cancel];
        self._cpyprogress=nil;
    }
}

- (void)windowDidLoad
{
    [ProgressManager sharedInstance].bProgressClose=NO;
    [super windowDidLoad];
    [self.window center];
    [self.window setHasShadow:YES];
    switch (_oper) {
        case pc_copy:
            self.window.title=@"复制中";
            _actionTarget.stringValue=@"准备复制";
            break;
        case pc_delete:
            self.window.title=@"删除中";
            _actionTarget.stringValue=@"准备删除";
            break;
        case pc_bucket:
            self.window.title=@"删除中";
            _actionTarget.stringValue=@"准备删除";
            break;
        default:
            break;
    }
    _progressIndicator.doubleValue=0;
    self._cpyprogress=[[[CopyProgress alloc]init:_obj._jsonInfo type:_oper] autorelease];
    [self._cpyprogress setProgressCallBack:^(NSInteger v) {
        if (v==0) {
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
            return;
        }
        if (v>[ProgressManager sharedInstance].nCount) {
            v=[ProgressManager sharedInstance].nCount;
        }
        if ([ProgressManager sharedInstance].nCount>0) {
            NSUInteger pos=v*100/[ProgressManager sharedInstance].nCount;
            [_progressIndicator setDoubleValue:pos];
            switch (_oper) {
                case pc_copy:
                    if (1==[ProgressManager sharedInstance].nCount) {
                        _actionTarget.stringValue=[NSString stringWithFormat:@"正在复制［%@］",[ProgressManager sharedInstance].strFilename];
                    }
                    else {
                        _actionTarget.stringValue=[NSString stringWithFormat:@"正在复制%ld/%ld个项目",v,[ProgressManager sharedInstance].nCount];
                    }
                    break;
                case pc_delete:
                    if (1==[ProgressManager sharedInstance].nCount) {
                        _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除［%@］",[ProgressManager sharedInstance].strFilename];
                    }
                    else {
                        _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除%ld/%ld个项目",v,[ProgressManager sharedInstance].nCount];
                    }
                    break;
                case pc_bucket:
                    if (1==[ProgressManager sharedInstance].nCount) {
                        _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除［%@］",[ProgressManager sharedInstance].strFilename];
                    }
                    else {
                        _actionTarget.stringValue=[NSString stringWithFormat:@"正在删除%ld/%ld个项目",v,[ProgressManager sharedInstance].nCount];
                    }
                    break;
                default:
                    break;
            }
        }
    }];
    [[ProgressManager sharedInstance] addProgress:_cpyprogress];
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

-(void)setprogresstype:(OperPackage*)package type:(NSInteger)type
{
    self._obj=package;
    self._oper=type;
}

@end
