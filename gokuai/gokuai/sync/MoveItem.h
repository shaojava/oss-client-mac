#import <Foundation/Foundation.h>

@interface MoveItem : NSObject
{
    NSString* frompath;
    NSString* topath;
    BOOL dir;
}
@property(nonatomic,copy)NSString*  frompath;
@property(nonatomic,copy)NSString*  topath;
@property(nonatomic)BOOL dir;

@end
