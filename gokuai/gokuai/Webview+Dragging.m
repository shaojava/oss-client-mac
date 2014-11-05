
#import "Webview+Dragging.h"
#import "JSONKit.h"
#import "Util.h"

@implementation GKWebview


@synthesize rpoint;
@synthesize jsonInfo;

@synthesize dropEvent;
@synthesize dragfinishEvent;

@synthesize _out;
@synthesize outstr;
//////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        outstr = nil;
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    
    return self;
}

//destination
-(BOOL) prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *list = [pasteboard propertyListForType:NSFilenamesPboardType];
    if (list.count) {
        NSPoint pt=[sender draggingLocation];
        
        NSMutableArray* retArray=[NSMutableArray arrayWithCapacity:list.count];
        for (NSString* string in list) {
            [retArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:string,@"path", nil]];
        }
        
        CGFloat poxY=self.frame.size.height-pt.y;
        NSDictionary* ret=[NSDictionary dictionaryWithObjectsAndKeys:retArray,@"list",
                              [NSNumber numberWithFloat:pt.x],@"x",
                              [NSNumber numberWithFloat:poxY],@"y",
                              nil];
        self.jsonInfo=[ret JSONString];
        
        if (dropEvent) {
            dropEvent();
        }
    }
    
    return YES;
}

//source

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    _out = NO;
    
	NSPasteboard *pboard = [sender draggingPasteboard];
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
	}
    
	return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender;
{
    _out = YES;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender;
{
    self.outstr = nil;
    
    if (_out) {
        rpoint = [sender draggingLocation];
        
        if (dragfinishEvent) {
            dragfinishEvent();
        }
        
        _out = NO;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////