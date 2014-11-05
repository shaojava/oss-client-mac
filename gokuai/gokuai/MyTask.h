#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "TransPortDB.h"

@class  GKMenuItem;

@interface MyTask : NSOperation

@end

@interface DirectoryhandlerTask : NSOperation
{
    id  _handler;
    NSMutableArray*  _array;
}

@property(nonatomic, retain) id _handler;
@property(nonatomic, copy) NSMutableArray* _array;
-(id)initWithTask:(id)handler
            array:(NSMutableArray*)array;
@end


@interface GetSyncUpdates : NSOperation
{
    NSString*   _act;
    NSInteger   _memberid;
}

@property(nonatomic)NSInteger _memberid;
@property(nonatomic, retain) NSString* _act;

-(id)init:(NSInteger)memberid
      act:(NSString*)act;

@end


@interface DownloadImageTask : NSOperation<ASIHTTPRequestDelegate>
{
    NSString*   strFilehash;
}
@property(nonatomic, retain) NSString* strFilehash;

-(id)init:(NSString*)filehash;

@end

@interface SaveItem : NSOperation
{
    NSInteger       _mountid;
    NSString*       _webpath;
    BOOL            _dir;
    NSInteger       _version;
    NSString*       _fullpath;
}
@property(nonatomic)NSInteger _mountid;
@property(nonatomic,copy)NSString* _webpath;
@property(nonatomic)BOOL    _dir;
@property(nonatomic) NSInteger _version;
@property(nonatomic,copy)NSString* _fullpath;

@end

@interface FileSaveAs : NSOperation {
    NSMutableArray* _saveItems;
}

@property(nonatomic,retain)NSMutableArray* _saveItems;

-(id)init:(NSMutableArray*)saveItems;

-(void)GetFileList:(NSString*)webpath
           mountid:(NSInteger)mountid
          savepath:(NSString*)savepath;

@end

@interface MountCompare: NSOperation 
{
    id _manager;
}
@property(nonatomic,retain)id _manager;

-(id)init:(id)manager;

@end


@interface OpenTask : NSOperation
{
    NSString* _json;
}
@property(nonatomic,copy)NSString* _json;

-(id)init:(NSString*)json;

@end





