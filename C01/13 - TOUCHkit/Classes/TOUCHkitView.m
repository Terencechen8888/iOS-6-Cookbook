/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "TOUCHkitView.h"

UIImage *fingers;

@implementation TOUCHkitView

static TOUCHkitView *sharedInstance = nil;

+ (id) sharedInstance 
{
    // 若尚未存在便建立共享實體
    if(!sharedInstance)
    {
		sharedInstance = [[self alloc] initWithFrame:CGRectZero];
    }
    
    // 成為主視窗的子視圖
    if (!sharedInstance.superview)
    {
        UIWindow *keyWindow= [UIApplication sharedApplication].keyWindow;
        sharedInstance.frame = keyWindow.bounds;
        [keyWindow addSubview:sharedInstance];
    }
    
    return sharedInstance;
}


// 想要使用touchColor屬性的話可以改寫預設的顏色
- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = YES;
        _touchColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
		touches = nil;
	}
	
	return self;
}

// 基本的觸控處理

- (void) touchesBegan:(NSSet *)theTouches withEvent:(UIEvent *)event
{
	touches = theTouches;
	[self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet *)theTouches withEvent:(UIEvent *)event
{
	touches = theTouches;
	[self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)theTouches withEvent:(UIEvent *)event
{
	touches = nil;
	[self setNeedsDisplay];
}

// 隨著觸控事件繪製回饋圓圈
- (void) drawRect: (CGRect) rect
{
    // 清除
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, self.bounds);
	
    // 填滿透明色
	[[UIColor clearColor] set];
	CGContextFillRect(context, self.bounds);
	
	float size = 25.0f; // 根據標準的44.0f觸控點而來
	
    for (UITouch *touch in touches)
    {
        [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5f] set];
        CGPoint aPoint = [touch locationInView:self];
        CGContextAddEllipseInRect(context, CGRectMake(aPoint.x - size, aPoint.y - size, 2 * size, 2 * size));
        CGContextFillPath(context);
        
        float dsize = 1.0f;
        [_touchColor set];
        aPoint = [touch locationInView:self];
        CGContextAddEllipseInRect(context, CGRectMake(aPoint.x - size - dsize, aPoint.y - size - dsize, 2 * (size - dsize), 2 * (size - dsize)));
        CGContextFillPath(context);
    }

    // 使用後重置觸控
    touches = nil;
}
@end