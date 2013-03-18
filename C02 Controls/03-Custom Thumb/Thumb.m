/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "Thumb.h"

// 以灰階深淺顏色建立大姆哥圖像
UIImage *thumbWithLevel (float aLevel)
{
    float INSET_AMT = 1.5f;
    CGRect baseRect = CGRectMake(0.0f, 0.0f, 40.0f, 100.0f);
    CGRect thumbRect = CGRectMake(0.0f, 40.0f, 40.0f, 20.0f);
    
    UIGraphicsBeginImageContext(baseRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填滿一塊矩形區域
    [[UIColor darkGrayColor] setFill];
    CGContextAddRect(context, CGRectInset(thumbRect, INSET_AMT, INSET_AMT));
    CGContextFillPath(context);
    
    // 大姆哥的外框
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 2.0f);    
    CGContextAddRect(context, CGRectInset(thumbRect, 2.0f * INSET_AMT, 2.0f * INSET_AMT));
    CGContextStrokePath(context);
    
    // 填滿一塊橢圓區域準備標示數值
    CGRect ellipseRect = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    [[UIColor colorWithWhite:aLevel alpha:1.0f] setFill];
    CGContextAddEllipseInRect(context, ellipseRect);
    CGContextFillPath(context);
    
    // 繪製數字
    NSString *numstring = [NSString stringWithFormat:@"%0.1f", aLevel];
    UIColor *textColor = (aLevel > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
    [textColor set];
    UIFont *font = [UIFont fontWithName:@"Georgia" size:20.0f];
    [numstring drawInRect:CGRectInset(ellipseRect, 0.0f, 6.0f) withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
    
    // 數字外圍的圓框
    [[UIColor grayColor] setStroke];
    CGContextSetLineWidth(context, 3.0f);    
    CGContextAddEllipseInRect(context, CGRectInset(ellipseRect, 2.0f, 2.0f));
    CGContextStrokePath(context);
    
    // 建立並回傳圖像
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// 回傳基本的大姆哥圖像，不包含泡泡
UIImage *simpleThumb()
{
    float INSET_AMT = 1.5f;
    CGRect baseRect = CGRectMake(0.0f, 0.0f, 40.0f, 100.0f);
    CGRect thumbRect = CGRectMake(0.0f, 40.0f, 40.0f, 20.0f);
    
    UIGraphicsBeginImageContext(baseRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 為大姆哥填滿一塊矩形區域
    [[UIColor darkGrayColor] setFill];
    CGContextAddRect(context, CGRectInset(thumbRect, INSET_AMT, INSET_AMT));
    CGContextFillPath(context);
    
    // 大姆哥的外框
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 2.0f);    
    CGContextAddRect(context, CGRectInset(thumbRect, 2.0f * INSET_AMT, 2.0f * INSET_AMT));
    CGContextStrokePath(context);
    
    // 取得大姆哥
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}