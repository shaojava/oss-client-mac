#import "PeerBase.h"
#import "ASIHTTPRequest.h"
#import "DownloadTask.h"

@interface DownloadPeer : PeerBase<ASIHTTPRequestDelegate>
{
    BOOL        bRequestStart;
    ASIHTTPRequest* pRequest;
}

@property(nonatomic,retain)ASIHTTPRequest* pRequest;
@property(nonatomic)BOOL bRequestStart;

-(id)init:(DownloadTask*)task host:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object;
-(void)StartDownload:(ULONGLONG)pos size:(ULONGLONG)size;
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;
-(void)requestFinished:(ASIHTTPRequest *)request;
-(void)requestFailed:(ASIHTTPRequest *)request;

@end
