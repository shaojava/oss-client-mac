#import <Cocoa/Cocoa.h>

@interface ProgressManager : NSObject{
    NSOperationQueue* _progressQueue;
    NSString* strRet;
    BOOL    bProgressClose;
    NSInteger nCount;
    NSString* strFilename;
}

@property(nonatomic,retain)NSString *strRet;
@property(nonatomic,retain)NSString *strFilename;
@property(nonatomic)BOOL bProgressClose;

@property(nonatomic)NSInteger nCount;

+ (ProgressManager*) sharedInstance;
-(void)addProgress:(NSOperation*)progress;

@end
