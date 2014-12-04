//
//  AppUpdateWindowController.h
//  gokuai
//
//  Created by GouKuai on 12-11-20.
//
//

#import <Cocoa/Cocoa.h>

@interface AppUpdateWindowController : NSWindowController
{
    NSString *downloadProgress;     //下载进度
    NSString *appVersion;           //本地版本
    NSString *serVersion;           //最新版本
    IBOutlet NSProgressIndicator *appProgress;
}
@property (nonatomic,retain) NSString *downloadProgress;
@property (nonatomic,retain) NSString *appVersion; 
@property (nonatomic,retain) NSString *serVersion; 
@property (nonatomic,retain) IBOutlet NSProgressIndicator *appProgress;
@end
