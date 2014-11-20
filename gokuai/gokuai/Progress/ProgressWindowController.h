

#import <Cocoa/Cocoa.h>
#import "CopyProgress.h"
#import "OperationManager.h"

@class transportnode;

typedef enum _progress_category_ {
    pc_copy,
    pc_delete,
    pc_bucket,
} progress_category;

@interface ProgressWindowController : NSWindowController
{
    IBOutlet NSTextField* _actionTarget;
    IBOutlet NSProgressIndicator* _progressIndicator;
    progress_category _oper;
    OperPackage*  _obj;
    CopyProgress* _cpyprogress;
}

@property(assign,nonatomic)progress_category _oper;
@property(retain,nonatomic)OperPackage* _obj;
@property(nonatomic,retain)CopyProgress* _cpyprogress;

-(void)setprogresstype:(OperPackage*)package type:(NSInteger)type;
-(void)displayex;

@end
