/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIView-NameExtensions.h"
#import <objc/runtime.h>

static const char nametag_key; // Thanks Oliver Drobnik

@implementation UIView (NameExtensions)
#pragma mark Associations
- (id) nametag 
{
    return objc_getAssociatedObject(self, (void *) &nametag_key);
}

- (void)setNametag:(NSString *) theNametag 
{
    objc_setAssociatedObject(self, (void *) &nametag_key, theNametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *) viewWithNametag: (NSString *) aName
{
    if (!aName) return nil;
    
    // 這是正確的視圖嗎？
    if ([self.nametag isEqualToString:aName])
        return self;
    
    // 搜度優先遞迴搜尋第一個子視圖
    for (UIView *subview in self.subviews) 
    {
        UIView *resultView = [subview viewNamed:aName];
        if (resultView) return resultView;
    }
    
    // 沒找到
    return nil;
}

- (UIView *) viewNamed: (NSString *) aName
{
    if (!aName) return nil;
    return [self viewWithNametag:aName];
}
@end