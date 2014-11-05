//
//  CopyProgress.m
//  GoKuai
//
//  Created by GoKuai on 12/13/13.
//
//

#import "CopyProgress.h"

#import "Util.h"

@implementation CopyItem

@synthesize webpath;

@synthesize oldpath;
@synthesize newpath;

@synthesize bDir;
@synthesize cpysize;
@synthesize sumsize;

-(void) dealloc
{
    self.webpath=nil;
    self.oldpath=nil;
    self.newpath=nil;
    
    [super dealloc];
}

-(BOOL) isfinished
{
    if (bDir) {
        return [Util isdir:self.newpath];
    }
    return (cpysize==sumsize);
}

@end

@implementation CopyAll

@synthesize files;
@synthesize folders;
@synthesize cpysize;
@synthesize sumsize;
@synthesize cpycount;
@synthesize sumcount;

-(void) dealloc
{
    self.files=nil;
    self.folders=nil;

    [super dealloc];
}

-(id) init
{
    if (self=[super init]) {
        self.files=[NSMutableArray array];
        self.folders=[NSMutableArray array];
        self.cpysize=0;
        self.sumsize=0;
        self.cpycount=0;
        self.sumcount=0;
    }
    return self;
}

-(BOOL) isfinished
{
    return ((cpysize==sumsize)
            && (cpycount==sumcount));
}

-(NSUInteger) progress:(unsigned long long)sizecpyed
{
    if (self.isfinished) {
        return (100);
    }
    if (sumsize) {
        return sizecpyed?(sizecpyed*100/sumsize):(cpysize*100/sumsize);
    }
    return 0;
}

@end


@implementation CopyProgress

@synthesize progressCallBack;

-(void) dealloc
{
    [_all release];
    [progressCallBack release];
    [super dealloc];
}

-(id) initWithPaths:(NSArray*)cpyItems
{
    if (self=[super init]) {
        _all=[[CopyAll alloc]init];
        
        _all.cpycount=0;
        for (CopyItem* cm in cpyItems) {
            
            if (cm.bDir) {
                [_all.folders addObject:cm];
            }
            else {
                [_all.files addObject:cm];
            }
            _all.sumcount++;
            _all.sumsize+=cm.sumsize;
        }
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
            unsigned long long allsize=_all.cpysize;
            for (int i=0; i<_all.files.count;) {
                CopyItem* cpyfile=[_all.files objectAtIndex:i];
                cpyfile.cpysize=[[[NSFileManager defaultManager] attributesOfItemAtPath:cpyfile.newpath error:nil] fileSize];
                if (cpyfile.isfinished) {
                    _all.cpycount+=1;
                    _all.cpysize+=cpyfile.cpysize;
                    [_all.files removeObject:cpyfile];
                }
                else {
                    allsize+=cpyfile.cpysize;
                    i++;
                }
            }
            for (int i=0; i<_all.folders.count;) {
                CopyItem* cpyfolder=[_all.folders objectAtIndex:i];
                if (cpyfolder.isfinished) {
                    _all.cpycount+=1;
                    [_all.folders removeObject:cpyfolder];
                }
                else {
                    i++;
                }
            }
            if (![self isCancelled]) {
                progressCallBack([_all progress:allsize]);
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
