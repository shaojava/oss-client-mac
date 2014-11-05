#import <Foundation/Foundation.h>
#import "ManagerBase.h"

@interface UploadManager : ManagerBase

-(id)init;
-(void)Run;
-(void)Stop:(NSString*)bucket object:(NSString*)object;
-(void)Delete:(NSString*)bucket object:(NSString*)object;
-(void)CheckFinish;

@end
