/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Utility.h"
#import "DownloadHelper.h"

// 長影片 (35 MB)
#define LARGE_MOVIE @"http://www.archive.org/download/BettyBoopCartoons/Betty_Boop_More_Pep_1936_512kb.mp4"

// 短影片 (3 MB)
#define SMALL_MOVIE @"http://www.archive.org/download/Drive-inSaveFreeTv/Drive-in--SaveFreeTv_512kb.mp4"

// 假網址
#define FAKE_MOVIE @"http://www.idontbelievethisisavalidurlforthisexample.com"

// 目前被測試的網址
#define MOVIE_PATH  LARGE_MOVIE
#define MOVIE_URL   [NSURL URLWithString:MOVIE_PATH]

// 下載項目的儲存位置
#define DEST_PATH	[NSHomeDirectory() stringByAppendingString:@"/Documents/Movie.mp4"]
#define DEST_URL    [NSURL fileURLWithPath:DEST_PATH]

@interface TestBedViewController : UIViewController <DownloadHelperDelegate>
@end

@implementation TestBedViewController
{
    BOOL success;
    UIProgressView *progress;
    DownloadHelper *helper;
}

- (void) playMovie
{
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:DEST_URL];
    player.moviePlayer.allowsAirPlay = YES;
    [player.moviePlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:player.moviePlayer queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         [[NSNotificationCenter defaultCenter] removeObserver:self];
     }];
    
    [self presentMoviePlayerViewControllerAnimated:player];
}

- (void) downloadFinished
{
    // 恢復GUI
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.navigationItem.titleView = nil;
    self.title = @"Success";
    
    // 播放影片
    [self playMovie];
}

- (void) downloadReceivedData
{
    CGFloat percent = (CGFloat)helper.bytesRead / (CGFloat)helper.expectedLength;
    progress.progress = percent;
}

- (void) dataDownloadFailed: (NSString *) reason
{
    NSLog(@"Error downloading: %@", reason);
    self.navigationItem.titleView = nil;
    self.title = @"Failed Download";
}

- (void) go
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.navigationItem.titleView = progress;

    // 移除先前的資料
    if ([[NSFileManager defaultManager] fileExistsAtPath:DEST_PATH])
    {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:DEST_PATH error:&error])
            NSLog(@"Error removing existing data: %@", error.localizedFailureReason);
    }

    // 擷取資料
    helper = [DownloadHelper download:MOVIE_PATH withTargetPath:DEST_PATH withDelegate:self];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(go));
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}