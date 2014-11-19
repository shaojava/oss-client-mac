#import <Foundation/Foundation.h>
#import "TaskBask.h"
#import "Common.h"
#import "ASIHTTPRequest.h"

@interface PeerBase : NSObject
{
    id          pTask;
    NSString*   strHost;
    NSString*   strBucket;
    NSString*   strObject;
    NSString*   strHeader;
    BOOL        bStart;
    BOOL        bStop;
    NSInteger   nIndex;
    ULONGLONG   ullPos;
    ULONGLONG   ullSize;
    ASIHTTPRequest* pRequest;
}
@property(nonatomic,retain)id pTask;
@property(nonatomic,retain)NSString* strHost;
@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strHeader;
@property(nonatomic,retain)NSString* strObject;
@property(nonatomic)BOOL bStart;
@property(nonatomic)BOOL bStop;
@property(nonatomic,assign)NSInteger nIndex;
@property(nonatomic,assign)ULONGLONG ullPos;
@property(nonatomic,assign)ULONGLONG ullSize;
@property(nonatomic,retain)ASIHTTPRequest* pRequest;

-(void)Stop;
-(BOOL)IsIdle;

@end
