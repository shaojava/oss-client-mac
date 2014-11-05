#import "NetworkDef.h"

@implementation TransTaskItem

@synthesize strPathhash;
@synthesize strHost;
@synthesize strBucket;
@synthesize strObject;
@synthesize strFullpath;
@synthesize ullFilesize;
@synthesize ullOffset;
@synthesize nStatus;
@synthesize strUploadId;
@synthesize nErrorNum;
@synthesize strMsg;
@synthesize ullSpeed;

-(id)init
{
    if (self = [super init])
    {
        self.strPathhash=@"";
        self.strHost=@"";
        self.strBucket=@"";
        self.strObject=@"";
        self.strFullpath=@"";
        self.ullFilesize=0;
        self.ullOffset=0;
        self.nStatus=0;
        self.strUploadId=@"";
        self.nErrorNum=0;
        self.strMsg=@"";
        self.ullSpeed=0;
    }
    return self;
}

-(void)dealloc
{
    strPathhash=nil;
    strHost=nil;
    strBucket=nil;
    strObject=nil;
    strFullpath=nil;
    strUploadId=nil;
    strMsg=nil;
    [super dealloc];
}

@end

@implementation SaveFileItem

@synthesize strHost;
@synthesize strBucket;
@synthesize strObject;
@synthesize strFullpath;
@synthesize strEtag;
@synthesize ullFilesize;
@synthesize bDir;

-(id)init
{
    if (self = [super init])
    {
        self.strHost=@"";
        self.strBucket=@"";
        self.strObject=@"";
        self.strFullpath=@"";
        self.strEtag=@"";
        self.ullFilesize=0;
        self.bDir=NO;
    }
    return self;
}

-(void)dealloc
{
    strHost=nil;
    strBucket=nil;
    strObject=nil;
    strFullpath=nil;
    strEtag=nil;
    [super dealloc];
}

@end

@implementation CopyFileItem

@synthesize strObject;
@synthesize ullFilesize;
@synthesize strDstObject;

-(id)init
{
    if (self = [super init])
    {
        self.strObject=@"";
        self.ullFilesize=0;
        self.strDstObject=@"";
    }
    return self;
}

-(void)dealloc
{
    strObject=nil;
    strDstObject=nil;
    [super dealloc];
}

@end

