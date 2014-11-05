#import "DownloadManager.h"
#import "TaskBask.h"

@implementation DownloadManager

-(id)init
{
    if (self = [super init])
    {
        self.pThread = [[[NSThread alloc] initWithTarget:self selector:@selector(Run) object:nil] autorelease];
        [self.pThread start];
    }
    return self;
}

-(void)Run
{
    while (!self.bOut) {
        
        
    }
}

-(void)Stop:(NSString*)fullpath
{
    [self.pLock lock];
    for (TaskBask * item in self.pArray) {

    }
    
    
    [self.pLock unlock];
}

-(void)Delete:(NSString*)fullpath
{
    
}

@end
