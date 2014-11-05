//
//  PasteWindowController.m
//  GoKuai
//
//  Created by GoKuai on 13-12-30.
//
//
//////////////////////////////////////////////////////////////////////////////////////////////////

#import "MoveAndPasteWindowController.h"

#import "Util.h"
#import "MoveItem.h"
#import "NSStringExpand.h"
#import "MyTask.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

#define DEF_MOVE_WND_WIDTH  400
#define DEF_MOVE_WND_HEIGHT  98

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MoveAndPasteWindowController

//////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _applyflag=-1;
        
        self.window=[[[NSWindow alloc]init] autorelease];
        self.window.backgroundColor=[NSColor whiteColor];
        
        NSRect rect;
        rect.size=NSMakeSize(DEF_MOVE_WND_WIDTH, DEF_MOVE_WND_HEIGHT);
        rect.origin=[Util getWindowDisplayOriginPoint:rect.size];
        [self.window setFrame:rect display:YES];
        
        _icon=[[[NSImageView alloc]initWithFrame:NSMakeRect(15, 32, 32, 32)] autorelease];
        [self.window.contentView addSubview:_icon];
        
        _copyinfo=[[[GKResizableTextField alloc]initWithFrame:NSMakeRect(64, 42, 320, 28)] autorelease];
        [_copyinfo setBordered:NO];
        [_copyinfo setBackgroundColor:[NSColor clearColor]];
        [_copyinfo setEditable:NO];
        //[_copyinfo.cell setTruncatesLastVisibleLine:YES];
        //[_copyinfo.cell setLineBreakMode: NSLineBreakByCharWrapping];
        [self.window.contentView addSubview:_copyinfo];
        
        _applytoall=[[[NSButton alloc]initWithFrame:NSMakeRect(12, 10, 88, 18)] autorelease];
        [_applytoall setButtonType:NSSwitchButton];
        [self.window.contentView addSubview:_applytoall];
        
        _keepboth=[[[NSButton alloc]initWithFrame:NSMakeRect(106, 10, 88, 18)] autorelease];
        [_keepboth setButtonType:NSMomentaryPushInButton];
        [_keepboth setBezelStyle:NSRoundRectBezelStyle];
        [self.window.contentView addSubview:_keepboth];
        
        _stop=[[[NSButton alloc]initWithFrame:NSMakeRect(204, 10, 88, 18)] autorelease];
        [_stop setButtonType:NSMomentaryPushInButton];
        [_stop setBezelStyle:NSRoundRectBezelStyle];
        [_stop setBordered:YES];
        [self.window.contentView addSubview:_stop];
        
        _replace=[[[NSButton alloc]initWithFrame:NSMakeRect(300, 10, 88, 18)] autorelease];
        [_replace setButtonType:NSMomentaryPushInButton];
        [_replace setBezelStyle:NSRoundRectBezelStyle];
        [_replace setBordered:YES];
        [self.window.contentView addSubview:_replace];
        
        [_copyinfo setFont:[NSFont systemFontOfSize:11]];
        [_applytoall setFont:[NSFont systemFontOfSize:11]];
        [_keepboth setFont:[NSFont systemFontOfSize:11]];
        [_stop setFont:[NSFont systemFontOfSize:11]];
        [_replace setFont:[NSFont systemFontOfSize:11]];
        
        [_applytoall setTarget:self];
        [_applytoall setAction:@selector(buttonApplyToAllClicked:)];
        [_keepboth setTarget:self];
        [_keepboth setAction:@selector(buttonNotReplaceClicked:)];
        [_stop setTarget:self];
        [_stop setAction:@selector(buttonStopClicked:)];
        [_replace setTarget:self];
        [_replace setAction:@selector(buttonReplaceClicked:)];
        
        _applytoall.title=[Util localizedStringForKey:@"全部应用" alternate:nil];
        _replace.title=[Util localizedStringForKey:@"替换" alternate:nil];
        _keepboth.title=[Util localizedStringForKey:@"保留两者" alternate:nil];
        _stop.title=[Util localizedStringForKey:@"停止" alternate:nil];
        
     }
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

/**
-(BOOL) window_will_close:(NSNotification*)notification
{
    if ([notification object]==self.window) {
        _applyflag=1;
        [NSApp stopModal];
        [self.window orderOut:nil];
    }
    
    return NO;
}
 **/

//////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*) backupfilename:(NSString*)filename
{
    NSString* pathext=[filename pathExtension];
    if (pathext.length) {
        return [NSString stringWithFormat:@"%@ 2.%@",
                [filename substringToIndex:filename.length-pathext.length-1],pathext];
    }
    return [NSString stringWithFormat:@"%@ 2",filename];
}

-(NSArray*) GetKeepBothNames:(NSArray*)rplfiles dstfiles:(NSArray*)dstfiles
{
    NSMutableArray* retArray=[NSMutableArray arrayWithCapacity:rplfiles.count];
    
    for (NSDictionary* fileitem in rplfiles) {
        NSString* webpath=[fileitem valueForKey:@"webpath"];
        
        NSMutableDictionary* retDic=[NSMutableDictionary dictionaryWithDictionary:fileitem];
        [retDic setValue:webpath forKey:@"oldwebpath"];
        
        webpath=[self GetKeepBothName:webpath dstfiles:dstfiles];
        [retDic setValue:webpath forKey:@"webpath"];
        [retArray addObject:retDic];
    }
    return retArray;
}

-(NSString*) GetKeepBothName:(NSString*)webpath dstfiles:(NSArray*)dstfiles
{
    NSString* retstring=nil;
   
    return retstring;
}

-(BOOL) pastefilesfrom:(NSArray*)srcfiles mountid:(NSInteger)mountid overwrite:(id)overwrite
{
    return YES;
}
-(BOOL) pastefilesfrom:(NSArray*)srcfiles savepath:(NSString*)savepath
{
        return YES;
}
-(void) resizeWindow:(NSSize)newsz
{
    NSSize oldsz=_copyinfo.frame.size;
    CGFloat offset=newsz.height-oldsz.height;
    if (!newsz.height || !offset) {
        return;
    }

    NSRect tmprect=_copyinfo.frame;
    tmprect.size.height=newsz.height;
    [_copyinfo setFrame:tmprect];
    
    tmprect=self.window.frame;
    tmprect.size.height+=offset;
    [self.window setFrame:tmprect display:YES];
    
    tmprect=_icon.frame;
    tmprect.origin.y+=offset;
    [_icon setFrame:tmprect];
}

-(void) alertDisplay:(BOOL)hasFolder onlyone:(BOOL)onlyone isdir:(BOOL)isdir
{
    [self resizeWindow:[_copyinfo intrinsicContentSize]];
    
    _applytoall.state=0;
    [_applytoall setHidden:onlyone?YES:NO];
    
    [self performSelectorOnMainThread:@selector(myrunmodal) withObject:nil waitUntilDone:YES];
}

-(void) myrunmodal
{
    [NSApp runModalForWindow:self.window];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction) buttonApplyToAllClicked:(id)sender
{
    NSLog(@"%ld",(long)_applytoall.state);
}

-(IBAction)buttonNotReplaceClicked:(id)sender
{
    _applyflag=0;
    [NSApp stopModal];
    [self.window orderOut:nil];
}
-(IBAction)buttonStopClicked:(id)sender
{
    _applyflag=1;
    [NSApp stopModal];
    [self.window orderOut:nil];
}
-(IBAction)buttonReplaceClicked:(id)sender
{
    _applyflag=2;
    [NSApp stopModal];
    [self.window orderOut:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

@end

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////