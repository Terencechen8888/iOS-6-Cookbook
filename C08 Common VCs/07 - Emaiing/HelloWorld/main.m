/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    UISwitch *editSwitch;
    
    UIPopoverController *popover;
}

#pragma mark - Utility
- (void) performDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) presentViewController:(UIViewController *)viewControllerToPresent
{
    // 最好以模態形式呈現
    [self presentViewController:viewControllerToPresent animated:YES completion:nil];
}

#pragma mark - Assets Library
- (void) loadImageFromAssetURL: (NSURL *) assetURL into: (UIImage **) image
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    ALAssetsLibraryAssetForURLResultBlock resultsBlock = ^(ALAsset *asset)
    {
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        CGImageRef cgImage = [assetRepresentation CGImageWithOptions:nil];
        CFRetain(cgImage); // 感謝Oliver Drobnik
        if (image) *image = [UIImage imageWithCGImage:cgImage];
        CFRelease(cgImage);
    };
    
    ALAssetsLibraryAccessFailureBlock failure = ^(NSError *__strong error)
    {
        NSLog(@"Error retrieving asset from url: %@", error.localizedFailureReason);
    };
    
    [library assetForURL:assetURL resultBlock:resultsBlock failureBlock:failure];
}

#pragma mark - Email
- (NSString *) mimeTypeForExtension: (NSString *) ext
{
    // 根據副檔名查出UTI
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) ext, NULL);
    if (!UTI) return nil;
    
    // 透過UTI查出檔案的MIME類型
    // 若是無法辨認的MIME類型，會回傳nil
    
    NSString *mimeType = (__bridge_transfer NSString *) UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    
    return mimeType;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self performDismiss];
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail was cancelled");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail was saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail was sent");
            break;
        default:
            break;
    }
}

- (void) sendImage
{
    UIImage *image = imageView.image;
    if (!image) return;
    
    // 建立並設定郵件
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    [mcvc setSubject:@"Here’s a great photo!"];
    NSString *body = @"<h1>Check this out</h1>\
    <p>I snapped this image from the\
    <code><b>UIImagePickerController</b></code>.</p>";
    [mcvc setMessageBody:body isHTML:YES];
    [mcvc addAttachmentData:UIImageJPEGRepresentation(image, 1.0f)
                   mimeType:@"image/jpeg" fileName:@"pickerimage.jpg"];
    
    // 顯示郵件撰寫視圖控制器
    [self presentViewController:mcvc];
}

#pragma mark - Image Picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 若有編輯後的圖像，使用它
    UIImage __autoreleasing *image = info[UIImagePickerControllerEditedImage];
    
    // 若無，取得原始版本的圖像
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    if (!image && !assetURL)
    {
        NSLog(@"Cannot retrieve an image from the selected item. Giving up.");
    }
    else if (!image)
    {
        NSLog(@"Retrieving from Assets Library");
        [self loadImageFromAssetURL:assetURL into:&image];
    }

    if (image)
    {
        imageView.image = image;
        if ([MFMailComposeViewController canSendMail])
            self.navigationItem.leftBarButtonItem = BARBUTTON(@"Mail", @selector(sendImage));
    }

    [self performDismiss];
}

// 解除圖像控制器
- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self performDismiss];
}

// 懸浮元件被解除了
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
    popover = nil;
}

- (void) snapImage
{
    // 建立並初始化圖像挑選器
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = editSwitch.isOn;
    picker.delegate = self;
    
    [self presentViewController:picker];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemCamera, @selector(snapImage));

        // 在標題視圖裡放入開關，切換編輯狀態
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
        RESIZABLE(toolbar);
        self.navigationItem.titleView = toolbar;
        editSwitch = [[UISwitch alloc] init];
        toolbar.items = @[BARBUTTON(@"Edits", nil), CUSTOMBARBUTTON(editSwitch)];
    }    
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