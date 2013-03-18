/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define MAXCIRCLES  12
#define SIDELENGTH  96.0f
#define HALFCIRCLE  48.0f
#define INSET_AMT   4

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
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gestureRecognizers = @[pan];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event 
{
	CGPoint pt;
	float HALFSIDE = SIDELENGTH / 2.0f;
	
	// 將圓點當做中心，正規化
	pt.x = (point.x - HALFSIDE) / HALFSIDE;
	pt.y = (point.y - HALFSIDE) / HALFSIDE;
	
	// x^2 + y^2 = radius（半徑）
	float xsquared = pt.x * pt.x;
	float ysquared = pt.y * pt.y;
	
	// 若半徑小於或等於1，該點落於圓圈內
	if ((xsquared + ysquared) < 1.0) return YES;
	return NO;
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
@end

@implementation TestBedViewController

- (CGPoint) randomPosition
{
    CGFloat x = random() % ((int)(self.view.bounds.size.width - 2 * HALFCIRCLE)) + HALFCIRCLE;
    CGFloat y = random() % ((int)(self.view.bounds.size.height - 2 * HALFCIRCLE)) + HALFCIRCLE;
    return CGPointMake(x, y);
}

#define RANDOMLEVEL	((random() % 128) / 256.0f)

- (UIImage *) createImage
{
	UIColor *color = [UIColor colorWithRed:RANDOMLEVEL green:RANDOMLEVEL blue:RANDOMLEVEL alpha:1.0f];
	
	UIGraphicsBeginImageContext(CGSizeMake(SIDELENGTH, SIDELENGTH));
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// 建立填滿顏色的橢圓
	[color setFill];
	CGRect rect = CGRectMake(0.0f, 0.0f, SIDELENGTH, SIDELENGTH);
	CGContextAddEllipseInRect(context, rect);
	CGContextFillPath(context);
	
	// 繪製圓圈外圍，數次
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextAddEllipseInRect(context, CGRectInset(rect, INSET_AMT, INSET_AMT));
	CGContextStrokePath(context);
	CGContextAddEllipseInRect(context, CGRectInset(rect, 2*INSET_AMT, 2*INSET_AMT));
	CGContextStrokePath(context);
	
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor blackColor];

    // 在螢幕上的亂數位置加入圓圈
    for (int i = 0; i < MAXCIRCLES; i++)
    {
        DragView *dragger = [[DragView alloc] initWithImage:[self createImage]];
        dragger.center = [self randomPosition];
        [self.view addSubview:dragger];
    }	
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
    [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    // UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = tbvc;
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