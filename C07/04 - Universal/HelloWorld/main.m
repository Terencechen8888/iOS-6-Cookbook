/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define CONSTRAIN(VIEW, FORMAT)     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:0 metrics:nil views:NSDictionaryOfVariableBindings(VIEW)]]
#define PREPCONSTRAINTS(VIEW) [VIEW setTranslatesAutoresizingMaskIntoConstraints:NO]

#pragma mark -
#pragma mark Detail View Controller

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIPopoverController *myPopoverController;
@end

@implementation DetailViewController
+ (id) controller
{
	DetailViewController *controller = [[DetailViewController alloc] init];
	controller.view.backgroundColor = [UIColor blackColor];
	return controller;
}

// 變成直擺時會被呼叫，隱藏表格視圖
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)aPopoverController
{
    barButtonItem.title = aViewController.title;
	self.navigationItem.leftBarButtonItem = barButtonItem;
    self.myPopoverController = aPopoverController;
}

// 變成橫擺時會被呼叫
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	self.navigationItem.leftBarButtonItem = nil;
    self.myPopoverController = nil;
}

// 啟用這個方法便能在直擺時避免懸浮元件
// 若無此方法，便會得到預設行為
/* - (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}*/
@end

#pragma mark Table-based Root View Browser
@interface ColorTableViewController : UITableViewController
@end

@implementation ColorTableViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSArray *) selectors
{
    return @[@"blackColor", @"redColor", @"greenColor", @"blueColor", @"cyanColor", @"yellowColor", @"magentaColor", @"orangeColor", @"purpleColor", @"brownColor"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self selectors].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generic"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"generic"];
    
    NSString *item = [self selectors][indexPath.row];
	cell.textLabel.text = item;
	cell.textLabel.textColor = [UIColor performSelector:NSSelectorFromString(item) withObject:nil];
    cell.accessoryType = IS_IPAD ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (IS_IPAD)
	{
        UINavigationController *nav = [self.splitViewController.viewControllers lastObject];
        UIViewController *controller = [nav topViewController];
		controller.view.backgroundColor = cell.textLabel.textColor;
	}
	else
	{
		DetailViewController *controller = [DetailViewController controller];
		controller.view.backgroundColor = cell.textLabel.textColor;
        controller.title = cell.textLabel.text;
		[self.navigationController pushViewController:controller animated:YES];
	}
}

- (void) viewWillAppear: (BOOL) animated
{
	self.tableView.rowHeight = 72.0f;
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
- (UISplitViewController *) splitviewController
{
	// 建立包在導覽控制器裡的主要（根）視圖
	ColorTableViewController *rootVC = [[ColorTableViewController alloc] init];
    rootVC.title = @"Colors";
	UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootVC];
	
	// 建立包在導覽控制器裡的細節視圖
	DetailViewController *detailVC = [DetailViewController controller];
	UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:detailVC];
	
	// 將兩者加入分割視圖控制器
	UISplitViewController *svc = [[UISplitViewController alloc] init];
	svc.viewControllers = @[rootNav, detailNav];
	svc.delegate = detailVC;
	
	return svc;
}

- (UINavigationController *) navWithColorTableViewController
{
	ColorTableViewController *rootVC = [[ColorTableViewController alloc] init];
    rootVC.title = @"Colors";
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
	return nav;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	if (IS_IPAD)
		window.rootViewController = [self splitviewController];
	else
		window.rootViewController = [self navWithColorTableViewController];
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