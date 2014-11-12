#import <Foundation/Foundation.h>

@interface CopyAll : NSObject {
    
    NSArray* array;
    unsigned long long cpycount;
    unsigned long long sumcount;
}

@property(nonatomic,retain)NSArray* array;
@property(nonatomic,assign) unsigned long long cpycount;
@property(nonatomic,assign) unsigned long long sumcount;

-(BOOL) isfinished;

@end

@interface CopyProgress : NSOperation {
    CopyAll* _all;
    NSInteger nType;
    void(^progressCallBack)(NSInteger v);
}

@property(nonatomic,copy) void(^progressCallBack)(NSInteger v);
@property(nonatomic)NSInteger nType;

-(id) initWithPaths:(NSArray*)items type:(NSInteger)type;

-(BOOL) isfinished;

@end
