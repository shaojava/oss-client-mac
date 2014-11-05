#import <Foundation/Foundation.h>
#import "GKAlert.h"


@interface NSAlert (Blocks)


+(void) showGKSheetModalForWindow:(NSWindow*) window
                                message:(NSString*) message
                        informativeText:(NSString*) text
                             alertStyle:(NSAlertStyle) style
                      otherButtonTitles:(NSArray*) otherButtons
                              onDismiss:(DismissResultBlock) dismissed;

+(NSAlert*) showSheetModalForWindow:(NSWindow*) window
                            message:(NSString*) message
                    informativeText:(NSString*) text
                         alertStyle:(NSAlertStyle) style
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled;

+(void) showGKSheetModalForWindow:(NSWindow*) window
                          message:(NSString*) message
                             text:(NSString*) text
                cancelButtonTitle:(NSString*) cancelButtonTitle;


//NSAlertFirstButtonReturn(1000),1001,1002,...
+(NSInteger) showGKSheetModalForWindow:(NSWindow*) window
                               message:(NSString*) message
                                  text:(NSString*) text
                          buttonTitles:(NSArray*)buttonTitles;


@end