#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "UploadManager.h"
#import "DownloadCallbackThread.h"
#import "UploadCallbackThread.h"
#import "Regular.h"

@interface Network : NSObject{
    DownloadManager*    dManager;
    UploadManager*      uManager;
    DownloadCallbackThread* dCallback;
    UploadCallbackThread*   uCallback;
    NSInteger           nDownloadFinish;
    NSInteger           nDownloadCount;
    ULONGLONG           nDownloadSpeed;
    NSInteger           nUploadFinish;
    NSInteger           nUploadCount;
    ULONGLONG           nUploadSpeed;
    NSInteger           nDPeerMax;
    NSInteger           nUPeerMax;
    
    Regular*            regular;
}

@property(nonatomic,retain)DownloadManager* dManager;
@property(nonatomic,retain)UploadManager* uManager;
@property(nonatomic,retain)DownloadCallbackThread* dCallback;
@property(nonatomic,retain)UploadCallbackThread* uCallback;
@property(nonatomic)NSInteger nDonwloadFinish;
@property(nonatomic)NSInteger nDownloadCount;
@property(nonatomic)ULONGLONG nDownloadSpeed;
@property(nonatomic)NSInteger nUploadFinish;
@property(nonatomic)NSInteger nUploadCount;
@property(nonatomic)ULONGLONG nUploadSpeed;
@property(nonatomic)NSInteger nDPeerMax;
@property(nonatomic)NSInteger nUPeerMax;
@property(nonatomic,retain)Regular* regular;

+(Network*)shareNetwork;

-(id)init;
-(void)uninit;

-(void)SetDTaskMax:(NSInteger)num;
-(void)SetUTaskMax:(NSInteger)num;
-(void)SetDPeerMax:(NSInteger)num;
-(void)SetUPeerMax:(NSInteger)num;

-(void)StartDownload:(NSArray*)items;
-(void)StartDownloadAll;
-(void)StopDownload:(NSArray*)items;
-(void)StopDownloadAll;
-(void)DeleteDownload:(NSArray*)items;
-(void)DeleteDownloadAll;
-(void)StartUpload:(NSArray*)items;
-(void)StartUploadAll;
-(void)StopUpload:(NSArray*)items;
-(void)StopUploadAll;
-(void)DeleteUpload:(NSArray*)items;
-(void)DeleteUploadAll;
-(NSString*)AddFileUpload:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object fullpath:(NSString*)fullpath count:(NSInteger*)count;
-(NSString*)AddFileUpload:(NSString *)host bucket:(NSString *)bucket object:(NSString *)object array:(NSArray *)array;

-(void)DeleteTmpFile:(NSString*)fullpath;

@end
