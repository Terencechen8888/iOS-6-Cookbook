/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "RotatingSegue.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape(self.interfaceOrientation)

#define CONSTRAIN(VIEW, FORMAT)     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:0 metrics:nil views:NSDictionaryOfVariableBindings(VIEW)]]
#define PREPCONSTRAINTS(VIEW) [VIEW setTranslatesAutoresizingMaskIntoConstraints:NO]

@interface TestBedViewController : UIViewController
{
    NSArray *childControllers;
    UIView *backsplash;
    UIPageControl *pageControl;
    int vcIndex;
    int nextIndex;
}
@end

@implementation TestBedViewController
// 自訂的非正式委派方法
- (void) segueDidComplete
{
    UIViewController *source = [childControllers objectAtIndex:vcIndex];
    UIViewController *destination = [childControllers objectAtIndex:nextIndex];
    
    [destination didMoveToParentViewController:self];
    [source removeFromParentViewController];

    vcIndex = nextIndex;
    pageControl.currentPage = vcIndex;
}

// 以客製的串場切換到新視圖
- (void) switchToView: (int) newIndex goingForward: (BOOL) goesForward
{
    if (vcIndex == newIndex) return;
    nextIndex = newIndex;
    
    // 換到新控制器
    UIViewController *source = [childControllers objectAtIndex:vcIndex];
    UIViewController *destination = [childControllers objectAtIndex:newIndex];
    
    destination.view.frame = backsplash.bounds;
    
    [source willMoveToParentViewController:nil];
    [self addChildViewController:destination];

    RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];
    segue.goesForward = goesForward;
    segue.delegate = self;
    [segue perform];
}

// 往前
- (void) progress: (id) sender
{
    int newIndex = ((vcIndex + 1) % childControllers.count);
    [self switchToView:newIndex goingForward:YES];
}

// 往後
- (void) regress: (id) sender
{
    int newIndex = vcIndex - 1;
    if (newIndex < 0) newIndex = childControllers.count - 1;
    [self switchToView:newIndex goingForward:NO];
}

// 建立核心介面
- (void) viewDidLoad
{
    // 建立基本的背景
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // 建立背景圖，支援動畫效果
    backsplash = [[UIView alloc] initWithFrame:CGRectInset(self.view.frame, 50.0f, 50.0f)];
    backsplash.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backsplash];
    
    // 加入頁面視圖控制器
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 4;
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    
    // 從storyboard載入子控制器陣列
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"child" bundle:[NSBundle mainBundle]];
    childControllers = [NSArray arrayWithObjects:
                        [aStoryboard instantiateViewControllerWithIdentifier:@"0"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"1"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"2"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"3"],
                        nil];
    
    UISwipeGestureRecognizer *leftSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(progress:)];
    leftSwiper.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwiper.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:leftSwiper];
    
    UISwipeGestureRecognizer *rightSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(regress:)];
    rightSwiper.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwiper.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:rightSwiper];
    
    // 設定每個子控制器的標號與frame
    for (UIViewController *controller in childControllers)
    {
        controller.view.tag = 1066;
        controller.view.frame = backsplash.bounds;
    }
    
    // 以第一個子控制器初始化畫面
    vcIndex = 0;
    UIViewController *controller = (UIViewController *)[childControllers objectAtIndex:0];

    // 加入子視圖控制器
    [self addChildViewController:controller];
    [backsplash addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (UIViewController *controller in childControllers)
        controller.view.frame = backsplash.bounds;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
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