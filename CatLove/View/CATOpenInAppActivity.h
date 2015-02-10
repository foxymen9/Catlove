//
//  CATOpenInAppActivity.h
//  Custom activity for Instagram and Pinterest
//
//  Created by astraea on 08/07/14.
//  Copyright (c) 2014 Will Han
// 

#import <UIKit/UIKit.h>

@class CATOpenInAppActivity;

@protocol CATOpenInAppActivityDelegate <NSObject>
@optional
- (void)openInAppActivityWillPresentDocumentInteractionController:(CATOpenInAppActivity*)activity;
- (void)openInAppActivityDidDismissDocumentInteractionController:(CATOpenInAppActivity*)activity;
@end

@interface CATOpenInAppActivity : UIActivity <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id superViewController;
@property (nonatomic, weak) id<CATOpenInAppActivityDelegate> delegate;

- (id)initWithView:(UIView *)view andRect:(CGRect)rect andImage:(UIImage *)image andText:(NSString *)string andTitle:(NSString *) title andURL:(NSURL* ) url;
- (id)initWithView:(UIView *)view andBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)dismissDocumentInteractionControllerAnimated:(BOOL)animated;

@end
