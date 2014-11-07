#import <Foundation/Foundation.h>
#import "ManagerBase.h"

@interface DownloadManager : ManagerBase

-(id)init;
-(void)Run;
-(void)Stop:(NSString*)fullpath;
-(void)Delete:(NSString*)fullpath;
-(void)CheckFinish;

@end
