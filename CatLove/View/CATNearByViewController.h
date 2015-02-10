//
//  CATNearByViewController.h
//  CatLove
//
//  Created by astraea on 7/18/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerAssetCellDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@interface CATNearByViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, QBImagePickerAssetCellDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) IBOutlet UITableView *petlistTable;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *guidecatImageView;
@property (nonatomic, strong) IBOutlet UILabel *disconnectLabel;
@property (nonatomic, strong) IBOutlet UIView *disconnectView;
@property (nonatomic, strong) IBOutlet UIButton *hideGuideCatButton;
- (void)removeNotification;
- (void)reloadPetsForceReload;

@end
