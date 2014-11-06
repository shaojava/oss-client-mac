
#import "CallbackThread.h"

@interface UploadCallbackThread : CallbackThread

-(id)init;
-(void)run;
-(void)SendCallbackInfo:(TransTaskItem*)item;
-(void)SendCallbackInfos;

@end
