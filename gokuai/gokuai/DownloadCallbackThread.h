
#import "CallbackThread.h"

@interface DownloadCallbackThread : CallbackThread

-(id)init;
-(void)run;
-(void)SendCallbackInfo:(TransTaskItem*)item;
-(void)SendCallbackInfos;

@end
