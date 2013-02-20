/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "CrayonHandler.h"

#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@interface TestBedViewController : UITableViewController
{
    CrayonHandler *crayons;
}
@end

@implementation TestBedViewController

// 段的數目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return crayons.numberOfSections;
}

// 某段含有的列的數目
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [crayons countInSection:section];
}

// 根據索引路徑回傳儲存格
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *crayonName = [crayons colorNameAtIndexPath:indexPath];
    cell.textLabel.text = crayonName;
	if ([crayonName hasPrefix:@"White"])
		cell.textLabel.textColor = [UIColor blackColor];
	else
		cell.textLabel.textColor = [crayons colorAtIndexPath:indexPath];

	return cell;
}

// 根據給定標題，找出段的編號
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [ALPHA rangeOfString:title].location;
}

// 回傳某段得標頭文字
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = [crayons nameForSection:section];
    if (!sectionName) return nil;
    return [NSString stringWithFormat:@"Crayon names starting with '%@'", sectionName];
}

// 段的索引的標題
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
    NSMutableArray *indices = [NSMutableArray array];
    for (int i = 0; i < crayons.numberOfSections; i++)
    {
        NSString *name = [crayons nameForSection:i];
        if (name) [indices addObject:name];
    }
    return indices;
}

// 點選某列時，更新導覽列的顏色
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *color = [crayons colorAtIndexPath:indexPath];
    self.navigationController.navigationBar.tintColor = color;
}


// 設定表格
- (void) loadView
{
    [super loadView];
    [self.tableView registerClass:[UITableViewCell class]forCellReuseIdentifier:@"cell"];
    crayons = [[CrayonHandler alloc] init];
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