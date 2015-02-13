#import "SettingsDb.h"
#import "Common.h"
#import "Util.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

@implementation UserInfo

@synthesize strAccessID;
@synthesize strAccessKey;
@synthesize strArea;
@synthesize strHost;
@synthesize strPassword;

-(id)init
{
    if (self =[super init]) {
        self.strAccessID=@"";
        self.strAccessKey=@"";
        self.strArea=@"";
        self.strHost=@"";
        self.strPassword=@"";
    }
    return self;
}

-(void)dealloc
{
    self.strAccessID=nil;
    self.strAccessKey=nil;
    self.strArea=nil;
    self.strHost=nil;
    self.strPassword=nil;
    [super dealloc];
}

@end

@implementation SettingsDb

@synthesize dbQueue;
@synthesize bHttps;
@synthesize nDMax;
@synthesize nUMax;

+(SettingsDb*)shareSettingDb
{
    static SettingsDb* shareSettingDbInstance = nil;
    static dispatch_once_t onceSettingDbToken;
    dispatch_once(&onceSettingDbToken, ^{
        shareSettingDbInstance = [[SettingsDb alloc]initpath:[Util getAppDelegate].strUserDB];
    });
    return shareSettingDbInstance;
}

-(id)initpath:(NSString*)path
{
    if (self = [super init])
    {
        self.dbQueue= [FMDatabaseQueue databaseQueueWithPath:path];
        [self createtable];
        [self addnewrow];
    }
    return self;
}

-(void)dealloc
{
    [dbQueue release];
    [super dealloc];
}

-(void)createtable
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
    {
         [db executeUpdate:@"CREATE TABLE IF NOT EXISTS userinfo(accessid char[1000],accesskey char[1000],area char[1000],host char[1000],password char[40]);"];
         [db executeUpdate:@"CREATE TABLE IF NOT EXISTS settings(https int,dmax int,umax int,dpmax int,upmax int,uploadpath varchar[2000] COLLATE NOCASE,downloadpath varchar[2000] COLLATE NOCASE);"];
         NSInteger count=0;
         NSString *sql =@"select count(*) as cnt from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             count=[rs intForColumn:@"cnt"];
             break;
         }
         [rs close];
         if (count==0) {
             NSString* sql=@"insert into settings(https,dmax,umax,dpmax,upmax) values('0','5','5','5','5');";
             [db executeUpdate:sql];
         }
     }];
}

-(void) addnewrow
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         BOOL res = [db executeUpdate:@"ALTER TABLE settings add dpmax int;"];
         if (res)
         {
             [db executeUpdate:@"update settings set dpmax='5';"];
         }
         res = [db executeUpdate:@"ALTER TABLE settings add upmax int;"];
         if (res)
         {
             [db executeUpdate:@"update settings set upmax='5';"];
         }
         res = [db executeUpdate:@"ALTER TABLE settings add uploadpath varchar[2000] COLLATE NOCASE;"];
         if (res)
         {
             [db executeUpdate:@"update settings set uploadpath='';"];
         }
         res = [db executeUpdate:@"ALTER TABLE settings add downloadpath varchar[2000] COLLATE NOCASE;"];
         if (res)
         {
             [db executeUpdate:@"update settings set downloadpath='';"];
         }
     }];
}

-(void)close
{
    [self.dbQueue close];
}


-(void) clear_userinfo
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         [db executeUpdate:@"delete from userinfo;"];
     }];
}


-(void)setuserinfo:(UserInfo*)userinfo
{
    NSString* accessid=[userinfo.strAccessID stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString* accesskey=[userinfo.strAccessKey stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString* area=[userinfo.strArea stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString* host=[userinfo.strHost stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString* password=[userinfo.strPassword stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db)
    {
        NSString *sql =@"delete from userinfo;";
        [db executeUpdate:sql];
        sql=[NSString stringWithFormat:@"insert into userinfo(accessid,accesskey,area,host,password) values('%@','%@','%@','%@','%@');",accessid,accesskey,area,host,password];
         [db executeUpdate:sql];
     }];
}

-(UserInfo*)getuserinfo
{
    UserInfo *item=[[[UserInfo alloc]init] autorelease];
    [self.dbQueue inDatabase:^(FMDatabase *db)
    {
        NSString *sql=@"select * from userinfo;";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            item.strAccessID=[rs stringForColumn:@"accessid"];
            item.strAccessKey=[rs stringForColumn:@"accesskey"];
            item.strArea=[rs stringForColumn:@"area"];
            item.strHost=[rs stringForColumn:@"host"];
            item.strPassword=[rs stringForColumn:@"password"];
            break;
        }
        [rs close];
    }];
    return item;
}

-(void)setUserPassword:(NSString*)password
{
    NSString* rpassword=[password stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update userinfo set password='%@'",rpassword];
         [db executeUpdate:sql];
     }];
}

-(NSString*)getUserPassword
{
    __block NSString* ret=@"";
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select password from userinfo";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs stringForColumn:@"password"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setHost:(NSString*)host
{
    NSString* rhost=[host stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update userinfo set password='%@'",rhost];
         [db executeUpdate:sql];
     }];
}

-(void)deleteuserinfo
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=@"delete from userinfo;";
         [db executeUpdate:sql];
     }];
}

-(void)sethttps:(BOOL)value
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set https='%d'",value];
         [db executeUpdate:sql];
     }];
}

-(BOOL)gethttps
{
    __block BOOL ret=YES;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select https from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs boolForColumn:@"https"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setDMax:(NSInteger)value
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set dmax='%ld'",value];
         [db executeUpdate:sql];
     }];
}

-(NSInteger)getDMax
{
    __block NSInteger ret=5;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select dmax from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs intForColumn:@"dmax"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setUMax:(NSInteger)value
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set umax='%ld'",value];
         [db executeUpdate:sql];
     }]; 
}

-(NSInteger)getUMax
{
    __block NSInteger ret=5;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select umax from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs intForColumn:@"umax"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setDPMax:(NSInteger)value
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set dpmax='%ld'",value];
         [db executeUpdate:sql];
     }]; 
}

-(NSInteger)getDPMax
{
    __block NSInteger ret=5;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select dpmax from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs intForColumn:@"dpmax"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setUPMax:(NSInteger)value
{
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set upmax='%d'",value];
         [db executeUpdate:sql];
     }]; 
}

-(NSInteger)getUPMax
{
    __block NSInteger ret=5;
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select upmax from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs intForColumn:@"upmax"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setUploadPath:(NSString*)value
{
    NSString* rvalue=[value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set uploadpath='%@'",rvalue];
         [db executeUpdate:sql];
     }];
}

-(NSString*)getUploadPath
{
    __block NSString* ret=@"";
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select uploadpath from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs stringForColumn:@"uploadpath"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setDownloadPath:(NSString*)value
{
    NSString* rvalue=[value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set downloadpath='%@'",rvalue];
         [db executeUpdate:sql];
     }];
}

-(NSString*)getDownloadPath
{
    __block NSString* ret=@"";
    [self.dbQueue inDatabase:^(FMDatabase *db) 
     {
         NSString *sql =@"select downloadpath from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next]) 
         {
             ret=[rs stringForColumn:@"downloadpath"];
             break;
         }
         [rs close];
     }];
    return ret;
}

@end
