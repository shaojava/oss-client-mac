
#import "TaskBask.h"

@interface UploadTask : TaskBask
{
    NSFileHandle*   pIndexFileHandle;
    char*  pPartBuffer;
    NSMutableArray* pPartList;
}

@property(nonatomic,retain)NSFileHandle* pIndexFileHandle;
@property(nonatomic,retain)NSMutableArray* pPartList;

-(id)init:(TransTaskItem*)item;
-(void)Finish;
-(void)FinishIndex:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size etag:(NSString*)etag;
-(void)ErrorIndex:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size error:(NSInteger)error msg:(NSString*)msg;
-(BOOL)CheckMultipart;
-(BOOL)CreateMultipartFile;
-(BOOL)DeleteMultipartFile;
-(void)SaveMultipartFile;
-(NSInteger)GetUploadIndex:(ULONGLONG *)pos size:(ULONGLONG *)size;
-(NSInteger)CheckIndex:(ULONGLONG)pos;
-(void)TaskError:(NSInteger)error msg:(NSString*)msg;
-(void)ResetUploadId;

-(void)CheckPeer;
-(void)CheckDeleteFile;

-(void)callbackUrlInfo:(RegularItem*)item;

@end
