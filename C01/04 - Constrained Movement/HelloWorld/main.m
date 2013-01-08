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
    CGPoint previousLocation;
}
@end

@implementation DragView
- (id) initWithImage: (UIImage *) anImage
{
    if (self = [super initWithImage:anImage])
    {
        self.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gestureRecognizers = @[panRecognizer];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 將被觸摸到的視圖帶到最前面
    [self.superview bringSubviewToFront:self];
    
    // 記住原來的位置
    previousLocation = self.center;
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	CGPoint translation = [uigr translationInView:self.superview];
	CGPoint newcenter = CGPointMake(previousLocation.x + translation.x, previousLocation.y + translation.y);
	
	// 將移動範圍限制在父視圖的bounds內
	float halfx = CGRectGetMidX(self.bounds);
	newcenter.x = MAX(halfx, newcenter.x);
	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
	
	float halfy = CGRectGetMidY(self.bounds);
	newcenter.y = MAX(halfy, newcenter.y);
	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
	
	// 設定新位置
	self.center = newcenter;	
}
@end

@interface TestBedViewController : UIViewController
{
    UIView *bgView;
}
@end

@implementation TestBedViewController
- (CGPoint) randomFlowerPosition
{
    CGFloat halfFlower = 32.0f; // 花朵一半的大小
    
    // 花朵必須完整顯示於視圖內，依此設定CGRectInset
    CGSize insetSize = CGRectInset(bgView.bounds, 2*halfFlower, 2*halfFlower).size;

    // 回傳範圍內的一個亂數位置
    CGFloat randomX = random() % ((int)insetSize.width) + halfFlower;
    CGFloat randomY = random() % ((int)insetSize.height) + halfFlower;
    return CGPointMake(randomX, randomY);
}

- (void) layoutFlowers
{
    // 移動所有花朵到新的亂數位置
    [UIView animateWithDuration:0.3f animations: ^(){
        for (UIView *flowerDragger in bgView.subviews)
            flowerDragger.center = [self randomFlowerPosition];}];
}

- (void) viewDidAppear:(BOOL)animated
{
    bgView.frame = CGRectInset(self.view.bounds, 64.0f, 64.0f);
    [self layoutFlowers];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bgView];
    
    NSInteger maxFlowers = 12; // 花朵的數目
    NSArray *flowerArray = @[@"blueFlower.png", @"pinkFlower.png", @"orangeFlower.png"];

    // 加入花朵
	for (int i = 0; i < maxFlowers; i++)
	{
		NSString *whichFlower = [flowerArray objectAtIndex:(random() % flowerArray.count)];
		DragView *flowerDragger = [[DragView alloc] initWithImage:[UIImage imageNamed:whichFlower]];
		[bgView addSubview:flowerDragger];
    }
    
    // 提供亂數擺放花朵的"Randomize"按鈕
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Randomize", @selector(layoutFlowers));
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    bgView.frame = CGRectInset(self.view.bounds, 64.0f, 64.0f);

    // 檢查花朵是否在螢幕外，若是則移動到螢幕內
    
    CGFloat halfFlower = 32.0f;
    CGRect targetRect = CGRectInset(bgView.bounds, halfFlower * 2, halfFlower * 2);
    targetRect = CGRectOffset(targetRect, halfFlower, halfFlower);
    
    for (UIView *flowerDragger in bgView.subviews)
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