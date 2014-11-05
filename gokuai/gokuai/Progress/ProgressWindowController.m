
#import "ProgressWindowController.h"


#import "ProgressManager.h"

#import "Util.h"
#import "TransPortDB.h"
#import "LaunchpadWindowController.h"

////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ProgressPackage

@synthesize _oper;
@synthesize _obj;
@synthesize _lck;
@synthesize _defApp;
@synthesize _opentype;

-(id) initOpen:(id)obj lck:(BOOL)lck defApp:(NSString *)defApp type:(NSString*)type;
{
    if (self = [super init]) {
        self._oper = pc_load;
        self._obj = obj;
        self._lck = lck;
        self._defApp = defApp;
        self._opentype=type;
    }
    
    return self;
}

-(id) initCopy:(id)obj;
{
    if (self = [super init]) {
        self._oper = pc_copy;
        self._obj = obj;
    }
    
    return self;
}

-(void) dealloc
{
    self._obj = nil;
    self._defApp = nil;
    self._opentype=nil;
    [super dealloc];
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ProgressWindowController

@synthesize _package;

@synthesize _progress;
@synthesize _cpyprogress;

////////////////////////////////////////////////////////////////////////////////////////////////

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
        
        if (pc_copy == _package._oper ) {
            [[Util getAppDelegate].launchpadWindowController makeAble:YES];
        }
        
        [self myclear];
        [self release];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////

-(void) updateLoadProgress:(DownloadState)retval progress:(double)progress retstr:(NSString*)retstr prompt:(NSString*)prompt
{
    BOOL close = YES;
    if (DS_Ing==retval) {
        [_progressIndicator setHidden:NO];
        [_actionProgress setHidden:NO];
        [_btnMultiFunc setHidden:NO];
        _progressIndicator.doubleValue=progress;
        _actionProgress.stringValue=retstr;
        _actionTarget.stringValue=prompt;
        close = NO;
    }
    else if (DS_Int==retval) {
        _actionTarget.stringValue=prompt;
        close = NO;
    }
    else if (DS_Done==retval) {
        [_progressIndicator setHidden:NO];
        [_actionProgress setHidden:NO];
        [_btnMultiFunc setHidden:NO];
        _progressIndicator.doubleValue=progress;
        _actionProgress.stringValue=retstr;
        [self myopen];
    }
    else if (DS_Cancel==retval) {
    }
    else if (DS_Err==retval) {
    }
    if (close) {
        [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
}

-(void) updateCopyProgress:(NSInteger)value
{
    if (value >= 0 && value <=100) {
        [_progressIndicator setHidden:NO];
        [_actionProgress setHidden:NO];
        [_btnMultiFunc setHidden:NO];
        
        [_progressIndicator setDoubleValue:value];
        _actionProgress.stringValue=[NSString stringWithFormat:@"%ld %%",value];
    }
    
    if (_cpyprogress.isfinished) {
        [self performSelectorOnMainThread:@selector(myhide) withObject:nil waitUntilDone:YES];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)buttonCancelClicked:(id)sender
{
    if (pc_load == _package._oper ) {
        [self.window orderOut:nil];
    }
    else if ( pc_copy == _package._oper ) {
        [self.window close];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) myshow {
    if ( pc_copy == _package._oper) {
        [self.window setParentWindow:[Util getAppDelegate].launchpadWindowController.window];
        [[Util getAppDelegate].launchpadWindowController makeAble:NO];
    }
    
    [self.window makeKeyAndOrderFront:nil];
}

-(void) myhide {
    [self.window close];
}

-(void) myopen
{
   
}

-(void) myclear
{
    if (_progress) {
        if (DS_Ing==_progress.loadstate) {

        }
        
        [_progress cancel];
        self._progress=nil;
    }
    
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setActionType:(NSInteger)type filename:(NSString*)filename prompt:(NSString*)prompt
{
    if ( 0 == type ) {
        self.window.title=[Util localizedStringForKey:@"打开中" alternate:nil];
        _actionTarget.stringValue=prompt;
        
        [_btnMultiFunc setImage:[NSImage imageNamed:@"bc_normal.png"]];
        [_btnMultiFunc setAlternateImage:[NSImage imageNamed:@"bc_hover.png"]];
        [_btnMultiFunc setToolTip:[Util localizedStringForKey:@"取消下载" alternate:nil]];
    }
    else if ( 1 == type ) {
        self.window.title=[Util localizedStringForKey:@"复制中" alternate:nil];
        _actionTarget.stringValue=prompt;
        
        [_btnMultiFunc setImage:[NSImage imageNamed:@"bc_normal.png"]];
        [_btnMultiFunc setAlternateImage:[NSImage imageNamed:@"bc_hover.png"]];
        [_btnMultiFunc setToolTip:[Util localizedStringForKey:@"取消复制" alternate:nil]];
    }
    
    [_actionProgress setHidden:YES];
    [_progressIndicator setHidden:YES];
    [_btnMultiFunc setHidden:YES];
    
    _progressIndicator.doubleValue=0;
    [_fileIcon setImage:[Util iconFromFileType:filename]];
}

-(void) _openfile:(transportnode*)transitem specified:(NSString*)specified lock:(BOOL)lock
{

}

-(void) _copyFile:(NSArray*)cpyItems
{
    NSString* filename=nil;
    NSString* prompt=nil;
    
    if (0==cpyItems.count) {
        return;
    }
    else if (1==cpyItems.count) {
        CopyItem* cm=[cpyItems objectAtIndex:0];
        
        filename=[cm.oldpath lastPathComponent];
        prompt=[NSString stringWithFormat:[Util localizedStringForKey:@"正在拷贝［%@］" alternate:nil],filename];
    }
    else {
        prompt=[NSString stringWithFormat:[Util localizedStringForKey:@"正在拷贝%ld个项目" alternate:nil], cpyItems.count];
    }
    
    [self setActionType:1 filename:filename prompt:prompt];
    
    self._cpyprogress=[[[CopyProgress alloc]initWithPaths:cpyItems] autorelease];
    [self._cpyprogress setProgressCallBack:^(NSInteger v) {
        [self updateCopyProgress:v];
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
        case 0:
            [self _openfile:_package._obj specified:_package._defApp lock:_package._lck];
            break;
        case 1:
            [self _copyFile:_package._obj];
            break;
            
        default:
            break;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *)uniquestring;
{
    if ( pc_copy == _package._oper ) {
        return nil;
    }
    return nil;
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////