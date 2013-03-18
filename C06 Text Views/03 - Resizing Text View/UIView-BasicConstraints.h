/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (BasicConstraints)
// 視覺格式，這些方法只能參考 [self] 與 superview
- (NSArray *) constraintsForVisualFormat: (NSString *) aVisualFormat withMetrics: (NSDictionary *) metrics;
- (NSArray *) constraintsForVisualFormat: (NSString *) aVisualFormat;
- (void) addVisualFormat: (NSString *) aVisualFormat;
- (void) removeVisualFormat: (NSString *) aVisualFormat;

// 除錯
- (NSString *) constraintRepresentation: (NSLayoutConstraint *) aConstraint;
- (void) showConstraints;
@property (nonatomic, readonly, strong) NSString *debugName;

// 測試約束規則
- (BOOL) constraint: (NSLayoutConstraint *) constraint1 matches: (NSLayoutConstraint *) constraint2;
- (NSLayoutConstraint *) constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (void) removeMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (void) removeMatchingConstraints: (NSArray *) anArray;

// 彈性調整大小
- (NSArray *) stretchConstraints: (NSLayoutFormatOptions) anAlignment;
- (NSArray *) stretchConstraints: (NSLayoutFormatOptions) anAlignment withEdgeInset: (CGFloat) anInset;
- (void) stretchAlongAxes: (NSLayoutFormatOptions) anAlignment;
- (void) stretchAlongAxes: (NSLayoutFormatOptions) anAlignment withEdgeInset: (CGFloat) anInset;
- (void) fitToHeightWithInset: (CGFloat) anInset;
- (void) fitToWidthWithInset: (CGFloat) anInset;

// 對齊與置中
- (NSArray *) alignmentConstraints: (NSLayoutFormatOptions) anAlignment;
- (void) setAlignmentInSuperview: (NSLayoutFormatOptions) anAlignment;
- (NSLayoutConstraint *) horizontalCenteringConstraint;
- (NSLayoutConstraint *) verticalCenteringConstraint;
- (void) centerHorizontallyInSuperview;
- (void) centerVerticallyInSuperview;

// 父視圖bounds的限制
- (NSArray *) constraintsLimitingViewToSuperviewBounds;
- (void) constrainWithinSuperviewBounds;
- (void) addSubviewAndConstrainToBounds:(UIView *)view;

// 大小、位置、長寬比例形式
- (NSArray *) sizeConstraints: (CGSize) aSize;
- (NSArray *) positionConstraints: (CGPoint) aPoint;
- (NSLayoutConstraint *) aspectConstraint: (CGFloat) aspectRatio;
- (void) constrainSize:(CGSize)aSize;
- (void) constrainPosition: (CGPoint)aPoint; // 在 superview bounds 之內
- (void) constrainAspectRatio: (CGFloat) aspectRatio;

// 僅供測試用
- (void) layoutItems: (NSArray *) viewArray usingInsets: (BOOL) useInsets horizontally: (BOOL) horizontally;
@end

