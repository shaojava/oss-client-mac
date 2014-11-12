#import "ProgressManager.h"

@implementation ProgressManager

-(id) init
{
    if (self=[super init]) {
        _progressQueue=[[NSOperationQueue alloc]init];
        [_progressQueue setMaxConcurrentOperationCount:12];
    }
    return self;
}

-(void) dealloc
{
    [_progressQueue release];
    _progressQueue=nil;
    [super dealloc];
}

+ (ProgressManager*) sharedInstance
{
    static ProgressManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[ProgressManager alloc] init];
	});
	return sharedInstance;
}

-(void) addProgress:(NSOperation*)progress
{
    [_progressQueue addOperation:progress];
}

@end
