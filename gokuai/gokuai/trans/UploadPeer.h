
#import "PeerBase.h"
#import "Md5Sum.h"
#import "UploadTask.h"

@interface UploadPeer : PeerBase
{
    NSFileHandle*   pFileHandle;
    NSString*       strUploadID;
    ULONGLONG       ullRead;
}

@property(nonatomic,retain)NSFileHandle* pFileHandle;
@property(nonatomic,retain)NSString* strUploadID;
@property(nonatomic,assign)ULONGLONG ullRead;

-(id)init:(UploadTask*)task host:(NSString*)host bucket:(NSString*)bucket object:(NSString*)object;
-(BOOL)OpenFile:(NSString*)uploadid fullpath:(NSString*)fullpath;
-(void)StartUpload:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size;


@end
