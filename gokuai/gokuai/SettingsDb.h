#import <Foundation/Foundation.h>

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
@end
