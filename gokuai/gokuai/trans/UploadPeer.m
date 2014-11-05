
#import "UploadPeer.h"
#import "OSSApi.h"
#import "NSDataExpand.h"

@implementation UploadPeer

@synthesize pFileHandle;
@synthesize strUploadID;
@synthesize ullRead;

-(id)init:(UploadTask *)task host:(NSString *)host bucket:(NSString *)bucket object:(NSString *)object
{
    if (self=[super init]) {
        self.pTask=task;
        self.strHost=host;
        self.strBucket=bucket;
        self.strObject=object;
        self.strHeader=@"";
        self.bStart=NO;
        self.bStop=NO;
        self.nIndex=0;
        self.ullPos=0;
        self.ullSize=0;
        self.pFileHandle=nil;
        self.strUploadID=@"";
        self.ullRead=0;
    }
    return self;
}

-(void)dealloc
{
    pFileHandle=nil;
    strUploadID=nil;
    [super dealloc];
}

-(BOOL)OpenFile:(NSString*)uploadid fullpath:(NSString*)fullpath
{
    self.strUploadID=uploadid;
    self.pFileHandle=[NSFileHandle fileHandleForReadingAtPath:fullpath];
    if (self.pFileHandle==nil) {
        return NO;
    }
    return YES;
}

-(void)StartUpload:(NSInteger)index pos:(ULONGLONG)pos size:(ULONGLONG)size
{
    self.nIndex=index;
    self.ullPos=pos;
    self.ullSize=size;
    [self.pFileHandle seekToFileOffset:self.ullPos];
    self.bStart=YES;
    self.ullRead=0;
}

-(void)main{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        OSSAddObject *ret=[[[OSSAddObject alloc]init] autorelease];
        if (self.strUploadID.length) {
            [self.pFileHandle seekToFileOffset:self.ullPos];
            NSData * data=[self.pFileHandle readDataOfLength:self.ullSize];
            if ([OSSApi AddObject:self.strHost bucketname:self.strBucket objectname:self.strObject filesize:self.ullSize filedata:data ret:&ret]) {
                NSString * md5=[[NSString stringWithFormat:@"\"%@\"",[data md5Data2String]] lowercaseString];
                NSString * retetage=[ret.strEtag lowercaseString];
                if ([md5 isEqualToString:retetage]) {
                    //zheng
                }
                else {
                    //
                }
            }
            else {
                //
            }
        }
        else {
            
            [self.pFileHandle seekToFileOffset:self.ullPos];
            NSData * data=[self.pFileHandle readDataOfLength:self.ullSize];
            if ([OSSApi UploadPartObject:self.strHost bucketname:self.strBucket objectname:self.strObject uploadid:self.strUploadID partnumber:self.nIndex filesize:self.ullSize filedata:data ret:&ret]) {
                NSString * md5=[[NSString stringWithFormat:@"\"%@\"",[data md5Data2String]] lowercaseString];
                NSString * retetage=[ret.strEtag lowercaseString];
                if ([md5 isEqualToString:retetage]) {
                    //zheng
                }
                else {
                    //
                }
            }
            else {
                //
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [pool release];
        self.bStart=NO;
    }
}


@end
