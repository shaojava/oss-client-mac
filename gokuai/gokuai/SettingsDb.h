#import <Foundation/Foundation.h>
#import "Common.h"

@interface UserInfo : NSObject
{
    NSString* strAccessID;
    NSString* strAccessKey;
    NSString* strArea;
    NSString* strHost;
    NSString* strPassword;
}
@property(nonatomic,copy)NSString* strAccessID;
@property(nonatomic,copy)NSString* strAccessKey;
@property(nonatomic,copy)NSString* strArea;
@property(nonatomic,copy)NSString* strHost;
@property(nonatomic,copy)NSString* strPassword;

@end

@interface RamInfo : NSObject
{
    NSString* strKeyID;
    NSString* strSubKeyID;
    NSString* strSubSecret;
    ULONGLONG ullCreateTime;
}
@property(nonatomic,copy)NSString* strKeyID;
@property(nonatomic,copy)NSString* strSubKeyID;
@property(nonatomic,copy)NSString* strSubSecret;
@property(nonatomic)ULONGLONG ullCreateTime;
- (id)initWithJsonDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionary;
-(void)setValueWithJson:(NSDictionary*) dictionary;
-(void)Encrypt;
-(void)Decrypt;

@end

@interface StsInfo : NSObject
{
    NSString* strKeyID;
    NSString* strSubKeyID;
    NSString* strToken;
    NSString* strStsKeyID;
    NSString* strStsSecret;
    ULONGLONG ullCreateTime;
    ULONGLONG ullExpireTime;
}
@property(nonatomic,copy)NSString* strKeyID;
@property(nonatomic,copy)NSString* strSubKeyID;
@property(nonatomic,copy)NSString* strToken;
@property(nonatomic,copy)NSString* strStsKeyID;
@property(nonatomic,copy)NSString* strStsSecret;
@property(nonatomic)ULONGLONG ullCreateTime;
@property(nonatomic)ULONGLONG ullExpireTime;

- (id)initWithJsonDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionary;
-(void)setValueWithJson:(NSDictionary*) dictionary;
-(void)Encrypt;
-(void)Decrypt;

@end

@class FMDatabaseQueue;

@interface SettingsDb : NSObject
{
    FMDatabaseQueue*    dbQueue;
    BOOL        bHttps;
    NSInteger   nDMax;
    NSInteger   nUMax;
}
@property(nonatomic, retain) FMDatabaseQueue* dbQueue;
@property(nonatomic,assign)BOOL bHttps;
@property(nonatomic,assign)NSInteger nDMax;
@property(nonatomic,assign)NSInteger nUMax;

+(SettingsDb*)shareSettingDb;
#pragma mark-
#pragma mark- 表的打开，创建和关闭
-(id)initpath:(NSString*)path;
-(void)createtable;
-(void)addnewrow;
-(void)close;
#pragma mark-
#pragma mark- 用户表的操作
-(void)setuserinfo:(UserInfo*)userinfo;
-(UserInfo*)getuserinfo;
-(void)setUserPassword:(NSString*)password;
-(NSString*)getUserPassword;
-(void)setHost:(NSString*)host;
-(void)deleteuserinfo;

#pragma mark-
#pragma mark- 设置表的操作

-(void)sethttps:(BOOL)value;
-(BOOL)gethttps;
-(void)setDMax:(NSInteger)value;
-(NSInteger)getDMax;
-(void)setUMax:(NSInteger)value;
-(NSInteger)getUMax;
-(void)setDPMax:(NSInteger)value;
-(NSInteger)getDPMax;
-(void)setUPMax:(NSInteger)value;
-(NSInteger)getUPMax;

-(void)setUploadPath:(NSString*)value;
-(NSString*)getUploadPath;

-(void)setDownloadPath:(NSString*)value;
-(NSString*)getDownloadPath;

-(void)setlanguage:(NSInteger)value;
-(NSInteger)getlanguage;

-(void)setContentDisposition:(NSInteger)value;
-(NSInteger)getContentDisposition;

-(void)addRam:(RamInfo*)item;
-(void)delRam:(RamInfo*)item;
-(RamInfo*)getRam:(NSString*)subkeyid;
-(NSMutableArray*)getRams;

-(void)addSts:(StsInfo*)item;
-(void)delSts:(StsInfo*)item;
-(StsInfo*)getSts:(NSString*)stskeyid;
-(NSMutableArray*)getSts;

+(NSString*)action:(NSString*)cmd json:(NSString*)json;
+(NSString*)actionAddRam:(NSString*)json;
+(NSString*)actionDelRam:(NSString*)json;
+(NSString*)actionGetRam:(NSString*)json;
+(NSString*)actionGetRams:(NSString*)json;
+(NSString*)actionAddSts:(NSString*)json;
+(NSString*)actionDelSts:(NSString*)json;
+(NSString*)actionGetSts:(NSString*)json;
+(NSString*)actionGetStss:(NSString*)json;

-(NSString*)Encrypt:(NSString*)key;
-(NSString*)Decrypt:(NSString*)key;

@end
