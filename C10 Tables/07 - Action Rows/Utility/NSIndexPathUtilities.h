/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

#define INDEXPATH(SECTION, ROW) [NSIndexPath indexPathForRow:ROW inSection:SECTION]

@interface NSIndexPath (adjustments)

// 此索引路徑是否位於其他的之前
- (BOOL) before: (NSIndexPath *) path;

@property (nonatomic, readonly) NSIndexPath *next;
@property (nonatomic, readonly) NSIndexPath *previous;
@end
