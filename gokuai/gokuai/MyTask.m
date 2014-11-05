#import "MyTask.h"
#import "Util.h"
#import "Common.h"
#import "GKHTTPRequest.h"
#import "SettingsDb.h"
#import "AppDelegate.h"
#import "NSStringExpand.h"

#import "JSONKit.h"

@implementation MyTask

- (void)main{
    
}

@end

@implementation DirectoryhandlerTask

@synthesize _handler;
@synthesize _array;

-(void)dealloc
{
    [_array release];
    self._handler=nil;
    [super dealloc];
}

-(id)initWithTask:(id)handler
            array:(NSMutableArray*)array
{
    if (self =[super init]) {
        
        self._handler = handler;
        self._array=array;
    }
    return self;
}
- (void)main{
  
    
}

@end


@implementation DownloadImageTask

@synthesize strFilehash;

-(id)init:(NSString*)filehash;
{
    if (self = [super init])
    {
        self.strFilehash=filehash;
    }
    return self;
}

-(void)dealloc
{
    [strFilehash release];
    [super dealloc];
}

- (void)main{
  
}

@end

@implementation SaveItem

@synthesize _mountid;
@synthesize _webpath;
@synthesize _dir;
@synthesize _version;
@synthesize _fullpath;

-(void)dealloc
{
    [_webpath release];
    [_fullpath release];
    [super dealloc];
}

@end


@implementation FileSaveAs

@synthesize _saveItems;

-(id)init:(NSMutableArray*)saveItems
{
    if (self = [super init])
    {
        self._saveItems=saveItems;
    }
    return self;
}

-(void)dealloc
{
    [_saveItems release];
    [super dealloc];
}

-(void)GetFileList:(NSString*)webpath
           mountid:(NSInteger)mountid
          savepath:(NSString*)savepath
{
    
}

- (void)main{
  }

@end


@implementation MountCompare

@synthesize _manager;

-(id)init:(id)manager
{
    if (self = [super init])
    {
        self._manager=manager;
    }
    return self;
}

-(void)dealloc
{
    [_manager release];
    [super dealloc];
}

- (void)main{
   }

@end

@implementation OpenTask

@synthesize _json;

-(id)init:(NSString*)json
{
    if (self = [super init])
    {
        self._json=json;
    }
    return self;
}

-(void)dealloc
{
    [_json release];
    [super dealloc];
}

- (void)main {
    
}
-(void) Start
{
   [[NSApp keyWindow] disableCursorRects];
    [[NSCursor disappearingItemCursor] set];
}

-(void) Finish
{
    [[NSCursor arrowCursor] set];
    [[NSApp keyWindow] disableCursorRects];
}

@end