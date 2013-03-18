/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController  <UITextFieldDelegate>
{
    UITextField *tf;
    IBOutlet UITextField *leftLabel;
}
@end

@implementation TestBedViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) viewDidLoad
{
    // 手動建立文字輸入欄位
	tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 97.0f, 31.0f)];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:tf];
    
    // 置中並放在其他欄位之下
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[leftLabel]-15-[tf]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(leftLabel, tf)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tf attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
  
	// 更新所有文字輸入欄位，包括定義在IB裡的，
	// 設定委派、returnKeyType、以及其他有用的屬性
	for (UIView *view in self.view.subviews)
	{
		if ([view isKindOfClass:[UITextField class]])
		{
            UITextField *aTextField = (UITextField *)view;
            aTextField.delegate = self;
            
            aTextField.returnKeyType = UIReturnKeyDone;
            aTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

            aTextField.borderStyle = UITextBorderStyleRoundedRect;
            aTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            aTextField.autocorrectionType = UITextAutocorrectionTypeNo;

            aTextField.font = [UIFont fontWithName:@"Futura" size:12.0f];
            aTextField.placeholder = @"Placeholder";
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	/* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible]; */
    
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}