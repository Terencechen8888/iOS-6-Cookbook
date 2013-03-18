/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "CrayonHandler.h"

#define ALPHA    @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@interface TestBedViewController : UITableViewController <UISearchBarDelegate>
{
    CrayonHandler *crayons;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
}
@end

@implementation TestBedViewController

// 段的數目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    if (aTableView == searchController.searchResultsTableView) return 1;
    return crayons.numberOfSections;
}

// 某段含有的列的數目
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (aTableView == searchController.searchResultsTableView)
        return [crayons filterWithString:searchBar.text];
    return [crayons countInSection:section];
}

// 根據索引路徑回傳儲存格
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *crayonName;
    
    if (aTableView == self.tableView)
    {
        crayonName = [crayons colorNameAtIndexPath:indexPath];
    }
    else
    {
        if (indexPath.row < crayons.filteredArray.count)
            crayonName  = crayons.filteredArray[indexPath.row];
    }
    
    if (!crayonName)
    {
        NSLog(@"Unexpected error retrieving cell: [%d, %d] table: %@", indexPath.section, indexPath.row, aTableView);
        return nil;
    }

    cell.textLabel.text = crayonName ;
    cell.textLabel.textColor = [crayons colorNamed:crayonName];
    if ([crayonName hasPrefix:@"White"])
        cell.textLabel.textColor = [UIColor blackColor];

    return cell;
}

// 根據給定標題，找出段的編號
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (title == UITableViewIndexSearch)
    {
        [self.tableView scrollRectToVisible:searchBar.frame animated:NO];
        return -1;
    }
    return [ALPHA rangeOfString:title].location;
}

// 段的索引的標題
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
    if (aTableView == searchController.searchResultsTableView) return nil;
    
    NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    for (int i = 0; i < crayons.numberOfSections; i++)
    {
        NSString *name = [crayons nameForSection:i];
        if (name) [indices addObject:name];
    }
    return indices;
}

// 回傳某段得標頭文字
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (aTableView == searchController.searchResultsTableView) return nil;
    return [crayons nameForSection:section];
}


// 點選某列時，更新導覽列的顏色
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *color = nil;
    if (aTableView == self.tableView)
        color = [crayons colorAtIndexPath:indexPath];
    else
    {
        if (indexPath.row < crayons.filteredArray.count)
        {
            NSString *colorName = crayons.filteredArray[indexPath.row];
            if (colorName)
                color = [crayons colorNamed:colorName];
        }
    }
    
    if (color)
    {
        self.navigationController.navigationBar.tintColor = color;
        searchBar.tintColor = color;
    }

}

// 謝謝Jack Lucky。Cancel按鈕代表重置搜尋關鍵字
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    [searchBar setText:@""];
}

// 顯示時，將搜尋列捲到外面
- (void) viewDidAppear:(BOOL)animated
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


// 設定表格
- (void) loadView
{
    [super loadView];
    crayons = [[CrayonHandler alloc] init];
    

    // 建立搜尋列
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    searchBar.tintColor = COOKBOOK_PURPLE_COLOR;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.keyboardType = UIKeyboardTypeAlphabet;
    self.tableView.tableHeaderView = searchBar;
    
    // 建立搜尋顯示控制器
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
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