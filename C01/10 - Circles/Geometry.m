/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "Geometry.h"

CGPoint GEORectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGRect GEORectAroundCenter(CGPoint center, float dx, float dy)
{
    return CGRectMake(center.x - dx, center.y - dy, dx * 2, dy * 2);
}

CGRect GEORectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
    return CGRectOffset(rect, dx, dy);
}

CGPoint GEOPointOffset(CGPoint aPoint, CGFloat dx, CGFloat dy)
{
    return CGPointMake(aPoint.x + dx, aPoint.y + dy);
}

// 測試是否相等。厚顏無恥地從Sam "Svlad" Marshall偷來的
BOOL floatEqual(CGFloat a, CGFloat b)
{
    return (fabs(a-b) < FLT_EPSILON);
}

// 弧度轉角度
CGFloat degrees(CGFloat radians)
{
    return radians * 180.0f / M_PI;
}

// 角度轉弧度
CGFloat radians(CGFloat degrees)
{
    return degrees * M_PI / 180.0f;
}

// 兩個向量，正規化後，求出點積
CGFloat dotproduct (CGPoint v1, CGPoint v2)
{
    CGFloat dot = (v1.x * v2.x) + (v1.y * v2.y);
    CGFloat a = ABS(sqrt(v1.x * v1.x + v1.y * v1.y));
    CGFloat b = ABS(sqrt(v2.x * v2.x + v2.y * v2.y));
    dot /= (a * b);
    
    return dot;
}

// 回傳兩點的距離
CGFloat distance (CGPoint p1, CGPoint p2)
{
    CGFloat dx = p2.x - p1.x;
    CGFloat dy = p2.y - p1.y;
    
    return sqrt(dx*dx + dy*dy);
}

CGFloat dx(CGPoint p1, CGPoint p2)
{
    return p2.x - p1.x;
}

CGFloat dy(CGPoint p1, CGPoint p2)
{
    return p2.y - p1.y;
}

NSInteger sign(CGFloat x)
{
    return (x < 0.0f) ? (-1) : 1;
}

// 根據給定的原點，回傳點座標
CGPoint pointWithOrigin(CGPoint pt, CGPoint origin)
{
    return CGPointMake(pt.x - origin.x, pt.y - origin.y);
}
