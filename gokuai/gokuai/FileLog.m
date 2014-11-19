#import "FileLog.h"
#import "Util.h"
#import "JSONKit.h"

#define MaxMem  500

@implementation FileLog

@synthesize arrayLog;
@synthesize pFilehandle;

+(FileLog*)shareFileLog
{
    static FileLog* shareFileLogInstance = nil;
    static dispatch_once_t onceFileLogToken;
    dispatch_once(&onceFileLogToken, ^{
        NSDate *today =[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSLocale* locale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString * dateString = [formatter stringFromDate:today];
        [locale release];
        [formatter release];
        NSString * path=[NSString stringWithFormat:@"%@/%@.log",[Util getAppDelegate].strLogPath,dateString];
        shareFileLogInstance = [[FileLog alloc]initpath:path];
    });
    return shareFileLogInstance;
}

-(id)initpath:(NSString*)path
{
    if (self=[self init]) {
        if (![Util existfile:path]) {
            [Util createfile:path];
        }
        self.pFilehandle=[NSFileHandle fileHandleForWritingAtPath:path];
        self.arrayLog=[NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

-(void)log:(NSString*)msg add:(BOOL)add
{
    NSDate *today =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale* locale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString * dateString = [formatter stringFromDate:today];
    [locale release];
    [formatter release];
    NSString * temp=[NSString stringWithFormat:@"%@:%@\r\n",dateString,msg];
    if (self.pFilehandle) {
        [self.pFilehandle writeData:[temp dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (add) {
        [self.arrayLog addObject:temp];
        if (self.arrayLog.count>MaxMem) {
            [self.arrayLog removeObjectAtIndex:0];
        }
    }
}

-(NSString*)GetLog
{
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    NSMutableArray* arrayRet=[NSMutableArray array];
    for (NSString* item in self.arrayLog) {
        NSMutableDictionary* dicRet=[NSMutableDictionary dictionary];
        [dicRet setValue:item forKey:@"msg"];
        [arrayRet addObject:dicRet];
    }
    [dicRetlist setValue:arrayRet forKey:@"list"];
    return [dicRetlist JSONString];
}

@end
