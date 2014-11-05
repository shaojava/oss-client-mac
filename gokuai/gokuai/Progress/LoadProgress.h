//
//  Download.h
//  gkedit
//
//  Created by apple on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _download_state_ {
    DS_Err,
    DS_Int,
    DS_Ing,
    DS_Cancel,
    DS_Done,
}DownloadState;


@class transportnode;

@interface LoadProgress : NSOperation {    
    DownloadState loadstate;
    NSString* specifyApp;
    transportnode* tptnode;
    NSInteger   _nNum;
    void(^loadprogressCallBack)(DownloadState retvalue,double progress,NSString* retstring,NSString* prompt);
}

@property(nonatomic,assign) DownloadState loadstate;
@property(nonatomic,retain) NSString* specifyApp;
@property(nonatomic,retain) transportnode* tptnode;
@property(nonatomic)NSInteger _nNum;

/*
 * retvalue: DownloadState
 * retstring: "已下载24%，240 kb/s" if ok, "" otherwise
 */
@property(nonatomic,copy) void(^loadprogressCallBack)(DownloadState retvalue,double progress,NSString* retstring,NSString* prompt);

@end