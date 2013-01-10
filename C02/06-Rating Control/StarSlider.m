/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "StarSlider.h"

#define WIDTH 24.0f
#define OFF_ART	[UIImage imageNamed:@"Star-White-Half.png"]
#define ON_ART	[UIImage imageNamed:@"Star-White.png"]

@implementation StarSlider
- (id) initWithFrame: (CGRect) aFrame
{
	if (self = [super initWithFrame:aFrame])
	{
		float minimumWidth = WIDTH * 8.0f; // 五個星號，在兩兩中間與兩端留一些空間
		float minimumHeight = 34.0f;
		
		// 這個控制項的frame最小是260×34
		self.frame = CGRectMake(0.0f, 0.0f, MAX(minimumWidth, aFrame.size.width), MAX(minimumHeight, aFrame.size.height));
		
		// 加入星號，一開始先假設寬度是固定的
		float offsetCenter = WIDTH;
		for (int i = 1; i <= 5; i++)
		{
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, WIDTH, WIDTH)];
			imageView.image = OFF_ART;
			imageView.center = CGPointMake(offsetCenter, self.frame.size.height / 2.0f);
			offsetCenter += WIDTH * 1.5f;
			[self addSubview:imageView];
		}
	}
	
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25f];

	return self;
}

- (id) init
{
	return [self initWithFrame:CGRectZero];
}

+ (id) control
{
	return [[self alloc] init];
}

- (void) updateValueAtPoint: (CGPoint) p
{
	int newValue = 0;
	UIImageView *changedView = nil;
	
	for (UIImageView *eachItem in [self subviews])
		if (p.x < eachItem.frame.origin.x)
		{
			eachItem.image = OFF_ART;
		}
		else 
		{
			changedView = eachItem;
			eachItem.image = ON_ART;
			newValue++;
		}
	
	if (self.value != newValue)
	{
		self.value = newValue;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
		
		// 以縮放動畫效果呈現新數值
		[UIView animateWithDuration:0.15f 
						 animations:^{changedView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);}
						 completion:^(BOOL done){[UIView animateWithDuration:0.1f animations:^{changedView.transform = CGAffineTransformIdentity;}];}];
	}	
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	// 建立UIControlEventTouchDown事件
	CGPoint touchPoint = [touch locationInView:self];
	[self sendActionsForControlEvents:UIControlEventTouchDown];
	
	// 計算數值
	[self updateValueAtPoint:touchPoint];
	return YES;
}
	 
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	// 檢查拖拉是在範圍內還是外
	CGPoint touchPoint = [touch locationInView:self];
	if (CGRectContainsPoint(self.frame, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchDragOutside];

	// 計算數值
	[self updateValueAtPoint:[touch locationInView:self]];
	return YES;
}

- (void) endTrackingWithTouch: (UITouch *)touch withEvent: (UIEvent *)event
{
    // 檢查觸控結束時，在範圍內還是外
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

	 
- (void)cancelTrackingWithEvent: (UIEvent *) event
{
	[self sendActionsForControlEvents:UIControlEventTouchCancel];
}
@end
