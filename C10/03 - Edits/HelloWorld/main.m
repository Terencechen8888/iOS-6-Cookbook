/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

#define IMAGE_SIZE  100.0f

@interface TestBedViewController : UITableViewController
{
    NSMutableArray *items;
}
@end

@implementation TestBedViewController

#pragma mark Data Source
// 段的數目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	return 1;
}

// 某段含有的列的數目
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

// 根據索引路徑回傳儲存格
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = items[indexPath.row];
    
    // 大致置中每張圖像
    CGFloat targetWidth = aTableView.bounds.size.width - IMAGE_SIZE - 40.0f;
    cell.indentationLevel = 1;
    cell.indentationWidth = targetWidth / 2.0f;
	return cell;
}

#pragma mark Edits
- (void) setBarButtonItems
{
    // 終止任何正進行中的動作
    if (self.undoManager.isUndoing || self.undoManager.isRedoing)
    {
        [self performSelector:@selector(setBarButtonItems) withObject:nil afterDelay:0.1f];
        return;
    }

    UIBarButtonItem *undo = SYSBARBUTTON_TARGET(UIBarButtonSystemItemUndo, self.undoManager, @selector(undo));
    undo.enabled = self.undoManager.canUndo;
    UIBarButtonItem *redo = SYSBARBUTTON_TARGET(UIBarButtonSystemItemRedo, self.undoManager, @selector(redo));
    redo.enabled = self.undoManager.canRedo;
    UIBarButtonItem *add = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(addItem:));

    self.navigationItem.leftBarButtonItems = @[add, undo, redo];
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

- (void) updateItemAtIndexPath: (NSIndexPath *) indexPath withObject: (id) object
{
    // 為回復功能作準備
    id undoObject = object ? nil : [items objectAtIndex:indexPath.row];
	[[self.undoManager prepareWithInvocationTarget:self] updateItemAtIndexPath:indexPath withObject:undoObject];
    
	// 不能插入nil項目，傳入nil的意思是刪除
    [self.tableView beginUpdates];
    if (!object)
    {
        [items removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else
    {
        [items insertObject:object atIndex:indexPath.row];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    [self.tableView endUpdates];

    [self performSelector:@selector(setBarButtonItems) withObject:nil afterDelay:0.1f];
}

- (void) addItem: (id) sender
{
	// 加入新項目
	NSIndexPath *newPath = [NSIndexPath indexPathForRow:items.count inSection:0];
    UIImage *image = blockImage(IMAGE_SIZE);
	[self updateItemAtIndexPath:newPath withObject:image];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 刪除項目
	[self updateItemAtIndexPath:indexPath withObject:nil];
}

-(void) tableView: (UITableView *) tableView moveRowAtIndexPath: (NSIndexPath *) oldPath toIndexPath:(NSIndexPath *) newPath
{
	if (oldPath.row == newPath.row) return;
	
	[[self.undoManager prepareWithInvocationTarget:self] tableView:self.tableView moveRowAtIndexPath:newPath toIndexPath:
     oldPath];

	id item = [items objectAtIndex:oldPath.row];
	[items removeObjectAtIndex:oldPath.row];
	[items insertObject:item atIndex:newPath.row];

    if (self.undoManager.isUndoing || self.undoManager.isRedoing)
    {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[oldPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }	
    
    [self performSelector:@selector(setBarButtonItems) withObject:nil afterDelay:0.1f];
}

#pragma mark Selection
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 無動作
    // UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark First Responder for Undo Support
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

#pragma mark View Setup

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // 重新調整儲存格，讓圖像顯示在中間
    [self.tableView reloadData];
}

- (void) loadView
{
    [super loadView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = IMAGE_SIZE + 20.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    items = [NSMutableArray array];
    
    // 提供Undo功能
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self setBarButtonItems];
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
    
    srand(time(0));
    
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