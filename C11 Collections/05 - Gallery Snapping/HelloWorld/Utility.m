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

UIImage *blockImage()
{
    CGFloat inset = 10.0f;
    CGSize backgroundSize = CGSizeMake(251.0f, 246.0f);
    CGRect bounds = (CGRect){.size = backgroundSize};
    
	UIGraphicsBeginImageContext(backgroundSize);
	CGContextRef context = UIGraphicsGetCurrentContext();

    // 繪製白色背景與外框圖檔frame.png
	[[UIColor whiteColor] set];
	CGContextAddRect(context, bounds);
	CGContextFillPath(context);
    UIImage *frameImage = [UIImage imageNamed:@"frame.png"];
    [frameImage drawInRect:bounds];
	    
    // 建立白色背景的範圍
    bounds = CGRectMake(25.0f, 22.0f, 200.0f, 200.0f);
    
    // 準備插入子視圖的位置
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



