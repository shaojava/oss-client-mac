#import <Foundation/Foundation.h>

@interface FileLog : NSObject
{
    NSMutableArray* arrayLog;
    NSFileHandle* pFilehandle;
}

@property(nonatomic,retain)NSMutableArray* arrayLog;
@property(nonatomic,retain)NSFileHandle* pFilehandle;

+(FileLog*)shareFileLog;
-(id)initpath:(NSString*)path;
-(void)log:(NSString*)msg add:(BOOL)add;
-(NSString*)GetLog;

@end
