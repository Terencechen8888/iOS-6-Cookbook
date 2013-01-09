/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "CustomSlider.h"
#import "Thumb.h"

@implementation CustomSlider
// 視情況更新大姆哥圖像
- (void) updateThumb
{
	// 數值超過一定變動程度以上，便更新大姆哥，譬如10%
	if ((self.value < 0.98) && (ABS(self.value - previousValue) < 0.1f)) return;
	
	// 高亮度狀態下，建立自訂後的大姆哥圖像
    UIImage *customimg = thumbWithLevel(self.value);
	[self setThumbImage: customimg forState: UIControlStateHighlighted];
	previousValue = self.value;
}

// 增大滑桿的尺寸，容納尺寸較大的大姆哥
- (void) startDrag: (UISlider *) aSlider
{
	self.frame = CGRectInset(self.frame, 0.0f, -30.0f);
}

// 手指離開螢幕，將滑桿尺寸調回原本大小
- (void) endDrag: (UISlider *) aSlider
{
    self.frame = CGRectInset(self.frame, 0.0f, 30.0f);
}

- (id) initWithFrame:(CGRect) aFrame
{
    if (!(self = [super initWithFrame:aFrame]))
        return self;
    
    // 滑桿數值的初始值
	previousValue = -99.0f;
    self.value = 0.0f;

    [self setThumbImage:simpleThumb() forState:UIControlStateNormal];
    
    // 設定觸控事件（開始、移動、結束）的回呼方法
	[self addTarget:self action:@selector(startDrag:) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(updateThumb) forControlEvents:UIControlEventValueChanged];
	[self addTarget:self action:@selector(endDrag:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    
    return self;
}

+ (id) slider
{
    CustomSlider *slider = [[CustomSlider alloc] initWithFrame:(CGRect){.size=CGSizeMake(200.0f, 40.0f)}];
    
    return slider;
}
@end
