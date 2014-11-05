

#import "MyTimer.h"
#import "Util.h"
#import "AppDelegate.h"

@implementation MyTimer

@synthesize thread;

-(id)init
{
    if (self=[super init]) {
        self.thread = [[[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil] autorelease];
        [self.thread start];
    }
    return self;
}

-(void)exit
{
    
}

-(void)dealloc
{
    [thread cancel];
    [thread release];
    [super dealloc];
}

-(void)run
{
    CFAbsoluteTime timericonrun = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime timerspeed = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime timercount = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime timerupdate = CFAbsoluteTimeGetCurrent();
    while (TRUE) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
            if (now-timericonrun>1) {
              
                timericonrun=now;
            }
            if (now-timerspeed>2) {
                
                timerspeed=now;
            }
            if (now-timercount>4) {
                
                timercount=now;
            }
            if (now-timerupdate>3600) {
                
                timerupdate=now;
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            [pool release];
        }
        [NSThread sleepForTimeInterval:1];
    }
}

@end
