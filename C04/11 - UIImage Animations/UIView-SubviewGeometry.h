/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface UIView (SubviewGeometry)
// 根據指定的中心點座標，檢查某視圖是否能被容納於父視圖裡
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInsets: (UIEdgeInsets) insets;
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInset: (float) inset;
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView;

// 在父視圖裡滑動視圖，指定水平與垂直方向的滑動百分比例
// 保證視圖會被完全容納於父視圖範圍內
- (CGPoint) centerInView: (UIView *) aView withHorizontalPercent: (float) h withVerticalPercent: (float) v;
- (CGPoint) centerInSuperviewWithHorizontalPercent: (float) h withVerticalPercent: (float) v;

// 移動到父視圖內的亂數位置，子視圖保證會
// 完全容納在父視圖範圍內，若有指定UIEdgeInsets，也會被侷限在這裡頭
- (CGPoint) randomCenterInView: (UIView *) aView withInsets: (UIEdgeInsets) insets;
- (CGPoint) randomCenterInView: (UIView *) aView withInset: (float) inset;

// 在某視圖或父視圖內，以動畫效果進行移動，移動到亂數位置，
// 子視圖保證會完全容納在父視圖範圍內
- (void) moveToRandomLocationInView: (UIView *) aView animated: (BOOL) animated;
- (void) moveToRandomLocationInSuperviewAnimated: (BOOL) animated;
@end
