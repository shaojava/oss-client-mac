//
//  WebView+EventEnbled.h
//  GoKuai
//
//  Created by GoKuai on 1/6/14.
//
//

#import <Cocoa/Cocoa.h>

@interface WindowEve : NSWindow {
    BOOL _disable;
}

-(void) disableWindowEx;
-(void) enableWindowEx;

@end
