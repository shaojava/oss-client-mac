#import <Foundation/Foundation.h>
#import "Common.h"

@interface ManagerBase : NSObject
{
    BOOL                bOut;
    BOOL                bFinish;
    NSLock*             pLock;
    NSMutableArray*     pArray;
    NSOperationQueue*   pQueue;
    NSThread*           pThread;
    ULONGLONG           ullSize;
    ULONGLONG           ullSizeTime;
    NSInteger           nMax;
    NSInteger           nAdding;
    ULONGLONG           ullResetTime;
}

@property(nonatomic)BOOL bOut;
@property(nonatomic)BOOL bFinish;
@property(nonatomic,retain)NSLock* pLock;
@property(nonatomic,retain)NSMutableArray* pArray;
@property(nonatomic,retain)NSOperationQueue* pQueue;
@property(nonatomic,retain)NSThread* pThread;
@property(nonatomic,assign)ULONGLONG ullSize;
@property(nonatomic,assign)ULONGLONG ullSizeTime;
@property(nonatomic,assign)NSInteger nMax;
@property(nonatomic)NSInteger nAdding;
@property(nonatomic)ULONGLONG ullResetTime;

-(id)init;
-(void)uninit;
-(void)SetMax:(NSInteger)max;
-(void)StopAll;
-(void)CheckFinishorError;
-(ULONGLONG)GetSpeed;
-(ULONGLONG)GetSpeed:(NSString*)bucket object:(NSString*)object;
-(ULONGLONG)GetOffset:(NSString*)bucket object:(NSString*)object;
-(NSMutableArray*)GetAll;
-(void)startAdding;
-(void)finishAdding;

@end
