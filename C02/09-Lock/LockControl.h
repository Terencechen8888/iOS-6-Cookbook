/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>

@interface LockControl : UIControl
{
    BOOL value;
    UIImageView *lockView;
    UIImageView *trackView;
    UIImageView *thumbView;
}
@property (nonatomic, assign) BOOL value;

// 目標必須實作handleUnlock:
+ (id) controlWithTarget: (id) target;
@end
