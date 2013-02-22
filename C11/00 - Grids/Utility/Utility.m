void drawString(CGRect rect, UIFont *font, UIColor *color, NSString *string)
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [color set];
    CGPoint corePoint = rect.origin;
    [string drawAtPoint:corePoint forWidth:rect.size.width withFont:font fontSize:font.pointSize lineBreakMode:NSLineBreakByWordWrapping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    CGContextRestoreGState(context);
}

void fillRectWithColor(UIColor *color, CGRect bounds)
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [color set];
	CGContextAddRect(context, bounds);
	CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}

void strokeRectWithColorAndWidth(UIColor *color, CGFloat width, CGRect bounds)
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [color set];
	CGContextAddRect(context, bounds);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

UIImage *stringImage(NSString *string, UIFont *font, CGFloat inset, UIColor *color)
{
    CGSize baseSize = [string sizeWithFont:font];
    CGSize adjustedSize = CGSizeMake(baseSize.width + inset * 2, baseSize.height + inset * 2);
    
    // 開始繪製
	UIGraphicsBeginImageContext(adjustedSize);
    
    // 繪製背景
    CGRect bounds = (CGRect){.size = adjustedSize};
    fillRectWithColor([UIColor whiteColor], bounds);
    fillRectWithColor(color, bounds);
    
    // 繪製黑色邊框
    strokeRectWithColorAndWidth([UIColor blackColor], inset, bounds);
    
    // 繪製字串，黑色
    CGRect insetBounds = CGRectInset(bounds, inset, inset);
    drawString(insetBounds, font, [UIColor blackColor], string);
    
    // 回傳新圖像物件
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

UIImage *blockStringImage(NSString *string, float size)
{
    UIFont *font = [UIFont fontWithName:@"Futura" size:size];
    return stringImage(string, font, 10.0f, [UIColor whiteColor]);
}
