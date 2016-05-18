//
//  Regular.m
//  GoKuai
//
//  Created by livedeal on 15/8/25.
//
//

#import "Regular.h"
#import "RegexKitLite.h"

@implementation Regular

@synthesize nodeLock;
@synthesize nodeArray;

-(id)init
{
    if (self = [super init])
    {
        self.nodeArray=[[[NSMutableArray alloc]init] autorelease];
        self.nodeLock=[[[NSLock alloc]init] autorelease];
    }
    return self;
}

-(void)dealloc
{
    self.nodeArray=nil;
    self.nodeLock=nil;
    [super dealloc];
}

-(void)addNodes:(NSArray*)items
{
    for (RegularItem* item in items) {
        [self addNode:item];
    }
}

-(void)addNode:(RegularItem*)item
{
    BOOL bHave=NO;
    [self.nodeLock lock];
    for( RegularItem* temp in self.nodeArray) {
        if ([temp.strBucket isEqualToString:item.strBucket]) {
            temp.nStatus=item.nStatus;
            temp.strHost=item.strHost;
            temp.strRegular=item.strRegular;
            bHave=YES;
            break;
        }
    }
    if (!bHave) {
        if (item.strRegular.length!=0) {
            [self.nodeArray addObject:item];
        }
    }
    [self.nodeLock unlock];
}

-(RegularItem*)checkNode:(NSString*)bucket object:(NSString*)object ret:(BOOL*)ret
{
    *ret=NO;
    RegularItem * temp=nil;
    for (RegularItem * item in self.nodeArray) {
        if ([item.strBucket isEqualToString:bucket]&&item.nStatus>0) {
            if ([object isMatchedByRegex:item.strRegular]) {
                *ret=YES;
                temp=item;
            }
        }
    }
    return temp;
}

@end
