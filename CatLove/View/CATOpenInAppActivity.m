//
//  CATOpenInAppActivity.m
//  Custom activity for Instagram and Pinterest
//
//  Created by astraea on 08/07/14.
//  Copyright (c) 2014 Will Han
//

#import "CATOpenInAppActivity.h"
#import <MobileCoreServices/MobileCoreServices.h> // For UTI
#import <Pinterest/Pinterest.h>

@interface CATOpenInAppActivity () <UIActionSheetDelegate>

// Private attributes
@property (nonatomic, strong) NSArray *fileURLs;
@property (atomic) CGRect rect;
@property (nonatomic, strong) UIBarButtonItem *barButtonItem;
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIDocumentInteractionController *docController;
@property (nonatomic, strong) UIImage *petImage;
@property (nonatomic, strong) NSString *petString;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *url;

@end

@implementation CATOpenInAppActivity
@synthesize rect = _rect;
@synthesize superView = _superView;
@synthesize superViewController = _superViewController;

//+ (UIActivityCategory)activityCategory
//{
//    return UIActivityCategoryShare;
//}

- (id)initWithView:(UIView *)view andRect:(CGRect)rect andImage:(UIImage *)image andText:(NSString *)string andTitle:(NSString *) title andURL:(NSURL* ) url
{
    if(self =[super init]){
        self.superView = view;
        self.rect = rect;
        self.petImage = image;
        self.title = title;
        self.petString = string;
        self.url = url;
    }
    return self;
}

- (id)initWithView:(UIView *)view andBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(self =[super init]){
        self.superView = view;
        self.barButtonItem = barButtonItem;
    }
    return self;
}

- (NSString *)activityType
{
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
	return self.title;
}

- (UIImage *)activityImage
{
	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        return [UIImage imageNamed:@"TTOpenInAppActivity7"];
    else
        return [UIImage imageNamed:@"CATOpenInAppActivity"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSMutableArray *fileURLs = [NSMutableArray array];
    
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]] && [(NSURL *)activityItem isFileURL]) {
            [fileURLs addObject:activityItem];
		}
	}
    
    self.fileURLs = [fileURLs copy];
}

- (void)performActivity
{
    if(!self.superViewController){
        [self activityDidFinish:YES];
        return;
    }

    void(^presentOpenIn)(void) = ^{
        if ([self.title isEqualToString:@"Instagram"])
        {
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
            {
                CGRect cropRect = CGRectMake(0, 0, 612, 612);
                NSString *jpgPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ff.ig"];
                UIImage *newImage = self.petImage;
                if (newImage.size.height < 612 || newImage.size.width < 612)
                {
                    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], cropRect);
                    newImage = [[UIImage alloc] initWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                }
                
                [UIImageJPEGRepresentation(newImage, 1.0) writeToFile:jpgPath atomically:YES];
                NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@",jpgPath]];
                self.docController.UTI = @"com.instagram.exclusivegram";
                self.docController = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
                self.docController.annotation = [NSDictionary dictionaryWithObject:self.petString forKey:@"InstagramCaption"];
                [self.docController presentOpenInMenuFromRect: CGRectZero  inView: self.superView animated: YES ];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"Please install Instagram and log in." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            NSURL *sourceURL = [NSURL URLWithString:@"pinterest://pin"];
            if ([[UIApplication sharedApplication] canOpenURL:sourceURL]) {
                
                Pinterest *pinterest = [[Pinterest alloc]initWithClientId:@"1438677" urlSchemeSuffix:@"pin1438677"];
                [pinterest createPinWithImageURL:self.url
                                       sourceURL:[NSURL URLWithString:@"http://gopetlove.com/"]
                                     description:self.petString];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please install Pinterest and log in." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
            }
        }
    };

    //  Check to see if it's presented via popover
    if ([self.superViewController respondsToSelector:@selector(dismissPopoverAnimated:)]) {
        [self.superViewController dismissPopoverAnimated:YES];
        [((UIPopoverController *)self.superViewController).delegate popoverControllerDidDismissPopover:self.superViewController];
        
        presentOpenIn();
    } else {    //  Not in popover, dismiss as if iPhone
        [self.superViewController dismissViewControllerAnimated:YES completion:^(void){
            presentOpenIn();
        }];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

#pragma mark - Helper

- (void)dismissDocumentInteractionControllerAnimated:(BOOL)animated {
    // Hide menu
    [self.docController dismissMenuAnimated:animated];
    
    // Inform app that the activity has finished
    [self activityDidFinish:NO];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void) documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    // iÍnform delegate
    if([self.delegate respondsToSelector:@selector(openInAppActivityWillPresentDocumentInteractionController:)]) {
        [self.delegate openInAppActivityWillPresentDocumentInteractionController:self];
    }
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller
{
    // Inform delegate
    if([self.delegate respondsToSelector:@selector(openInAppActivityDidDismissDocumentInteractionController:)]) {
        [self.delegate openInAppActivityDidDismissDocumentInteractionController:self];
    }
    
    // Inform app that the activity has finished
    [self activityDidFinish:YES];
}

@end

