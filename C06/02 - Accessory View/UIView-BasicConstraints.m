/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "UIView-BasicConstraints.h"

@implementation UIView (BasicConstraints)
 /*
 對齊方式
 NSLayoutFormatAlignAllLeft = (1 << NSLayoutAttributeLeft),
 NSLayoutFormatAlignAllRight = (1 << NSLayoutAttributeRight),
 NSLayoutFormatAlignAllTop = (1 << NSLayoutAttributeTop),
 NSLayoutFormatAlignAllBottom = (1 << NSLayoutAttributeBottom),
 */

#pragma mark -
#pragma mark Debugging

// 除錯用
- (NSString *) nameForLayoutAttribute: (NSLayoutAttribute) anAttribute
{
    switch (anAttribute)
    {
        case NSLayoutAttributeLeft: return @"left";
        case NSLayoutAttributeRight: return @"right";
        case NSLayoutAttributeTop: return @"top";
        case NSLayoutAttributeBottom: return @"bottom";
        case NSLayoutAttributeLeading: return @"leading";
        case NSLayoutAttributeTrailing: return @"trailing";
        case NSLayoutAttributeWidth: return @"width";
        case NSLayoutAttributeHeight: return @"height";
        case NSLayoutAttributeCenterX: return @"centerX";
        case NSLayoutAttributeCenterY: return @"centerY";
        case NSLayoutAttributeBaseline: return @"baseline";
        default: return @"not-an-attribute";
    }
}

- (NSString *) nameForLayoutRelation: (NSLayoutRelation) aRelation
{
    switch (aRelation)
    {
        case NSLayoutRelationLessThanOrEqual: return @"<=";
        case NSLayoutRelationEqual: return @"==";
        case NSLayoutRelationGreaterThanOrEqual: return @">=";
        default: return @"not-a-relation";
    }
}

- (NSString *) nameForItem: (id) anItem
{
    if (!anItem) return @"nil";
    if (anItem == self) return @"[self]";
    if (anItem == self.superview) return @"[superview]";
    return [NSString stringWithFormat:@"[%@:%x]", [anItem class], (int) anItem];
}

- (NSString *) debugName
{
    return [NSString stringWithFormat:@"[%@:%x]", [self class], (int) self];
}

- (NSString *) constraintRepresentation: (NSLayoutConstraint *) aConstraint
{
    NSString *item1 = [self nameForItem:aConstraint.firstItem];
    NSString *item2 = [self nameForItem:aConstraint.secondItem];
    NSString *relation = [self nameForLayoutRelation:aConstraint.relation];
    NSString *attr1 = [self nameForLayoutAttribute:aConstraint.firstAttribute];
    NSString *attr2 = [self nameForLayoutAttribute:aConstraint.secondAttribute];
    
    NSString *result;
    
    if (!aConstraint.secondItem)
    {
        result = [NSString stringWithFormat:@"(%4.0f) %@.%@ %@ %0.3f", aConstraint.priority, item1, attr1, relation, aConstraint.constant];
    }
    else if (aConstraint.multiplier == 1.0f)
    {
        if (aConstraint.constant == 0.0f)
            result = [NSString stringWithFormat:@"(%4.0f) %@.%@ %@ %@.%@", aConstraint.priority, item1, attr1, relation, item2, attr2];
        else
            result = [NSString stringWithFormat:@"(%4.0f) %@.%@ %@ (%@.%@ + %0.3f)", aConstraint.priority, item1, attr1, relation, item2, attr2, aConstraint.constant];
    }
    else
    {
        if (aConstraint.constant == 0.0f)
            result = [NSString stringWithFormat:@"(%4.0f) %@.%@ %@ (%@.%@ * %0.3f)", aConstraint.priority, item1, attr1, relation, item2, attr2, aConstraint.multiplier];
        else
            result = [NSString stringWithFormat:@"(%4.0f) %@.%@ %@ ((%@.%@ * %0.3f) + %0.3f)", aConstraint.priority, item1, attr1, relation, item2, attr2, aConstraint.multiplier, aConstraint.constant];
    }
    
    return result;
}

- (void) showConstraints
{
    NSLog(@"View %@ has %d constraints", self.debugName, self.constraints.count);
    for (NSLayoutConstraint *constraint in self.constraints)
        NSLog(@"%@", [self constraintRepresentation:constraint]);
    printf("\n");
}

#pragma mark -
#pragma mark Managing Constraints

// 這會忽略任何優先順序，只在 y (R) mx + b 裡尋找
- (BOOL) constraint: (NSLayoutConstraint *) constraint1 matches: (NSLayoutConstraint *) constraint2
{
    if (constraint1.firstItem != constraint2.firstItem) return NO;
    if (constraint1.secondItem != constraint2.secondItem) return NO;
    if (constraint1.firstAttribute != constraint2.firstAttribute) return NO;
    if (constraint1.secondAttribute != constraint2.secondAttribute) return NO;
    if (constraint1.relation != constraint2.relation) return NO;
    if (constraint1.multiplier != constraint2.multiplier) return NO;
    if (constraint1.constant != constraint2.constant) return NO;

    return YES;
}

// 找出第一個符合的約束規則（優先順序、封存與否，皆忽略）
- (NSLayoutConstraint *) constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if ([self constraint:constraint matches:aConstraint])
            return constraint;
    }
    
    for (NSLayoutConstraint *constraint in self.superview.constraints)
    {
        if ([self constraint:constraint matches:aConstraint])
            return constraint;
    }

    return nil;
}

// 移除約束規則
- (void) removeMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    NSLayoutConstraint *match = [self constraintMatchingConstraint:aConstraint];
    if (match)
    {
        [self removeConstraint:match];
        [self.superview removeConstraint:match];
    }
}

- (void) removeMatchingConstraints: (NSArray *) anArray
{
    for (NSLayoutConstraint *constraint in anArray)
        [self removeMatchingConstraint:constraint];
}

- (NSArray *) constraintsForVisualFormat: (NSString *) aVisualFormat withMetrics: (NSDictionary *) metrics
{
    return [NSLayoutConstraint constraintsWithVisualFormat:aVisualFormat options:0 metrics:metrics views: NSDictionaryOfVariableBindings(self)];
}

- (NSArray *) constraintsForVisualFormat: (NSString *) aVisualFormat
{
    return [self constraintsForVisualFormat:aVisualFormat withMetrics:nil];
}

- (void) addVisualFormat: (NSString *) aVisualFormat
{
    BOOL refersToSuperview = ([aVisualFormat rangeOfString:@"|"].location != NSNotFound);
    NSArray *constraints = [self constraintsForVisualFormat:aVisualFormat];
    [(refersToSuperview ? self.superview : self) addConstraints:constraints];
}

// 「移除視圖不持有的約束規則，無任何作用」
- (void) removeVisualFormat: (NSString *) aVisualFormat
{
    NSArray *constraints = [self constraintsForVisualFormat:aVisualFormat];
    [self removeMatchingConstraints:constraints];
}

#pragma mark - 
#pragma mark Flexible sizing

- (NSArray *) stretchConstraints: (NSLayoutFormatOptions) anAlignment
{
    NSArray *constraints;
    
    if ((anAlignment & NSLayoutFormatAlignAllLeft) != 0)
        constraints = [self constraintsForVisualFormat:@"H:|[self(>=0)]"];
    if ((anAlignment & NSLayoutFormatAlignAllRight) != 0)
        constraints = [self constraintsForVisualFormat:@"H:[self(>=0)]|"];
    if ((anAlignment & NSLayoutFormatAlignAllTop) != 0)
        constraints = [self constraintsForVisualFormat:@"V:|[self(>=0)]"];
    if ((anAlignment & NSLayoutFormatAlignAllBottom) != 0)
        constraints = [self constraintsForVisualFormat:@"V:[self(>=0)]|"];
    
    return constraints;
}

- (NSArray *) stretchConstraints: (NSLayoutFormatOptions) anAlignment withEdgeInset: (CGFloat) anInset
{
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *metrics = @{@"inset":@(anInset)};
    
    if ((anAlignment & NSLayoutFormatAlignAllLeft) != 0)
        [constraints addObjectsFromArray:[self constraintsForVisualFormat:@"H:|-inset-[self(>=0)]" withMetrics:metrics]];
    if ((anAlignment & NSLayoutFormatAlignAllRight) != 0)
        [constraints addObjectsFromArray:[self constraintsForVisualFormat:@"H:[self(>=0)]-inset-|" withMetrics:metrics]];
    if ((anAlignment & NSLayoutFormatAlignAllTop) != 0)
        [constraints addObjectsFromArray:[self constraintsForVisualFormat:@"V:|-inset-[self(>=0)]" withMetrics:metrics]];
    if ((anAlignment & NSLayoutFormatAlignAllBottom) != 0)
        [constraints addObjectsFromArray:[self constraintsForVisualFormat:@"V:[self(>=0)]-inset-|" withMetrics:metrics]];

    return constraints;
}

- (void) stretchAlongAxes: (NSLayoutFormatOptions) anAlignment
{
    [self.superview addConstraints:[self stretchConstraints:anAlignment]];
}

- (void) stretchAlongAxes: (NSLayoutFormatOptions) anAlignment withEdgeInset: (CGFloat) anInset
{
    [self.superview addConstraints:[self stretchConstraints:anAlignment withEdgeInset:anInset]];
}

- (void) fitToHeightWithInset: (CGFloat) anInset
{
    [self.superview addConstraints:[self stretchConstraints:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom withEdgeInset:anInset]];
}

- (void) fitToWidthWithInset: (CGFloat) anInset
{
    [self.superview addConstraints:[self stretchConstraints:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight withEdgeInset:anInset]];
}

#pragma mark -
#pragma mark Alignment and Centering

// 對齊，若需要便OR在一起
- (NSArray *) alignmentConstraints: (NSLayoutFormatOptions) anAlignment
{
    NSArray *constraints;
    
    if ((anAlignment & NSLayoutFormatAlignAllLeft) != 0)
        constraints = [self constraintsForVisualFormat:@"H:|[self]"];
    else if ((anAlignment & NSLayoutFormatAlignAllRight) != 0)
        constraints = [self constraintsForVisualFormat:@"H:[self]|"];
    
    if ((anAlignment & NSLayoutFormatAlignAllTop) != 0)
        constraints = [self constraintsForVisualFormat:@"V:|[self]"];
    else if ((anAlignment & NSLayoutFormatAlignAllBottom) != 0)
        constraints = [self constraintsForVisualFormat:@"V:[self]|"];
    
    return constraints;
}

- (void) setAlignmentInSuperview: (NSLayoutFormatOptions) anAlignment
{
    return [self.superview addConstraints:[self alignmentConstraints:anAlignment]];
}

- (NSLayoutConstraint *) horizontalCenteringConstraint
{
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
}

- (NSLayoutConstraint *) verticalCenteringConstraint
{
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
}

// 置中
- (void) centerHorizontallyInSuperview
{
    if (!self.superview) return;   
    [self.superview addConstraint:[self horizontalCenteringConstraint]];
}

- (void) centerVerticallyInSuperview
{
    if (!self.superview) return;
    [self.superview addConstraint:[self verticalCenteringConstraint]];
}


#pragma mark -
#pragma mark Constrain within Superview Bounds

- (NSArray *) constraintsLimitingViewToSuperviewBounds
{
    NSMutableArray *array = [NSMutableArray array];
    
    [array addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
    [array addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    [array addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [array addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    
    return array;
}

- (void) constrainWithinSuperviewBounds
{
    if (!self.superview) return;
    [self.superview addConstraints:[self constraintsLimitingViewToSuperviewBounds]];
}

- (void) addSubviewAndConstrainToBounds:(UIView *)view
{
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view constrainWithinSuperviewBounds];
}

#pragma mark -
#pragma mark Size, Position, and Aspect

- (NSArray *) sizeConstraints: (CGSize) aSize
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(theWidth@750)]" options:0 metrics:@{@"theWidth":@(aSize.width)} views:NSDictionaryOfVariableBindings(self)]];
    [array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(theHeight@750)]" options:0 metrics:@{@"theHeight":@(aSize.height)} views:NSDictionaryOfVariableBindings(self)]];
    return array;
}

- (NSArray *) positionConstraints: (CGPoint) aPoint
{
    NSMutableArray *array = [NSMutableArray array];
    
    // X位置
    [array addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:aPoint.x]];
    
    // Y位置
    [array addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:aPoint.y]];
    
    return array;    
}

- (NSLayoutConstraint *) aspectConstraint: (CGFloat) aspectRatio
{
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:aspectRatio constant:0.0f];
    
}

// 設定視圖在父視圖裡的位置
- (void) constrainPosition: (CGPoint)aPoint
{
    if (!self.superview) return;
    [self.superview addConstraints: [self positionConstraints:aPoint]];
}

// 設定視圖大小
- (void) constrainSize:(CGSize)aSize
{
    [self addConstraints:[self sizeConstraints:aSize]];
}

// 設定長寬比例
- (void) constrainAspectRatio: (CGFloat) aspectRatio
{
    [self addConstraint:[self aspectConstraint:aspectRatio]];
}

#pragma mark -
#pragma mark Tryouts

// 這是個非常糟糕的視圖分佈方案，但的確示範了如何動態建立你自己的
// 視圖字典。這種作法將會逐漸被捨棄
- (void) layoutItems: (NSArray *) viewArray usingInsets: (BOOL) useInsets horizontally: (BOOL) horizontally
{
    // 在viewArray裡的視圖都必須是子視圖
    for (UIView *view in viewArray)
    {
        if (![self.subviews containsObject:view])
        {
            NSLog(@"Error: a view was passed that is not a subview: %@", view);
            return;
        }
    }
    
    // 至少要有兩個視圖
    if (viewArray.count < 2)
    {
        NSLog(@"Error: you must layout at least two items. Count is %d", viewArray.count);
        return;
    }
    
    NSMutableString *formatString = [NSMutableString string];
    [formatString appendFormat:@"%@:|%@", horizontally ? @"H" : @"V", useInsets ? @"-" : @""];
    
    NSMutableDictionary *viewDictionary = [NSMutableDictionary dictionary];
    int i = 1;
    
    float xWidth = self.bounds.size.width;
    if (useInsets) xWidth -= 2 * 24.0f;
    
    for (UIView *view in viewArray)
        xWidth -= view.bounds.size.width;
    
    if (xWidth < 0.0f)
    {
        NSLog(@"Error: Not enough room to fit all views");
        return;
    }
    
    xWidth /= (viewArray.count - 1);
    
    for (UIView *view in viewArray)
    {
        NSString *viewName = [NSString stringWithFormat:@"view%0d", i];

        // 建立約束規則
        [formatString appendFormat:@"[%@]", viewName];
        [viewDictionary setObject:view forKey:viewName];
        if (view != viewArray.lastObject)
            [formatString appendFormat:@"-(>=%f)-", xWidth];
        i++;
        
        // 固定視圖
        // [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        // [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    
    [formatString appendFormat:@"%@|", useInsets ? @"-" : @""];
    
    NSLog(@"FormatString: %@", formatString);
    
    // 建立約束規則
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:viewDictionary];
    
    [self addConstraints:constraints];
}
@end

