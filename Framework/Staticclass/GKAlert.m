#import "GKAlert.h"
#import "Util.h"

@implementation GKAlert

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc
{
    if (_dismissBlock) {
        [_dismissBlock release];
        _dismissBlock = nil;
    }
    if (_cancelBlock) {
        [_cancelBlock release];
        _cancelBlock = nil;
    }
    if (_dismissResultBlock) {
        [_dismissResultBlock release];
        _dismissResultBlock = nil;
    }
    if (_lock) {
        [_lock release];
    }
    
    [super dealloc];
}

-(void)showGKSheetModalForWindow:(NSWindow*) window
                         message:(NSString*) message
                 informativeText:(NSString*) text
                      alertStyle:(NSAlertStyle) style
               otherButtonTitles:(NSArray*) otherButtons
                       onDismiss:(DismissResultBlock) dismissed
{
	[self setMessageText:message];
	[self setInformativeText:text];
	[self setAlertStyle:style];
    for(NSString *buttonTitle in otherButtons) {
		[self addButtonWithTitle:buttonTitle];
    }
    
    _dismissResultBlock  = [dismissed copy];
    
	[self beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(gkAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)gkAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    
 	NSInteger buttonIndex = returnCode;
    _dismissResultBlock(buttonIndex);
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) showSheetModalForWindow:(NSWindow*) window
                             message:(NSString*) message
                     informativeText:(NSString*) text
                          alertStyle:(NSAlertStyle) style
                   cancelButtonTitle:(NSString*) cancelButtonTitle
                   otherButtonTitles:(NSArray*) otherButtons
                           onDismiss:(DismissBlock) dismissed
                            onCancel:(CancelBlock) cancelled
{
    [self setMessageText:message];
	[self setInformativeText:text];
	[self setAlertStyle:style];
	
	for(NSString *buttonTitle in otherButtons) {
		[self addButtonWithTitle:buttonTitle];
    }
    
	_cancelBlock  = [cancelled copy];
	_dismissBlock  = [dismissed copy];
	
	if (cancelButtonTitle) {
		_hasCancelButton = YES;
		[self addButtonWithTitle:cancelButtonTitle];
	}
	else {
		_hasCancelButton = NO;
    }
	
	[self beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	NSInteger count = [[alert buttons] count];
	NSInteger buttonIndex = returnCode-1000;
	
    // cancel button is last button added
	if(_hasCancelButton && buttonIndex == count-1)
	{
        if (_cancelBlock) {
            _cancelBlock();
        }
	}
	else
	{
        if (_dismissBlock) {
            _dismissBlock(buttonIndex);
        }
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)mywindowclose
{
    [_lock unlockWithCondition:1];
    NSLog(@"mywindowclose");
}

-(void) showEx:(NSWindow*)window
{
    NSLog(@"showEx1");
    
    [self beginSheetModalForWindow:window
                     modalDelegate:nil
                    didEndSelector:@selector(mywindowclose)
                       contextInfo:nil];
    
    NSLog(@"showEx2");
}

-(void) showGKSheetModalForWindow:(NSWindow*) window
                      messageText:(NSString*) messageText
                  informativeText:(NSString*) informativeText
                cancelButtonTitle:(NSString*) cancelButtonTitle
{
    [self setMessageText:messageText];
    [self setInformativeText:informativeText];
    [self addButtonWithTitle:cancelButtonTitle];
    
    if (![[NSThread currentThread] isMainThread]) {
        _lock=[[NSConditionLock alloc]initWithCondition:0];
        [self performSelectorOnMainThread:@selector(showEx:) withObject:window waitUntilDone:YES];
        [_lock lockWhenCondition:1];
    }
    else {
        [self showEx:window];
    }
    NSLog(@"showGKSheetModalForWindow");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) showModalEx:(NSWindow*)window
{
     _retIndex=[self runModal];
}

-(NSInteger) showGKSheetModalForWindow:(NSWindow*) window
                           messageText:(NSString*) messageText
                       informativeText:(NSString*) informativeText
                          buttonTitles:(NSArray*) buttonTitles
{
    [self setMessageText:messageText];
    [self setInformativeText:informativeText];
    
    for (int i=0; i<buttonTitles.count; i++) {
        NSString* title=[buttonTitles objectAtIndex:i];
        if (title.length) {
            [self addButtonWithTitle:title];
        }
    }

    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:@selector(showModalEx:) withObject:window waitUntilDone:YES];
    }
    else {
        [self showModalEx:window];
    }
    
    return _retIndex;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////