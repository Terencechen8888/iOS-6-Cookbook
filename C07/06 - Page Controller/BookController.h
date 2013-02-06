/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

// 用來儲存最新近顯示的書本頁面
#define DEFAULTS_BOOKPAGE   @"BookControllerMostRecentPage"

typedef enum
{
    BookLayoutStyleBook, // 裝置橫擺時，並排頁面
    BookLayoutStyleFlipBook, // 裝置直擺時，並排頁面
    BookLayoutStyleHorizontalScroll,
    BookLayoutStyleVerticalScroll,
} BookLayoutStyle;

@protocol BookControllerDelegate <NSObject>
- (id) viewControllerForPage: (int) pageNumber;
@optional
- (NSInteger) numberOfPages; // 主要用途是為了捲動編排形式
- (void) bookControllerDidTurnToPage: (NSNumber *) pageNumber;
@end

@interface BookController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
+ (id) bookWithDelegate: (id) theDelegate;
+ (id) bookWithDelegate: (id) theDelegate style: (BookLayoutStyle) aStyle;
- (void) moveToPage: (uint) requestedPage;
- (int) currentPage;

@property (nonatomic, weak) id <BookControllerDelegate> bookDelegate;
@property (nonatomic) uint pageNumber;
@property (nonatomic) BookLayoutStyle layoutStyle;
@end