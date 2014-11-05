//
//  WebView+EventEnbled.m
//  GoKuai
//
//  Created by GoKuai on 1/6/14.
//
//

#import "Window+Event.h"

@implementation WindowEve


-(void) disableWindowEx
{
    _disable=YES;
}
-(void) enableWindowEx
{
    _disable=NO;
}

-(void)sendEvent:(NSEvent *)theEvent
{
    if (_disable) {
        switch([theEvent type])
        {
            case NSScrollWheel:
            case NSLeftMouseDown:
            case NSLeftMouseUp:
            case NSLeftMouseDragged:
            case NSMouseMoved:
            case NSRightMouseDown:
            case NSRightMouseUp:
            case NSRightMouseDragged:
                return;
                break;
            default:
                break;
        }
    }
    
    [super sendEvent:theEvent];
}

@end
