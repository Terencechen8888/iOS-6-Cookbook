/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface DragView : UIImageView
{
	CGPoint startLocation;
}
@end

@implementation DragView
- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
		self.userInteractionEnabled = YES;
	return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// 計算並儲存偏移量，並把視圖帶到最上面
	startLocation = [[touches anyObject] locationInView:self];
	[self.superview bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	// 計算偏移量
	CGPoint pt = [[touches anyObject] locationInView:self];
	float dx = pt.x - startLocation.x;
	float dy = pt.y - startLocation.y;
	CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
	
	// 設定新位置
	self.center = newcenter;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (CGPoint) randomFlowerPosition
{
    CGFloat halfFlower = 32.0f; // 花朵一半的大小
    
    // 花朵必須完整顯示於視圖內，依此設定CGRectInset
    CGSize insetSize = CGRectInset(self.view.bounds, 2*halfFlower, 2*halfFlower).size;

    // 回傳範圍內的一個亂數位置
    CGFloat randomX = random() % ((int)insetSize.width) + halfFlower;
    CGFloat randomY = random() % ((int)insetSize.height) + halfFlower;
    return CGPointMake(randomX, randomY);
}

- (void) layoutFlowers
{
    // Move every flower into a new random place
    [UIView animateWithDuration:0.3f animations: ^(){
        for (UIView *flowerDragger in self.view.subviews)
            flowerDragger.center = [self randomFlowerPosition];}];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self layoutFlowers];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSInteger maxFlowers = 12; // 花朵的數目
    NSArray *flowerArray = @[@"blueFlower.png", @"pinkFlower.png", @"orangeFlower.png"];

    // 加入花朵
	for (int i = 0; i < maxFlowers; i++)
	{
		NSString *whichFlower = [flowerArray objectAtIndex:(random() % flowerArray.count)];
		DragView *flowerDragger = [[DragView alloc] initWithImage:[UIImage imageNamed:whichFlower]];
		[self.view addSubview:flowerDragger];
    }
    
    // 提供亂數擺放花朵的"Randomize"按鈕
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Randomize", @selector(layoutFlowers));
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // 檢查花朵是否在螢幕外，若是則移動到螢幕內
    
    CGFloat halfFlower = 32.0f;
    CGRect targetRect = CGRectInset(self.view.bounds, halfFlower * 2, halfFlower * 2);
    targetRect = CGRectOffset(targetRect, halfFlower, halfFlower);
    
    for (UIView *flowerDragger in self.view.subviews)
        if (!CGRectContainsPoint(targetRect, flowerDragger.center))
            [UIView animateWithDuration:0.3f animations:
             ^(){flowerDragger.center = [self randomFlowerPosition];}];
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
    [application setStatusBarHidden:YES];
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