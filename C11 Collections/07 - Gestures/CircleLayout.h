/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface CircleLayout : UICollectionViewFlowLayout
{
    NSInteger numberOfItems;
    CGPoint centerPoint;
    CGFloat radius;
    CGFloat scale;
    CGFloat rotation;
    CGFloat currentRotation;
}
- (void) rotateBy: (CGFloat) theta; // 中間
- (void) rotateTo: (CGFloat) theta; // 結束
- (void) scaleTo: (CGFloat) factor;
@end
