/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "PunchedLayout.h"

@implementation PunchedLayout
- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}

-(void) prepareLayout
{
    [super prepareLayout];
    
    boundsSize = self.collectionView.bounds.size;
    midX = boundsSize.width / 2.0f;
}

- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes* attributes in array)
    {
        attributes.transform3D = CATransform3DIdentity;
        if (!CGRectIntersectsRect(attributes.frame, rect)) continue;
        
        CGPoint contentOffset = self.collectionView.contentOffset;
        CGPoint itemCenter = CGPointMake(attributes.center.x - contentOffset.x, attributes.center.y - contentOffset.y);
                
        CGFloat distance = ABS(midX - itemCenter.x);
        CGFloat normalized = distance / midX;
        normalized = MIN(1.0f, normalized);
        CGFloat zoom = cos(normalized * M_PI_4);
        
        // attributes.zIndex = 1;
        attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0f);
    }
    
    return array;
}

- (CGPoint) targetContentOffsetForProposedContentOffset: (CGPoint) proposedContentOffset withScrollingVelocity: (CGPoint) velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    
    // 根據某啟始點，取得所有出現在畫面上的項目
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, boundsSize.width, boundsSize.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];

    // 決定x軸座標
    CGFloat proposedCenterX = proposedContentOffset.x + midX;
    
    // 尋找調整幅度最小的那個項目
    for (UICollectionViewLayoutAttributes* layoutAttributes in array)
    {
        CGFloat distance = layoutAttributes.center.x - proposedCenterX;
        if (ABS(distance) < ABS(offsetAdjustment))
            offsetAdjustment = distance;
    }
    
    // 調整位移量
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}
@end