#import <Cocoa/Cocoa.h>

@interface ProgressManager : NSObject{
    NSOperationQueue* _progressQueue;
    NSString* strRet;
    BOOL    bProgressClose;
}

@property(nonatomic,retain)NSString *strRet;
@property(nonatomic)BOOL bProgressClose;

+ (ProgressManager*) sharedInstance;
-(void)addProgress:(NSOperation*)progress;

@end
