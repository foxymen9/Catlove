//
//  CATSettingsViewController.h
//  CatLove
//
//  Created by astraea on 7/18/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <FacebookSDK/FacebookSDK.h>
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"

@interface CATSettingsViewController : UIViewController <MFMailComposeViewControllerDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}
@property (nonatomic, strong) IBOutlet UILabel *email;
@property (nonatomic, strong) IBOutlet UILabel *radiusLabel;
@property (nonatomic, strong) IBOutlet UISlider *radius;
@property (nonatomic, strong) IBOutlet UIView *buyView;
@property (nonatomic, strong) IBOutlet UIView *restoreView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UISwitch *privateSwitch;
@property (strong, nonatomic) SKProduct *product;
@property (nonatomic, assign) BOOL isPurchased;
@end
