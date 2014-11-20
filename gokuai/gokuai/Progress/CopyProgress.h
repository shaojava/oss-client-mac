#import <Foundation/Foundation.h>

@interface CopyAll : NSObject {
    NSArray* array;
    NSInteger nCount;
    NSInteger nIndex;
}

@property(nonatomic,retain)NSArray* array;
@property(nonatomic,assign)NSInteger nCount;
@property(nonatomic,assign)NSInteger nIndex;

-(BOOL) isfinished;

@end

@interface CopyProgress : NSOperation {
    CopyAll* _all;
    NSInteger nType;
    NSInteger nTempIndex;
    NSTimer*  pTimer;
    NSString* _strHost;
    NSString* _strBucket;
    void(^progressCallBack)(NSInteger v);
}

@property(nonatomic,copy) void(^progressCallBack)(NSInteger v);
@property(nonatomic)NSInteger nType;
@property(nonatomic)NSInteger nTempIndex;
@property(nonatomic,retain)NSString* _strHost;
@property(nonatomic,retain)NSString* _strBucket;

-(id) initWithPaths:(NSArray*)items type:(NSInteger)type;
-(id) initWithPaths:(NSArray*)items host:(NSString*)host bucket:(NSString*)bucket;
-(BOOL) isfinished;

@end
