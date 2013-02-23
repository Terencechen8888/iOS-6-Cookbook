/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

UIColor *randomColor()
{
    return [UIColor colorWithRed:((rand() % 255) / 255.0f)
                           green:((rand() % 255) / 255.0f)
                            blue:((rand() % 255) / 255.0f)
                           alpha:0.5f];
}

CGRect centerRectInRect(CGRect rect, CGRect mainRect)
{
    return CGRectOffset(rect,
						CGRectGetMidX(mainRect)-CGRectGetMidX(rect),
						CGRectGetMidY(mainRect)-CGRectGetMidY(rect));
}

UIImage *stringImageTinted(NSString *string, UIFont *aFont, CGFloat side)
{
    CGSize imageSize = CGSizeMake(side, side);
    CGSize baseSize = [string sizeWithFont:aFont];
    
    CGRect bounds = (CGRect){.size = imageSize};
    CGRect stringBounds = (CGRect){.size = baseSize};
    
    CGRect insetRect = centerRectInRect(stringBounds, bounds);

	UIGraphicsBeginImageContext(imageSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 繪製白色背景
	[[UIColor whiteColor] set];
	CGContextAddRect(context, bounds);
	CGContextFillPath(context);
    
    // 在白色背景上，隨機塗上某顏色
    [[UIColor colorWithRed:((rand() % 255) / 255.0f)
                     green:((rand() % 255) / 255.0f)
                      blue:((rand() % 255) / 255.0f)
                     alpha:0.65f] set];
    CGContextAddRect(context, bounds);
    CGContextFillPath(context);
    
    // 繪製黑色邊框
    [[UIColor blackColor] set];
	CGContextAddRect(context, bounds);
    CGContextSetLineWidth(context, 10.0f);
    CGContextStrokePath(context);
    
    // 繪製字串，黑色
    [string drawInRect:insetRect withFont:aFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}



