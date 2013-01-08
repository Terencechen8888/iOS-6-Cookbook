//
//  CircleRecognizer.m
//  HelloWorld
//
//  Created by Erica Sadun on 6/18/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import "CircleRecognizer.h"
#import "Geometry.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

// 計算並回傳最小的包圍矩形
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]
CGRect boundingRect(NSArray *points)
{
    CGRect rect = CGRectZero;
    CGRect ptRect;
    
    for (int i = 0; i < points.count; i++)
    {
        CGPoint pt = POINT(i);
        ptRect = CGRectMake(pt.x, pt.y, 0.0f, 0.0f);
        rect = (CGRectEqualToRect(rect, CGRectZero)) ? ptRect : CGRectUnion(rect, ptRect);
    }
    
    return rect;
}

#define SHOWDEBUG NO

CGRect testForCircle(NSArray *points, NSDate *firstTouchDate)
{
    if (points.count < 2) 
    {
        if (SHOWDEBUG) NSLog(@"Too few points (2) for circle");
        return CGRectZero;
    }
    
    // 檢測1：在多短時間內必須完成手勢
    float duration = [[NSDate date] timeIntervalSinceDate:firstTouchDate];
    if (SHOWDEBUG) NSLog(@"Transit duration: %0.2f", duration);
    
    float maxDuration = 2.0f;
    if (duration > maxDuration) // 在模擬器執行時，允許較大的延遲
    {
        if (SHOWDEBUG) NSLog(@"Excessive touch duration: %0.2f seconds vs %0.1f seconds", duration, maxDuration);
        return CGRectZero;
    }
    
    // 檢測2：方向變化的次數，應限制在4次左右
    int inflections = 0;
    for (int i = 2; i < (points.count - 1); i++)
    {
        float deltx = dx(POINT(i), POINT(i-1));
        float delty = dy(POINT(i), POINT(i-1));
        float px = dx(POINT(i-1), POINT(i-2));
        float py = dy(POINT(i-1), POINT(i-2));
        
        if ((sign(deltx) != sign(px)) || (sign(delty) != sign(py)))
            inflections++;
    }
    
    if (inflections > 5)
    {
        if (SHOWDEBUG) NSLog(@"Excessive number of inflections (%d vs 4). Fail.", inflections);
        return CGRectZero;
    }
    
    // 檢測3：起點與終點必須在一定程度內靠在一起
    float tolerance = [[[UIApplication sharedApplication] keyWindow] bounds].size.width / 3.0f;    
    if (distance(POINT(0), POINT(points.count - 1)) > tolerance)
    {
        if (SHOWDEBUG) NSLog(@"Start and end points too far apart. Fail.");
        return CGRectZero;
    }
    
    // 檢測4：計算手勢劃過的角度  
    CGRect circle = boundingRect(points);
    CGPoint center = GEORectGetCenter(circle);
    float distance = ABS(acos(dotproduct(pointWithOrigin(POINT(0), center), pointWithOrigin(POINT(1), center))));
    for (int i = 1; i < (points.count - 1); i++)
        distance += ABS(acos(dotproduct(pointWithOrigin(POINT(i), center), pointWithOrigin(POINT(i+1), center))));
    
    float transitTolerance = distance - 2 * M_PI;
    
    if (transitTolerance < 0.0f) // 小於2*PI
    {
        if (transitTolerance < - (M_PI / 4.0f)) // 小於45度
        {
            if (SHOWDEBUG) NSLog(@"Transit was too short, under 315 degrees");
            return CGRectZero;
        }
    }
    
    if (transitTolerance > M_PI) // 多了180度以上
    {
        if (SHOWDEBUG) NSLog(@"Transit was too long, over 540 degrees");
        return CGRectZero;
    }
    
    return circle;
}

@implementation CircleRecognizer

// called automatically by the runtime after the gesture state has been set to UIGestureRecognizerStateEnded
// any internal state should be reset to prepare for a new attempt to recognize the gesture
// after this is received all remaining active touches will be ignored (no further updates will be received for touches that had already begun but haven't ended)
// 當手勢狀態設定為UIGestureRecognizerStateEnded時，此方法
// 會自動被執行階段程式庫呼叫，任何內部狀態都應該重置，
// 準備辨識下一次新的手勢，所有剩餘的觸控會被忽略。
// （不會收到任何已經開始但還沒結束的觸控事件。）
- (void)reset
{
	[super reset];
	
	points = nil;
	firstTouchDate = nil;
	self.state = UIGestureRecognizerStatePossible;
}

// mirror of the touch-delivery methods on UIResponder
// UIGestureRecognizers aren't in the responder chain, but observe touches hit-tested to their view and their view's subviews
// UIGestureRecognizers receive touches before the view to which the touch was hit-tested
// 模仿UIResponder裡處理的觸控方法
// UIGestureRecognizers並不在回應者鏈裡，但會觀察擊中視圖與
// 子視圖的觸控事件。
// 被擊中的視圖收到觸控事件前，UIGestureRecognizers就會收到
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (touches.count > 1) 
	{
		self.state = UIGestureRecognizerStateFailed;
		return;
	}
	
	points = [NSMutableArray array];
	firstTouchDate = [NSDate date];
	UITouch *touch = [touches anyObject];
	[points addObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	[points addObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]];	
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent: event];
	BOOL detectionSuccess = !CGRectEqualToRect(CGRectZero, testForCircle(points, firstTouchDate));
	if (detectionSuccess)
		self.state = UIGestureRecognizerStateRecognized;
	else
		self.state = UIGestureRecognizerStateFailed;
}
@end