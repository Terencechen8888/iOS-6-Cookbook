/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "BookController.h"

#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define SAFE_ADD(_Array_, _Object_) {if (_Object_ && [_Array_ isKindOfClass:[NSMutableArray class]]) [pageControllers addObject:_Object_];}
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)


#pragma Book Controller
@implementation BookController

#pragma mark Utility

- (int) currentPage
{
    int pageCheck = ((UIViewController *)[self.viewControllers objectAtIndex:0]).view.tag;
    return pageCheck;
}


#pragma mark Presentation indices for page indicator (Data Source)
/*
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    // 在iOS 6測試版時有點失常
    // return [self currentPage];
    return 0;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    if (bookDelegate && [bookDelegate respondsToSelector:@selector(numberOfPages)])
       return [bookDelegate numberOfPages];
    
    return 0;
}
 */

#pragma mark Page Handling

// 如果你想使用其他種寫法，請自行修改
- (BOOL) useSideBySide: (UIInterfaceOrientation) orientation
{
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    
    switch (_layoutStyle)
    {
        case BookLayoutStyleHorizontalScroll:
        case BookLayoutStyleVerticalScroll: return NO;
        case BookLayoutStyleFlipBook: return !isLandscape;
        default: return isLandscape;
    }
}

// 更新目前頁面，設定偏好預設值，呼叫委派
- (void) updatePageTo: (uint) newPageNumber
{
    _pageNumber = newPageNumber;
    
    // 上傳到雲端？
    [[NSUserDefaults standardUserDefaults] setInteger:_pageNumber forKey:DEFAULTS_BOOKPAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];

    SAFE_PERFORM_WITH_ARG(_bookDelegate, @selector(bookControllerDidTurnToPage:), [NSNumber numberWithInt:_pageNumber]);
}

// 向委派要求控制器
- (UIViewController *) controllerAtPage: (int) aPageNumber
{
    if (_bookDelegate &&
        [_bookDelegate respondsToSelector:@selector(viewControllerForPage:)])
    {
        UIViewController *controller = [_bookDelegate viewControllerForPage:aPageNumber];
        controller.view.tag = aPageNumber;
        return controller;
    }
    return nil;
}
// 更新顯示頁面
- (void) fetchControllersForPage: (uint) requestedPage orientation: (UIInterfaceOrientation) orientation
{
    BOOL sideBySide = [self useSideBySide:orientation];
    int numberOfPagesNeeded = sideBySide ? 2 : 1;
    int currentCount = self.viewControllers.count;
    
    uint leftPage = requestedPage;
    if (sideBySide && (leftPage % 2)) leftPage = floor(leftPage / 2) * 2;
    
    // 只有在數目正確時，才對目前頁面進行檢查
    if (currentCount && (currentCount == numberOfPagesNeeded))
    {
        if (_pageNumber == requestedPage) return;
        if (_pageNumber == leftPage) return;
    }
    
    // 比較新舊頁面，決定翻頁方向
    UIPageViewControllerNavigationDirection direction = (requestedPage > _pageNumber) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    // 更新控制器，絕對不能加入nil
    NSMutableArray *pageControllers = [NSMutableArray array];
    SAFE_ADD(pageControllers, [self controllerAtPage:leftPage]);    
    if (sideBySide)
        SAFE_ADD(pageControllers, [self controllerAtPage:leftPage + 1]);
    
    [self setViewControllers:pageControllers direction: direction animated:YES completion:nil];
    [self updatePageTo:leftPage];
}

// 從外界而來的翻頁請求
- (void) moveToPage: (uint) requestedPage
{
    // 謝謝Dino Lupo
    [self fetchControllersForPage:requestedPage orientation:(UIInterfaceOrientation)self.interfaceOrientation];
}

#pragma mark Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    [self updatePageTo:_pageNumber + 1];
    return [self controllerAtPage:(viewController.view.tag + 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    [self updatePageTo:_pageNumber - 1];
    return [self controllerAtPage:(viewController.view.tag - 1)];
}

#pragma mark Delegate

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSUInteger indexOfCurrentViewController = 0;
    if (self.viewControllers.count)
        indexOfCurrentViewController = ((UIViewController *)[self.viewControllers objectAtIndex:0]).view.tag;
    [self fetchControllersForPage:indexOfCurrentViewController orientation:orientation];
    
    BOOL sideBySide = [self useSideBySide:orientation];
    UIPageViewControllerSpineLocation spineLocation = sideBySide ? UIPageViewControllerSpineLocationMid : UIPageViewControllerSpineLocationMin;
    self.doubleSided = sideBySide;
    return spineLocation;
}

#pragma mark Class utility routines
// 回傳新書本
+ (id) bookWithDelegate: (id) theDelegate style: (BookLayoutStyle) aStyle
{
    // 判斷裝置擺向
    UIPageViewControllerNavigationOrientation orientation = UIPageViewControllerNavigationOrientationHorizontal;
    if ((aStyle == BookLayoutStyleFlipBook) || (aStyle == BookLayoutStyleVerticalScroll))
        orientation = UIPageViewControllerNavigationOrientationVertical;
    
    // 判斷過場效果風格
    UIPageViewControllerTransitionStyle transitionStyle = UIPageViewControllerTransitionStylePageCurl;
    if ((aStyle == BookLayoutStyleHorizontalScroll) || (aStyle == BookLayoutStyleVerticalScroll))
        transitionStyle = UIPageViewControllerTransitionStyleScroll;
    
    // 以字典傳入選項，鍵為書脊位置（捲頁）
    // 與控制器之間的分隔設定（捲動）
    BookController *bc = [[BookController alloc] initWithTransitionStyle:transitionStyle navigationOrientation:orientation options:nil];
    
    bc.layoutStyle = aStyle;
    bc.dataSource = bc;
    bc.delegate = bc;
    bc.bookDelegate = theDelegate;
    
    return bc;
}

+ (id) bookWithDelegate: (id) theDelegate
{
    return [self bookWithDelegate:theDelegate style:BookLayoutStyleBook];
}
@end
