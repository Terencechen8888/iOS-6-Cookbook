/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
@end

@implementation TestBedViewController
{
    UIPopoverController *popover;
    NSURL *playbackURL;
}

- (void) performDismiss
{
    if (IS_IPHONE)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [popover dismissPopoverAnimated:YES];
}

- (void) presentViewController:(UIViewController *)viewControllerToPresent
{
    if (IS_IPHONE)
	{
        [self presentViewController:viewControllerToPresent animated:YES completion:nil];
	}
	else
	{
        popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerToPresent];
        popover.delegate = self;
        [popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

// 懸浮元件被解除了
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
    popover = nil;
}

- (BOOL) videoRecordingAvailable
{
    // 圖像來源種類必須為可用狀態
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return NO;
    
    // 而且，媒體種類必須包含影片類型
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    return  [mediaTypes containsObject:(NSString *)kUTTypeMovie];
}

- (void) playMovie
{
    // 播放
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:playbackURL];
    player.moviePlayer.allowsAirPlay = YES;
    player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    
    [self.navigationController presentMoviePlayerViewControllerAnimated:player];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:player.moviePlayer queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerLoadStateDidChangeNotification object:player.moviePlayer queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         if ((player.moviePlayer.loadState & MPMovieLoadStatePlayable) != 0)
             [player.moviePlayer performSelector:@selector(play) withObject:nil afterDelay:1.0f];
     }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (error)
    {
        NSLog(@"Error saving video: %@", error.localizedFailureReason);
        return;
    }
    
    // 允許播放影片
    self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, @selector(playMovie));
}

- (void) saveVideo: (NSURL *) mediaURL
{
    // 檢查影片是否相容於相簿，並儲存
	BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(mediaURL.path);
	if (compatible)
    {
        playbackURL = mediaURL;
		UISaveVideoAtPathToSavedPhotosAlbum(mediaURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
    }
    
}

- (void) trimVideo: (NSDictionary *) info
{
	// 取得指向影片的URL
	NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mediaURL options:nil];

    // 建立儲存修剪版本的路徑
    NSString *urlPath = mediaURL.path;
    NSString *extension = urlPath.pathExtension;
    NSString *base = [urlPath stringByDeletingPathExtension];
    NSString *newPath = [NSString stringWithFormat:@"%@-trimmed.%@", base, extension];
    NSLog(@"newPath: %@", newPath);
    NSURL *fileURL = [NSURL fileURLWithPath:newPath];

    // 設定修剪範圍
    CGFloat editingStart = [info[@"_UIImagePickerControllerVideoEditingStart"] floatValue];
    CGFloat editingEnd = [info[@"_UIImagePickerControllerVideoEditingEnd"] floatValue];
    CMTime startTime = CMTimeMakeWithSeconds(editingStart, 1);
    CMTime endTime = CMTimeMakeWithSeconds(editingEnd, 1);
    CMTimeRange exportRange = CMTimeRangeFromTimeToTime(startTime, endTime);
    
    // 建立AVAssetExportSession進行匯出動作
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = fileURL;
    session.outputFileType = AVFileTypeQuickTimeMovie;
    session.timeRange = exportRange;
    
    // 開始匯出
    [session exportAsynchronouslyWithCompletionHandler:^()
    {
        if (session.status == AVAssetExportSessionStatusCompleted)
            [self saveVideo:fileURL];
        else if (session.status == AVAssetExportSessionStatusFailed)
            NSLog(@"AV export session failed");
        else
            NSLog(@"Export session status: %d", session.status);
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self performDismiss];
    [self trimVideo:info];
}


// 解除圖像控制器
- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self performDismiss];
}

- (void) recordVideo
{
    if (popover) return;
    
    // 建立並初始化圖像挑選器控制器
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType =  UIImagePickerControllerSourceTypeCamera;
	picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
	picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    [self presentViewController:picker];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self videoRecordingAvailable])
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemCamera, @selector(recordVideo));
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
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
    
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