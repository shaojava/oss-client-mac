#import "PeerBase.h"
#import "DownloadTask.h"

@interface DownloadPeer : PeerBase<ASIHTTPRequestDelegate>

-(id)init:(DownloadTask*)task host:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object;
-(void)StartDownload:(ULONGLONG)pos size:(ULONGLONG)size;
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;
-(void)requestFinished:(ASIHTTPRequest *)request;
-(void)requestFailed:(ASIHTTPRequest *)request;

@end
