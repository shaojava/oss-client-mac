

#import <Cocoa/Cocoa.h>

@interface ProgressManager : NSObject{
    NSOperationQueue* _progressQueue;
}

+ (ProgressManager*) sharedInstance;
-(void) addProgress:(NSOperation*)progress;

@end
