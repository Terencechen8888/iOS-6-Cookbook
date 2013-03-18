/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*
 
 段的名稱一定是"section"，保持一致讓開發工作更簡便
 
 */

@interface CoreDataHelper : NSObject
@property (nonatomic) NSString *entityName;
@property (nonatomic) NSString *defaultSortAttribute;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) BOOL hasStore;
@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, readonly) NSInteger numberOfEntities;

- (void) setupCoreData;

- (void) fetchData;
- (void) fetchItemsMatching: (NSString *) searchString forAttribute: (NSString *) attribute sortingBy: (NSString *) sortAttribute;

- (BOOL) save;
- (NSManagedObject *) newObject;
- (BOOL) clearData;
- (BOOL) deleteObject: (NSManagedObject *) object;

- (NSInteger) numberOfItemsInSection: (NSInteger) section;
@end
