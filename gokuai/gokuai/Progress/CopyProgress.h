//
//  CopyProgress.h
//  GoKuai
//
//  Created by GoKuai on 12/13/13.
//
//

#import <Foundation/Foundation.h>

@interface CopyItem : NSObject {
    
    NSString* webpath;
    
    NSString* oldpath;
    NSString* newpath;

    BOOL bDir;
    unsigned long long cpysize;
    unsigned long long sumsize;
}

@property(nonatomic,retain) NSString* webpath;

@property(nonatomic,retain) NSString* oldpath;
@property(nonatomic,retain) NSString* newpath;

@property(nonatomic,assign) BOOL bDir;
@property(nonatomic,assign) unsigned long long cpysize;
@property(nonatomic,assign) unsigned long long sumsize;

-(BOOL) isfinished;

@end


@interface CopyAll : NSObject {
    
    NSMutableArray* files;
    NSMutableArray* folders;
    
    unsigned long long cpysize;
    unsigned long long cpycount;
    
    unsigned long long sumsize;
    unsigned long long sumcount;
}

@property(nonatomic,retain)NSMutableArray* files;
@property(nonatomic,retain)NSMutableArray* folders;

@property(nonatomic,assign) unsigned long long cpysize;
@property(nonatomic,assign) unsigned long long cpycount;

@property(nonatomic,assign) unsigned long long sumsize;
@property(nonatomic,assign) unsigned long long sumcount;

-(BOOL) isfinished;
-(NSUInteger) progress:(unsigned long long)sizecpyed;

@end



@interface CopyProgress : NSOperation {
    CopyAll* _all;
    void(^progressCallBack)(NSInteger v);
}

@property(nonatomic,copy) void(^progressCallBack)(NSInteger v);

-(id) initWithPaths:(NSArray*)cpyItems;

-(BOOL) isfinished;

@end
