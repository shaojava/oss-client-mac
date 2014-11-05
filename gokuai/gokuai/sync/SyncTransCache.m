#import "SyncTransCache.h"
#import "Util.h"


@implementation SyncTransCache

@synthesize cachepath;

+(SyncTransCache *)shareSyncTransCache
{
    static SyncTransCache * sharedSyncCacheInstance = nil;
    static dispatch_once_t onceSyncCacheToken;
    dispatch_once(&onceSyncCacheToken, ^{
        
    });
    return sharedSyncCacheInstance;
}

-(id)initpath:(NSString*)path
{
    if (self = [super init])
    {
        self.cachepath=path;
        [Util createfolder:self.cachepath];
        [self removeerrorfile];
    }
    return self;
}

-(void) dealloc
{
    self.cachepath=nil;
    [super dealloc];
}

-(BOOL)copyfile:(NSString*)srcpath
         topath:(NSString*)topath
{
    if ([Util existfile:topath])
    {
        return YES;
    }
    else
    {
        return [Util copyfileneedtemp:srcpath newfile:topath];
    }
}


-(void)timeremovefile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *dirArray= [manager contentsOfDirectoryAtPath:self.cachepath error:NULL];
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    NSInteger time_spin=15;
    for(int i = 0; i < [dirArray count];i++)
    {
        CFAbsoluteTime now=CFAbsoluteTimeGetCurrent();
        if (now - time > time_spin) {
            return;
        }
        NSString *filename=[dirArray objectAtIndex:i];
        NSString *temppath=[NSString stringWithFormat:@"%@/%@",self.cachepath,filename];
        NSRange range=[temppath rangeOfString:@"_ok"];
        if (range.location!=NSNotFound)
        {
            continue;
        }
        [Util deletefile:temppath];
    }
}

-(BOOL)checkdownloaderror:(NSString *)path
{
    NSString *fullpath=[NSString stringWithFormat:@"%@_error",path];
    BOOL ret=[Util existfile:fullpath];
    if (ret) {
        unsigned long long filetime=[Util filemodifytime:fullpath];
        unsigned long long time = [[NSDate date] timeIntervalSince1970];
        if (time-filetime>600) {
            [Util deletefile:fullpath];
        }
    }
    return ret;
}
-(void)clear
{
    [Util deletefile:self.cachepath];
}

-(void)removeerrorfile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *dirArray= [manager contentsOfDirectoryAtPath:self.cachepath error:NULL];
    for(int i = 0; i < [dirArray count];i++)
    {
        NSString *filename=[dirArray objectAtIndex:i];
        NSString *temppath=[NSString stringWithFormat:@"%@/%@",self.cachepath,filename];
        NSRange range=[temppath rangeOfString:@"_error"];
        if (range.location!=NSNotFound)
        {
            [Util deletefile:temppath];
        }
    }
}
@end
