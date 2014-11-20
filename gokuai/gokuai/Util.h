#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "AppDelegate.h"
#import "OSSRet.h"

@interface Util : NSObject

+(AppDelegate *)getAppDelegate;
+(NSString*) localizedStringForKey:(NSString*) key alternate:(NSString*) alternate;
+(BOOL)createfolder:(NSString*)path;
+(BOOL)createfile:(NSString*)path;
+(BOOL)isdir:(NSString*)path;
+(BOOL)existfile:(NSString*)path;
+(BOOL)movefile:(NSString*)existingfile
        newfile:(NSString*)newfile;
+(BOOL)copyfile:(NSString*)existingfile
        newfile:(NSString*)newfile;
+(BOOL)copyfile:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace;
+(BOOL)copyfileneedtemp:(NSString*)existingfile
                newfile:(NSString*)newfile;
+(BOOL)deletefile:(NSString*)path;
+(BOOL)deletefile2recyclebin:(NSString*)path;
+(BOOL)deletefolder:(NSString*)path
             undo:(BOOL)undo;
+(BOOL)isemptydir:(NSString*)path;
+(unsigned long long)filesize:(NSString*)path;
+(unsigned long long)filemodifytime:(NSString*)path;
+(unsigned long long)filecreatetime:(NSString*)path;
+(void)openWebUrl:(NSString*)url;
+(NSPoint)getWindowDisplayOriginPoint:(NSSize)size;
+ (NSString*)getGMTDate;
+(void) webScriptObjectCallback:(JSObjectRef)_objRef contextRef:(JSContextRef)_ctx args:(JSValueRef*)_args argCnt:(NSInteger)_argCnt;
+(void) webScriptObjectCallback:(WebScriptObject*)obj webFrame:(WebFrame*)frame jsonString:(NSString*)string;
+(NSString*)GetErrorMessage:(NSInteger)error;
+(NSString*)GetOssErrorMessage:(NSString*)error;
+(NSString*)GetHttpErrorMessage:(NSInteger)error;
+(NSString*)errorInfoWithCode:(NSInteger)err;
+(NSString*)errorInfoWithCode:(NSString*)action message:(NSString*)message ret:(OSSRet*)ret;


+(NSDictionary*) dictionaryWithJsonInfo:(NSString*) jsonInfo;
+(NSOpenPanel*) OpenPanelAddFiles:(NSWindow*)parentWindow :(NSString*)dstpath;
+(NSOpenPanel*) OpenPanelSelectPath:(NSWindow*)parentWindow :(NSString*)dstpath;
+(NSImage*) iconFromFileType:(NSString*)fileType;
+(NSString *)getfindertarget:(NSInteger)windowid;
+ (BOOL) didProgressLaunched:(NSString *)bundleId;
//zip文件解压到哪个目录下
+(BOOL) unzip:(NSString*)srcpath
          dst:(NSString*)dstpath;
//将目录下的文件打包成文件
+(BOOL) zip:(NSString*)srcpath
        dst:(NSString*)dstpath;
+(NSString*)ChangeHost:(NSString*)host;

@end
