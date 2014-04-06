#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>

#define OFSCHEMIFY(str) [NSURL URLWithString:[[@"omnifocus:///add?name=" stringByAppendingString:str] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]

@interface OmniFast : NSObject <LAListener, UIAlertViewDelegate> {
@private
	UIAlertView *_taskView;
}
@end

@implementation OmniFast

- (BOOL)dismiss {
	if (_taskView) {
		[_taskView dismissWithClickedButtonIndex:[_taskView cancelButtonIndex] animated:YES];
		return YES;
	}

	return NO;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	_taskView = nil;
	[_taskView release];

	if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Create"]) {
		NSString *task = [alertView textFieldAtIndex:0].text;
		NSLog(@"[OmniFast] Creating task \"%@\" using OmniFocus URL-scheme...", task);
		[[UIApplication sharedApplication] openURL:OFSCHEMIFY(task)];
	}
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (![self dismiss]) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"omnifocus:"]]) {
			_taskView = [[UIAlertView alloc] initWithTitle:@"OmniFast" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
			[_taskView setAlertViewStyle:UIAlertViewStylePlainTextInput];
			[[_taskView textFieldAtIndex:0] setPlaceholder:@"New OmniFocus Task"];
		}

		else {
			_taskView = [[UIAlertView alloc] initWithTitle:@"OmniFocus Required" message:@"Please install OmniFocus for iOS 7 from the App Store to use OmniFast!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		}

		[_taskView show];
		[event setHandled:YES];
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	if ([self dismiss]) {
		[event setHandled:YES];
	}
}

- (void)dealloc {
	[_taskView release];
	[super dealloc];
}

+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"libactivator.OmniFast"];
	[pool release];
}

@end
