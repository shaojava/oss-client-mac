#import "SettingsDb.h"
#import "Common.h"
#import "Util.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "NSStringExpand.h"
#import "JSONKit.h"
#import "OSSRsa.h"
#import "NSDataExpand.h"


#define RAM_NAME	@"ram"
#define STS_NAME	@"sts"

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

@implementation RamInfo

@synthesize strKeyID;
@synthesize strSubKeyID;
@synthesize strSubSecret;
@synthesize ullCreateTime;


-(id)init
{
    if (self =[super init]) {
        self.strKeyID=@"";
        self.strSubKeyID=@"";
        self.strSubSecret=@"";
        self.ullCreateTime=0;
    }
    return self;
}

-(void)dealloc
{
    self.strKeyID=nil;
    self.strSubKeyID=nil;
    self.strSubSecret=nil;
    [super dealloc];
}


- (id)initWithJsonDictionary:(NSDictionary*)dictionary
{
    if (self = [self init])
    {
        [self setValueWithJson:dictionary];
    }
    return self;
}

-(NSDictionary*)dictionary
{
    NSMutableDictionary* dicRet=[NSMutableDictionary dictionary];
    [dicRet setValue:self.strKeyID forKey:@"keyid"];
    [dicRet setValue:self.strSubKeyID forKey:@"subkeyid"];
    [dicRet setValue:self.strSubSecret forKey:@"subsecret"];
    [dicRet setValue:[NSNumber numberWithLongLong:self.ullCreateTime] forKey:@"createtime"];
    return dicRet;
}

-(void)setValueWithJson:(NSDictionary*) dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.strSubKeyID =[dictionary objectForKey:@"subkeyid"];
    if (self.strSubKeyID.length==0) {
        self.strSubKeyID=@"";
    }
    self.strSubSecret =[dictionary objectForKey:@"subsecret"];
    if (self.strSubSecret.length==0) {
        self.strSubSecret=@"";
    }
}
-(void)Encrypt
{
    NSString* device=[OSSRsa getcomputerid];
    NSString* devicehash=[device sha1HexDigest];
    NSData* ret=[OSSRsa CryptEncrypt:devicehash data:[self.strKeyID dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strKeyID=[ret base64Encoding];
    }
    ret=[OSSRsa CryptEncrypt:devicehash data:[self.strSubKeyID dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strSubKeyID=[ret base64Encoding];
    }
    ret=[OSSRsa CryptEncrypt:devicehash data:[self.strSubSecret dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strSubSecret=[ret base64Encoding];
    }
}
-(void)Decrypt
{
    NSString* device=[OSSRsa getcomputerid];
    NSString* devicehash=[device sha1HexDigest];
    NSData* ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strKeyID]];
    if (ret!=nil) {
        self.strKeyID=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
    ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strSubKeyID]];
    if (ret!=nil) {
        self.strSubKeyID=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
    ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strSubSecret]];
    if (ret!=nil) {
        self.strSubSecret=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
}

@end

@implementation StsInfo

@synthesize strKeyID;
@synthesize strSubKeyID;
@synthesize strToken;
@synthesize strStsKeyID;
@synthesize strStsSecret;
@synthesize ullCreateTime;
@synthesize ullExpireTime;

-(id)init
{
    if (self =[super init]) {
        self.strKeyID=@"";
        self.strSubKeyID=@"";
        self.strToken=@"";
        self.strStsKeyID=@"";
        self.strStsSecret=@"";
        self.ullCreateTime=0;
        self.ullExpireTime=0;
    }
    return self;
}

-(void)dealloc
{
    self.strKeyID=nil;
    self.strSubKeyID=nil;
    self.strToken=nil;
    self.strStsKeyID=nil;
    self.strStsSecret=nil;
    [super dealloc];
}

- (id)initWithJsonDictionary:(NSDictionary*)dictionary
{
    if (self = [self init])
    {
        [self setValueWithJson:dictionary];
    }
    return self;
}

-(NSDictionary*)dictionary
{
    NSMutableDictionary* dicRet=[NSMutableDictionary dictionary];
    [dicRet setValue:self.strKeyID forKey:@"keyid"];
    [dicRet setValue:self.strSubKeyID forKey:@"subkeyid"];
    [dicRet setValue:self.strToken forKey:@"token"];
    [dicRet setValue:self.strStsKeyID forKey:@"stskeyid"];
    [dicRet setValue:self.strStsSecret forKey:@"stssecret"];
    [dicRet setValue:[NSNumber numberWithLongLong:self.ullCreateTime] forKey:@"createtime"];
    [dicRet setValue:[NSNumber numberWithLongLong:self.ullExpireTime] forKey:@"expiretime"];
    return dicRet;
}

-(void)setValueWithJson:(NSDictionary*) dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.strSubKeyID =[dictionary objectForKey:@"subkeyid"];
    if (self.strSubKeyID.length==0) {
        self.strSubKeyID=@"";
    }
    self.strToken =[dictionary objectForKey:@"token"];
    if (self.strToken.length==0) {
        self.strToken=@"";
    }
    self.strStsKeyID =[dictionary objectForKey:@"stskeyid"];
    if (self.strStsKeyID.length==0) {
        self.strStsKeyID=@"";
    }
    self.strStsSecret =[dictionary objectForKey:@"stssecret"];
    if (self.strStsSecret.length==0) {
        self.strStsSecret=@"";
    }
    self.ullExpireTime =[[dictionary objectForKey:@"expiretime"] longLongValue];
}
-(void)Encrypt
{
    NSString* device=[OSSRsa getcomputerid];
    NSString* devicehash=[device sha1HexDigest];
    NSData* ret=[OSSRsa CryptEncrypt:devicehash data:[self.strKeyID dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strKeyID=[ret base64Encoding];
    }
    ret=[OSSRsa CryptEncrypt:devicehash data:[self.strSubKeyID dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strSubKeyID=[ret base64Encoding];
    }
    ret=[OSSRsa CryptEncrypt:devicehash data:[self.strToken dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strToken=[ret base64Encoding];
    }
    ret=[OSSRsa CryptEncrypt:devicehash data:[self.strStsKeyID dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strStsKeyID=[ret base64Encoding];
    }
    ret=[OSSRsa CryptEncrypt:devicehash data:[self.strStsSecret dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        self.strStsSecret=[ret base64Encoding];
    }
}
-(void)Decrypt
{
    NSString* device=[OSSRsa getcomputerid];
    NSString* devicehash=[device sha1HexDigest];
    NSData* ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strKeyID]];
    if (ret!=nil) {
        self.strKeyID=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
    ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strSubKeyID]];
    if (ret!=nil) {
        self.strSubKeyID=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
    ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strToken]];
    if (ret!=nil) {
        self.strToken=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
    ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strStsKeyID]];
    if (ret!=nil) {
        self.strStsKeyID=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
    ret=[OSSRsa CryptDecrypt:devicehash data:[NSData base64Decoded:self.strStsSecret]];
    if (ret!=nil) {
        self.strStsSecret=[[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
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
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS settings(https int,dmax int,umax int,dpmax int,upmax int,uploadpath varchar[2000] COLLATE NOCASE,downloadpath varchar[2000] COLLATE NOCASE,language int,Disposition int);"];
        NSString *sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (keyid varchar[500],subkeyid varchar[500],subsecret varchar[500],createtime bigint,PRIMARY KEY(subkeyid));",RAM_NAME];
        [db executeUpdate:sql];
        sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (keyid varchar[500],subkeyid varchar[500],token varchar[500],stskeyid varchar[500],stssecret varchar[500],createtime bigint,expiretime bigint,PRIMARY KEY(stskeyid));",STS_NAME];
        [db executeUpdate:sql];
        NSInteger count=0;
        sql =@"select count(*) as cnt from settings";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            count=[rs intForColumn:@"cnt"];
            break;
        }
        [rs close];
        if (count==0) {
            NSString* sql=@"insert into settings(https,dmax,umax,dpmax,upmax,uploadpath,downloadpath,language,Disposition) values('0','5','5','5','5','','','0','0');";
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
         res = [db executeUpdate:@"ALTER TABLE settings add language int;"];
         if (res)
         {
             [db executeUpdate:@"update settings set language='0';"];
         }
         res = [db executeUpdate:@"ALTER TABLE settings add Disposition int;"];
         if (res)
         {
             [db executeUpdate:@"update settings set Disposition='0';"];
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
         NSString *sql=[NSString stringWithFormat:@"update settings set upmax='%ld'",value];
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


-(void)setlanguage:(NSInteger)value
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set language='%ld'",value];
         [db executeUpdate:sql];
     }];
}

-(NSInteger)getlanguage
{
    __block NSInteger ret=1;
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =@"select language from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next])
         {
             ret=[rs intForColumn:@"language"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)setContentDisposition:(NSInteger)value
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql=[NSString stringWithFormat:@"update settings set Disposition='%ld'",value];
         [db executeUpdate:sql];
     }];
}

-(NSInteger)getContentDisposition
{
    __block NSInteger ret=1;
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =@"select Disposition from settings";
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next])
         {
             ret=[rs intForColumn:@"Disposition"];
             break;
         }
         [rs close];
     }];
    return ret;
}

-(void)addRam:(RamInfo*)item
{
    [item Encrypt];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"select * from %@ where subkeyid = '%@';",RAM_NAME,[item.strSubKeyID replacetosql]];
         FMResultSet *rs = [db executeQuery:sql];
         BOOL bHave=NO;
         while ([rs next])
         {
             bHave=YES;
         }
         [rs close];
         if (bHave) {
             sql =[NSString stringWithFormat:@"Update %@ set keyid='%@',subsecret='%@',createtime='%llu' where subkeyid = '%@';",RAM_NAME,[item.strKeyID replacetosql],[item.strSubSecret replacetosql],item.ullCreateTime,[item.strSubKeyID replacetosql]];
         }
         else {
             sql =[NSString stringWithFormat:@"insert into %@ (keyid,subkeyid,subsecret,createtime) values ('%@','%@','%@','%llu');",RAM_NAME,[item.strKeyID replacetosql],[item.strSubKeyID replacetosql],[item.strSubSecret replacetosql],item.ullCreateTime];
         }
         [db executeUpdate:sql];
     }];
}
-(void)delRam:(RamInfo*)item
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"delete from %@ where subkeyid = '%@';",RAM_NAME,[[self Encrypt:item.strSubKeyID] replacetosql]];
         [db executeUpdate:sql];
     }];
}
-(RamInfo*)getRam:(NSString*)subkeyid
{
    RamInfo *item=[[[RamInfo alloc]init]autorelease];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"select * from %@ where subkeyid = '%@';",RAM_NAME,[[self Encrypt:subkeyid] replacetosql]];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next])
         {
             item.strKeyID=[rs stringForColumn:@"keyid"];
             item.strSubKeyID=[rs stringForColumn:@"subkeyid"];
             item.strSubSecret=[rs stringForColumn:@"subsecret"];
             item.ullCreateTime=[rs longLongIntForColumn:@"createtime"];
             [item Decrypt];
         }
         [rs close];
     }];
    return item;
}

-(NSMutableArray*)getRams
{
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"select * from %@;",RAM_NAME];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next])
         {
             RamInfo *item=[[[RamInfo alloc]init]autorelease];
             item.strKeyID=[rs stringForColumn:@"keyid"];
             item.strSubKeyID=[rs stringForColumn:@"subkeyid"];
             item.strSubSecret=[rs stringForColumn:@"subsecret"];
             item.ullCreateTime=[rs longLongIntForColumn:@"createtime"];
             [item Decrypt];
             [all addObject:item];
         }
         [rs close];
     }];
    return all;
}

-(void)addSts:(StsInfo*)item
{
    [item Encrypt];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"select * from %@ where stskeyid = '%@';",STS_NAME,[item.strStsKeyID replacetosql]];
         FMResultSet *rs = [db executeQuery:sql];
         BOOL bHave=NO;
         while ([rs next])
         {
             bHave=YES;
         }
         [rs close];
         if (bHave) {
             sql =[NSString stringWithFormat:@"Update %@ set keyid='%@',subkeyid='%@',token='%@',stssecret='%@',createtime='%llu',expiretime='%llu' where stskeyid = '%@';",RAM_NAME,[item.strKeyID replacetosql],[item.strSubKeyID replacetosql],[item.strToken replacetosql],[item.strStsSecret replacetosql],item.ullCreateTime,item.ullExpireTime,[item.strStsKeyID replacetosql]];
         }
         else {
             sql =[NSString stringWithFormat:@"insert into %@ (keyid,subkeyid,token,stskeyid,stssecret,createtime,expiretime) values ('%@','%@','%@','%@','%@','%llu','%llu');",RAM_NAME,[item.strKeyID replacetosql],[item.strSubKeyID replacetosql],[item.strToken replacetosql],[item.strStsKeyID replacetosql],[item.strStsSecret replacetosql],item.ullCreateTime,item.ullExpireTime];
         }
         [db executeUpdate:sql];
     }];
}
-(void)delSts:(StsInfo*)item
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"delete from %@ where stskeyid = '%@';",STS_NAME,[[self Encrypt:item.strStsKeyID] replacetosql]];
         [db executeUpdate:sql];
     }];
}
-(StsInfo*)getSts:(NSString*)stskeyid
{
    StsInfo *item=[[[StsInfo alloc]init]autorelease];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"select * from %@ where stskeyid = '%@';",RAM_NAME,[[self Encrypt:stskeyid] replacetosql]];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next])
         {
             item.strKeyID=[rs stringForColumn:@"keyid"];
             item.strSubKeyID=[rs stringForColumn:@"subkeyid"];
             item.strToken=[rs stringForColumn:@"token"];
             item.strStsKeyID=[rs stringForColumn:@"stskeyid"];
             item.strStsSecret=[rs stringForColumn:@"stssecret"];
             item.ullCreateTime=[rs longLongIntForColumn:@"createtime"];
             item.ullExpireTime=[rs longLongIntForColumn:@"expiretime"];
             [item Decrypt];
         }
         [rs close];
     }];
    return item;
}
-(NSMutableArray*)getSts
{
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *sql =[NSString stringWithFormat:@"select * from %@ ;",RAM_NAME];
         FMResultSet *rs = [db executeQuery:sql];
         while ([rs next])
         {
             StsInfo *item=[[[StsInfo alloc]init]autorelease];
             item.strKeyID=[rs stringForColumn:@"keyid"];
             item.strSubKeyID=[rs stringForColumn:@"subkeyid"];
             item.strToken=[rs stringForColumn:@"token"];
             item.strStsKeyID=[rs stringForColumn:@"stskeyid"];
             item.strStsSecret=[rs stringForColumn:@"stssecret"];
             item.ullCreateTime=[rs longLongIntForColumn:@"createtime"];
             item.ullExpireTime=[rs longLongIntForColumn:@"expiretime"];
             [item Decrypt];
             [all addObject:item];
         }
         [rs close];
     }];
    return all;
}
+(NSString*)action:(NSString*)cmd json:(NSString*)json
{
    if ([cmd isEqualToString:@"addram"]) {
        return [SettingsDb actionAddRam:json];
    }
    if ([cmd isEqualToString:@"delram"]) {
        return [SettingsDb actionDelRam:json];
    }
    if ([cmd isEqualToString:@"getram"]) {
        return [SettingsDb actionGetRam:json];
    }
    if ([cmd isEqualToString:@"getrams"]) {
        return [SettingsDb actionGetRams:json];
    }
    if ([cmd isEqualToString:@"addsts"]) {
        return [SettingsDb actionAddSts:json];
    }
    if ([cmd isEqualToString:@"delsts"]) {
        return [SettingsDb actionDelSts:json];
    }
    if ([cmd isEqualToString:@"getsts"]) {
        return [SettingsDb actionGetSts:json];
    }
    if ([cmd isEqualToString:@"getstss"]) {
        return [SettingsDb actionGetStss:json];
    }
    return @"{}";
}
+(NSString*)actionAddRam:(NSString*)json
{
    NSString* ret=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:json];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return ret;
    }
    RamInfo* item=[[RamInfo alloc]initWithJsonDictionary:dictionary];
    item.strKeyID=[Util getAppDelegate].strAccessKey;
    item.ullCreateTime=(ULONGLONG)[[NSDate date] timeIntervalSince1970];
    [[SettingsDb shareSettingDb] addRam:item];
    [item release];
    return ret;
}
+(NSString*)actionDelRam:(NSString*)json
{
    NSString* ret=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:json];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return ret;
    }
    RamInfo* item=[[RamInfo alloc]initWithJsonDictionary:dictionary];
    [[SettingsDb shareSettingDb] delRam:item];
    [item release];
    return ret;
}
+(NSString*)actionGetRam:(NSString*)json
{
    NSString* ret=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:json];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return ret;
    }
    RamInfo* item=[[RamInfo alloc]initWithJsonDictionary:dictionary];
    RamInfo* retitem=[[SettingsDb shareSettingDb] getRam:item.strSubKeyID];
    [item release];
    if (retitem.strSubKeyID.length) {
        return [[retitem dictionary] JSONString];
    }
    return ret;
}
+(NSString*)actionGetRams:(NSString*)json
{
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    NSMutableArray* array=[[SettingsDb shareSettingDb] getRams];
    NSMutableArray* arrayRet=[NSMutableArray array];
    for (RamInfo* item in array) {
        [arrayRet addObject:[item dictionary]];
    }
    [dicRetlist setValue:arrayRet forKey:@"list"];
    return [dicRetlist JSONString];
}
+(NSString*)actionAddSts:(NSString*)json
{
    NSString* ret=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:json];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return ret;
    }
    StsInfo* item=[[StsInfo alloc]initWithJsonDictionary:dictionary];
    item.strKeyID=[Util getAppDelegate].strAccessKey;
    item.ullCreateTime=(ULONGLONG)[[NSDate date] timeIntervalSince1970];
    [[SettingsDb shareSettingDb] addSts:item];
    [item release];
    return ret;
}
+(NSString*)actionDelSts:(NSString*)json
{
    NSString* ret=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:json];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return ret;
    }
    StsInfo* item=[[StsInfo alloc]initWithJsonDictionary:dictionary];
    [[SettingsDb shareSettingDb] delSts:item];
    [item release];
    return ret;
}
+(NSString*)actionGetSts:(NSString*)json
{
    NSString* ret=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:json];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return ret;
    }
    StsInfo* item=[[StsInfo alloc]initWithJsonDictionary:dictionary];
    StsInfo* retitem=[[SettingsDb shareSettingDb] getSts:item.strStsKeyID];
    [item release];
    if (retitem.strStsKeyID.length) {
        return [[retitem dictionary] JSONString];
    }
    return ret;
}
+(NSString*)actionGetStss:(NSString*)json
{
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    NSMutableArray* array=[[SettingsDb shareSettingDb] getRams];
    NSMutableArray* arrayRet=[NSMutableArray array];
    for (StsInfo* item in array) {
        [arrayRet addObject:[item dictionary]];
    }
    [dicRetlist setValue:arrayRet forKey:@"list"];
    return [dicRetlist JSONString];
}

-(NSString*)Encrypt:(NSString*)key
{
    NSString* device=[OSSRsa getcomputerid];
    NSString* devicehash=[device sha1HexDigest];
    NSData* ret=[OSSRsa CryptEncrypt:devicehash data:[key dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret!=nil) {
        return [ret base64Encoding];
    }
    return @"";
}
-(NSString*)Decrypt:(NSString*)key
{
    NSString* device=[OSSRsa getcomputerid];
    NSString* devicehash=[device sha1HexDigest];
    NSData* keydata=[NSData base64Decoded:key];
    NSData* ret=[OSSRsa CryptDecrypt:devicehash data:keydata];
    if (ret!=nil) {
        return [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
    }
    return @"";
}

@end
