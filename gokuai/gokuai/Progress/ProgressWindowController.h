

#import <Cocoa/Cocoa.h>
#import "CopyProgress.h"

@class transportnode;

typedef enum _progress_category_ {
    pc_copy,
    pc_delete,
} progress_category;


@interface ProgressPackage : NSObject {
    progress_category _oper;
    id _obj;
}

@property(assign,nonatomic)progress_category _oper;
@property(retain,nonatomic)id _obj;

-(id) initCopy:(id)obj;
-(id) initDelete:(id)obj;

@end

@interface ProgressWindowController : NSWindowController
{
    IBOutlet NSTextField* _actionTarget;
    IBOutlet NSProgressIndicator* _progressIndicator;
    ProgressPackage *_package;
    CopyProgress *_cpyprogress;
}

@property(nonatomic,retain) ProgressPackage *_package;
@property(nonatomic,retain) CopyProgress* _cpyprogress;

-(void) displayex;

@end
