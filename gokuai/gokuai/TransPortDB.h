#import <Foundation/Foundation.h>
#import "NetworkDef.h"
@class  FMDatabaseQueue;

@interface TransPortDB : NSObject
{
    FMDatabaseQueue*    dbQueue;
}
@property(nonatomic, retain) FMDatabaseQueue* dbQueue;

+(TransPortDB*)shareTransPortDB;

#pragma mark-
#pragma mark- 表的打开，创建和关闭
-(void)OpenPath:(NSString*)path;
-(void)CreateTable;
-(void)ChangeOld;
-(void)ClearTrans;
-(void)Close;
#pragma mark-
#pragma mark- 传输表的操作
-(BOOL)Add_Download:(TransTaskItem*)item;
-(BOOL)Update_DownloadStart:(NSString*)fullpath;
-(BOOL)Update_DownloadStartActlast:(NSString*)fullpath;

-(BOOL)Update_DownloadStatus:(NSString*)fullpath status:(NSInteger)status;
-(BOOL)Update_DownloadOffset:(NSString*)fullpath offset:(ULONGLONG)offset;
-(BOOL)Update_DownloadOffsetFinish:(NSString *)fullpath offset:(unsigned long long)offset;
-(BOOL)Update_DownloadActlast:(NSString*)fullpath;
-(BOOL)Update_DownloadActlast:(NSString *)fullpath time:(ULONGLONG)time;
-(BOOL)Update_DownloadError:(NSString*)fullpath error:(NSInteger)error msg:(NSString*)msg;
-(BOOL)Delete_Download:(NSString*)fullpath;
-(BOOL)Delete_Download:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object;
-(NSMutableArray*)Get_AllDownload:(NSInteger)start count:(NSInteger)count;
-(TransTaskItem*)Get_Download;
-(BOOL)Check_DownloadFinish;
-(BOOL)StartDownloadAll;
-(BOOL)StopDownloadAll;
-(BOOL)DeleteDownloadAll;
-(BOOL)DeleteDownloadAllFinish;

-(BOOL)Add_Upload:(TransTaskItem*)item;
-(BOOL)Update_UploadStart:(NSString*)bucket object:(NSString*)object;
-(BOOL)Update_UploadStartActlast:(NSString*)pathhash;
-(BOOL)Update_UploadStatus:(NSString*)pathhash status:(NSInteger)status;
-(BOOL)Update_UploadStatus:(NSString*)bucket object:(NSString*)object status:(NSInteger)status;
-(BOOL)Update_UploadOffset:(NSString*)pathhash offset:(ULONGLONG)offset;
-(BOOL)Update_UploadActlast:(NSString*)pathhash;
-(BOOL)Update_UploadActlast:(NSString*)pathhash time:(ULONGLONG)time;
-(BOOL)Update_UploadUploadId:(NSString*)pathhash uploadid:(NSString*)uploadid;
-(BOOL)Update_UploadError:(NSString*)pathhash error:(NSInteger)error msg:(NSString*)msg;
-(BOOL)Delete_Upload:(NSString*)bucket object:(NSString*)object;
-(NSMutableArray*)Get_AllUpload:(NSInteger)start count:(NSInteger)count;
-(TransTaskItem*)Get_Upload;
-(BOOL)Check_UploadFinish;
-(BOOL)StartUploadAll;
-(BOOL)StopUploadAll;
-(BOOL)DeleteUploadAll;
-(BOOL)DeleteUploadAllFinish;

-(NSInteger)GetUploadCount;
-(NSInteger)GetDownloadCount;
-(NSInteger)GetUploadFinishCount;
-(NSInteger)GetDownloadFinishCount;
-(void)ResetError;
-(void)ResetDownloadError;
-(void)ResetUploadError;
-(void)ResetErrorTime;
-(void)ResetStart;
-(void)begin;
-(void)end;

@end
