#import <Foundation/Foundation.h>

@interface SyncTransCache : NSObject {
    NSString*       cachepath;
}

@property(nonatomic, copy) NSString* cachepath;


+(SyncTransCache *)shareSyncTransCache;

//删除缓存临时下载文件
-(void)timeremovefile;
//
-(BOOL)checkdownloaderror:(NSString *)path;
//清楚缓存
-(void)clear;

-(void)removeerrorfile;

@end
