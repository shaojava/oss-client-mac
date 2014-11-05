

#import <Cocoa/Cocoa.h>
#import "LoadProgress.h"
#import "CopyProgress.h"

@class transportnode;

typedef enum _progress_category_ {
    pc_load,
    pc_copy,
} progress_category;


@interface ProgressPackage : NSObject {
    progress_category _oper;
    
    id _obj;
    BOOL _lck;
    NSString *_opentype;
    NSString *_defApp;
}

@property(assign,nonatomic)progress_category _oper;

@property(retain,nonatomic)id _obj;
@property(assign,nonatomic)BOOL _lck;
@property(retain,nonatomic)NSString *_defApp;
@property(retain,nonatomic)NSString * _opentype;

-(id) initOpen:(id)obj lck:(BOOL)lck defApp:(NSString *)defApp type:(NSString*)type;
-(id) initCopy:(id)obj;

@end

@interface ProgressWindowController : NSWindowController
{
    IBOutlet NSTextField* _actionTarget;
    IBOutlet NSTextField* _actionProgress;

    IBOutlet NSImageView* _fileIcon;
    IBOutlet NSProgressIndicator* _progressIndicator;
    IBOutlet NSButton* _btnMultiFunc;

    ProgressPackage *_package;
    
    LoadProgress *_progress;
    CopyProgress *_cpyprogress;
    
    BOOL _islock;
    
}

@property(nonatomic,retain) ProgressPackage *_package;

@property(nonatomic,retain) LoadProgress* _progress;
@property(nonatomic,retain) CopyProgress* _cpyprogress;

-(NSString *)uniquestring;

-(void) displayex;

@end
