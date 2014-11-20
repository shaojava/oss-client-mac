

#import <Cocoa/Cocoa.h>
#import "CopyProgress.h"
#import "OperationManager.h"

@class transportnode;

typedef enum _progress_category_ {
    pc_copy,
    pc_delete,
    pc_bucket,
} progress_category;


@interface ProgressPackage : NSObject {
    progress_category _oper;
    OperPackage* _obj;
}

@property(assign,nonatomic)progress_category _oper;
@property(retain,nonatomic)OperPackage* _obj;

-(id)initCopy:(OperPackage*)obj;
-(id)initDelete:(OperPackage*)obj;
-(id)initDeleteBucket:(OperPackage*)obj; 

@end

@interface ProgressWindowController : NSWindowController
{
    IBOutlet NSTextField* _actionTarget;
    IBOutlet NSProgressIndicator* _progressIndicator;
    ProgressPackage *_package;
    CopyProgress *_cpyprogress;
    NSString*   _strRetCallback;
}

@property(nonatomic,retain) ProgressPackage *_package;
@property(nonatomic,retain) CopyProgress* _cpyprogress;
@property(nonatomic,retain) NSString* _strRetCallback;

-(void) displayex;
-(void) parsecopy;
-(void) parsedelete;
-(void) parsebucket;

@end
