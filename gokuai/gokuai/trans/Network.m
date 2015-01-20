#import "Network.h"
#import "TransPortDB.h"
#import "NetworkDef.h"
#import "Util.h"
#import "NSStringExpand.h"
#import "SettingsDb.h"
#import "JSONKit.h"
#import "OSSApi.h"

@implementation Network

@synthesize dManager;
@synthesize uManager;
@synthesize dCallback;
@synthesize uCallback;
@synthesize nDonwloadFinish;
@synthesize nDownloadCount;
@synthesize nDownloadSpeed;
@synthesize nUploadFinish;
@synthesize nUploadCount;
@synthesize nUploadSpeed;
@synthesize nUPeerMax;
@synthesize nDPeerMax;

+(Network*)shareNetwork
{
    static Network* shareNetworkInstance = nil;
    static dispatch_once_t onceNetworkToken;
    dispatch_once(&onceNetworkToken, ^{
        shareNetworkInstance = [[Network alloc]init];
        
    });
    return shareNetworkInstance;
}

-(id)init
{
    if (self = [super init])
    {
        [TransPortDB shareTransPortDB];
        self.dManager=[[[DownloadManager alloc]init]autorelease];
        self.uManager=[[[UploadManager alloc]init]autorelease];
        self.dCallback=[[[DownloadCallbackThread alloc]init]autorelease];
        self.uCallback=[[[UploadCallbackThread alloc]init]autorelease];
        self.nDonwloadFinish=0;
        self.nDownloadCount=0;
        self.nDownloadSpeed=0;
        self.nUploadFinish=0;
        self.nUploadCount=0;
        self.nUploadSpeed=0;
        [self SetDTaskMax:[[SettingsDb shareSettingDb] getDMax]];
        [self SetUTaskMax:[[SettingsDb shareSettingDb] getUMax]];
        [self SetDPeerMax:[[SettingsDb shareSettingDb] getDPMax]];
        [self SetUPeerMax:[[SettingsDb shareSettingDb] getUPMax]];
    }
    return self;
}

-(void)dealloc
{
    dManager=nil;
    uManager=nil;
    dCallback=nil;
    uCallback=nil;
    [super dealloc];
}

-(void)uninit
{
    
}

-(void)SetDTaskMax:(NSInteger)num
{
    //zhemg
    if (num>20) {
        num=20;
    }
    [self.dManager SetMax:num];
}

-(void)SetUTaskMax:(NSInteger)num
{
    //zheng
    if (num>20) {
        num=20;
    }
    [self.uManager SetMax:num];
}

-(void)SetDPeerMax:(NSInteger)num
{
    self.nDPeerMax=num;
}

-(void)SetUPeerMax:(NSInteger)num
{
    self.nUPeerMax=num;
}

-(void)StartDownload:(NSArray*)items
{
    for (NSString* item in items) {
        [[TransPortDB shareTransPortDB] Update_DownloadStart:item];
    }
}

-(void)StartDownloadAll
{
    [[TransPortDB shareTransPortDB] StartDownloadAll];
}

-(void)StopDownload:(NSArray*)items
{
    for (NSString* item in items) {
        [self.dManager Stop:item];
        [[TransPortDB shareTransPortDB] Update_DownloadStatus:item status:TRANSTASK_STOP];
    }
}

-(void)StopDownloadAll
{
    [[TransPortDB shareTransPortDB] StopDownloadAll];
    [self.dManager StopAll];
}

-(void)DeleteDownload:(NSArray*)items
{
    for (NSString* item in items) {
        [self.dManager Delete:item];
        [self DeleteTmpFile:item];
        [[TransPortDB shareTransPortDB] Delete_Download:item];
    }
}

-(void)DeleteDownloadAll
{
    NSMutableArray * all=[[TransPortDB shareTransPortDB] Get_Downloads];
    for (TransTaskItem* item in all) {
        [self DeleteTmpFile:item.strFullpath];
    }
    [[TransPortDB shareTransPortDB] DeleteDownloadAll];
    [self.dManager StopAll];
}

-(void)StartUpload:(NSArray*)items
{
    for (SaveFileItem* item in items) {
        [[TransPortDB shareTransPortDB] Update_UploadStart:item.strBucket object:item.strObject];
    }
}

-(void)StartUploadAll
{
    [[TransPortDB shareTransPortDB] StartUploadAll];
}

-(void)StopUpload:(NSArray*)items
{
    for (SaveFileItem* item in items) {
        [self.uManager Stop:item.strBucket object:item.strObject];
        [[TransPortDB shareTransPortDB] Update_UploadStatus:item.strBucket object:item.strObject status:TRANSTASK_STOP];
    }
}

-(void)StopUploadAll
{
    [[TransPortDB shareTransPortDB] StopUploadAll];
    [self.uManager StopAll];
}

-(void)DeleteUpload:(NSArray*)items
{
    for (SaveFileItem* item in items) {
        [self.uManager Delete:item.strBucket object:item.strObject];
        TransTaskItem * itemret=[[TransPortDB shareTransPortDB] Get_Upload:item.strBucket object:item.strObject];
        if (itemret&&itemret.strUploadId.length) {
            OSSRet * abort;
            [OSSApi AbortMultipartUpload:itemret.strHost bucketname:itemret.strBucket objectname:itemret.strObject uploadid:itemret.strUploadId ret:&abort];
        }
        [[TransPortDB shareTransPortDB] Delete_Upload:item.strBucket object:item.strObject];
    }
}

-(void)DeleteUploadAll
{
    NSMutableArray * all=[[TransPortDB shareTransPortDB] Get_Uploads];
    for (TransTaskItem * item in all) {
        if (item.strUploadId.length) {
            OSSRet * abort;
            [OSSApi AbortMultipartUpload:item.strHost bucketname:item.strBucket objectname:item.strObject uploadid:item.strUploadId ret:&abort];
        }
    }
    [[TransPortDB shareTransPortDB] DeleteUploadAll];
    [self.uManager StopAll];
}

-(NSString*)AddFileUpload:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object fullpath:(NSString*)fullpath count:(NSInteger *)count
{
    NSString * strRet=@"";
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *dirArray=[manager contentsOfDirectoryAtPath:fullpath error:NULL];
    for(int i = 0; i < [dirArray count];i++)  
    {
        NSString *filename=[dirArray objectAtIndex:i];
        NSString *temppath=[NSString stringWithFormat:@"%@/%@",fullpath,filename];
        if ([Util islinkfile:temppath]) {
            continue;
        }
        if([Util isdir:temppath]){
            TransTaskItem *item=[[TransTaskItem alloc]init];
            item.strHost=host;
            item.strBucket=bucket;
            item.strObject=[NSString stringWithFormat:@"%@%@/",object,filename];
            item.strFullpath=temppath;
            item.nStatus=TRANSTASK_NORMAL;
            item.strPathhash=[[NSString stringWithFormat:@"%@%@",item.strBucket,item.strObject] sha1HexDigest];
            [[TransPortDB shareTransPortDB] Add_Upload:item];
            (*count)++;
            if ((*count)>=1000000) {
                NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:1000000],@"error",
                                      @"队列已超出客户端上传能力，请使用OSS的API上传。",@"message",nil];
                strRet=[dicRet JSONString];
                [item release];
                break;
            }
            NSString * strTemp=[self AddFileUpload:host bucket:bucket object:item.strObject fullpath:temppath count:count];
            [item release];
            if (strTemp.length) {
                strRet=strTemp;
                break;
            }
        }
        else {
            TransTaskItem *item=[[TransTaskItem alloc]init];
            item.strHost=host;
            item.strBucket=bucket;
            item.strObject=[NSString stringWithFormat:@"%@%@",object,filename];
            item.strFullpath=temppath;
            item.ullFilesize=[Util filesize:temppath];
            item.nStatus=TRANSTASK_NORMAL;
            item.strPathhash=[[NSString stringWithFormat:@"%@%@",item.strBucket,item.strObject] sha1HexDigest];
            [[TransPortDB shareTransPortDB] Add_Upload:item];
            [item release];
            (*count)++;
            if ((*count)>=1000000) {
                NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:1000000],@"error",
                                      @"队列已超出客户端上传能力，请使用OSS的API上传。",@"message",nil];
                strRet=[dicRet JSONString];
                break;
            }
        }
    }
    [pool release];
    return strRet;
}

-(NSString*)AddFileUpload:(NSString *)host bucket:(NSString *)bucket object:(NSString *)object array:(NSArray *)array
{
    NSString * strRet=@"";
    NSInteger count=[[TransPortDB shareTransPortDB] GetUploadCount];
    [self.uManager startAdding];
    [[TransPortDB shareTransPortDB] begin];
    for (NSString* path in array) {
        if ([Util isdir:path]) {
            TransTaskItem *item=[[TransTaskItem alloc]init];
            item.strHost=host;
            item.strBucket=bucket;
            item.strObject=[NSString stringWithFormat:@"%@%@/",object,[path lastPathComponent]];
            item.strFullpath=path;
            item.nStatus=TRANSTASK_NORMAL;
            item.strPathhash=[[NSString stringWithFormat:@"%@%@",item.strBucket,item.strObject] sha1HexDigest];
            [[TransPortDB shareTransPortDB] Add_Upload:item];
            count++;
            if (count>=1000000) {
                NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:1000000],@"error",
                                      @"队列已超出客户端上传能力，请使用OSS的API上传。",@"message",nil];
                strRet=[dicRet JSONString];
                [item release];
                break;
            }
            NSString * strTemp=[self AddFileUpload:host bucket:bucket object:item.strObject fullpath:path count:&count];
            [item release];
            if (strTemp.length) {
                strRet=strTemp;
                break;
            }
        }
        else {
            TransTaskItem *item=[[TransTaskItem alloc]init];
            item.strHost=host;
            item.strBucket=bucket;
            item.strObject=[NSString stringWithFormat:@"%@%@",object,[path lastPathComponent]];
            item.strFullpath=path;
            item.ullFilesize=[Util filesize:path];
            item.nStatus=TRANSTASK_NORMAL;
            item.strPathhash=[[NSString stringWithFormat:@"%@%@",item.strBucket,item.strObject] sha1HexDigest];
            [[TransPortDB shareTransPortDB] Add_Upload:item];
            [item release];
            count++;
            if (count>=1000000) {
                NSDictionary* dicRet=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:1000000],@"error",
                                      @"队列已超出客户端上传能力，请使用OSS的API上传。",@"message",nil];
                strRet=[dicRet JSONString];
                break;
            }
        }
    }
    [[TransPortDB shareTransPortDB] end];
    [self.uManager finishAdding];
    return strRet;
}

-(void)DeleteTmpFile:(NSString*)fullpath
{
    NSString * temppath=[NSString stringWithFormat:@"%@%@",fullpath,OSSEXT];
    if ([Util existfile:temppath]) {
        [Util deletefile:temppath];
    }
    temppath=[NSString stringWithFormat:@"%@%@%@",fullpath,OSSEXT,OSSTMP];
    if ([Util existfile:temppath]) {
        [Util deletefile:temppath];
    }
}

@end
