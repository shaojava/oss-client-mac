#import "Util.h"
#import "FileMD5Hash.h"
#import <IOKit/IOKitLib.h>
#import "NSStringExpand.h"
#import "NSDataExpand.h"
#include <sys/sysctl.h>
#include <sys/resource.h>
#include <sys/vm.h>
#import "JSONKit.h"
#import "Common.h"
#import <netinet/in.h>
#import "AppDelegate.h"

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#import <netinet6/in6.h>
#endif
#include <SystemConfiguration/SystemConfiguration.h>


@implementation Util

+(AppDelegate *)getAppDelegate
{
    return (AppDelegate*)[NSApplication sharedApplication].delegate;
}

+(NSString*) localizedStringForKey:(NSString*) key alternate:(NSString*) alternate
{
    return key;
}

//0.0.0.0
+(BOOL)checkVersion:(NSString *)_version
{
	if (!_version.length) {
        return NO;
    }
    return YES;
}

+(BOOL)createfolder:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir=YES;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
            return NO;
    }
    else {
        if (!isDir) {
            return NO;
        }
    }
    return YES;
}

+(BOOL)createfile:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir=NO;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
        if(![fileManager createFileAtPath:path contents:nil attributes:nil])
            return NO;
    return YES;
}

+(BOOL)isdir:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir=YES;
    BOOL ret=[fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (isDir&&ret) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)isfile:(NSString*)path
{
    BOOL isDir=YES;
    BOOL ret=[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (ret&&!isDir) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)existfile:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

+(BOOL)isemptydir:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSArray *subpaths=[fileManager contentsOfDirectoryAtPath:path error:nil];
    if (subpaths==nil) {
        return YES;
    }
    else {
        BOOL ret=YES;
        for (NSString *obj in subpaths)
        {
            NSString* path = (NSString*)obj;
            BOOL isignore=NO;
            if ([path hasPrefix:@"."]) {
                isignore=YES;
            }
            if ([path isEqualToString:@"Icon\r"]) {
                isignore=YES;
            }
            if (!isignore) {
                ret=NO;
                break;
            }
        }
        return ret;
    }
}

+(NSArray *)subpathsAtPath:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    return [fileManager subpathsAtPath:path];
}

+(BOOL)movefile:(NSString*)existingfile
        newfile:(NSString*)newfile
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    return [fileManager moveItemAtPath:existingfile toPath:newfile error:nil];
}

+(BOOL)copyfile:(NSString*)existingfile
        newfile:(NSString*)newfile
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL ret=YES;
    if ([fileManager fileExistsAtPath:newfile]) {
        ret=[fileManager removeItemAtPath:newfile error:NULL];
    }
    if(ret)
        ret=[fileManager copyItemAtPath:existingfile toPath:newfile error:NULL];
    if (!ret)
    {
        return NO;
    }
    else
        return YES;
}

+(BOOL)copyfile:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace
{
    if ([existingfile isEqualToString:newfile]) {
        return YES;
    }
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL ret=YES;
    if ([fileManager fileExistsAtPath:newfile]) {
        if (!replace) {
            return YES;
        }
        ret=[fileManager removeItemAtPath:newfile error:NULL];
    }
    if(ret)
        ret=[fileManager copyItemAtPath:existingfile toPath:newfile error:NULL];
    if (!ret)
    {
        return NO;
    }
    else
        return YES;
}

+(BOOL)movefolder:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace
{
    if ([Util existfile:existingfile]) {
        if ([Util isdir:existingfile]) {
            [Util createfolder:newfile];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSString* path=[existingfile lastaddslash];
            NSString* newpath=[newfile lastaddslash];
            NSFileManager *manager = [NSFileManager defaultManager];
            NSArray *dirArray=[manager contentsOfDirectoryAtPath:path error:NULL];
            for(int i = 0; i < [dirArray count];i++)  
            {
                NSString *filename=[dirArray objectAtIndex:i];
                NSString *temppath=[NSString stringWithFormat:@"%@%@",path,filename];
                NSString*tempnewpath=[NSString stringWithFormat:@"%@%@",newpath,filename];
                if([Util isdir:temppath]){
                    if (![Util movefile:temppath newfile:tempnewpath]) {
                        if (![self copyfile:temppath newfile:tempnewpath replace:replace]) {
                            return NO;
                        }
                    }
                }
                else {
                    if (![Util movefile:temppath newfile:tempnewpath]) {
                        if (![Util copyfile:temppath newfile:tempnewpath replace:replace]) {
                            return NO;
                        }
                    }
                }
            }
            [pool release];
            return YES;
        }
        else {
            return [Util copyfile:existingfile newfile:newfile replace:replace];
        }
    }
    else {
        return YES;
    }
}

+(BOOL)copyfolder:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace
{
    if ([Util existfile:existingfile]) {
        if ([Util isdir:existingfile]) {
            [Util createfolder:newfile];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSString* path=[existingfile lastaddslash];
            NSString* newpath=[newfile lastaddslash];
            NSFileManager *manager = [NSFileManager defaultManager];
            NSArray *dirArray=[manager contentsOfDirectoryAtPath:path error:NULL];
            for(int i = 0; i < [dirArray count];i++)  
            {
                NSString *filename=[dirArray objectAtIndex:i];
                NSString *temppath=[NSString stringWithFormat:@"%@%@",path,filename];
                NSString*tempnewpath=[NSString stringWithFormat:@"%@%@",newpath,filename];
                if([Util isdir:temppath]){
                    if (![self copyfile:temppath newfile:tempnewpath replace:replace]) {
                        return NO;
                    }
                }
                else {
                    if (![Util copyfile:temppath newfile:tempnewpath replace:replace]) {
                        return NO;
                    }
                }
            }
            [pool release];
            return YES;
        }
        else {
            return [Util copyfile:existingfile newfile:newfile replace:replace];
        }
    }
    else {
        return YES;
    }
}

+(BOOL)copyfileUI:(NSString *)existingfile newfile:(NSString *)newfile replace:(BOOL)replace
{
    return [self copyfile:existingfile newfile:newfile replace:replace];
}

+(BOOL)copyfileneedtemp:(NSString*)existingfile
                newfile:(NSString*)newfile
{
    BOOL ret=YES;
    @try {
        NSString * tempfile=[NSString stringWithFormat:@"%@.gkcopy",newfile];
        NSFileManager *fileManager= [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:tempfile]) {
            ret=[fileManager removeItemAtPath:tempfile error:NULL];
        }
        if(ret){
            ret=[fileManager copyItemAtPath:existingfile toPath:tempfile error:NULL];
        }
        if (ret&&[fileManager fileExistsAtPath:newfile]) {
            ret=[fileManager removeItemAtPath:newfile error:NULL];
        }
        if(ret)
        {
            ret=[fileManager moveItemAtPath:tempfile toPath:newfile error:NULL];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"copy %@",exception);
    }
    @finally {
        return ret;
    }
}
+(BOOL)deletefile:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:NULL];
}
+(BOOL)deletefile2recyclebin:(NSString*)path
{
    NSString* temp=[NSString stringWithFormat:@"%@/",[path stringByDeletingLastPathComponent]];
    return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation 
                                                 source:temp
                                            destination:@"" 
                                                  files:[NSArray arrayWithObject:[path lastPathComponent]]
                                                    tag:nil];
}
+(BOOL)deletefolder:(NSString*)path
             undo:(BOOL)undo
{
    if (undo) {
        return [Util deletefile2recyclebin:path];
    }
    else {
        return [Util deletefile:path];
    }
}

+(BOOL)deletefileinfolder:(NSString*)path
                     undo:(BOOL)undo
{
    path=[path lastaddslash];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSArray *subpaths=[fileManager contentsOfDirectoryAtPath:path error:nil];
    if (subpaths==nil) {
        return YES;
    }
    else {
        for (NSString *obj in subpaths)
        {
            NSString *temppath=[NSString stringWithFormat:@"%@%@",path,obj];
            if (![Util isdir:temppath]) {
                if (undo) {
                    [Util deletefile2recyclebin:temppath];
                }
                else {
                    [Util deletefile:temppath];
                }
            }
        }
    }
    return YES;
}

+(unsigned long long)filesize:(NSString*)path
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
    NSNumber *theFileSize=[fileAttributes objectForKey:NSFileSize];
    if (theFileSize)
        return [theFileSize unsignedLongLongValue];
    else
        return 0;
}

+(NSString *)filetype:(NSString*)path
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
    return [fileAttributes objectForKey:NSFileType];
}

+(unsigned long long)filemodifytime:(NSString*)path
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
    NSDate *fileModificationDate=[fileAttributes objectForKey:NSFileModificationDate];
    if (fileModificationDate){
        NSTimeInterval time=[fileModificationDate timeIntervalSince1970];
        return time;
    }
    else
        return 0;
}

+(unsigned long long)filecreatetime:(NSString*)path
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
    NSDate *fileModificationDate=[fileAttributes objectForKey:NSFileCreationDate];
    if (fileModificationDate){
        NSTimeInterval time=[fileModificationDate timeIntervalSince1970];
        return time;
    }
    else
        return 0;
}

+(void)setfilereadonly:(NSString*)path
{
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:292],NSFilePosixPermissions,nil];
    NSError *theError;
    [[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:path error:&theError];
}

+(void)setfilereadwirte:(NSString*)path
{
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:420],NSFilePosixPermissions,nil];
    NSError *theError;
    [[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:path error:&theError];
}

+(NSString*)getfilehash:(NSString*)path
{
    CFStringRef result = [FileSHA1 FileMD5HashCreateWithPath:(CFStringRef)path size:0];
    NSString *strFileSHA1 = [(NSString*)result copy];
    if (result) {
        CFRelease(result);
    }
    return [strFileSHA1 autorelease];
}

+ (NSString*)getGMTDate
{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    return [df stringFromDate:[NSDate date]];
}

+(void)openWebUrl:(NSString*)url
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}


+(BOOL)createlink:(NSString*)path
          srcpath:(NSString*)srcpath
{
    return [[NSFileManager defaultManager] createSymbolicLinkAtPath:path withDestinationPath:srcpath error:nil];
}

+(NSPoint)getWindowDisplayOriginPoint:(NSSize)size
{
    NSPoint originPoint;
    NSScreen *screen =[NSScreen mainScreen];
    
    if (size.width==screen.frame.size.width
        && size.height==screen.frame.size.height) {
        
        originPoint=NSMakePoint(0, screen.frame.size.height);
    }
    else {
        originPoint=NSMakePoint(screen.frame.size.width/2-size.width/2, screen.frame.size.height-100);
    }
    
    return originPoint;
}

+(BOOL)findspace:(NSString*)path
{
    NSString* filename=[path lastPathComponent];
    NSString* key=@" ";
    if ([filename hasSuffix:key]) {
        return YES;
    }
    if ([filename hasPrefix:key]) {
        return YES;
    }
    return NO;
}

+(NSString*)replacespace:(NSString*)path
{
    NSString* dir=[path stringByDeletingLastPathComponent];
    NSString* filename=[path lastPathComponent];
    NSString* key=@" ";
    NSString* temp;
    while ([filename hasSuffix:key]) {
        temp=[filename substringToIndex:filename.length-1];
        filename=temp;
    }
    while ([filename hasPrefix:key]) {
        temp=[filename substringFromIndex:1];
        filename=temp;
    }
    if (filename==nil||filename.length==0) {
        filename=@"_";
    }
    NSString *ret=[NSString stringWithFormat:@"%@/%@",dir,filename];
    return ret;
}
+(BOOL)popupAlertMsgBox:(NSString*)msg
{
     NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:msg];
    [alert addButtonWithTitle:[Util localizedStringForKey:@"确定" alternate:nil]];
    [alert addButtonWithTitle:[Util localizedStringForKey:@"取消" alternate:nil]];
    
    NSInteger isOK =[alert runModal];
    if (isOK == 1000)
        return YES;
    return NO;
}

+(BOOL)checknamecase:(NSString*)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSString * filename=[fileManager displayNameAtPath:path];
    NSString * filename1=[path lastPathComponent];
    if (filename.length>0) {
        if ([filename isEqualToString:filename1]) {
            return NO;
        }
        NSString * temp=[NSString stringWithFormat:@"%@.%@",filename,[path pathExtension]];
        if ([temp isEqualToString:filename1]) {
            return NO;
        }
        else
            return YES;
    }
    return NO;
}


+(CGImageRef) convertToCGImageFromNasImage:(NSImage *) image {
    NSData* cocoaData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [image representations]];
    CFDataRef carbonData = (CFDataRef)cocoaData;
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
    CGImageRef myCGImage = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
    CFRelease(imageSourceRef);
    return myCGImage;
}

+(BOOL)illegalInWindows:(NSString*)fileName
{
    //attention: '/'->':'
    NSString* illegalCharactors = @"/\\\"*:<>?|";
    if (NSNotFound == [fileName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:illegalCharactors]].location) {
        return NO;
    }
    
    return YES;
}

//回调 javascript
+(void) webScriptObjectCallback:(JSObjectRef)_objRef contextRef:(JSContextRef)_ctx args:(JSValueRef*)_args argCnt:(NSInteger)_argCnt
{
    JSObjectCallAsFunction(_ctx, _objRef, NULL, _argCnt, _args, NULL);
}

+(void) webScriptObjectCallback:(WebScriptObject*)obj webFrame:(WebFrame*)frame jsonString:(NSString*)string
{
    if (![obj isKindOfClass:[WebScriptObject class]]
        || !JSObjectIsFunction([frame globalContext],[obj JSObject])) {
        return;
    }
    JSObjectRef func = [obj JSObject];
    JSContextRef ctx =[frame globalContext];
    JSValueRef valref = JSValueMakeFromJSONString(ctx, JSStringCreateWithCFString((CFStringRef)string));
    JSObjectCallAsFunction(ctx, func, NULL, 1, &valref, NULL);
}

+(NSString*) GetMyErrorMessage:(NSInteger)err
{
    NSString *ret=@"";
    switch (err) {
        case MY_NO_ERROR:
            return @"";
        case MY_ERROR_EXIST:
            return [Util localizedStringForKey:@"文件已存在" alternate:nil];
        case MY_ERROR_UNLINK:
            return [Util localizedStringForKey:@"网络未连接" alternate:nil];
        case MY_ERROR_ROMOVESUB:
            return [Util localizedStringForKey:@"不能移动到子目录下" alternate:nil];
        case MY_ERROR_SYNC_NOT_EXIST:
            return [Util localizedStringForKey:@"同步不存在" alternate:nil];
        case MY_ERROR_LINK_MOVE:
            return [Util localizedStringForKey:@"设置同步失败" alternate:nil];
        case MY_ERROR_JSON:
            return [Util localizedStringForKey:@"参数格式不正确" alternate:nil];
        case MY_ERROR_SERVER_NOT_EXIST:
            return [Util localizedStringForKey:@"还没有获取到服务器地址" alternate:nil];
        case MY_ERROR_EMOJI_NOT_SUPPORT:
            return [Util localizedStringForKey:@"不支持Emoji表情字符作为文件名" alternate:nil];
        default:
            break;
    }
    return ret;
}

+(NSString*) errorInfoWithCode:(NSInteger)err
{
    NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:err],@"error",
                          [Util GetMyErrorMessage:err],@"message",nil];
    return [dicRet JSONString];
}

+(NSString*) errorInfoWithCode:(NSInteger)err anderrmsg:(NSString*)errmsg
{
    NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:err],@"error",
                          errmsg,@"message",nil];
    return [dicRet JSONString];
}

+(NSString*) errorInfoWithReq:(RequestRet*)req
{
    return nil;
}

+(NSDictionary*) dictionaryWithJsonInfo:(NSString*) jsonInfo
{
    return [jsonInfo objectFromJSONString];
}


+(void) chooseApplicationAndOpenFile:(NSWindow*)parentWindow fullpath:(NSString*)fullpath
{
    NSString *appsDir = nil;
    NSArray *appsDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory,NSLocalDomainMask,YES);
    
    if ([appsDirs count]) {
        appsDir = [appsDirs objectAtIndex:0];
    }
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:[self localizedStringForKey:@"选择应用程序" alternate:nil]];
    [openPanel setPrompt:[self localizedStringForKey:@"打开" alternate:nil]];
    [openPanel setMessage:[NSString stringWithFormat:[self localizedStringForKey:@"选择一个应用程序以打开文稿\"%@\"。" alternate:nil], [fullpath lastPathComponent]]];
    
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:appsDir]];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"app"]];

    NSString* appPath=nil;
    [NSApp beginSheet:openPanel modalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
    NSInteger iRet=[openPanel runModal];
    
    [NSApp endSheet:openPanel];
    if (NSOKButton==iRet) {
        appPath=((NSURL*)[[openPanel URLs] objectAtIndex:0]).path;
        [[NSWorkspace sharedWorkspace] openFile:fullpath withApplication:appPath];
    }
}

+(NSOpenPanel*) OpenPanelAddFiles:(NSWindow*)parentWindow :(NSString*)dstpath
{
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];    //default:0
    [panel setCanCreateDirectories:YES];    //default:0
    
    [panel setCanChooseFiles:YES];          //default:1
    [panel setAllowsMultipleSelection:YES]; //default:0
    [panel setTitle:[self localizedStringForKey:@"选择文件" alternate:nil]];
    [panel setPrompt:[self localizedStringForKey:@"选择" alternate:nil]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:dstpath?dstpath:NSHomeDirectory()]];
    
    return panel;
}

+(NSOpenPanel*) OpenPanelSelectPath:(NSWindow*)parentWindow :(NSString*)dstpath
{
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    
    [panel setCanChooseFiles:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setTitle:[self localizedStringForKey:@"选择路径" alternate:nil]];
    [panel setPrompt:[self localizedStringForKey:@"选择" alternate:nil]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:dstpath.length?dstpath:NSHomeDirectory()]];
    
    return panel;
}


+(NSImage*) iconFromFileType:(NSString*)path
{
    NSString* suffix=path;
    NSString* extName=[path pathExtension];
    if (extName.length) {
        suffix=extName;
    }
    return [[NSWorkspace sharedWorkspace] iconForFileType:suffix];
}

+(void) systemPreferenceWithNetwork
{
    NSAppleScript *settingNet = [[NSAppleScript alloc] initWithSource:@"tell application \"System Preferences\"\nset current pane to pane \"com.apple.preference.network\"\nactivate\nend tell"];
    [settingNet executeAndReturnError:nil];
    [settingNet release];
}
/*
 windowid   ： window number
 retrun     :  be target or @"";
 */
+(NSString *)getfindertarget:(NSInteger)windowid
{
    NSString *strval = @"";
    @try {
        NSString *source = [NSString stringWithFormat:
                            @"tell application \"Finder\"\n"
                            @"  try\n"
                            @"      return POSIX PATH of (target of window id %ld as alias)\n"
                            @"  on error\n"
                            @"      return \"\"\n"
                            @"  end try\n"
                            @"end tell",
                            (long)windowid];
        
        NSAppleScript* duplicate = [[[NSAppleScript alloc] initWithSource:source] autorelease];
        NSAppleEventDescriptor* descriptor=[duplicate executeAndReturnError:nil];
        strval = descriptor.stringValue;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return strval;
}


+(void) setDockBadge:(NSInteger)count;
{
    NSString* strval = count ? [NSString stringWithFormat:@"%ld", (long)count] : nil;
    [[NSApp dockTile] setBadgeLabel:strval];
}

/**
 * 过滤Emoji表情字符
 */
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
     
     return returnValue;
}

+ (BOOL) didProgressLaunched:(NSString *)bundleId
{
    BOOL result = NO;
    
    ProcessSerialNumber psn = { kNoProcess, kNoProcess };
    while (GetNextProcess(&psn) == noErr) {
        CFDictionaryRef cfDict = ProcessInformationCopyDictionary(&psn,  kProcessDictionaryIncludeAllInformationMask);
        if (cfDict) {
            NSString *bundleid = [(NSDictionary *)cfDict objectForKey:(id)kCFBundleIdentifierKey];
            if ( [bundleId isEqualToString:bundleid] ) {
                result = YES;
                break;
            }
            
            CFRelease(cfDict);
        }
    }
    return result;
}

+(BOOL)islink
{
    struct sockaddr_in zeroAddress;  
    bzero(&zeroAddress, sizeof(zeroAddress));  
    zeroAddress.sin_len = sizeof(zeroAddress);  
    zeroAddress.sin_family = AF_INET;  
    // 以下objc相关函数、类型需要添加System Configuration 框架  
    // 用0.0.0.0来判断本机网络状态  
    SCNetworkReachabilityRef defaultRouteReachability=SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);  
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags= SCNetworkReachabilityGetFlags(defaultRouteReachability,&flags); 
    if (defaultRouteReachability) {
        CFRelease(defaultRouteReachability);  
    }
    if (!didRetrieveFlags)  
    {  
        return NO;  
    }  
    //kSCNetworkFlagsReachable:    能够连接网络
    BOOL isReachable = flags & kSCNetworkFlagsReachable;  
    //kSCNetworkFlagsConnectionRequired:     能够连接网络，但是首先得建立连接过程
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;  
    return (isReachable && !needsConnection) ? YES : NO;
}

+(BOOL) unzip:(NSString*)srcpath
          dst:(NSString*)dstpath
{
    BOOL bVal =NO;
    @try {
        NSString *source = [NSString stringWithFormat:
                            @"tell application \"System Events\"\n"
                            @"  try\n"
                            @"      do shell script \"unzip -qo -d '%@' '%@'\"\n"
                            @"      return 1\n"
                            @"  on error\n"
                            @"      return 0\n"
                            @"  end try\n"
                            @"end tell",
                            dstpath,srcpath];
        NSAppleScript* duplicate = [[[NSAppleScript alloc] initWithSource:source] autorelease];
        NSAppleEventDescriptor* descriptor=[duplicate executeAndReturnError:nil];
        bVal = descriptor.booleanValue;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return bVal;
}

+(BOOL) zip:(NSString*)srcpath
        dst:(NSString*)dstpath
{
    BOOL bVal =NO;
    if (![self existfile:srcpath]) {
        return NO;
    }
    @try {
        NSString *source = [NSString stringWithFormat:
                            @"tell application \"System Events\"\n"
                            @"  try\n"
                            @"      do shell script \"cd '%@'\n zip -r '%@' . -x *__MACOSX/* *.DS_Store\"\n"
                            @"      return 1\n"
                            @"  on error\n"
                            @"      return 0\n"
                            @"  end try\n"
                            @"end tell",
                            srcpath,dstpath];
        NSAppleScript* duplicate = [[[NSAppleScript alloc] initWithSource:source] autorelease];
        NSAppleEventDescriptor* descriptor=[duplicate executeAndReturnError:nil];
        bVal = descriptor.booleanValue;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return bVal;
}

+(NSString*)ChangeHost:(NSString*)host
{
    if ([Util getAppDelegate].strHost.length>0) {
        return [Util getAppDelegate].strHost;
    }
    else {
        if ([Util getAppDelegate].strArea.length) {
            if ([host hasPrefix:[Util getAppDelegate].strArea]) {
                return [NSString stringWithFormat:@"%@-internal.aliyuncs.com",host];
            }
            else {
                return [NSString stringWithFormat:@"%@.aliyuncs.com",host];
            }
        }
        else {
            return [NSString stringWithFormat:@"%@.aliyuncs.com",host];
        }
    }
}

@end

