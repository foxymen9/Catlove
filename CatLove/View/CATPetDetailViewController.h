//
//  CPetDetailViewController.h
//  CatLove
//
//  Created by astraea on 6/29/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATPet.h"
#import "SmoothLineView.h"
#import "MBProgressHUD.h"
#import <iAd/iAd.h>
#import <StoreKit/StoreKit.h>
#import <SpriteKit/SpriteKit.h>
#import "CATPetManager.h"
#import "THLabel.h"
#import "CATPetDetailScene.h"

@interface CATPetDetailViewController : UIViewController <UIGestureRecognizerDelegate, MBProgressHUDDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate, CATPetManagerDelegate>

@property (nonatomic, strong) CATPet *selectedPet;
@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView* petImageView;
@property (nonatomic, strong) IBOutlet THLabel* pettingLabel;
@property (nonatomic, strong) IBOutlet THLabel* totalPettedCount;
@property (nonatomic, strong) IBOutlet UILabel* moewLabel;
@property (nonatomic, strong) IBOutlet THLabel* petNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView* petMeImageView;
@property (nonatomic, strong) IBOutlet UIImageView* petMeAnimationImageView;
@property (nonatomic, strong) IBOutlet UIImageView* blush1ImageView;
@property (nonatomic, strong) IBOutlet UIImageView* blush2ImageView;
@property (nonatomic, strong) IBOutlet UIImageView* heartsImageView;
@property (nonatomic, strong) IBOutlet UIImageView* sparkleImageView;
@property (nonatomic, strong) IBOutlet UIImageView* purrImageView;
@property (nonatomic, strong) IBOutlet UIImageView* meowImageView;
@property (nonatomic, strong) IBOutlet UIButton* borrowButton;
@property (nonatomic, strong) IBOutlet UIButton* backButton;
@property (nonatomic, strong) IBOutlet UIButton* shareButton;
@property (nonatomic, strong) IBOutlet UIButton* reportButton;
@property (nonatomic, strong) IBOutlet SmoothLineView* lineView;
@property (nonatomic, strong) IBOutlet ADBannerView* adsBannerView;
@property (nonatomic, strong) IBOutlet UIView *purchaseView;
@property (nonatomic, strong) IBOutlet UIView *tempView;
@property (nonatomic, strong) IBOutlet SKView *skview;

@property (strong, nonatomic) CATPetDetailScene *scene;

@property (strong, nonatomic) SKProduct *product;
@end
