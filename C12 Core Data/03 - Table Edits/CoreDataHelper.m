/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "CoreDataHelper.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation CoreDataHelper

#pragma mark Fetch
- (void) fetchItemsMatching: (NSString *) searchString forAttribute: (NSString *) attribute sortingBy: (NSString *) sortAttribute
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:_context];
    
    // 初始化擷取請求
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    [fetchRequest setFetchBatchSize:0];
    
    // 套用漸升型排序
    NSString *sortKey = sortAttribute ? : _defaultSortAttribute;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES selector:nil];
    NSArray *descriptors = @[sortDescriptor];
    fetchRequest.sortDescriptors = descriptors;
    
    // 設定過濾條件
    if (searchString && searchString.length && attribute && attribute.length)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", attribute, searchString];

    // 初始化擷取請求控制器
    NSError __autoreleasing *error;
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_context sectionNameKeyPath:@"section" cacheName:nil];
    
    // 執行
    if (![_fetchedResultsController performFetch:&error])
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
}

- (void) fetchData
{
    [self fetchItemsMatching:nil forAttribute:nil sortingBy:nil];
}

#pragma mark Info
- (NSInteger) numberOfSections
{
    return _fetchedResultsController.sections.count;
}

- (NSInteger) numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = _fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (NSInteger) numberOfEntities
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:_context]];
    [request setIncludesSubentities:YES];
    
    NSError __autoreleasing *error;
    NSUInteger count = [_context countForFetchRequest:request error:&error];
    if(count == NSNotFound)
    {
        NSLog(@"Error: Could not count entities %@", error.localizedFailureReason);
        return 0;
    }
    
    return count;
}

# pragma mark Management
// 儲存
- (BOOL) save
{
    NSError __autoreleasing *error;
    BOOL success;
    if (!(success = [_context save:&error]))
        NSLog(@"Error saving context: %@", error.localizedFailureReason);
    return success;
}

// 刪除全部物件
- (BOOL) clearData
{
    [self fetchData];
    if (!_fetchedResultsController.fetchedObjects.count) return YES;
    for (NSManagedObject *entry in _fetchedResultsController.fetchedObjects)
        [_context deleteObject:entry];
    return [self save];
}

// 刪除一個物件
- (BOOL) deleteObject: (NSManagedObject *) object
{
    [self fetchData];
    if (!_fetchedResultsController.fetchedObjects.count) return NO;
    [_context.undoManager beginUndoGrouping];
    [_context deleteObject:object];
    [_context.undoManager endUndoGrouping];
    [_context.undoManager setActionName:@"Delete"];
    return [self save];
}

// 建立新物件
- (NSManagedObject *) newObject
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:_context];
    return object;
}
#pragma mark Init
- (BOOL) hasStore
{
    if (!_entityName)
    {
        NSLog(@"Error: entity name not set");
        return NO;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@.sqlite", DOCUMENTS_FOLDER, _entityName];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void) setupCoreData
{
    NSError __autoreleasing *error;
    
    if (!_entityName || !_defaultSortAttribute)
    {
        NSLog(@"Error: set entity name, sort, and section names before init");
        return;
    }

    // 初始化模型
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // 建立儲存庫協調者
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    // 連接儲存庫與檔案
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.sqlite", DOCUMENTS_FOLDER, _entityName]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error])
    {
        NSLog(@"Error creating persistent store coordinator: %@", error.localizedFailureReason);
        return;
    }

    // 建立內文
    _context = [[NSManagedObjectContext alloc] init];
    _context.persistentStoreCoordinator = persistentStoreCoordinator;
    _context.undoManager = [[NSUndoManager alloc] init];
    _context.undoManager.levelsOfUndo = 999;

    [self fetchData];
}
@end
