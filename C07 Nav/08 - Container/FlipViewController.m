/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "FlipViewController.h"

#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

#define CONSTRAIN(VIEW, FORMAT)     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(FORMAT) options:0 metrics:nil views:NSDictionaryOfVariableBindings(VIEW)]]
#define PREPCONSTRAINTS(VIEW) [VIEW setTranslatesAutoresizingMaskIntoConstraints:NO]

@implementation FlipViewController
// 解除視圖控制器
- (void) done: (id) sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    if (!controllers.count)
    {
        NSLog(@"Error: No root view controller");
        return;
    }
    
    // 清除子視圖控制器
    UIViewController *currentController = (UIViewController *)controllers[0];
    [currentController willMoveToParentViewController:nil];
    [currentController.view removeFromSuperview];
    [currentController removeFromParentViewController];
}

- (void) flip: (id) sender
{
    // 僅能在兩個控制其實呼叫
    if (controllers.count < 2) return;

    // 判斷哪個在前面、哪個在後面
    UIViewController *front =  (UIViewController *)controllers[0];
    UIViewController *back =  (UIViewController *)controllers[1];
    
    // 選擇過場動畫的方向
    UIViewAnimationTransition transition = reversedOrder ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
    
    // 隱藏資訊按鈕，直到翻頁完成
    infoButton.alpha = 0.0f;
    
    // 準備移除前面的、準備加入後面的
    [front willMoveToParentViewController:nil];
    [self addChildViewController:back];
    
    back.view.frame = front.view.frame;

    // 執行過場動畫
    [self transitionFromViewController: front toViewController:back duration:0.5f options: transition  animations:nil completion:^(BOOL done){
        
        // 將資訊按鈕放回視圖裡
        [self.view bringSubviewToFront:infoButton];
        [UIView animateWithDuration:0.3f animations:^(){
            infoButton.alpha = 1.0f;
        }];
        
        // 結束過場動畫
        [front removeFromParentViewController];
        [back didMoveToParentViewController:self];
        
        reversedOrder = !reversedOrder;
        controllers = @[back, front];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (!controllers.count)
    {
        NSLog(@"Error: No root view controller");
        return;
    }
    
    UIViewController *front = controllers[0];
    UIViewController *back = nil;
    if (controllers.count > 1)
    {
        back = controllers[1];
        back.view.frame = front.view.frame;
    }

    [self addChildViewController:front];
    [self.view addSubview:front.view];
    [front didMoveToParentViewController:front];
    
    // 檢查是否顯示中，檢查可否翻頁
    BOOL isPresented = self.isBeingPresented;
    
    // 若重複使用，清理物件實體
    if (navbar || infoButton)
    {
        [navbar removeFromSuperview];
        [infoButton removeFromSuperview];
        navbar = nil;
    }

    // 顯示中，加入客製導覽列
    if (isPresented)
    {
        navbar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
        navbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        navbar.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,44.0f);
        [self.view addSubview:navbar];
    }

    // 若已經顯示控制器，右按鈕應為Done
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = isPresented ? SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(done:)) : nil;
    
    // 填入導覽列的內容
    if (navbar)
        [navbar setItems:@[self.navigationItem] animated:NO];
    
    // 設定子視圖控制器的視圖的大小
    CGFloat verticalOffset = (navbar != nil) ? 44.0f : 0.0f;
    CGRect destFrame = CGRectMake(0.0f, verticalOffset, self.view.frame.size.width, self.view.frame.size.height - verticalOffset);
    front.view.frame = destFrame;
    back.view.frame = destFrame;

    // 設定資訊按鈕
    if (controllers.count < 2) return; // 至此，我們的工作完成了
    
    // 建立"i"按鈕
    infoButton = [UIButton buttonWithType:_prefersDarkInfoButton ? UIButtonTypeInfoDark : UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(flip:) forControlEvents:UIControlEventTouchUpInside];
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    // 將"i"置於視圖右下方
    CGSize frameSize = self.view.frame.size;
    infoButton.frame = CGRectMake(frameSize.width - 44.0f, frameSize.height - 44.0f, 44.0f, 44.0f);
    [self.view addSubview:infoButton];
}

// 抱歉，不，我說真的，抱歉。
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (controllers.count < 2) return;
    ((UIViewController *)controllers[1]).view.frame = ((UIViewController *)controllers[0]).view.frame;
}

- (void) loadView
{
    [super loadView];    
    self.view.backgroundColor = [UIColor blackColor];
}

// 回傳新的初始化後的FlipViewController
- (id) initWithFrontController: (UIViewController *) front andBackController: (UIViewController *) back
{
    if (!(self = [super init])) return self;
    
    if (!front)
    {
        NSLog(@"Error: Attempting to create FlipViewController without a root controller.");
        return self;
    }
    
    if (back)
        controllers = @[front, back];
    else
        controllers = @[front];
    
    reversedOrder = NO;
    
    return self;
}
@end
