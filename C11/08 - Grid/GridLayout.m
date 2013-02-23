/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "GridLayout.h"

#define INDEXPATH(SECTION, ITEM) [NSIndexPath indexPathForItem:ITEM inSection:SECTION]

/*

 Note: 此網格狀流動佈局，不會繞捲，所以不會使用行距的設定
 
 */

@implementation GridLayout

#pragma mark -
#pragma mark Items

// 委派有提供個別項目的大小嗎？
- (BOOL) usesIndividualSizing
{
    return [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)];
}

// 根據索引路徑，回傳項目的儲存格大小
- (CGSize) sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    BOOL individuallySized = [self usesIndividualSizing];
    CGSize itemSize = self.itemSize;
    if (individuallySized)
        itemSize = [(id <UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    return itemSize;
}

#pragma mark -
#pragma mark Insets

// 使用個別邊緣間距嗎？
- (BOOL) usesIndividualInsets
{
    return [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)];
}

// 回傳段的邊緣間距
- (UIEdgeInsets) insetsForSection: (NSInteger) section
{
    UIEdgeInsets insets = self.sectionInset;
    if ([self usesIndividualInsets])
        insets = [(id <UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    return insets;
}

#pragma mark -
#pragma mark Item Spacing

// 使用個別項目的間距嗎？
- (BOOL) usesIndividualItemSpacing
{
    return [self.collectionView.delegate respondsToSelector:@selector(layout:minimumInteritemSpacingForSectionAtIndex:)];
}

// 回傳某段裡的間距
- (CGFloat) itemSpacingForSection: (NSInteger) section
{
    CGFloat spacing = self.minimumInteritemSpacing;
    if ([self usesIndividualItemSpacing])
        spacing = [(id <UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    return spacing;
}

#pragma mark -
#pragma mark Layout Geometry

// 找出最高的子視圖
- (CGFloat) maxItemHeightForSection: (NSInteger) section
{
    CGFloat maxHeight = 0.0f;
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    for (int i = 0; i < numberOfItems; i++)
    {
        NSIndexPath *indexPath = INDEXPATH(section, i);
        CGSize itemSize = [self sizeForItemAtIndexPath:indexPath];
        maxHeight = MAX(maxHeight, itemSize.height);
    }
    
    return maxHeight;
}

// 水平寬度，從段的開頭到結尾
- (CGFloat) fullWidthForSection: (NSInteger) section
{
    UIEdgeInsets insets = [self insetsForSection:section];
    CGFloat horizontalInsetExtent = insets.left + insets.right;
    CGFloat collectiveWidth = horizontalInsetExtent;   

    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    for (int i = 0; i < numberOfItems; i++)
    {
        NSIndexPath *indexPath = INDEXPATH(section, i);
        CGSize itemSize = [self sizeForItemAtIndexPath:indexPath];

        collectiveWidth += itemSize.width;
        collectiveWidth += [self itemSpacingForSection:section];
    }
    
    collectiveWidth -= [self itemSpacingForSection:section]; // 減去一個間隔，n-1
    
    return collectiveWidth;
}

// 每一段的範圍
- (CGSize) fullSizeForSection: (NSInteger) section
{
    CGFloat headerExtent = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? self.headerReferenceSize.width : self.headerReferenceSize.height;
    CGFloat footerExtent =(self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? self.footerReferenceSize.width : self.footerReferenceSize.height;
    
    UIEdgeInsets insets = [self insetsForSection:section];
    CGFloat verticalInsetExtent = insets.top + insets.bottom;
    CGFloat maxHeight = [self maxItemHeightForSection:section];
    
    CGFloat fullHeight = headerExtent + footerExtent + verticalInsetExtent + maxHeight;
    CGFloat fullWidth = [self fullWidthForSection:section];

    return CGSizeMake(fullWidth, fullHeight);
}

// 在每一段裡，每個項目的位移量
- (CGFloat) horizontalInsetForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UIEdgeInsets insets = [self insetsForSection:indexPath.section];
    float horizontalOffset = insets.left;
    if (indexPath.item > 0)
    {
        for (int i = 0; i < indexPath.item; i++)
        {
            CGSize itemSize = [self sizeForItemAtIndexPath:INDEXPATH(indexPath.section, i)];
            horizontalOffset += (itemSize.width + [self itemSpacingForSection:indexPath.section]);
        }
    }
    
    return horizontalOffset;
}

// 每個項目往下的位移量
- (CGFloat) verticalInsetForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CGSize thisItemSize = [self sizeForItemAtIndexPath:indexPath];
    CGFloat verticalOffset = 0.0f;

    // 前面的段
    if (indexPath.section > 0)
    {
        for (int i = 0; i < indexPath.section; i++)
            verticalOffset += [self fullSizeForSection:i].height;
    }
    
    // 標頭
    CGFloat headerExtent = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? self.headerReferenceSize.width : self.headerReferenceSize.height;
    verticalOffset += headerExtent;
    
    // 邊緣間距，上
    UIEdgeInsets insets = [self insetsForSection:indexPath.section];
    verticalOffset += insets.top;
    
    // 垂直置中
    CGFloat maxHeight = [self maxItemHeightForSection:indexPath.section];
    CGFloat fullHeight = (maxHeight - thisItemSize.height);
    CGFloat midHeight = fullHeight / 2.0f;

    switch (self.alignment)
    {
        case GridRowAlignmentNone:
        case GridRowAlignmentTop:
            break;
        case GridRowAlignmentCenter:
            verticalOffset += midHeight;
            break;
        case GridRowAlignmentBottom:
            verticalOffset += fullHeight;
            break;
        default:
            break;
    }
    
    return verticalOffset;
}

#pragma mark -
#pragma mark Layout Attributes

// 放置每一項目
- (UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath
{
	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGSize thisItemSize = [self sizeForItemAtIndexPath:indexPath];

    float verticalOffset = [self verticalInsetForItemAtIndexPath:indexPath];
    float horizontalOffset = [self horizontalInsetForItemAtIndexPath:indexPath];

    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
        attributes.frame = CGRectMake(horizontalOffset, verticalOffset, thisItemSize.width, thisItemSize.height);
    else
        attributes.frame = CGRectMake(verticalOffset, horizontalOffset, thisItemSize.width, thisItemSize.height);

	return attributes;
}

// 回傳完整的範圍
- (CGSize) collectionViewContentSize
{
    NSInteger sections = self.collectionView.numberOfSections;
    
    CGFloat maxWidth = 0.0f;
    CGFloat collectiveHeight = 0.0f;
    
    for (int i = 0; i < sections; i++)
    {
        CGSize sectionSize = [self fullSizeForSection:i];
        collectiveHeight += sectionSize.height;
        maxWidth = MAX(maxWidth, sectionSize.width);
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
        return CGSizeMake(maxWidth, collectiveHeight);
    else
        return CGSizeMake(collectiveHeight, maxWidth);
}

// 提供網格狀的佈局屬性
- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++)
        for (NSInteger item = 0 ; item < [self.collectionView numberOfItemsInSection: section]; item++)
        {
            UICollectionViewLayoutAttributes *layout = [self layoutAttributesForItemAtIndexPath:INDEXPATH(section, item)];
            [attributes addObject:layout];
        }
    return attributes;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}
@end
