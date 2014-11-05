

#import <Foundation/Foundation.h>

@interface MyTimer : NSObject
{
    NSThread *  thread;
}
@property(nonatomic,retain)NSThread* thread;

-(id)init;
-(void)exit;
-(void)run;

@end
