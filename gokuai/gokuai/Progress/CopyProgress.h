#import <Foundation/Foundation.h>

@interface CopyProgress : NSOperation {
    NSInteger nType;
    NSInteger nTempIndex;
    NSInteger nTempCount;
    NSTimer*  pTimer;
    NSString* _strJson;
    BOOL       bTimer;
    void(^progressCallBack)(NSInteger v);
}

@property(nonatomic,copy) void(^progressCallBack)(NSInteger v);
@property(nonatomic)NSInteger nType;
@property(nonatomic)NSInteger nTempIndex;
@property(nonatomic)NSInteger nTempCount;
@property(nonatomic)BOOL bTimer;
@property(nonatomic,retain)NSString* _strJson;


-(id)init:(NSString*)json type:(NSInteger)type;
-(void)parsecopy;
-(void)parsedelete;
-(void)parsebucket;


@end
