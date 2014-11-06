////////////////////////////////////////////////////////////////////////////////////////////////

#import "GKWebViewDelegate.h"

#import "JSONKit.h"
#import "FileMD5Hash.h"
#import "NSAlert+Blocks.h"
#import "NSStringExpand.h"
#import "Util.h"
#import "Common.h"
#import "SettingsDb.h"
#import "MyTask.h"
#import "OperationManager.h"

#import "AppDelegate.h"
#import "BrowserWebWindowController.h"
#import "LaunchpadWindowController.h"
#import "LoginWebWindowController.h"
#import "ProgressWindowController.h"
#import "MoveAndPasteWindowController.h"

#import "NSAlert+SynchronousSheet.h"

#import "OSSApi.h"
#import "Network.h"
#import "OSSRsa.h"



////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GKWebViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////

@synthesize delegateController;
@synthesize _bWindowsCloes;

////////////////////////////////////////////////////////////////////////////////////////////////

-(id)initWithDelegateController:(id)controller
{
    if (self=[super init]) {
        self.delegateController = controller;
        self._bWindowsCloes=NO;
        [WebView registerURLSchemeAsLocal:@"http"];
        [WebView registerURLSchemeAsLocal:@"https"];
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BrowserWebWindowController*) BrowserWebWindowController:(NSString*) url resizable:(BOOL)resize sole:(BOOL)sole solestr:(NSString*)solestr size:(NSSize)size
{
    BrowserWebWindowController* browserController=nil;
    if (!sole) {
        browserController=[[BrowserWebWindowController alloc]initWithWindowNibName:@"BrowserWebWindowController"];
    }
    else {
        browserController=[[Util getAppDelegate] getBrowserWebWindowController:solestr];
    }

    browserController.strUrl=url;
    browserController.solestr=solestr;

    if (resize) {
        browserController.window.styleMask|=NSResizableWindowMask;
        [browserController.window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    }
    else {
        //default: see xib
    }
    
    [browserController adjustframe:size];
    [browserController setAlertFrame];
    
    if ([@"child" isEqualToString:solestr]) {
        browserController.bClose=YES;
        
        [NSApp beginSheet:browserController.window modalForWindow:[(NSWindowController*)delegateController window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        [NSApp endSheet:browserController.window];
    }
    else {
        [NSApp activateIgnoringOtherApps:YES];
        [browserController showWindow:self];
    }
    
    return browserController;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)onOpenMainWindowInfo:(NSString*) jsonInfo
{
    NSDictionary* dicInfo=[jsonInfo objectFromJSONString];
    if (![dicInfo isKindOfClass:[NSDictionary class]]) {
        goto END;
    }
    
    NSString* type = [dicInfo objectForKey:@"type"];
    NSString* url = [dicInfo objectForKey:@"url"];
    NSInteger width = [[dicInfo objectForKey:@"width"] intValue];
    NSInteger height = [[dicInfo objectForKey:@"height"] intValue];
    BOOL resize=[[dicInfo objectForKey:@"resize"] boolValue];
    
    if ([@"child" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:NO  solestr:type size:NSMakeSize(width, height)];
    }
    else if ([@"normal" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:NO  solestr:type size:NSMakeSize(width, height)];
    }
    else if ([@"sole" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:YES solestr:type size:NSMakeSize(width, height)];
    }
    else if ([@"single" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:YES solestr:type size:NSMakeSize(width, height)];
    }
    
END:
    return;
}

-(NSString*) getAccessID
{
    return [NSString stringWithFormat:@"\"%@\"",[Util getAppDelegate].strAccessID];
}

-(NSString*) getSignature:(NSString*)json
{
    NSDictionary* dicInfo=[json objectFromJSONString];
    if (![dicInfo isKindOfClass:[NSDictionary class]]) {
        return @"{}";
    }
    NSString* verb = [dicInfo objectForKey:@"verb"];
    NSString* contentmd5 = [dicInfo objectForKey:@"content_md5"];
    NSString* contenttype = [dicInfo objectForKey:@"content_type"];
    NSInteger expires = [[dicInfo objectForKey:@"expires"] intValue];
    NSString* resource = [dicInfo objectForKey:@"canonicalized_resource"];
    NSDictionary* dicItems=[dicInfo objectForKey:@"canonicalized_oss_headers"];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if ([dicItems isKindOfClass:[NSDictionary class]]) {
        NSArray* arraykey=[dicItems allKeys];
        for (NSString* itemkey in arraykey) {
            OssSignKey *item=[[OssSignKey alloc]init];
            item.key=itemkey;
            item.value=[dicInfo objectForKey:itemkey];
            if (item.key.length&&item.value.length) {
                [array addObject:item];
            }
            [item release];
        }
    }
    NSString * ret=[OSSApi Signature:verb contentmd5:contentmd5 contenttype:contenttype date:expires keys:array resource:resource];
    return [NSString stringWithFormat:@"\"%@\"",ret];
}

-(void) addFile:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"addFile" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(void) saveFile:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"saveFile" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    } 
}

-(void) selectFileDlg:(NSString*) json cb:(WebScriptObject*)cb
{
    NSOpenPanel* panel=[Util OpenPanelAddFiles:nil :nil];
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    [panel beginSheetModalForWindow:baseController.window completionHandler:^(NSInteger result) {
        
        NSString* retString=@"{}";
        if (NSOKButton!=result) {
            goto END;
        }
        NSArray *urls=[panel URLs];
        NSMutableArray* arrayGet=[NSMutableArray arrayWithCapacity:urls.count];
        for (int i=0; i<urls.count; i++) {
            [arrayGet addObject:((NSURL*)[urls objectAtIndex:i]).path];
        };
        NSMutableArray* arrayRet=[NSMutableArray arrayWithCapacity:arrayGet.count];
        for (int i=0; i<arrayGet.count; i++) {
            NSDictionary* dic=[NSDictionary dictionaryWithObjectsAndKeys:[arrayGet objectAtIndex:i],@"path",nil];
            [arrayRet addObject:dic];
        }
        retString = [[NSDictionary dictionaryWithObjectsAndKeys:arrayRet,@"list", nil] JSONString];
        
    END:
        [Util webScriptObjectCallback:cb webFrame:[baseController mainframe] jsonString:retString];
    }];
}

-(NSString*) getUpload:(NSString*)json
{
    NSDictionary* dicInfo=[json objectFromJSONString];
    NSInteger nStart=0;
    NSInteger nCount=100;
    if ([dicInfo isKindOfClass:[NSDictionary class]]) {
        nStart = [[dicInfo objectForKey:@"start"] intValue];
        nCount = [[dicInfo objectForKey:@"count"] intValue];
    }
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    NSMutableArray* arrayRet=[NSMutableArray array];
    NSMutableArray * uploadlist=[[TransPortDB shareTransPortDB] Get_AllUpload:nStart count:nCount];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nDownloadSpeed] forKey:@"download"];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nUploadSpeed] forKey:@"upload"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDownloadCount] forKey:@"download_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDonwloadFinish] forKey:@"download_done_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadCount] forKey:@"upload_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadFinish] forKey:@"upload_done_count"];
    for (TransTaskItem* item in uploadlist) {
        NSMutableDictionary* dicRet=[NSMutableDictionary dictionary];
        if (item.nStatus==TRANSTASK_START) {
            item.ullSpeed=[[Network shareNetwork].uManager GetSpeed:item.strBucket object:item.strObject];
        }
        [dicRet setValue:item.strPathhash forKey:@"pathhash"];
        [dicRet setValue:item.strBucket forKey:@"bucket"];
        [dicRet setValue:item.strObject forKey:@"object"];
        [dicRet setValue:item.strFullpath forKey:@"fullpath"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullOffset] forKey:@"offset"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullFilesize] forKey:@"filesize"];
        [dicRet setValue:[NSNumber numberWithInteger:item.nStatus] forKey:@"status"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullSpeed] forKey:@"speed"];
        [dicRet setValue:item.strMsg forKey:@"errormsg"];
        [arrayRet addObject:dicRet];
    }
    [dicRetlist setValue:arrayRet forKey:@"list"];
    return [dicRetlist JSONString];
}

-(NSString*) getDownload:(NSString*)json
{
    NSDictionary* dicInfo=[json objectFromJSONString];
    NSInteger nStart=0;
    NSInteger nCount=100;
    if ([dicInfo isKindOfClass:[NSDictionary class]]) {
        nStart = [[dicInfo objectForKey:@"start"] intValue];
        nCount = [[dicInfo objectForKey:@"count"] intValue];
    }
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    NSMutableArray* arrayRet=[NSMutableArray array];
    NSMutableArray * downloadlist=[[TransPortDB shareTransPortDB] Get_AllDownload:nStart count:nCount];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nDownloadSpeed] forKey:@"download"];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[Network shareNetwork].nUploadSpeed] forKey:@"upload"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDownloadCount] forKey:@"download_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nDonwloadFinish] forKey:@"download_done_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadCount] forKey:@"upload_total_count"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[Network shareNetwork].nUploadFinish] forKey:@"upload_done_count"];
    for (TransTaskItem* item in downloadlist) {
        NSMutableDictionary* dicRet=[NSMutableDictionary dictionary];
        if (item.nStatus==TRANSTASK_START) {
            item.ullSpeed=[[Network shareNetwork].dManager GetSpeed:item.strBucket object:item.strObject];
        }
        [dicRet setValue:item.strBucket forKey:@"bucket"];
        [dicRet setValue:item.strObject forKey:@"object"];
        [dicRet setValue:item.strFullpath forKey:@"fullpath"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullOffset] forKey:@"offset"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullFilesize] forKey:@"filesize"];
        [dicRet setValue:[NSNumber numberWithInteger:item.nStatus] forKey:@"status"];
        [dicRet setValue:[NSNumber numberWithLongLong:item.ullSpeed] forKey:@"speed"];
        [dicRet setValue:item.strMsg forKey:@"errormsg"];
        [arrayRet addObject:dicRet];
    }
    [dicRetlist setValue:arrayRet forKey:@"list"];
    return [dicRetlist JSONString];
}

-(void) startUpload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"startUpload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    } 
}

-(void) startDownload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"startDownload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    } 
}

-(void) stopUpload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"stopUpload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    } 
}

-(void) stopDownload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"stopDownload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    } 
}

-(void) deleteUpload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"deleteUpload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    } 
}

-(void) deleteDownload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"deleteDownload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }  
}

-(NSString*) getClipboardData
{
    NSPasteboard * paste=[NSPasteboard generalPasteboard];
    NSArray* filenames = [paste propertyListForType:NSFilenamesPboardType];
    if (filenames.count) {
        NSMutableArray* retArray=[NSMutableArray arrayWithCapacity:filenames.count];
        for (NSString* string in filenames) {
            [retArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:string,@"path", nil]];
        }
        NSDictionary* retDic=[NSDictionary dictionaryWithObjectsAndKeys:retArray,@"list", nil];
        return [retDic JSONString];
    }
    return @"{}";
}

-(NSString*) getDragFiles
{
    if ([NSStringFromClass([delegateController class]) isEqualToString:@"LaunchpadWindowController"]) {
        return [(LaunchpadWindowController*)delegateController dragInformation];
    }
    return @"";
}

-(void) deleteObject:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"deleteObject" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(void) copyObject:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"copyObject" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(void) changeUpload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[Network shareNetwork].uCallback SetCallbackStatus:[baseController mainframe] cb:cb];
    }
}

-(void) changeDownload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[Network shareNetwork].dCallback SetCallbackStatus:[baseController mainframe] cb:cb];
    }
}

-(NSString*) getErrorLog
{
    //zheng
    return nil;
}

-(void) loginByKey:(NSString*) json cb:(WebScriptObject*)cb
{
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    [[OperationManager sharedInstance] pack:@"loginByKey" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    /*
     if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
     BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
     [[OperationManager sharedInstance] pack:@"loginByKey" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
     }*/
}

-(void) loginByFile:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"loginByFile" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(void) setPassword:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"setPassword" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(void) loginPassword:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"loginPassword" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(void) setServerLocation:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"setServerLocation" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(void) saveAuthorization:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"saveAuthorization" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}

-(NSString*) getDeviceEncoding
{
    NSString * device=[OSSRsa getcomputerid];
    return [NSString stringWithFormat:@"\"%@\"",[device sha1HexDigest]];
}

-(void) showLaunchpad
{
    [[Util getAppDelegate] OpenLaunchpadWindow];
}

-(void) setClipboardData:(NSString*)json
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pboard setString:json forType:NSPasteboardTypeString];
}

-(void) closeWnd
{
    [(NSWindowController*)delegateController close];
}

-(void) showWnd:(NSString*)json
{
    NSDictionary* dicInfo=[json objectFromJSONString];
    if (![dicInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString* type = [dicInfo objectForKey:@"type"];
    NSString* url = [dicInfo objectForKey:@"url"];
    NSInteger width = [[dicInfo objectForKey:@"width"] intValue];
    NSInteger height = [[dicInfo objectForKey:@"height"] intValue];
    BOOL resize=[[dicInfo objectForKey:@"resize"] boolValue];
    
    if ([@"child" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:NO  solestr:type size:NSMakeSize(width, height)];
    }
    else if ([@"normal" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:NO  solestr:type size:NSMakeSize(width, height)];
    }
    else if ([@"sole" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:YES solestr:type size:NSMakeSize(width, height)];
    }
    else if ([@"single" isEqualToString:type]) {
        [self BrowserWebWindowController:url resizable:resize sole:YES solestr:type size:NSMakeSize(width, height)];
    }
}

-(void) clearPassword
{
    [[SettingsDb shareSettingDb] deleteuserinfo];
}

-(void) showAuthorizationDlg
{
    //zheng
}

-(NSString*) getUIPath
{
    return [NSString stringWithFormat:@"\"%@\"",[Util getAppDelegate].strUIPath];
}

-(void) openLogFolder
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[Util getAppDelegate].strLogPath]];
}

-(void) deleteBucket:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"deleteBucket" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController];
    }
}
-(NSString*) changeHost:(NSString*)json
{
    NSString * host=@"";
    if (json.length>2) {
        NSRange range=NSMakeRange(1, json.length-2);
        host=[json substringWithRange:range];
    }
    else {
        host=json;
    }
    return [NSString stringWithFormat:@"\"%@\"",[Util ChangeHost:host]];
}
////////////////////////////////////////////////////////////////////////////////////////////////

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(getAccessID)
        ||selector == @selector(getSignature:)
        ||selector == @selector(addFile:cb:)
        ||selector == @selector(saveFile:cb:)
        ||selector == @selector(selectFileDlg:cb:)
        ||selector == @selector(getUpload:)
        ||selector == @selector(getDownload:)
        ||selector == @selector(startUpload:cb:)
        ||selector == @selector(startDownload:cb:)
        ||selector == @selector(stopUpload:cb:)
        ||selector == @selector(stopDownload:cb:)
        ||selector == @selector(deleteUpload:cb:)
        ||selector == @selector(deleteDownload:cb:)
        ||selector == @selector(getClipboardData)
        ||selector == @selector(getDragFiles)
        ||selector == @selector(deleteObject:cb:)
        ||selector == @selector(copyObject:cb:)
        ||selector == @selector(changeUpload:cb:)
        ||selector == @selector(changeDownload:cb:)
        ||selector == @selector(getErrorLog)
        ||selector == @selector(loginByKey:cb:)
        ||selector == @selector(loginByFile:cb:)
        ||selector == @selector(setPassword:cb:)
        ||selector == @selector(loginPassword:cb:)
        ||selector == @selector(setServerLocation:cb:)
        ||selector == @selector(saveAuthorization:cb:)
        ||selector == @selector(getDeviceEncoding)
        ||selector == @selector(showLaunchpad)
        ||selector == @selector(setClipboardData:)
        ||selector == @selector(closeWnd)
        ||selector == @selector(showWnd:)
        ||selector == @selector(clearPassword)
        ||selector == @selector(showAuthorizationDlg)
        ||selector == @selector(getUIPath)
        ||selector == @selector(openLogFolder)
        ||selector == @selector(deleteBucket:cb:)
        ||selector == @selector(changeHost:)
        ) {
        return NO;
    }
    return YES;
}

+ (NSString *) webScriptNameForSelector:(SEL)sel {
    NSString* ret=nil;
    if (sel == @selector(getAccessID)) {
		ret=@"getAccessID";
    }
    else if (sel == @selector(getSignature:)) {
        ret=@"getSignature";
    }
    else if (sel == @selector(addFile:cb:)) {
        ret=@"addFile";
    }
    else if (sel == @selector(saveFile:cb:)) {
        ret=@"saveFile";
    }
    else if (sel == @selector(selectFileDlg:cb:)) {
		ret=@"selectFileDlg";
    }
    else if (sel == @selector(getUpload:)) {
		ret=@"getUpload";
    }
    else if (sel == @selector(getDownload:)) {
		ret=@"getDownload";
    }
    else if (sel == @selector(startUpload:cb:)) {
        ret=@"startUpload";
    }
    else if (sel == @selector(startDownload:cb:)) {
        ret=@"startDownload";
    }
    else if (sel == @selector(stopUpload:cb:)) {
		ret=@"stopUpload";
    }
    else if (sel == @selector(stopDownload:cb:)) {
		ret=@"stopDownload";
    }
    else if (sel == @selector(deleteUpload:cb:)) {
		ret=@"deleteUpload";
    }
    else if (sel == @selector(deleteDownload:cb:)) {
        ret=@"deleteDownload";
    }
    else if (sel == @selector(getClipboardData)) {
        ret=@"getClipboardData";
    }
    else if (sel == @selector(getDragFiles)) {
        ret=@"getDragFiles";
    }
    else if (sel == @selector(deleteObject:cb:)) {
        ret=@"deleteObject";
    }
    else if (sel == @selector(copyObject:cb:)) {
		ret=@"copyObject";
    }
    else if (sel == @selector(changeUpload:cb:)) {
        ret=@"changeUpload";
    }
    else if (sel == @selector(changeDownload:cb:)) {
        ret=@"changeDownload";
    }
    else if (sel == @selector(getErrorLog)) {
        ret=@"getErrorLog";
    }
    else if (sel == @selector(loginByKey:cb:)) {
		ret=@"loginByKey";
    }
    else if (sel == @selector(loginByFile:cb:)) {
		ret=@"loginByFile";
    }
    else if (sel == @selector(setPassword:cb:)) {
		ret=@"setPassword";
    }
    else if (sel == @selector(loginPassword:cb:)) {
		ret=@"loginPassword";
    }
    else if (sel == @selector(setServerLocation:cb:)) {
		ret=@"setServerLocation";
    }
    else if (sel == @selector(saveAuthorization:cb:)) {
		ret=@"saveAuthorization";
    }
    else if (sel == @selector(getDeviceEncoding)) {
		ret=@"getDeviceEncoding";
    }
    else if (sel == @selector(showLaunchpad)) {
		ret=@"showLaunchpad";
    }
    else if (sel == @selector(setClipboardData:)) {
        ret=@"setClipboardData";
    }
    else if (sel == @selector(closeWnd)) {
        ret=@"closeWnd";
    }
    else if (sel == @selector(showWnd:)) {
        ret=@"showWnd";
    }
    else if (sel == @selector(clearPassword)) {
        ret=@"clearPassword";
    }
    else if (sel == @selector(showAuthorizationDlg)) {
        ret=@"showAuthorizationDlg";
    }
    else if (sel == @selector(getUIPath)) {
        ret=@"getUIPath";
    }
    else if (sel == @selector(openLogFolder)) {
        ret=@"openLogFolder";
    }
    else if (sel == @selector(deleteBucket:cb:)) {
        ret=@"deleteBucket";
    }
    else if (sel == @selector(changeHost:)) {
        ret=@"changeHost";
    }
    else {
		ret=nil;
	}
    return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark-
#pragma mark  NSAlert Delegate

- (void)webView:(WebView *)webView windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject {
    [windowScriptObject setValue:self forKey:@"OSSClient"];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    if ( [NSStringFromClass([delegateController class]) isEqualToString:@"BrowserWebWindowController"]) {
  //      [[(BrowserWebWindowController*)delegateController lblAlert] setHidden:NO];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if (self._bWindowsCloes) {
        return;
    }
    @try {
        if ([NSStringFromClass([delegateController class]) isEqualToString:@"LoginWebWindowController"]) {
//            [(LoginWebWindowController*)delegateController onJudgeDealArray];
        }
        if ([NSStringFromClass([delegateController class]) isEqualToString:@"LaunchpadWindowController"]) {
            if (![[frame name] length]) {
                [[(NSWindowController*)delegateController window] setTitle:[sender stringByEvaluatingJavaScriptFromString:@"document.title"]];
            }
        }
        if ( [NSStringFromClass([delegateController class]) isEqualToString:@"BrowserWebWindowController"]) {
            [[(NSWindowController*)delegateController window] setTitle:[sender stringByEvaluatingJavaScriptFromString:@"document.title"]];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)property {
    
    return NO;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    return defaultMenuItems;
    //return nil; zheng
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert* alert=[NSAlert alertWithMessageText:[Util localizedStringForKey:@"温馨提示" alternate:nil]
                                   defaultButton:[Util localizedStringForKey:@"我知道了" alternate:nil] alternateButton:nil
                                     otherButton:nil informativeTextWithFormat:@"%@",message];
    [alert runModalSheetForWindow:[(NSWindowController*)delegateController window]];
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert* alert=[NSAlert alertWithMessageText:[Util localizedStringForKey:@"温馨提示" alternate:nil]
                                   defaultButton:[Util localizedStringForKey:@"确定" alternate:nil] alternateButton:[Util localizedStringForKey:@"取消" alternate:nil]
                                     otherButton:nil informativeTextWithFormat:@"%@",message];
    NSInteger ret=0;
    ret=[alert runModalSheetForWindow:[(NSWindowController*)delegateController window]];
    return (NSAlertFirstButtonReturn==ret)?YES:NO;
}


- (BOOL)webView:(WebView *)sender runBeforeUnloadConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert* alert=[NSAlert alertWithMessageText:[Util localizedStringForKey:@"温馨提示" alternate:nil]
                                   defaultButton:[Util localizedStringForKey:@"确定" alternate:nil] alternateButton:[Util localizedStringForKey:@"取消" alternate:nil]
                                     otherButton:nil informativeTextWithFormat:@"%@",message];
    
    NSInteger ret=0;
    ret=[alert runModalSheetForWindow:[(NSWindowController*)delegateController window]];
    return (NSAlertFirstButtonReturn==ret)?YES:NO;
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (self._bWindowsCloes) {
        return;
    }
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (self._bWindowsCloes) {
        return;
    }
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    
    [NSApp beginSheet:openDlg modalForWindow:[(NSWindowController*)delegateController window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    NSInteger iRet=[openDlg runModal];
    [NSApp endSheet:openDlg];
    
    if (NSOKButton==iRet) {
        NSURL *url=[[openDlg URLs] objectAtIndex:0];
        [resultListener chooseFilename:url.path];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    [listener use];
}

- (void)webView:(WebView *)webView willPerformDragSourceAction:(WebDragSourceAction)action fromPoint:(NSPoint)point withPasteboard:(NSPasteboard *)pasteboard;
{
    if ( [delegateController isKindOfClass:[LaunchpadWindowController class]] ) {
        LaunchpadWindowController *launchpadController = (LaunchpadWindowController *)delegateController;
        
        NSMutableArray *arrayval = [NSMutableArray array];
        for (drag_item *dragitem in launchpadController._dragitems) {

            if (dragitem.cached) {
                [arrayval addObject:dragitem.fullpath];
            }
        }
        
        if (arrayval.count) {
            [pasteboard declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil] owner:self];
            [pasteboard setPropertyList:arrayval forType:NSFilenamesPboardType];
        }
    }
}

@end
