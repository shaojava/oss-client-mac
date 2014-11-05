#import <Foundation/Foundation.h>
#import "Common.h"

#define ZeroPos 0xffffffffffffffff

@interface DataPair : NSObject
{
    ULONGLONG   ullFirstMark;
    ULONGLONG   ullLastMark;
}

@property(nonatomic)ULONGLONG ullFirstMark;
@property(nonatomic)ULONGLONG ullLastMark;

-(id)init:(ULONGLONG)pos;
-(id)init:(ULONGLONG)fisrt last:(ULONGLONG)last;

-(BOOL)isEqualToDataPair:(DataPair*)item;

@end
