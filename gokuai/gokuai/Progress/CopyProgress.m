#import "CopyProgress.h"
#import "Util.h"
#import "NetworkDef.h"
#import "OSSApi.h"
#import "ProgressWindowController.h"

#define COPY_MAX    1073741824

@implementation CopyAll

@synthesize array;
@synthesize cpycount;
@synthesize sumcount;

-(void) dealloc
{
    array=nil;
    [super dealloc];
}

-(id) init
{
    if (self=[super init]) {
        self.cpycount=0;
        self.sumcount=0;
    }
    return self;
}

-(BOOL) isfinished
{
    return (sumcount>=cpycount);
}

@end


@implementation CopyProgress

@synthesize progressCallBack;
@synthesize nType;

-(void) dealloc
{
    [_all release];
    [progressCallBack release];
    [super dealloc];
}

-(id) initWithPaths:(NSArray*)items type:(NSInteger)type
{
    if (self=[super init]) {
        _all=[[CopyAll alloc]init];
        _all.cpycount=items.count;
        _all.sumcount=0;
        _all.array=items;
        self.nType=type;
    }
    return self;
}

-(BOOL) isfinished
{
    return _all.isfinished;
}

-(void) main
{
    NSAutoreleasePool* pool=[[NSAutoreleasePool alloc]init];
    while (![self isCancelled]) {
        @try {
            if (self.nType==pc_copy) {
                for (int i=0; i<_all.array.count;i++) {
                    CopyFileItem* cpyfile=[_all.array objectAtIndex:i];
                    if (cpyfile.ullFilesize<COPY_MAX) {
                        OSSCopyRet *ret;
                        [OSSApi CopyObject:cpyfile.strDstHost dstbucketname:cpyfile.strDstBucket dstobjectname:cpyfile.strDstObject srcbucketname:cpyfile.strBucket srcobjectname:cpyfile.strObject ret:&ret];
                    }
                    else {
                        //zheng
                    }
                    _all.sumcount++;
                    if (![self isCancelled]) {
                        progressCallBack(_all.sumcount);
                    }
                }
            }
            else if (self.nType==pc_delete) {
                if (_all.array.count==1) {
                    DeleteFileItem* item=[_all.array objectAtIndex:0];
                    OSSRet *ret=[[[OSSRet alloc]init]autorelease];
                    [OSSApi DeleteObject:item.strHost bucketname:item.strBucket objectname:item.strObject ret:&ret];
                    _all.sumcount++;
                    if (![self isCancelled]) {
                        progressCallBack(_all.sumcount);
                    }
                }
                else {
                    for (int i=0; i<(_all.array.count+999)/1000;i++) {
                        DeleteFileItem* item;
                        NSMutableArray* array=[NSMutableArray arrayWithCapacity:1000];
                        for (int j=0; j<1000&&i*1000+j<_all.array.count; j++) {
                            item=[_all.array objectAtIndex:(i*1000+j)];
                            [array addObject:item.strObject];
                        }
                        OSSRet *ret;
                        [OSSApi DeleteObject:item.strHost bucketname:item.strBucket objectnames:array quiet:YES ret:&ret];
                        //zheng
                        _all.sumcount=i*1000;
                        if (![self isCancelled]) {
                            progressCallBack(_all.sumcount);
                        }
                    }
                }
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"COPY MAIN [ exception : %@]", [exception reason]);
        }
        @finally {
        }
    }
    [pool release];
}

@end
