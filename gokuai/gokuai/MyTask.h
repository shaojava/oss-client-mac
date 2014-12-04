#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@class  GKMenuItem;

@interface MyTask : NSOperation

@end

@interface GetUpdateXML : NSOperation 
{
    BOOL      _bShow;
}

@property(nonatomic)BOOL    _bShow;

-(id)init:(BOOL)bShow;

@end

@interface DownloadDmgTask : NSOperation<ASIHTTPRequestDelegate>
{
    NSString* _url;
    NSString* _savepath;
    NSInteger _size;
    ASIHTTPRequest* request;
    NSInteger _offset;
}
@property(nonatomic, retain) NSString* _url;
@property(nonatomic, retain) NSString* _savepath;
@property(nonatomic)NSInteger _size;
@property(nonatomic)NSInteger _offset;

-(id)init:(NSString*)url
 savepath:(NSString*)savepath
     size:(NSInteger)size;

@end