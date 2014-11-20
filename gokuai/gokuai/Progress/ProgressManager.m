#import "ProgressManager.h"

@implementation ProgressManager

@synthesize strRet;
@synthesize bProgressClose;

-(id) init
{
    if (self=[super init]) {
        _progressQueue=[[NSOperationQueue alloc]init];
        [_progressQueue setMaxConcurrentOperationCount:12];
        self.strRet=@"";
        self.bProgressClose=NO;
    }
    return self;
}

-(void) dealloc
{
    [_progressQueue release];
    _progressQueue=nil;
    strRet=nil;
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
    self.strRet=@"";
    [_progressQueue addOperation:progress];
}

@end
