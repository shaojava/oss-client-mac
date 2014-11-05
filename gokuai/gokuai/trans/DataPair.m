#import "DataPair.h"

@implementation DataPair

@synthesize ullFirstMark;
@synthesize ullLastMark;

-(id)init:(ULONGLONG)pos
{
    if (self = [super init])
    {
        self.ullFirstMark=pos;
        self.ullLastMark=pos;
    }
    return self;
}

-(id)init:(ULONGLONG)fisrt last:(ULONGLONG)last
{
    if (self = [super init])
    {
        self.ullFirstMark=fisrt;
        self.ullLastMark=last;
    }
    return self;
}

-(BOOL)isEqualToDataPair:(DataPair*)item
{
    if (self.ullFirstMark==item.ullFirstMark&&self.ullLastMark==item.ullLastMark) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
