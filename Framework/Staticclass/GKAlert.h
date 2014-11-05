
#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef void (^DismissBlock)(NSInteger buttonIndex);
typedef void (^CancelBlock)();
typedef BOOL (^DismissResultBlock)(NSInteger buttonIndex);

@interface GKAlert : NSAlert
{
    BOOL _hasCancelButton;
    
    DismissBlock _dismissBlock;
    CancelBlock _cancelBlock;
    DismissResultBlock _dismissResultBlock;
    
    NSInteger _retIndex;
    NSConditionLock*    _lock;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)showGKSheetModalForWindow:(NSWindow*) window
                         message:(NSString*) message
                 informativeText:(NSString*) text
                      alertStyle:(NSAlertStyle) style
               otherButtonTitles:(NSArray*) otherButtons
                       onDismiss:(DismissResultBlock) dismissed;

- (void)showSheetModalForWindow:(NSWindow*) window
                            message:(NSString*) message
                    informativeText:(NSString*) text
                         alertStyle:(NSAlertStyle) style
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled;

//确定
-(void) showGKSheetModalForWindow:(NSWindow*) window
                      messageText:(NSString*) messageText
                  informativeText:(NSString*) informativeText
                cancelButtonTitle:(NSString*) cancelButtonTitle;

//是、否
-(NSInteger) showGKSheetModalForWindow:(NSWindow*) window
                           messageText:(NSString*) messageText
                       informativeText:(NSString*) informativeText
                 buttonTitles:(NSArray*) buttonTitles;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////