#import <Foundation/Foundation.h>
#import "NetworkDef.h"
#import "DataLocator.h"

@interface TaskBask : NSOperation
{
    TransTaskItem*  pItem;
    NSMutableArray* listPeer;
    NSLock*         pLocksc;
    NSLock*         pFilesc;
    NSOperationQueue*   pQueue;
    DataLocator*    pFinish;
    DataLocator*    pUnFinish;
    NSInteger       nMax;
    BOOL            bStop;
    BOOL            bDelete;
    ULONGLONG       ullTranssize;
    ULONGLONG       ullStarttime;
    ULONGLONG       ullRuntime;
    ULONGLONG       ullPiecesize;
    ULONGLONG       ullSpeed;
}

@property(nonatomic,retain)TransTaskItem* pItem;
@property(nonatomic,retain)NSMutableArray* listPeer;
@property(nonatomic,retain)NSLock* pLocksc;
@property(nonatomic,retain)NSLock* pFilesc;
@property(nonatomic,retain)NSOperationQueue* pQueue;
@property(nonatomic,retain)DataLocator* pFinish;
@property(nonatomic,retain)DataLocator* pUnFinish;
@property(nonatomic)NSInteger nMax;
@property(nonatomic)BOOL bStop;
@property(nonatomic)BOOL bDelete;
@property(nonatomic)ULONGLONG ullTranssize;
@property(nonatomic)ULONGLONG ullStarttime;
@property(nonatomic)ULONGLONG ullRuntime;
@property(nonatomic)ULONGLONG ullPiecesize;
@property(nonatomic)ULONGLONG ullSpeed;

-(id)init:(TransTaskItem*)item;
-(BOOL)Stop:(BOOL)bdelete;
-(ULONGLONG)GetSpeed;
-(BOOL)CheckFinish;
-(NSInteger)GetPeerNum;

@end
