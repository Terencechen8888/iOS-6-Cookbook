/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "CrayonHandler.h"
#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]
#define CRAYON_COLOR(CRAYON) getColor([[CRAYON componentsSeparatedByString:@"#"] lastObject])
#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// 將十六進位的顏色值（6個字母）轉成UIColor物件
UIColor *getColor(NSString *hexColor)
{
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

@implementation CrayonHandler
// 回傳陣列，含有某段裡的項目
- (NSArray *) itemsInSection: (NSInteger) section
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", [self firstLetter:section]];
    return [[crayonColors allKeys] filteredArrayUsingPredicate:predicate];
}

// 計算運作中的段的數目
- (NSInteger) numberOfSections
{
    return sectionArray.count;
}

// 段裡有幾個項目
- (NSInteger) countInSection: (NSInteger) section
{
    return [sectionArray[section] count];
}

// 回傳段名的第一個字母
- (NSString *) firstLetter: (NSInteger) section
{
    return [[ALPHA substringFromIndex:section] substringToIndex:1];
}

// 段的名字，只有一個字母
- (NSString *) nameForSection: (NSInteger) section
{
    if (![self countInSection:section])
        return nil;
    return [self firstLetter:section];
}

// 根據索引路徑，回傳顏色名
- (NSString *) colorNameAtIndexPath: (NSIndexPath *) path
{
    if (path.section >= sectionArray.count)
        return nil;
    NSArray *currentItems = sectionArray[path.section];
    
    if (path.row >= currentItems.count)
        return nil;    
	NSString *crayon = currentItems[path.row];
    
    return crayon;
}

// 根據索引路徑，回傳顏色UIColor物件
- (UIColor *) colorAtIndexPath: (NSIndexPath *) path
{
    NSString *crayon = [self colorNameAtIndexPath:path];
    if (crayon)
        return crayonColors[crayon];
    return nil;
}

// 以顏色名回傳UIColor物件
- (UIColor *) colorNamed: (NSString *) aColor
{
    return crayonColors[aColor];
}

// 搜尋過濾
- (NSInteger) filterWithString: (NSString *) filter
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", filter];
	_filteredArray = [[crayonColors allKeys] filteredArrayUsingPredicate:predicate];
    return _filteredArray.count;
}

- (id) init
{
    if (!(self = [super init]))
        return nil;
    
    // 準備儲存蠟筆顏色的字典
	NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt"];
	NSArray *rawCrayons = [[NSString stringWithContentsOfFile:pathname encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	crayonColors = [NSMutableDictionary dictionary];
	for (NSString *string in rawCrayons)
		[crayonColors setObject:CRAYON_COLOR(string) forKey:CRAYON_NAME(string)];
    
    sectionArray = [NSMutableArray array];
    for (int i = 0; i < 26; i++)
        [sectionArray addObject:[self itemsInSection:i]];
    
    return self;
}
@end
