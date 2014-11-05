//
//  Download.m
//  gkedit
//
//  Created by apple on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "LoadProgress.h"

#import "Util.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation LoadProgress


@synthesize loadstate;
@synthesize specifyApp;
@synthesize tptnode;
@synthesize loadprogressCallBack;
@synthesize _nNum;

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) dealloc
{
    self.specifyApp=nil;
    self.tptnode=nil;
    self.loadprogressCallBack=nil;
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) progress
{
 }

-(void) main
{
    self._nNum=0;
    NSAutoreleasePool* pool=[[NSAutoreleasePool alloc]init];
    
    while (![self isCancelled]) {
        
        [self progress];
        [NSThread sleepForTimeInterval:1];
    }
    
END:
    
    [pool release];
}

-(void) callback:(DownloadState)retval progress:(double)progress retstr:(NSString*)retstr prompt:(NSString*)prompt
{
    if (![self isCancelled]) {
        loadstate=retval;
        loadprogressCallBack(retval,progress,retstr,prompt);
    }
}

@end
