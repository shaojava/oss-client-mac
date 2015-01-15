

#import "TransPortDB.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "Util.h"
#import "NSStringExpand.h"

#define SQLVERSION  @"1.0.0.0"

@implementation TransPortDB

@synthesize dbQueue;

+(TransPortDB*)shareTransPortDB
{
    static TransPortDB* shareTransPortDBInstance = nil;
    static dispatch_once_t onceTransPortDBToken;
    dispatch_once(&onceTransPortDBToken, ^{
        shareTransPortDBInstance = [[TransPortDB alloc]init];
    });
    return shareTransPortDBInstance;
}
#pragma mark-
#pragma mark- 表的打开，创建和关闭
-(void)OpenPath:(NSString*)path
{
    self.dbQueue= [FMDatabaseQueue databaseQueueWithPath:path];
    [self CreateTable];
    [self ChangeOld];
    [self ClearTrans];
    [self ResetError];
    [self ResetStart];
}

-(void)CreateTable
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         BOOL res = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Download(id INTEGER PRIMARY KEY AUTOINCREMENT,hash char[40],fullpath varchar[1024] COLLATE NOCASE,host varchar[1024] COLLATE NOCASE,bucket varchar[64] COLLATE NOCASE,object varchar[1024] COLLATE NOCASE,filesize bigint,status int,offset bigint,actlast bigint,errornum int,errormsg varchar[1024]);"];
         if (!res)
             NSLog(@"error to create Download");
         res = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Upload(id INTEGER PRIMARY KEY AUTOINCREMENT,pathhash char[40],host varchar[1024] COLLATE NOCASE,bucket varchar[64] COLLATE NOCASE,object varchar[1024] COLLATE NOCASE,fullpath varchar[1024] COLLATE NOCASE,filesize bigint,status int,offset bigint,actlast bigint,uploadid varchar[40],errornum int,errormsg varchar[1024]);"];
         if (!res)
             NSLog(@"error to create Upload");
         res = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS transsqlversion(version char[20]);"];
         if (res){
             NSInteger count=0;
             NSString *sql =@"select count(*) as cnt from transsqlversion";
             FMResultSet *rs = [db executeQuery:sql];
             while ([rs next])
             {
                 count=[rs intForColumn:@"cnt"];
                 break;
             }
             [rs close];
             if (count==0) {
                 NSString* sql=[NSString stringWithFormat:@"insert into transsqlversion values('%@');",SQLVERSION];
                 [db executeUpdate:sql];
             }
         }
         [db executeUpdate:@"CREATE UNIQUE INDEX ifullpath on Download(fullpath);"];
         [db executeUpdate:@"CREATE INDEX idstatus on Download(status,actlast,id);"];
         [db executeUpdate:@"CREATE UNIQUE INDEX ipathhash on Upload(pathhash);"];
         [db executeUpdate:@"CREATE INDEX iustatus on Upload(status,actlast,id);"];
     }];
}

-(void)ChangeOld
{
    
}

-(void)ClearTrans
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"delete from Download where status=%d;",TRANSTASK_FINISH];
         [db executeUpdate:sql];
         sql =[NSString stringWithFormat:@"delete from Upload where status=%d;",TRANSTASK_FINISH];
         [db executeUpdate:sql];
     }];
}

-(void)Close
{
    [self.dbQueue close];
}
#pragma mark-
#pragma mark- 传输表的操作
-(BOOL)Add_Download:(TransTaskItem*)item
{
    __block BOOL ret=NO;
    NSString *robject=[item.strObject stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *rfullpath=[item.strFullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"insert into Download(hash,fullpath,host,bucket,object,filesize,status,offset,actlast,errornum,errormsg) values('%@','%@','%@','%@','%@','%llu','%ld','%llu','0','0','');",item.strPathhash,rfullpath,item.strHost,item.strBucket,robject,item.ullFilesize,item.nStatus,item.ullOffset];
         ret=[db executeUpdate:sql];
         if (!ret) {
             sql =[NSString stringWithFormat:@"update Download set hash='%@',host='%@',bucket='%@',object='%@',filesize='%llu',status='%d',offset='0',actlast='0',errornum='0',errormsg='' where fullpath='%@';",item.strPathhash,item.strHost,item.strBucket,robject,item.ullFilesize,item.nStatus,rfullpath];
             ret=[db executeUpdate:sql];
         }
     }];
    return ret;
}

-(BOOL)Update_DownloadStart:(NSString*)fullpath
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set status='%d',actlast='0',errornum='0',errormsg='' where fullpath='%@';",TRANSTASK_NORMAL,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_DownloadStartActlast:(NSString*)fullpath
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ULONGLONG time = (ULONGLONG)[[NSDate date] timeIntervalSince1970];
         NSString *sql =[NSString stringWithFormat:@"update Download set status='%d',actlast='%llu',errornum='0',errormsg='' where fullpath='%@';",TRANSTASK_START,time,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_DownloadStatus:(NSString*)fullpath status:(NSInteger)status
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set status='%d',actlast='0',errornum='0',errormsg='' where fullpath='%@';",status,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_DownloadOffset:(NSString*)fullpath offset:(ULONGLONG)offset
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set offset='%llu' where fullpath='%@';",offset,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_DownloadOffsetFinish:(NSString *)fullpath offset:(unsigned long long)offset
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set offset='%llu',status='%d' where fullpath='%@';",offset,TRANSTASK_FINISH,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_DownloadActlast:(NSString*)fullpath
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ULONGLONG time = (ULONGLONG)[[NSDate date] timeIntervalSince1970];
         NSString *sql =[NSString stringWithFormat:@"update Download set actlast='%llu' where fullpath='%@';",time,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_DownloadActlast:(NSString *)fullpath time:(ULONGLONG)time
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set actlast='%llu' where fullpath='%@';",time,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_DownloadError:(NSString*)fullpath error:(NSInteger)error msg:(NSString*)msg
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *rmsg=[msg stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set status='%d',errornum='%ld',errormsg='%@' where fullpath='%@';",TRANSTASK_ERROR,error,rmsg,rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Delete_Download:(NSString*)fullpath
{
    __block BOOL ret=NO;
    NSString *rfullpath=[fullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"delete from Download where fullpath='%@';",rfullpath];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Delete_Download:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object
{
    __block BOOL ret=NO;
    NSString *rhost=[host stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *rbucket=[bucket stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *robject=[object stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"delete from Download where host='%@' and bucket='%@' and (object='%@' or object like '%@%%');",rhost,rbucket,robject,robject];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}
-(NSMutableArray*)Get_AllDownload:(NSInteger)start count:(NSInteger)count
{
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select * from Download order by id asc LIMIT %ld OFFSET %ld;",count,start];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             TransTaskItem *item=[[TransTaskItem alloc]init];
             item.strPathhash=[rs stringForColumn:@"hash"];
             item.strFullpath=[rs stringForColumn:@"fullpath"];
             item.strHost=[rs stringForColumn:@"host"];
             item.strBucket=[rs stringForColumn:@"bucket"];
             item.strObject=[rs stringForColumn:@"object"];
             item.ullFilesize=[rs longLongIntForColumn:@"filesize"];
             item.ullOffset=[rs longLongIntForColumn:@"offset"];
             item.nStatus=[rs intForColumn:@"status"];
             item.nErrorNum=[rs intForColumn:@"errornum"];
             item.strMsg=[rs stringForColumn:@"errormsg"];
             if (item.ullOffset>item.ullFilesize) {
                 item.ullOffset=item.ullFilesize;
             }
             [all addObject:item];
             [item release];
         }
         [rs close];
     }];
    return all;
}

-(TransTaskItem*)Get_Download
{
    TransTaskItem *item=[[[TransTaskItem alloc]init] autorelease];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select * from Download where status='%d' order by actlast asc,id asc limit 1;",TRANSTASK_NORMAL];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             item.strPathhash=[rs stringForColumn:@"hash"];
             item.strFullpath=[rs stringForColumn:@"fullpath"];
             item.strHost=[rs stringForColumn:@"host"];
             item.strBucket=[rs stringForColumn:@"bucket"];
             item.strObject=[rs stringForColumn:@"object"];
             item.ullFilesize=[rs longLongIntForColumn:@"filesize"];
             item.ullOffset=[rs longLongIntForColumn:@"offset"];
             item.nStatus=[rs intForColumn:@"status"];
             item.nErrorNum=[rs intForColumn:@"errornum"];
             item.strMsg=[rs stringForColumn:@"errormsg"];
             if (item.ullOffset>item.ullFilesize) {
                 item.ullOffset=item.ullFilesize;
             }
         }
         [rs close];
     }];
    return item;
}

-(BOOL)Check_DownloadFinish
{
    __block BOOL ret=YES;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select * from Download where status!='%d' limit 1;",TRANSTASK_FINISH];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=NO;
         }
         [rs close];
     }];
    return ret;
}

-(BOOL)StartDownloadAll
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set status='%d',errornum='0',errormsg='',actlast='0' where status!='%d' and status!='%d' and status!='%d';",TRANSTASK_NORMAL,TRANSTASK_NORMAL,TRANSTASK_START,TRANSTASK_FINISH];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)StopDownloadAll
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set status='%d',errornum='0',errormsg='',actlast='0' where status!='%d' and status!='%d';",TRANSTASK_STOP,TRANSTASK_STOP,TRANSTASK_FINISH];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)DeleteDownloadAll
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ret=[db executeUpdate:@"delete from Download"];
     }];
    return ret;
}

-(BOOL)DeleteDownloadAllFinish
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ret=[db executeUpdate:[NSString stringWithFormat:@"delete from Download where status=%d",TRANSTASK_FINISH]];
     }];
    return ret;
}

-(BOOL)Add_Upload:(TransTaskItem*)item
{
    __block BOOL ret=NO;
    NSString *robject=[item.strObject stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *rfullpath=[item.strFullpath stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"insert into Upload(pathhash,host,bucket,object,fullpath,filesize,status,offset,actlast,uploadid,errornum,errormsg) values('%@','%@','%@','%@','%@','%llu','%ld','%llu','0','%@','0','');",item.strPathhash,item.strHost,item.strBucket,robject,rfullpath,item.ullFilesize,item.nStatus,item.ullOffset,item.strUploadId];
         ret=[db executeUpdate:sql];
         if (!ret) {
             sql =[NSString stringWithFormat:@"update Upload set host='%@',bucket='%@',object='%@',fullpath='%@',filesize='%llu',status='%d',offset='0',actlast='0',uploadid='%@',errornum='0',errormsg='' where pathhash='%@';",item.strHost,item.strBucket,robject,rfullpath,item.ullFilesize,item.nStatus,item.strUploadId,item.strPathhash];
             ret=[db executeUpdate:sql];
         }
     }];
    return ret;
}

-(BOOL)Update_UploadStart:(NSString*)bucket object:(NSString*)object
{
    __block BOOL ret=NO;
    NSString *robject=[object stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set status='%d',actlast='0',errornum='0',errormsg='' where bucket='%@' and object='%@';",TRANSTASK_NORMAL,bucket,robject];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadStartActlast:(NSString*)pathhash
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ULONGLONG time = (ULONGLONG)[[NSDate date] timeIntervalSince1970];
         NSString *sql =[NSString stringWithFormat:@"update Upload set status='%d',actlast='%llu',errornum='0',errormsg='' where pathhash='%@';",TRANSTASK_START,time,pathhash];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadStatus:(NSString*)pathhash status:(NSInteger)status
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set status='%d' where pathhash='%@';",status,pathhash];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadStatus:(NSString*)bucket object:(NSString*)object status:(NSInteger)status
{
    __block BOOL ret=NO;
    NSString *robject=[object stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set status='%d' where bucket='%@' and object='%@';",status,bucket,robject];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadOffset:(NSString*)pathhash offset:(ULONGLONG)offset
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set offset='%llu' where pathhash='%@';",offset,pathhash];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadActlast:(NSString*)pathhash
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ULONGLONG time = (ULONGLONG)[[NSDate date] timeIntervalSince1970];
         NSString *sql =[NSString stringWithFormat:@"update Upload set actlast='%llu' where pathhash='%@';",time,pathhash];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadActlast:(NSString*)pathhash time:(ULONGLONG)time
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set actlast='%llu' where pathhash='%@';",time,pathhash];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadUploadId:(NSString*)pathhash uploadid:(NSString*)uploadid
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set uploadid='%@' where pathhash='%@';",uploadid,pathhash];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Update_UploadError:(NSString*)pathhash error:(NSInteger)error msg:(NSString*)msg
{
    __block BOOL ret=NO;
    NSString *rmsg=[msg stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set status='%d',errornum='%ld',errormsg='%@' where pathhash='%@';",TRANSTASK_ERROR,error,rmsg,pathhash];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)Delete_Upload:(NSString*)bucket object:(NSString*)object
{
    __block BOOL ret=NO;
    NSString *robject=[object stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"delete from Upload where bucket='%@' and object='%@';",bucket,robject];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(NSMutableArray*)Get_AllUpload:(NSInteger)start count:(NSInteger)count
{
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select * from Upload order by id asc LIMIT %ld OFFSET %ld;",count,start];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             TransTaskItem *item=[[TransTaskItem alloc]init];
             item.strPathhash=[rs stringForColumn:@"pathhash"];
             item.strFullpath=[rs stringForColumn:@"fullpath"];
             item.strHost=[rs stringForColumn:@"host"];
             item.strBucket=[rs stringForColumn:@"bucket"];
             item.strObject=[rs stringForColumn:@"object"];
             item.ullFilesize=[rs longLongIntForColumn:@"filesize"];
             item.ullOffset=[rs longLongIntForColumn:@"offset"];
             item.nStatus=[rs intForColumn:@"status"];
             item.strUploadId=[rs stringForColumn:@"uploadid"];
             item.nErrorNum=[rs intForColumn:@"errornum"];
             item.strMsg=[rs stringForColumn:@"errormsg"];
             if (item.ullOffset>item.ullFilesize) {
                 item.ullOffset=item.ullFilesize;
             }
             [all addObject:item];
             [item release];
         }
         [rs close];
     }];
    return all;
}
-(TransTaskItem*)Get_Upload
{
    TransTaskItem *item=[[[TransTaskItem alloc]init] autorelease];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select * from Upload where status='%d' order by actlast asc,id asc limit 1;",TRANSTASK_NORMAL];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             item.strPathhash=[rs stringForColumn:@"pathhash"];
             item.strFullpath=[rs stringForColumn:@"fullpath"];
             item.strHost=[rs stringForColumn:@"host"];
             item.strBucket=[rs stringForColumn:@"bucket"];
             item.strObject=[rs stringForColumn:@"object"];
             item.ullFilesize=[rs longLongIntForColumn:@"filesize"];
             item.ullOffset=[rs longLongIntForColumn:@"offset"];
             item.nStatus=[rs intForColumn:@"status"];
             item.strUploadId=[rs stringForColumn:@"uploadid"];
             item.nErrorNum=[rs intForColumn:@"errornum"];
             item.strMsg=[rs stringForColumn:@"errormsg"];
             if (item.ullOffset>item.ullFilesize) {
                 item.ullOffset=item.ullFilesize;
             }
         }
         [rs close];
     }];
    return item;
}
-(BOOL)Check_UploadFinish
{
    __block BOOL ret=YES;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select * from Upload where status!='%d' limit 1;",TRANSTASK_FINISH];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=NO;
         }
         [rs close];
     }];
    return ret;
}
-(BOOL)StartUploadAll
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set status='%d',errornum='0',errormsg='',actlast='0' where status!='%d' and status!='%d' and status!='%d';",TRANSTASK_NORMAL,TRANSTASK_NORMAL,TRANSTASK_START,TRANSTASK_FINISH];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)StopUploadAll
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set status='%d',errornum='0',errormsg='',actlast='0' where status!='%d' and status!='%d';",TRANSTASK_STOP,TRANSTASK_STOP,TRANSTASK_FINISH];
         ret=[db executeUpdate:sql];
     }];
    return ret;
}

-(BOOL)DeleteUploadAll
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ret=[db executeUpdate:@"delete from Upload;"];
     }];
    return ret;
}

-(BOOL)DeleteUploadAllFinish
{
    __block BOOL ret=NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         ret=[db executeUpdate:[NSString stringWithFormat:@"delete from Upload where status=%d;",TRANSTASK_FINISH]];
     }];
    return ret;
}

-(NSInteger)GetUploadCount
{
    __block NSInteger ret=0;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=@"select count(*) as 'icount' from Upload;";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs intForColumn:@"icount"];
         }
         [rs close];
     }];
    return ret;
}

-(NSInteger)GetDownloadCount
{
    __block NSInteger ret=0;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=@"select count(*) as 'icount' from Download;";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs intForColumn:@"icount"];
         }
         [rs close];
     }];
    return ret;
}

-(NSInteger)GetUploadFinishCount
{
    __block NSInteger ret=0;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select count(*) as 'icount' from Upload where status='%d';",TRANSTASK_FINISH];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret+=[rs intForColumn:@"icount"];
         }
         [rs close];
     }];
    return ret;
}
-(NSInteger)GetDownloadFinishCount
{
    __block NSInteger ret=0;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"select count(*) as 'icount' from Download where status='%d';",TRANSTASK_FINISH];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret+=[rs intForColumn:@"icount"];
         }
         [rs close];
     }];
    return ret;
}
-(void)ResetError
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set errornum='0',actlast='0',status='%d' where status>='%d';",TRANSTASK_NORMAL,TRANSTASK_ERROR];
         [db executeUpdate:sql];
         sql =[NSString stringWithFormat:@"update Upload set errornum='0',actlast='0',status='%d' where status>='%d';",TRANSTASK_NORMAL,TRANSTASK_ERROR];
         [db executeUpdate:sql];
     }];
}

-(void)ResetDownloadError
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set errornum='0',actlast='0',status='%d' where status>='%d';",TRANSTASK_NORMAL,TRANSTASK_ERROR];
         [db executeUpdate:sql];
     }];
}

-(void)ResetUploadError
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Upload set errornum='0',actlast='0',status='%d' where status>='%d';",TRANSTASK_NORMAL,TRANSTASK_ERROR];
         [db executeUpdate:sql];
     }];
}

-(void)ResetErrorTime
{
    
}
-(void)ResetStart
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =[NSString stringWithFormat:@"update Download set status='%d',actlast='0' where status='%d';",TRANSTASK_NORMAL,TRANSTASK_START];
         [db executeUpdate:sql];
         sql =[NSString stringWithFormat:@"update Upload set status='%d',actlast='0' where status='%d';",TRANSTASK_NORMAL,TRANSTASK_START];
         [db executeUpdate:sql];
     }];
}

-(void)begin
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         [db executeUpdate:@"begin transaction;"];
     }];

}
-(void)end
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         [db executeUpdate:@"commit transaction;end transaction;"];
     }];
}
@end
