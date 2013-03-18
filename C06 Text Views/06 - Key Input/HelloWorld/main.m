/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define CONSTRAIN(VIEW, FORMAT)     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:0 metrics:nil views:NSDictionaryOfVariableBindings(VIEW)]]

@interface KeyInputToolbar: UIToolbar <UIKeyInput>
{
	NSMutableString *string;
}
@end

@implementation KeyInputToolbar

// 有文字可以被刪除嗎？
- (BOOL) hasText
{
	if (!string || !string.length) return NO;
	return YES;
}

// 重新載入工具列，更新字串
- (void) update
{
	NSMutableArray *theItems = [NSMutableArray array];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[theItems addObject:BARBUTTON(string, @selector(becomeFirstResponder))];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	self.items = theItems;	
}

// 插入新字串
- (void)insertText:(NSString *)text
{
	if (!string) string = [NSMutableString string];
	[string appendString:text];
	[self update];
}

// 刪除一個字元
- (void)deleteBackward
{
	// 請特別小心，即使hasText回傳YES
	if (!string) 
	{
		string = [NSMutableString string];
		return;
	}
	
	if (!string.length) 
		return;
	
	// 刪除一個字元
	[string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
	[self update];
}

// 成為第一回應者時，送出相對應的通知
- (BOOL) becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];
    if (result)
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"KeyInputToolbarDidBecomeFirstResponder" object:nil]];
    return result;
}

- (BOOL)canBecomeFirstResponder 
{ 
	return YES; 
}

// 孩子，千萬別在要提交給App Store的程式碼裡使用底下的方法
// 強迫只使用實體鍵盤
/* - (void) disableOnscreenKeyboard
 {
 void *gs = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY);
 int (*kb)(BOOL yorn) = (int (*)(BOOL))dlsym(gs, "GSEventSetHardwareKeyboardAttached");
 kb(YES);
 dlclose(gs);	
 } */


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	// [self disableOnscreenKeyboard]; // 不符合App Store的規定
	[self becomeFirstResponder];
}	
@end

@interface TestBedViewController : UIViewController
{
    KeyInputToolbar *kit;
}
@end

@implementation TestBedViewController
- (void) done: (id) sender
{
    [kit resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    // 建立自訂視圖
	kit = [[KeyInputToolbar alloc] initWithFrame:CGRectZero];
	[self.view addSubview:kit];
    
    kit.translatesAutoresizingMaskIntoConstraints = NO;
    CONSTRAIN(kit, @"H:|[kit(>=0)]|");
    CONSTRAIN(kit, @"V:|-60-[kit(44.0)]");
     kit.userInteractionEnabled = YES;

    // 當自訂視圖成為第一回應者時
    // 在類iPhone介面上顯示Done完成按鈕
    [[NSNotificationCenter defaultCenter] addObserverForName:@"KeyInputToolbarDidBecomeFirstResponder" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
        if (!IS_IPAD)
            self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(done:));
    }];
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
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}