/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "CircleLayout.h"

@implementation CircleLayout
- (void) prepareLayout
{
    [super prepareLayout];
    
    CGSize size = self.collectionView.frame.size;
    numberOfItems = [self.collectionView numberOfItemsInSection:0];
    centerPoint = CGPointMake(size.width / 2.0f, size.height / 2.0f);
    radius = MIN(size.width, size.height) / 3.0f;
    
    insertedIndexPaths = [NSMutableArray array];
    deletedIndexPaths = [NSMutableArray array];
}

// 將內容大小固定為frame的大小
- (CGSize) collectionViewContentSize
{
    return self.collectionView.frame.size;
}

// 計算每個項目的位置
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    CGFloat progress = (float) path.item / (float) numberOfItems;
    CGFloat theta = 2.0f * M_PI * progress;
    CGFloat xPosition = centerPoint.x + radius * cos(theta);
    CGFloat yPosition = centerPoint.y + radius * sin(theta);
    attributes.size = [self itemSize];
    attributes.center = CGPointMake(xPosition, yPosition);
    return attributes;
}

// 計算每個項目的佈局屬性
- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger index = 0 ; index < numberOfItems; index++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

#pragma mark - Animated updates

// 根據updates，建立insertedIndexPaths與deletedIndexPathsupdates，分別存放
- (void)prepareForCollectionViewUpdates: (NSArray *)updates
{
    [super prepareForCollectionViewUpdates:updates];
    
    for (UICollectionViewUpdateItem* updateItem in updates)
    {
        if (updateItem.updateAction == UICollectionUpdateActionInsert)
            [insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        else if (updateItem.updateAction == UICollectionUpdateActionDelete)
            [deletedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
    }
}

// 建立新加入的項目的起始屬性
- (UICollectionViewLayoutAttributes *)insertionAttributesForItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    attributes.center = centerPoint;
    return attributes;
}

// 建立刪除項目的結束屬性
- (UICollectionViewLayoutAttributes *)deletionAttributesForItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    attributes.center = centerPoint;
    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    return attributes;
}

// 處理插入時的動畫效果
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [insertedIndexPaths containsObject:indexPath] ? [self insertionAttributesForItemAtIndexPath:indexPath] : [super initialLayoutAttributesForAppearingItemAtIndexPath:indexPath];
}

// 處理刪除時的動畫效果
- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [deletedIndexPaths containsObject:indexPath] ? [self deletionAttributesForItemAtIndexPath:indexPath] : [super finalLayoutAttributesForDisappearingItemAtIndexPath:indexPath];
}
@end
