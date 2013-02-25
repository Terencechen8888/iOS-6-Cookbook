/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "Person.h"
#import "Utility.h"

@interface TestBedViewController : UITableViewController <UISearchBarDelegate, NSFetchedResultsControllerDelegate>
{
    CoreDataHelper *dataHelper;
    UISearchDisplayController *searchController;
    NSArray *lineArray;
    int index;
    
    BOOL sectionHeadersAffected;
}
@end

@implementation TestBedViewController

#pragma mark Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 有幾段
    if (dataHelper.numberOfEntities == 0) return 0;
	return dataHelper.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 每段有幾列
    id <NSFetchedResultsSectionInfo> sectionInfo = dataHelper.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    // 段的標題
    NSArray *titles = [dataHelper.fetchedResultsController sectionIndexTitles];
    if (titles.count <= section)
        return @"Error";
    return titles[section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    // 允許捲動到搜尋列
	if (title == UITableViewIndexSearch)
	{
		[self.tableView scrollRectToVisible:searchController.searchBar.frame animated:NO];
		return -1;
	}
	return [dataHelper.fetchedResultsController.sectionIndexTitles indexOfObject:title];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
    // 段的索引標題，包括搜尋圖示
    if (aTableView == searchController.searchResultsTableView) return nil;
    return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[dataHelper.fetchedResultsController sectionIndexTitles]];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 根據目前顯示的表格回傳儲存格
    [aTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	Person *person = [dataHelper.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = person.fullname;    
	return cell;
}

#pragma mark Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 無動作
}

#pragma mark Editing and Undo
- (void) setBarButtonItems
{
    // 終止任何進行中的動作
    if (dataHelper.context.undoManager.isUndoing || dataHelper.context.undoManager.isRedoing)
    {
        [self performSelector:@selector(setBarButtonItems) withObject:nil afterDelay:0.1f];
        return;
    }
    
    UIBarButtonItem *undo = SYSBARBUTTON_TARGET(UIBarButtonSystemItemUndo, dataHelper.context.undoManager, @selector(undo));
    undo.enabled = dataHelper.context.undoManager.canUndo;
    UIBarButtonItem *redo = SYSBARBUTTON_TARGET(UIBarButtonSystemItemRedo, dataHelper.context.undoManager, @selector(redo));
    redo.enabled = dataHelper.context.undoManager.canRedo;
    UIBarButtonItem *add = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(addItem));
    
    self.navigationItem.leftBarButtonItems = @[add, undo, redo];
}


- (void) refresh
{
    // 若處於搜尋狀態，擷取搜尋後的結果，若不是，顯示所有資料
    if (searchController.searchBar.text)
        [dataHelper fetchItemsMatching:searchController.searchBar.text forAttribute:@"surname" sortingBy:nil];
    else
        [dataHelper fetchData];
    dataHelper.fetchedResultsController.delegate = self;
    
    // 重新載入表格
    [self.tableView reloadData];
    [searchController.searchResultsTableView reloadData];
    
    // 更新列按鈕項目
    [self setBarButtonItems];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeDelete)
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (type == NSFetchedResultsChangeInsert)
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    sectionHeadersAffected = YES;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    if (type == NSFetchedResultsChangeInsert)
        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    if (type == NSFetchedResultsChangeDelete)
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    sectionHeadersAffected = NO;
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];

    if (sectionHeadersAffected)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationNone];
    
    [self setBarButtonItems];
}

#define GETINDEX(ATTRIBUTE) [attributes indexOfObject:ATTRIBUTE]
- (void) setupNewPerson: (Person *) person
{
    // 加入一筆新資料到資料庫裡
    NSArray *attributes = @[@"number", @"gender", @"givenname", @"middleinitial", @"surname", @"streetaddress", @"city", @"state", @"zipcode", @"country", @"emailaddress", @"password", @"telephonenumber", @"mothersmaiden", @"birthday", @"cctype", @"ccnumber", @"cvv2", @"ccexpires", @"nationalid", @"ups", @"occupation", @"domain", @"bloodtype", @"pounds", @"kilograms", @"feetinches", @"centimeters"];

    if (!lineArray)
    {
        NSString *dataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FakePersons" ofType:@"csv"] encoding:NSUTF8StringEncoding error:nil];
        lineArray = [dataString componentsSeparatedByString:@"\n"];
    }
    NSString *line = lineArray[index++];
    NSArray *items = [line componentsSeparatedByString:@","];
    
    person.surname = items[GETINDEX(@"surname")];
    person.section = [[person.surname substringFromIndex:0] substringToIndex:1];
    person.emailaddress = items[GETINDEX(@"emailaddress")];
    person.gender = items[GETINDEX(@"gender")];
    person.middleinitial = items[GETINDEX(@"middleinitial")];
    person.occupation = items[GETINDEX(@"occupation")];
    person.givenname = items[GETINDEX(@"givenname")];
}

- (void) addItem
{
    // 將add以undo群組包起來
    NSUndoManager *manager = dataHelper.context.undoManager;
    [manager beginUndoGrouping];
    {
        Person *person = (Person *)[dataHelper newObject];
        [self setupNewPerson:person];
    }
    [manager endUndoGrouping];
    [manager setActionName:@"Add"];
    [dataHelper save];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 刪除
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObject *object = [dataHelper.fetchedResultsController objectAtIndexPath:indexPath];
        NSUndoManager *manager = dataHelper.context.undoManager;
        [manager beginUndoGrouping];
        {
            [dataHelper.context deleteObject:object];
        }
        [manager endUndoGrouping];
        [manager setActionName:@"Delete"];        
        [dataHelper save];
    }
}

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 只有主表格支援編輯功能
    if (aTableView == searchController.searchResultsTableView) return NO;
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;     // 不允許調整順序
}

- (void) setEditing: (BOOL) isEditing animated: (BOOL) animated
{
    [super setEditing:isEditing animated:animated];
    [self.tableView setEditing:isEditing animated:animated];
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if (path)
        [self.tableView deselectRowAtIndexPath:path animated:YES];
    
    [self setBarButtonItems];
}

#pragma mark Searching
#pragma mark Search Bar
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    // 停止搜尋
	aSearchBar.text = @"";
    [self refresh];
}

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText
{
    // 建立NSPredicate更新搜尋結果
	[dataHelper fetchItemsMatching:aSearchBar.text forAttribute:@"surname" sortingBy:nil];
}

#pragma mark Setup

- (void) loadView
{
    [super loadView];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // 建立搜尋列
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
	searchBar.delegate = self;
	self.tableView.tableHeaderView = searchBar;
	
	// 建立搜尋顯示控制器
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;

    // 建立Core Data
    dataHelper = [[CoreDataHelper alloc] init];
    dataHelper.entityName = @"Person";
    dataHelper.defaultSortAttribute = @"surname";
    
    // 準備亂數
    srand(time(0));
    index = rand() % 1000;

    // 設定
    [dataHelper setupCoreData];
    // [dataHelper clearData]; // 你或許想要在執行時先清除資料
    [self refresh];
}

#pragma mark First Responder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    
    if (dataHelper.numberOfEntities == 0) return;
    
    // 隱藏搜尋列
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic) UIWindow *window;
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
	[_window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}