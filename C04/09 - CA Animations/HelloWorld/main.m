/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController
{
    UIImageView *frontObject;
    UIImageView *backObject;
}
@end

@implementation TestBedViewController
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
}

- (void) animate: (id) sender
{
	// 設定
	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 1.0f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	
	switch ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]) 
	{
		case 0:
			animation.type = kCATransitionFade;
			break;
		case 1:
			animation.type = kCATransitionMoveIn;
			break;
		case 2:
			animation.type = kCATransitionPush;
			break;
		case 3:
			animation.type = kCATransitionReveal;
		default:
			break;
	}
	animation.subtype = kCATransitionFromBottom;
	
	// 執行動畫
	[self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
	[self.view.layer addAnimation:animation forKey:@"animation"];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 加入次要物件
    backObject = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Maroon.png"]];
    [self.view addSubview:backObject];
    PREPCONSTRAINTS(backObject);
    CENTER_VIEW(self.view, backObject);
    
    // 加入主要物件
    frontObject = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Purple.png"]];
    [self.view addSubview:frontObject];
    PREPCONSTRAINTS(frontObject);
    CENTER_VIEW(self.view, frontObject);

	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(animate:));
    
    // 加入分段控制項，選擇動畫效果
	UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:[@"Fade Over Push Reveal" componentsSeparatedByString:@" "]];
	sc.segmentedControlStyle = UISegmentedControlStyleBar;
	sc. selectedSegmentIndex = 0;
	self.navigationItem.titleView = sc;
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
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}