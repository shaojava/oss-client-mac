#import "NSAlert+Blocks.h"
#import "Util.h"

@implementation NSAlert (Blocks)


+(void)showGKSheetModalForWindow:(NSWindow*) window
                         message:(NSString*) message
                 informativeText:(NSString*) text
                      alertStyle:(NSAlertStyle) style
               otherButtonTitles:(NSArray*) otherButtons
                       onDismiss:(DismissResultBlock) dismissed
{
	GKAlert *alert = [[[GKAlert alloc] init] autorelease];
    [alert showGKSheetModalForWindow:window message:message informativeText:text alertStyle:style otherButtonTitles:otherButtons onDismiss:dismissed];
}


+ (NSAlert*) showSheetModalForWindow:(NSWindow*) window
									  message:(NSString*) message
							informativeText:(NSString*) text
								  alertStyle:(NSAlertStyle) style
						 cancelButtonTitle:(NSString*) cancelButtonTitle
						 otherButtonTitles:(NSArray*) otherButtons
									onDismiss:(DismissBlock) dismissed
									 onCancel:(CancelBlock) cancelled
{
	GKAlert *alert = [[GKAlert alloc] init];
    [alert showSheetModalForWindow:window message:message informativeText:text alertStyle:style cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons onDismiss:dismissed onCancel:cancelled];
    
    return [alert autorelease];
}

+(void) showGKSheetModalForWindow:(NSWindow*) window message:(NSString*) message text:(NSString*)text cancelButtonTitle:(NSString*) cancelButtonTitle
{
    GKAlert *alert = [[[GKAlert alloc] init] autorelease];
    [alert showGKSheetModalForWindow:window messageText:message informativeText:text cancelButtonTitle:cancelButtonTitle];
}

+(NSInteger) showGKSheetModalForWindow:(NSWindow*) window
                               message:(NSString*) message
                                  text:(NSString*) text
                          buttonTitles:(NSArray*)buttonTitles
{
    GKAlert* alert = [[[GKAlert alloc] init] autorelease];
    return [alert showGKSheetModalForWindow:window messageText:message informativeText:text buttonTitles:buttonTitles];
}


@end