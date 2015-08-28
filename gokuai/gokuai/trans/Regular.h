//
//  Regular.h
//  GoKuai
//
//  Created by livedeal on 15/8/25.
//
//

#import <Foundation/Foundation.h>
#import "NetworkDef.h"

@interface Regular : NSObject
{
    NSLock *nodeLock;
    NSMutableArray* nodeArray;
}
@property(nonatomic,retain)NSLock* nodeLock;
@property(nonatomic,retain)NSMutableArray* nodeArray;

-(id)init;
-(void)addNodes:(NSArray*)items;
-(void)addNode:(RegularItem*)item;
-(RegularItem*)checkNode:(NSString*)bucket object:(NSString*)object ret:(BOOL*)ret;

@end
