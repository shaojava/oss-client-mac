

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
    CFAbsoluteTime timerupdate = CFAbsoluteTimeGetCurrent();
    while (TRUE) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
            if (now-timerupdate>3600) {
                GetUpdateXML *task=[[GetUpdateXML alloc]init:YES];
                [[Util getAppDelegate].taskqueue addOperation:task];
                [task release];
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
