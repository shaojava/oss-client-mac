////////////////////////////////////////////////////////////////////////////////////////////////

#import "GKWebViewDelegate.h"

#import "JSONKit.h"
#import "FileMD5Hash.h"
#import "NSAlert+Blocks.h"
#import "NSStringExpand.h"
#import "Util.h"
#import "Common.h"
#import "SettingsDb.h"
#import "OperationManager.h"
#import "TransPortDB.h"
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
#import "FileLog.h"


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

    browserController.strUrl=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            item.value=[dicItems objectForKey:itemkey];
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
        [[OperationManager sharedInstance] pack:@"addFile" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    }
}

-(void) saveFile:(NSString*) json cb:(WebScriptObject*)cb
{
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    NSString* retString=[Util errorInfoWithCode:WEB_SUCCESS];
    NSDictionary* dictionary=[json objectFromJSONString];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        NSString* path=[dictionary objectForKey:@"path"];
        NSArray* list = [dictionary objectForKey:@"list"];
        if ([list isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:list.count];
            for (int i=0; i<list.count; i++) {
                NSDictionary* dic=[list objectAtIndex:i];
                SaveFileItem* savItem=[[[SaveFileItem alloc]init] autorelease];
                savItem.strBucket=[dic objectForKey:@"bucket"];
                savItem.strObject=[dic objectForKey:@"object"];
                savItem.strHost=[Util ChangeHost:[dic objectForKey:@"location"]];
                savItem.ullFilesize=[[dic objectForKey:@"filesize"] longLongValue];
                savItem.strEtag=[dic objectForKey:@"etag"];
                if (savItem.strEtag.length==0) {
                    savItem.strEtag=@"";
                }
                NSString * temp=savItem.strObject;
                if ([savItem.strObject hasSuffix:@"/"]) {
                    savItem.bDir=YES;
                    temp=[savItem.strObject substringToIndex:savItem.strObject.length-1];
                }
                if (savItem.strObject.length==0) {
                    savItem.bDir=YES;
                    temp=savItem.strBucket;
                }
                savItem.strFullpath=[NSString stringWithFormat:@"%@/%@",path,[temp lastPathComponent]];
                if (savItem.strObject.length&&savItem.strBucket.length) {
                    [array addObject:savItem];
                }
            }
            MoveAndPasteWindowController* moveController=[[Util getAppDelegate] getMoveAndPasteWindowController];
            if (![moveController savefiles:array savepath:path]) {
                goto END;
            }
            [[OperationManager sharedInstance] pack:@"saveFile" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:array];
            return ;
        }
    }
END:
    [Util webScriptObjectCallback:cb webFrame:[baseController mainframe] jsonString:retString];
}

-(void) saveFileDlg:(WebScriptObject*)cb
{
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    NSOpenPanel *panel=[Util OpenPanelSelectPath:baseController.window :[[SettingsDb shareSettingDb] getDownloadPath]];
    [panel beginSheetModalForWindow:baseController.window completionHandler:^(NSInteger result) {
        NSString* retString=@"{\"path\":\"\"}";
        if (NSOKButton!=result) {
            goto END;
        }
        NSURL *url=[[panel URLs] objectAtIndex:0];
        NSString* path=url.path;
        [[SettingsDb shareSettingDb] setDownloadPath:path]; 
        NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:path,@"path",nil];
        retString=[dicRet JSONString];
    END:
        [Util webScriptObjectCallback:cb webFrame:[baseController mainframe] jsonString:retString];
    }];
}


-(void) selectFileDlg:(NSString*) json cb:(WebScriptObject*)cb
{
    NSOpenPanel* panel=[Util OpenPanelAddFiles:nil :[[SettingsDb shareSettingDb] getUploadPath]];
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    [panel beginSheetModalForWindow:baseController.window completionHandler:^(NSInteger result) {
        NSString* retString=@"{}";
        if (NSOKButton!=result) {
            goto END;
        }
        NSArray *urls=[panel URLs];
        if (urls.count>0) {
            [[SettingsDb shareSettingDb] setUploadPath:((NSURL*)[urls objectAtIndex:0]).path];
        }
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
        [[OperationManager sharedInstance] pack:@"startUpload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    } 
}

-(void) startDownload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"startDownload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    } 
}

-(void) stopUpload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"stopUpload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    } 
}

-(void) stopDownload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"stopDownload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    } 
}

-(void) deleteUpload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"deleteUpload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    } 
}

-(void) deleteDownload:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"deleteDownload" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
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
        [[OperationManager sharedInstance] pack:@"deleteObject" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    }
}

-(void) copyObject:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"copyObject" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
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
    return [[FileLog shareFileLog] GetLog];
}

-(void) loginByKey:(NSString*) json cb:(WebScriptObject*)cb
{
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    [[OperationManager sharedInstance] pack:@"loginByKey" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
}

-(void) loginByFile:(NSString*) json cb:(WebScriptObject*)cb
{
    NSString* strRet=@"";
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanCreateDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTitle:@"选择授权文件"];
    [panel setPrompt:@"选择"];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"key",nil]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    [NSApp beginSheet:panel modalForWindow:baseController.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    NSInteger iRet=[panel runModal];
    [NSApp endSheet:panel];
    NSString* retString=@"{}";
    if (NSOKButton==iRet) {
        NSURL *url=[[panel URLs] objectAtIndex:0];
        strRet=url.path;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        [array addObject:strRet];
        [[OperationManager sharedInstance] pack:@"loginByFile" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:array];
    }
    else {
        retString=[Util errorInfoWithCode:WEB_UNSELECTFILE];
        [Util webScriptObjectCallback:cb webFrame:[baseController mainframe] jsonString:retString];
    }
}

-(void) setPassword:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"setPassword" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    }
}

-(void) loginPassword:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"loginPassword" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    }
}

-(void) setServerLocation:(NSString*) json cb:(WebScriptObject*)cb
{
    if ([delegateController isKindOfClass:[BaseWebWindowController class]]) {
        BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
        [[OperationManager sharedInstance] pack:@"setServerLocation" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
    }
}

-(void) saveAuthorization:(NSString*) json cb:(WebScriptObject*)cb
{
    BaseWebWindowController* baseController=(BaseWebWindowController*)delegateController;
    NSString* strRet=@"{}";
    NSDictionary *dictionary = [Util dictionaryWithJsonInfo:json];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        strRet=[Util errorInfoWithCode:WEB_JSONERROR];
    }
    else {
        NSSavePanel* panel=[NSSavePanel savePanel];
        [panel setCanCreateDirectories:NO];
        [panel setNameFieldStringValue:@"oss.key"];
        [panel setTitle:@"保存授权文件"];
        [panel setPrompt:@"保存"];
        [panel setExtensionHidden:NO];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"key",nil]];
        [panel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
        [NSApp beginSheet:panel modalForWindow:baseController.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        NSInteger iRet=[panel runModal];
        [NSApp endSheet:panel];
        if (NSOKButton==iRet) {
            NSURL *url=[panel URL];
            NSString* strPath=url.path;
            [Util createfile:strRet];
            NSString* keyid=[dictionary objectForKey:@"keyid"];
            NSString* keysecret=[dictionary objectForKey:@"keysecret"];
            NSString* encoding=[dictionary objectForKey:@"encoding"];
            OSSRsaItem* ret=[OSSRsa EncryptKey:[keyid dataUsingEncoding:NSUTF8StringEncoding] secret:[keysecret dataUsingEncoding:NSUTF8StringEncoding] device:encoding];
            if (ret.ret) {
                BOOL fileret=[Util createfile:strPath];
                if (fileret) {
                    NSFileHandle *pFile=[NSFileHandle fileHandleForWritingAtPath:strPath];
                    if (pFile) {
                        [pFile seekToFileOffset:0];
                        [pFile writeData:[OSSRsa GetGuid]];
                        NSUInteger checklength =ret.check.length;
                        [pFile writeData:[NSData dataWithBytes:&checklength length:4]];
                        [pFile writeData:ret.check];
                        NSUInteger keylength =ret.key.length;
                        [pFile writeData:[NSData dataWithBytes:&keylength length:4]];
                        [pFile writeData:ret.key];
                        NSUInteger secretlength =ret.secret.length;
                        [pFile writeData:[NSData dataWithBytes:&secretlength length:4]];
                        [pFile writeData:ret.secret];
                        [pFile synchronizeFile];
                        [pFile closeFile];
                    }
                    else {
                        fileret=NO;
                    }
                }
                if (fileret) {
                    strRet=[Util errorInfoWithCode:WEB_SUCCESS];
                }
                else {
                    strRet=[Util errorInfoWithCode:WEB_FILESAVEERROR];
                    NSString * msg=[NSString stringWithFormat:@"[创建授权文件失败][%@]",strPath];
                    [[FileLog shareFileLog] log:msg add:NO];
                }
            }
            else {
                strRet=[Util errorInfoWithCode:WEB_ENCRYPTERROR];
            }
        }
        else {
            strRet=[Util errorInfoWithCode:WEB_UNSELECTFILE];
        }
    }
    [Util webScriptObjectCallback:cb webFrame:[baseController mainframe] jsonString:strRet];
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
    NSString* tempjson=json;
    if (json.length>2) {
        NSRange range=NSMakeRange(1, json.length-2);
        tempjson=[json substringWithRange:range];
    }
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [pboard setString:tempjson forType:NSPasteboardTypeString];
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
        [[OperationManager sharedInstance] pack:@"deleteBucket" jsoninfo:json webframe:[baseController mainframe] cb:cb retController:baseController array:nil];
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

-(NSString*)configInfo;
{
    NSString* ret=@"";
    if ([Util getAppDelegate].strConfig) {
        ret=[Util getAppDelegate].strConfig;
    }
    return ret;
}

-(void)setTransInfo:(NSString*)json
{
    NSDictionary* dicInfo=[json objectFromJSONString];
    if (![dicInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSInteger dtm = [[dicInfo objectForKey:@"download_task_max"] intValue];
    NSInteger utm = [[dicInfo objectForKey:@"upload_task_max"] intValue];
    NSInteger dpm = [[dicInfo objectForKey:@"download_peer_max"] intValue];
    NSInteger upm = [[dicInfo objectForKey:@"upload_peer_max"] intValue];
    if (dtm>0) {
        [[SettingsDb shareSettingDb] setDMax:dtm];
        [[Network shareNetwork] SetDTaskMax:dtm];
    }
    if (utm>0) {
        [[SettingsDb shareSettingDb] setUMax:utm];
        [[Network shareNetwork] SetUTaskMax:utm];
    }
    if (dpm>0) {
        [[SettingsDb shareSettingDb] setDPMax:dpm];
        [[Network shareNetwork] SetDPeerMax:dpm];
    }
    if (upm>0) {
        [[SettingsDb shareSettingDb] setUPMax:upm];
        [[Network shareNetwork] SetUPeerMax:upm];
    }
}

-(NSString*)getTransInfo
{
    NSMutableDictionary* dicRetlist=[NSMutableDictionary dictionary];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[[SettingsDb shareSettingDb] getDMax]] forKey:@"download_task_max"];
    [dicRetlist setValue:[NSNumber numberWithLongLong:[[SettingsDb shareSettingDb] getUMax]] forKey:@"upload_task_max"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[[SettingsDb shareSettingDb] getDPMax]] forKey:@"download_peer_max"];
    [dicRetlist setValue:[NSNumber numberWithInteger:[[SettingsDb shareSettingDb] getUPMax]] forKey:@"upload_peer_max"];
    return [dicRetlist JSONString];
}

-(NSString*)getCurrentLocation
{
    NSString* ret=@"";
    if ([Util getAppDelegate].strArea.length) {
        ret=[NSString stringWithFormat:@"\"%@\"",[Util getAppDelegate].strArea];
    }
    return ret;
}

-(void)stopLoadDownload:(NSString*)json
{
    NSDictionary* dicInfo=[json objectFromJSONString];
    if (![dicInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSInteger all = [[dicInfo objectForKey:@"all"] intValue];
    if (all) {
        [Util getAppDelegate].bAddDownloadDelete=YES;
    }
    [Util getAppDelegate].bAddDownloadOut=YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(getAccessID)
        ||selector == @selector(getSignature:)
        ||selector == @selector(addFile:cb:)
        ||selector == @selector(saveFile:cb:)
        ||selector == @selector(saveFileDlg:)
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
        ||selector == @selector(configInfo)
        ||selector == @selector(setTransInfo:)
        ||selector == @selector(getTransInfo)
        ||selector == @selector(getCurrentLocation)
        ||selector == @selector(stopLoadDownload:)
        ) {
        return NO;
    }
    return YES;
}

+ (NSString *) webScriptNameForSelector:(SEL)sel {
    if (sel == @selector(getAccessID)) {
		return @"getAccessID";
    }
    if (sel == @selector(getSignature:)) {
        return @"getSignature";
    }
    if (sel == @selector(addFile:cb:)) {
        return @"addFile";
    }
    if (sel == @selector(saveFile:cb:)) {
        return @"saveFile";
    }
    if (sel == @selector(saveFileDlg:)) {
        return @"saveFileDlg";
    }
    if (sel == @selector(selectFileDlg:cb:)) {
		return @"selectFileDlg";
    }
    if (sel == @selector(getUpload:)) {
		return @"getUpload";
    }
    if (sel == @selector(getDownload:)) {
		return @"getDownload";
    }
    if (sel == @selector(startUpload:cb:)) {
        return @"startUpload";
    }
    if (sel == @selector(startDownload:cb:)) {
        return @"startDownload";
    }
    if (sel == @selector(stopUpload:cb:)) {
		return @"stopUpload";
    }
    if (sel == @selector(stopDownload:cb:)) {
		return @"stopDownload";
    }
    if (sel == @selector(deleteUpload:cb:)) {
		return @"deleteUpload";
    }
    if (sel == @selector(deleteDownload:cb:)) {
        return @"deleteDownload";
    }
    if (sel == @selector(getClipboardData)) {
        return @"getClipboardData";
    }
    if (sel == @selector(getDragFiles)) {
        return @"getDragFiles";
    }
    if (sel == @selector(deleteObject:cb:)) {
        return @"deleteObject";
    }
    if (sel == @selector(copyObject:cb:)) {
		return @"copyObject";
    }
    if (sel == @selector(changeUpload:cb:)) {
        return @"changeUpload";
    }
    if (sel == @selector(changeDownload:cb:)) {
        return @"changeDownload";
    }
    if (sel == @selector(getErrorLog)) {
        return @"getErrorLog";
    }
    if (sel == @selector(loginByKey:cb:)) {
		return @"loginByKey";
    }
    if (sel == @selector(loginByFile:cb:)) {
		return @"loginByFile";
    }
    if (sel == @selector(setPassword:cb:)) {
		return @"setPassword";
    }
    if (sel == @selector(loginPassword:cb:)) {
		return @"loginPassword";
    }
    if (sel == @selector(setServerLocation:cb:)) {
		return @"setServerLocation";
    }
    if (sel == @selector(saveAuthorization:cb:)) {
		return @"saveAuthorization";
    }
    if (sel == @selector(getDeviceEncoding)) {
		return @"getDeviceEncoding";
    }
    if (sel == @selector(showLaunchpad)) {
		return @"showLaunchpad";
    }
    if (sel == @selector(setClipboardData:)) {
        return @"setClipboardData";
    }
    if (sel == @selector(closeWnd)) {
        return @"closeWnd";
    }
    if (sel == @selector(showWnd:)) {
        return @"showWnd";
    }
    if (sel == @selector(clearPassword)) {
        return @"clearPassword";
    }
    if (sel == @selector(showAuthorizationDlg)) {
        return @"showAuthorizationDlg";
    }
    if (sel == @selector(getUIPath)) {
        return @"getUIPath";
    }
    if (sel == @selector(openLogFolder)) {
        return @"openLogFolder";
    }
    if (sel == @selector(deleteBucket:cb:)) {
        return @"deleteBucket";
    }
    if (sel == @selector(changeHost:)) {
        return @"changeHost";
    }
    if (sel == @selector(configInfo)) {
        return @"configInfo";
    }
    if (sel == @selector(setTransInfo:)) {
        return @"setTransInfo";
    }
    if (sel == @selector(getTransInfo)) {
        return @"getTransInfo";
    }
    if (sel == @selector(getCurrentLocation)) {
        return @"getCurrentLocation";
    }
    if (sel == @selector(stopLoadDownload:)) {
        return @"stopLoadDownload";
    }
    return nil;
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
            [Util getAppDelegate].bFinishCallback=YES;
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
    if ([Util getAppDelegate].bDebugMenu) {
        return defaultMenuItems;
    }
    else {
        return nil;
    }
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
