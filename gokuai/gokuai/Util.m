#import "Util.h"
#import "NSStringExpand.h"
#import "NSDataExpand.h"
#import "JSONKit.h"
#import "Common.h"
#import "AppDelegate.h"

@implementation Util

+(AppDelegate *)getAppDelegate
{
    return (AppDelegate*)[NSApplication sharedApplication].delegate;
}

+(NSString*) localizedStringForKey:(NSString*) key alternate:(NSString*) alternate
{
    return key;
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

+(CGImageRef) convertToCGImageFromNasImage:(NSImage *) image {
    NSData* cocoaData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [image representations]];
    CFDataRef carbonData = (CFDataRef)cocoaData;
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
    CGImageRef myCGImage = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
    CFRelease(imageSourceRef);
    return myCGImage;
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
        case WEB_SUCCESS:
            return @"";
        case WEB_JSONERROR:
            return [Util localizedStringForKey:@"参数格式不正确" alternate:nil];
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

+(NSDictionary*) dictionaryWithJsonInfo:(NSString*) jsonInfo
{
    return [jsonInfo objectFromJSONString];
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

