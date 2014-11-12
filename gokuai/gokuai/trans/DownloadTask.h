
#import "TaskBask.h"

#define OSSEXT      @".ossdownload"
#define OSSTMP      @"osstmp"

@interface DownloadTask : TaskBask
{
    NSFileHandle*   pIndexFileHandle;
    NSFileHandle*   pFileHandle;
    ULONGLONG       ullWriteTime;
}

@property(nonatomic,retain)NSFileHandle* pIndexFileHandle;
@property(nonatomic,retain)NSFileHandle* pFileHandle;
@property(nonatomic)ULONGLONG ullWriteTime;

-(id)init:(TransTaskItem*)item;
-(BOOL)CreateFile;
-(void)CloseFile;
-(void)CheckDeleteFile;
-(void)DeleteTmpFile;
-(void)Finish;
-(BOOL)WriteFile:(char *)data pos:(ULONGLONG)pos size:(NSInteger)size;
-(BOOL)GetDownloadIndex:(ULONGLONG*)pos size:(ULONGLONG*)size num:(NSInteger)num;
-(void)TaskError:(NSInteger)error msg:(NSString*)msg;
-(void)ErrorIndex:(ULONGLONG)pos size:(ULONGLONG)size error:(NSInteger)error msg:(NSString*)msg;
-(void)SaveIndexFile;
-(NSString*)GetTmpPath;
-(void)CheckPeer;

@end
