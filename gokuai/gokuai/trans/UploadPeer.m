
#import "UploadPeer.h"
#import "OSSApi.h"
#import "NSDataExpand.h"
#import "UploadTask.h"

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
        OSSAddObject *ret;
        if (self.strUploadID.length==0) {
            [self.pFileHandle seekToFileOffset:self.ullPos];
            NSData * data=[self.pFileHandle readDataOfLength:self.ullSize];
            if ([OSSApi AddObject:self.strHost bucketname:self.strBucket objectname:self.strObject filesize:self.ullSize filedata:data ret:&ret]) {
                NSString * md5=[NSString stringWithFormat:@"\"%@\"",[data md5Data2String]];
                NSString * retetag=ret.strEtag;
                if ([md5 isEqualToString:retetag]) {
                    [((UploadTask*)self.pTask) FinishIndex:self.nIndex pos:self.ullPos size:self.ullSize etag:md5];
                }
                else {
                    NSString * message=[NSString stringWithFormat:@"md5 error:%@ %@",md5,retetag];
                    [((UploadTask*)self.pTask) TaskError:TRANSERROR_MD5ERROR msg:message];
                }
            }
            else {
                
                [((UploadTask*)self.pTask) TaskError:ret.nCode msg:@"http code"];
            }
        }
        else {
            
            [self.pFileHandle seekToFileOffset:self.ullPos];
            NSData * data=[self.pFileHandle readDataOfLength:self.ullSize];
            if ([OSSApi UploadPartObject:self.strHost bucketname:self.strBucket objectname:self.strObject uploadid:self.strUploadID partnumber:self.nIndex filesize:self.ullSize filedata:data ret:&ret]) {
                NSString * md5=[NSString stringWithFormat:@"\"%@\"",[data md5Data2String]];
                NSString * retetag=ret.strEtag;
                if ([md5 isEqualToString:retetag]) {
                    [((UploadTask*)self.pTask) FinishIndex:self.nIndex pos:self.ullPos size:self.ullSize etag:md5];
                }
                else {
                    NSString * message=[NSString stringWithFormat:@"md5 error:%@ %@",md5,retetag];
                    [((UploadTask*)self.pTask) ErrorIndex:self.nIndex pos:self.ullPos size:self.ullSize error:TRANSERROR_MD5ERROR msg:message];
                }
            }
            else {
                if ([ret.strCode isEqualToString:@"NoSuchUpload"]) {
                    [((UploadTask*)self.pTask) ResetUploadId];
                }
                [((UploadTask*)self.pTask) ErrorIndex:self.nIndex pos:self.ullPos size:self.ullSize error:ret.nCode msg:@"http code"];
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
