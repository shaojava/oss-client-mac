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
    self.strPathhash=nil;
    self.strHost=nil;
    self.strBucket=nil;
    self.strObject=nil;
    self.strFullpath=nil;
    self.strUploadId=nil;
    self.strMsg=nil;
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
    self.strHost=nil;
    self.strBucket=nil;
    self.strObject=nil;
    self.strFullpath=nil;
    self.strEtag=nil;
    [super dealloc];
}

@end

@implementation CopyFileItem

@synthesize strHost;
@synthesize strBucket;
@synthesize strObject;
@synthesize ullFilesize;
@synthesize strDstHost;
@synthesize strDstBucket;
@synthesize strDstObject;

-(id)init
{
    if (self = [super init])
    {
        self.strHost=@"";
        self.strBucket=@"";
        self.strObject=@"";
        self.ullFilesize=0;
        self.strDstHost=@"";
        self.strDstBucket=@"";
        self.strDstObject=@"";
    }
    return self;
}

-(void)dealloc
{
    self.strHost=nil;
    self.strBucket=nil;
    self.strObject=nil;
    self.strDstHost=nil;
    self.strDstBucket=nil;
    self.strDstObject=nil;
    [super dealloc];
}

@end

@implementation DeleteFileItem

@synthesize strHost;
@synthesize strBucket;
@synthesize strObject;

-(id)init
{
    if (self = [super init])
    {
        self.strHost=@"";
        self.strBucket=@"";
        self.strObject=@"";
    }
    return self;
}

-(void)dealloc
{
    self.strHost=nil;
    self.strBucket=nil;
    self.strObject=nil;
    [super dealloc];
}

@end

@implementation RegularItem

@synthesize strBucket;
@synthesize strRegular;
@synthesize strHost;
@synthesize nStatus;
@synthesize nNum;

-(id)init
{
    if (self = [super init])
    {
        self.strBucket=@"";
        self.strRegular=@"";
        self.strHost=@"";
        self.nStatus=0;
        self.nNum=0;
    }
    return self;
}

-(void)dealloc
{
    self.strBucket=nil;
    self.strRegular=nil;
    self.strHost=nil;
    [super dealloc];
}

@end

