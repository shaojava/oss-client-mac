#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "AppDelegate.h"

@class RequestRet;

@interface Util : NSObject

+(AppDelegate *)getAppDelegate;

+(NSString*) localizedStringForKey:(NSString*) key alternate:(NSString*) alternate;

+(BOOL)checkVersion:(NSString *)_version;
+(BOOL)createfolder:(NSString*)path;
+(BOOL)createfile:(NSString*)path;
+(BOOL)isdir:(NSString*)path;
+(BOOL)isfile:(NSString*)path;
+(BOOL)existfile:(NSString*)path;


+(BOOL)movefile:(NSString*)existingfile
        newfile:(NSString*)newfile;
+(BOOL)copyfile:(NSString*)existingfile
        newfile:(NSString*)newfile;
+(BOOL)copyfile:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace;
+(BOOL)movefolder:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace;
+(BOOL)copyfolder:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace;
+(BOOL)copyfileneedtemp:(NSString*)existingfile
                newfile:(NSString*)newfile;
+(BOOL)copyfileUI:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace;
+(BOOL)deletefile:(NSString*)path;
+(BOOL)deletefile2recyclebin:(NSString*)path;
+(BOOL)deletefolder:(NSString*)path
             undo:(BOOL)undo;
+(BOOL)deletefileinfolder:(NSString*)path
                     undo:(BOOL)undo;
+(BOOL)isemptydir:(NSString*)path;
+(unsigned long long)filesize:(NSString*)path;
+(NSString *)filetype:(NSString*)path;
+(unsigned long long)filemodifytime:(NSString*)path;
+(unsigned long long)filecreatetime:(NSString*)path;

+(void)setfilereadonly:(NSString*)path;
+(void)setfilereadwirte:(NSString*)path;
+(NSArray *)subpathsAtPath:(NSString*)path;
+(NSString*)getfilehash:(NSString*)path;

+(void)openWebUrl:(NSString*)url;
+(BOOL)createlink:(NSString*)path
          srcpath:(NSString*)srcpath;


+(NSPoint)getWindowDisplayOriginPoint:(NSSize)size;

+(BOOL)findspace:(NSString*)path;
+(NSString*)replacespace:(NSString*)path;

+(BOOL)popupAlertMsgBox:(NSString*)msg;
+ (NSString*)getGMTDate;

+(BOOL)checknamecase:(NSString*)path;


+(BOOL)illegalInWindows:(NSString*)fileName;

+(void) webScriptObjectCallback:(JSObjectRef)_objRef contextRef:(JSContextRef)_ctx args:(JSValueRef*)_args argCnt:(NSInteger)_argCnt;
+(void) webScriptObjectCallback:(WebScriptObject*)obj webFrame:(WebFrame*)frame jsonString:(NSString*)string;

+(NSString*) GetMyErrorMessage:(NSInteger)err;
+(NSString*) errorInfoWithCode:(NSInteger)err;
+(NSString*) errorInfoWithCode:(NSInteger)err
                     anderrmsg:(NSString*)errmsg;
+(NSString*) errorInfoWithReq:(RequestRet*)req;

+(NSDictionary*) dictionaryWithJsonInfo:(NSString*) jsonInfo;

+(void) chooseApplicationAndOpenFile:(NSWindow*)parentWindow fullpath:(NSString*)fullpath;

+(NSOpenPanel*) OpenPanelAddFiles:(NSWindow*)parentWindow :(NSString*)dstpath;
+(NSOpenPanel*) OpenPanelSelectPath:(NSWindow*)parentWindow :(NSString*)dstpath;

+(NSImage*) iconFromFileType:(NSString*)fileType;

+(void) systemPreferenceWithNetwork;


+(NSString *)getfindertarget:(NSInteger)windowid;



+(void) setDockBadge:(NSInteger)count;
+ (BOOL)stringContainsEmoji:(NSString *)string;

+ (BOOL) didProgressLaunched:(NSString *)bundleId;

+(BOOL)islink;

//zip文件解压到哪个目录下
+(BOOL) unzip:(NSString*)srcpath
          dst:(NSString*)dstpath;
//将目录下的文件打包成文件
+(BOOL) zip:(NSString*)srcpath
        dst:(NSString*)dstpath;
+(NSString*)ChangeHost:(NSString*)host;








@end
