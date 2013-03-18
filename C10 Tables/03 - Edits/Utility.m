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

UIImage *stringImage(NSString *string, UIFont *aFont, CGFloat inset)
{
    CGSize baseSize = [string sizeWithFont:aFont];
    CGSize adjustedSize = CGSizeMake(baseSize.width + inset * 2, baseSize.height + inset * 2);
    
	UIGraphicsBeginImageContext(adjustedSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 繪製白色背景
    CGRect bounds = (CGRect){.size = adjustedSize};
	[[UIColor whiteColor] set];
	CGContextAddRect(context, bounds);
	CGContextFillPath(context);
    
    // 繪製黑色邊緣
    [[UIColor blackColor] set];
	CGContextAddRect(context, bounds);
    CGContextSetLineWidth(context, inset);
    CGContextStrokePath(context);

    // 繪製字串，黑色
    CGRect insetBounds = CGRectInset(bounds, inset, inset);
    [string drawInRect:insetBounds withFont:aFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

UIImage *blockImage(CGFloat side)
{
    CGFloat inset = 10.0f;
    CGSize backgroundSize = CGSizeMake(side, side);
    CGRect bounds = (CGRect){.size = backgroundSize};
    
	UIGraphicsBeginImageContext(backgroundSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 繪製白色背景與外框
	[[UIColor whiteColor] set];
	CGContextAddRect(context, bounds);
	CGContextFillPath(context);
    UIImage *frameImage = [UIImage imageNamed:@"frame.png"];
    [frameImage drawInRect:bounds];
    
    // 建立白色背景
    bounds = (CGRect){.size = backgroundSize};
    
    // 準備插入子畫面
    CGRect insetBounds = CGRectInset(bounds, inset, inset);
    int numChildren = 4 + rand() % 4;
    
    for (int i = 0; i < numChildren; i++)
    {
        [randomColor() set];
        CGFloat randX = insetBounds.origin.x + (insetBounds.size.width * .7) * (rand() % 1000) / 1000.0f;
        CGFloat dx = insetBounds.size.width - randX;
        CGFloat randW = dx * (0.5f + (rand() % 1000) / 2000.0f);
        
        CGFloat randY = insetBounds.origin.y + (insetBounds.size.height * .7) * (rand() % 1000) / 1000.0f;
        CGFloat dy = insetBounds.size.height - randY;
        CGFloat randH = dy * (0.5f + (rand() % 1000) / 2000.0f);
        
        // 加入上色後的子視圖
        CGRect childBounds = CGRectMake(randX, randY, randW, randH);
        CGContextAddEllipseInRect(context, childBounds);
        CGContextFillPath(context);
        
        [[UIColor blackColor] set];
        CGContextAddEllipseInRect(context, childBounds);
        CGContextSetLineWidth(context, 3.0f);
        CGContextStrokePath(context);
    }
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

