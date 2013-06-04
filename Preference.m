#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

__attribute__((visibility("hidden")))
@interface POListController: PSListController <UIAlertViewDelegate>
- (id)specifiers;
@end

@implementation POListController

- (id)specifiers
{
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PreferenceOrganizer" target:self] retain];
	}
	return _specifiers;
}

- (void)openGithub:(id)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/wakinchan/PreferenceOrganizer"]];
}

- (void)killPreferences:(id)specifier
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kill \"Preferences.app\"?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Apply", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) exit(1);
}

@end

//
// Many code import from FakeClockUp.plist
// https://github.com/r-plus/FakeClockUp/blob/experimental/Resources/FakeClockUp.plist
//

__attribute__((visibility("hidden")))
@interface LicenseController : PSViewController
{
	UITextView *view;
}
@end

@implementation LicenseController

- (id)initForContentSize:(CGSize)size
{
	if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)])
    	self = [super initForContentSize:size];
  	else
    	self = [super init];
  	if (self) {
	    CGRect frame;
	    frame.origin = CGPointMake(0,0);
	    frame.size = size;
	    view = [[UITextView alloc] initWithFrame:frame];
	    NSData *data = [NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/PreferenceOrganizerSettings.bundle/License"];
	    view.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
	    view.editable = NO;
	    view.font = [UIFont systemFontOfSize:8.0f];
	    if ([self respondsToSelector:@selector(navigationItem)])
	    	[[self navigationItem] setTitle:@"License"];
  	}
  	return self;
}

- (UIView *)view
{
	return view;
}

- (CGSize)contentSize
{
	return [view frame].size;
}

- (void)dealloc
{
	[view release];
  	view = nil;
	[super dealloc];
}
@end