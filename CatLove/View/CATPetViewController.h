//
//  CATPetViewController.h
//  CatLove
//
//  Created by astraea on 6/27/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerAssetCellDelegate.h"
#import "CATCameraViewController.h"
#import <GameKit/GameKit.h>
#import "MBProgressHUD.h"

@interface CATPetViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, QBImagePickerAssetCellDelegate, CATCameraViewControllerDelegate, GKGameCenterControllerDelegate, MBProgressHUDDelegate>
{
    BOOL userAuthenticated;
    BOOL _gameCenterFeaturesEnabled;
    MBProgressHUD *HUD;
}

@property (nonatomic, assign) CGSize imageSize;
@property (assign, readonly) BOOL gameCentreAvailable;;
@property (nonatomic, strong) IBOutlet UITableView* petlistTable;
@property (nonatomic, strong) IBOutlet UIButton* addNewButton;
@property (nonatomic, strong) IBOutlet UILabel *disconnectLabel;
@property (nonatomic, strong) IBOutlet UIView *disconnectView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

@end
