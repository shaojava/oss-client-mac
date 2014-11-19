#import "PeerBase.h"
#import "Md5Sum.h"
#import "UploadTask.h"

@interface UploadPeer : PeerBase<ASIHTTPRequestDelegate>
{
    NSFileHandle*   pFileHandle;
    NSString*       strUploadID;
    ULONGLONG       ullRead;
    NSMutableData*  retData;
    NSString*       strDateMd5;
}

@property(nonatomic,retain)NSFileHandle* pFileHandle;
@property(nonatomic,retain)NSString* strUploadID;
@property(nonatomic,assign)ULONGLONG ullRead;
@property(nonatomic,retain)NSMutableData* retData;
@property(nonatomic,retain)NSString* strDateMd5;

-(id)init:(UploadTask*)task host:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object;
-(BOOL)OpenFile:(NSString*)uploadid fullpath:(NSString*)fullpath;
-(void)StartUpload:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size;

-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;
-(void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes;
-(void)requestFinished:(ASIHTTPRequest *)request;
-(void)requestFailed:(ASIHTTPRequest *)request;

@end
