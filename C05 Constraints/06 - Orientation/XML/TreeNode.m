/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "TreeNode.h"

// 字串修整巨集
#define STRIP(X)	[X stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

@implementation TreeNode
#pragma mark Create and Initialize TreeNodes
+ (TreeNode *) treeNode
{
    TreeNode *node = [[self alloc] init];
    node.children = [NSMutableArray array];
	return node;
}

#pragma mark TreeNode type routines
- (BOOL) isLeaf
{
	return (self.children.count == 0);
}

- (BOOL) hasLeafValue
{
	return (self.leafvalue != nil);
}

#pragma mark TreeNode data recovery routines
// 回傳含有子鍵的陣列，不遞迴
- (NSArray *) keys
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children) [results addObject:node.key];
	return results;
}

// 回傳子鍵陣列，使用深度優先的遞迴
- (NSArray *) allKeys
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children) 
	{
		[results addObject:node.key];
		[results addObjectsFromArray:node.allKeys];
	}
	return results;
}

- (NSArray *) uniqArray: (NSArray *) anArray
{
	NSMutableArray *array = [NSMutableArray array];
	for (id object in [anArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)])
		if (![[array lastObject] isEqualToString:object]) [array addObject:object];
	return array;
}

// 回傳排序後的子鍵陣列（不重複），不遞迴
- (NSArray *) uniqKeys
{
	return [self uniqArray:[self keys]];
}

// 回傳排序後的子鍵陣列（不重複），使用深度優先的遞迴
- (NSArray *) uniqAllKeys
{
	return [self uniqArray:[self allKeys]];
}

// 回傳子樹葉陣列，不遞迴
- (NSArray *) leaves
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children)
        if (node.leafvalue)
            [results addObject:node.leafvalue];
	return results;
}

// 回傳子樹葉陣列，使用深度優先的遞迴
- (NSArray *) allLeaves
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in self.children) 
	{
		if (node.leafvalue)
            [results addObject:node.leafvalue];
		[results addObjectsFromArray:node.allLeaves];
	}
	return results;
}

#pragma mark TreeNode search and retrieve routines

// 回傳符合鍵的第一個子節點，寬度優先遞迴式搜尋
- (TreeNode *) nodeForKey: (NSString *) aKey
{
	TreeNode *result = nil;
	for (TreeNode *node in self.children) 
		if ([node.key isEqualToString: aKey])
		{
			result = node;
			break;
		}
	if (result) return result;
	for (TreeNode *node in self.children)
	{
		result = [node nodeForKey:aKey];
		if (result) break;
	}
	return result;
}

// 回傳符合鍵的第一個樹葉節點，寬度優先遞迴式搜尋
- (NSString *) leafForKey: (NSString *) aKey
{
	TreeNode *node = [self nodeForKey:aKey];
	return node.leafvalue;
}

// 回傳符合鍵的所有子節點，深度優先遞迴式搜尋
- (NSMutableArray *) nodesForKey: (NSString *) aKey
{
	NSMutableArray *result = [NSMutableArray array];
	for (TreeNode *node in self.children) 
	{
		if ([node.key isEqualToString: aKey]) [result addObject:node];
		[result addObjectsFromArray:[node nodesForKey:aKey]];
	}
	return result;
}

// 回傳符合鍵的所有樹葉節點，深度優先遞迴式搜尋
- (NSMutableArray *) leavesForKey: (NSString *) aKey
{
	NSMutableArray *result = [NSMutableArray array];
	for (TreeNode *node in [self nodesForKey:aKey]) 
		if (node.leafvalue)
			[result addObject:node.leafvalue];
	return result;
}

// 分支時以第一個符合的為準，順著鍵路徑，回傳物件
- (TreeNode *) nodeForKeys: (NSArray *) keys
{
	if (keys.count == 0) return self;
	
	NSMutableArray *nextArray = [NSMutableArray arrayWithArray:keys];
	[nextArray removeObjectAtIndex:0];
	
	for (TreeNode *node in self.children)
	{
		if ([node.key isEqualToString:[keys objectAtIndex:0]])
			return [node nodeForKeys:nextArray];
	}
	
	return nil;
}

// 分支時以第一個符合的為準，順著鍵路徑，回傳樹葉節點
- (NSString *) leafForKeys: (NSArray *) keys
{
	TreeNode *node = [self nodeForKeys:keys];
	return node.leafvalue;
}

#pragma mark output utilities
// 印出整棵樹
- (void) dumpAtIndent: (int) indent into:(NSMutableString *) outstring
{
	for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
	
	[outstring appendFormat:@"[%2d] Key: %@ ", indent, _key];
	if (self.leafvalue) [outstring appendFormat:@"(%@)", STRIP(self.leafvalue)];
	[outstring appendString:@"\n"];
	
	for (TreeNode *node in self.children) [node dumpAtIndent:indent + 1 into: outstring];
}

- (NSString *) dumpString
{
	NSMutableString *outstring = [[NSMutableString alloc] init];
	[self dumpAtIndent:0 into:outstring];
	return outstring;
}

#pragma mark conversion utilities
// 若你確定你是所有樹葉的父節點，轉換成字典
- (NSMutableDictionary *) dictionaryForChildren
{
	NSMutableDictionary *results = [NSMutableDictionary dictionary];
	
	for (TreeNode *node in self.children)
		if (node.hasLeafValue) [results setObject:node.leafvalue forKey:node.key];
	
	return results;
}

#pragma mark invocation forwarding
// 轉送訊息（Invocation Forwarding），讓節點像是陣列
- (id)forwardingTargetForSelector:(SEL)sel 
{ 
	if ([self.children respondsToSelector:sel]) return self.children; 
	return nil;
}

// 擴充選擇子，符合陣列的要求
- (BOOL)respondsToSelector:(SEL)aSelector
{
	if ( [super respondsToSelector:aSelector] )	return YES;
	if ([self.children respondsToSelector:aSelector]) return YES;
	return NO;
}

// 允許子節點佯裝成NSArray的形式
- (BOOL)isKindOfClass:(Class)aClass
{
	if (aClass == [TreeNode class]) return YES;
	if ([super isKindOfClass:aClass]) return YES;
	if ([self.children isKindOfClass:aClass]) return YES;
	
	return NO;
}
@end