//
//  CATPetViewController.m
//  CatLove
//
//  Created by astraea on 6/27/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATPetViewController.h"
#import "QBImagePickerAssetCell.h"
#import "CATPet.h"
#import "CATCameraViewController.h"
#import "CATPetDetailViewController.h"
#import <GameKit/GameKit.h>
#import "Flurry.h"
#import "CATUtility.h"
#import "CATAppDelegate.h"
#import "CATPetManager.h"
#import "ODRefreshControl.h"
#import "Reachability.h"

@interface CATPetViewController ()
{
    BOOL animating;
}
@property (nonatomic, strong) NSMutableArray *petArray;
@property (nonatomic, strong) NSMutableArray *petArrayForTable;
@property (nonatomic, strong) NSMutableOrderedSet *selectedPets;
@property (nonatomic, assign) BOOL isEditMode;
@end

@implementation CATPetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    // Custom initialization
    self.petArray = [NSMutableArray array];
    self.petArrayForTable = [NSMutableArray array];

    self.selectedPets = [NSMutableOrderedSet orderedSet];
    self.imageSize = CGSizeMake(100, 100);
    self.isEditMode = NO;
    self.petlistTable.delaysContentTouches = NO;

    //! game center
    [self authenticateLocalUser];

    //! refresh swipping
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.petlistTable];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    //! notification for internet disconnection
    self.disconnectLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:16];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[CATAppDelegate get] updateLastSeenScreen:2];

    if (self.isEditMode)
        return;

    // Status Bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    // Navigation Bar
    UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(selectPet:)];
    UIImage *image = [UIImage imageNamed:@"rankings25x25"];
    UIButton *showLeaderboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeaderboardButton.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
    [showLeaderboardButton setImage:image forState:UIControlStateNormal];
    [showLeaderboardButton addTarget:self action:@selector(showLeaderBoard:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *showLeaderboardButtonItem = [[UIBarButtonItem alloc] initWithCustomView:showLeaderboardButton];
    [selectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [showLeaderboardButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:selectButton animated:NO];
    [self.navigationItem setRightBarButtonItem:showLeaderboardButtonItem animated:NO];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Petlove_logo29x86"]];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0x7E green:0xE1 blue:0xD3 alpha:1];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // Tool Bar
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    UIBarButtonItem* spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removePet:)];
    [buttonsArray addObject:spaceButton];
    [buttonsArray addObject:removeButton];
    [self setToolbarItems:buttonsArray animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];

    // Reload All Pets
    [self reloadPets];
    
    self.disconnectView.hidden = [CATAppDelegate get].isInternetConnected;
    if (![CATAppDelegate get].isInternetConnected)
    {
        self.navigationItem.leftBarButtonItem = nil;
        [HUD hide:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self reloadPetsForceReload];
    [refreshControl endRefreshing];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    [self.disconnectView bringSubviewToFront:self.view];
    
    if([reach isReachable])
    {
        self.disconnectView.hidden = YES;
        [self reloadPets];
        if (self.petArrayForTable.count > 1)
        {
            UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(selectPet:)];
            [selectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
            [self.navigationItem setLeftBarButtonItem:selectButton animated:NO];
        }
    }
    else
    {
        self.disconnectView.hidden = NO;
        self.navigationItem.leftBarButtonItem = nil;
        [HUD hide:NO];
    }
}

- (void)reloadPets:(BOOL) isForceReload
{
    [self.petArray removeAllObjects];
    
    //! add add button assets
    CATPet *addbutton = [CATPet new];
    addbutton.petID = nil;
    addbutton.addNewButton = self.addNewButton;
    addbutton.petImage = [UIImage imageNamed:@"addcat100x100_select"];
    [self.petArray addObject:addbutton];
    
    //! load pets from server
    [self.petArray addObjectsFromArray:[[CATAppDelegate get].petManager getMyPetArray:isForceReload]];
    [self.petArrayForTable removeAllObjects];
    [self.petArrayForTable addObjectsFromArray:self.petArray];
    [self.petlistTable reloadData];
    
    //! hide spin
    [self stopSpin];
    
    //! hide edit button if there is no pets adopted
    if (self.petArray.count == 1)
    {
        self.backgroundImageView.hidden = NO;
    }
    else
    {
        self.backgroundImageView.hidden = YES;
    }
}

- (void)reloadPets
{
    if (![CATAppDelegate get].isInternetConnected)
        return;

    [self showActivity];
    [self startSpin];
	[HUD showWhileExecuting:@selector(reloadPets:) onTarget:self withObject:0 animated:YES];
}

- (void)reloadPetsForceReload
{
    if (![CATAppDelegate get].isInternetConnected)
        return;
    
    [self showActivity];
    [self startSpin];
	[HUD showWhileExecuting:@selector(reloadPets:) onTarget:self withObject:@YES animated:YES];
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         HUD.customView.transform = CGAffineTransformRotate(HUD.customView.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

- (void) showActivity
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner90x90"]];
	HUD.delegate = self;
}

#pragma mark - Buttons Actions -

- (void)selectPet: (id) sender
{
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    
    self.isEditMode = YES;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPet:)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.addNewButton setEnabled:NO];
}

- (void)cancelPet: (id) sender
{
    self.tabBarController.tabBar.userInteractionEnabled = YES;

    self.isEditMode = NO;
    
    UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(selectPet:)];
    [selectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    UIImage *image = [UIImage imageNamed:@"rankings25x25"];
    UIButton *showLeaderboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeaderboardButton.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
    [showLeaderboardButton setImage:image forState:UIControlStateNormal];
    [showLeaderboardButton addTarget:self action:@selector(showLeaderBoard:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *showLeaderboardButtonItem = [[UIBarButtonItem alloc] initWithCustomView:showLeaderboardButton];
    [self.navigationItem setLeftBarButtonItem:selectButton animated:NO];
    [self.navigationItem setRightBarButtonItem:showLeaderboardButtonItem animated:NO];
    [self.navigationController setToolbarHidden:YES animated:YES];

    [self.addNewButton setEnabled:YES];
    
    [self.selectedPets removeAllObjects];
    [self reloadPets];
}

- (IBAction)addPet: (id) sender
{
    if (self.isEditMode)
        return;
    
    NSString * storyboardName = @"Main_iPhone";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CATCameraViewController * cameraViewController = [storyboard instantiateViewControllerWithIdentifier:@"CATCameraViewController"];
    cameraViewController.delegate = self;
    [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (void)showLeaderBoard: (id) sender
{
    if (_gameCenterFeaturesEnabled)
    {
        GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController:gameCenterController animated:YES completion:nil];
    }
    else
    {
        [self authenticateLocalUser];
    }
}

- (void)removePet: (id) sender
{
    if ([self.selectedPets count] <= 0)
        return;

    NSString *deleteString = nil;
    if ([self.selectedPets count] > 1)
        deleteString = @"Are you sure you want to remove selected Pets?";
    else
        deleteString = [NSString stringWithFormat:@"Are you sure you want to remove %@?", [(CATPet *)[self.selectedPets objectAtIndex:0] petName]];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:deleteString delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)removePetOnServer
{
    [[CATAppDelegate get].petManager removePets:[self.selectedPets array]];
    
    [self reloadPets:YES];
    [self cancelPet: nil];
}

#pragma mark - TableView -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
    return margin + self.imageSize.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    numberOfRowsInSection = self.petArrayForTable.count / numberOfAssetsInRow;
    if((self.petArrayForTable.count - numberOfRowsInSection * numberOfAssetsInRow) > 0) numberOfRowsInSection++;
    
    // temperary code! it should be changed!
    if (self.petArrayForTable.count < 12)
    {
        return 4;
    }

    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"AssetCell";
    NSString *dummycellIdentifier = @"DummyCell";
    UITableViewCell *cell;
    if (indexPath.row > self.petArrayForTable.count / 3 || self.petArrayForTable.count == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:dummycellIdentifier];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    if (cell == nil) {
        if (indexPath.row > self.petArrayForTable.count / 3 || self.petArrayForTable.count == 0)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dummycellIdentifier];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [tableView setPagingEnabled:NO];
        }
        else
        {
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
            
            cell = [[QBImagePickerAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageSize:self.imageSize numberOfAssets:numberOfAssetsInRow margin:margin];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [(QBImagePickerAssetCell *)cell setDelegate:self];
            [(QBImagePickerAssetCell *)cell setAllowsMultipleSelection:YES];
        }
    }
    
    if (indexPath.row > self.petArrayForTable.count / 3 || self.petArrayForTable.count == 0)
    {
        return cell;
    }
    
    // Set assets
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger offset = numberOfAssetsInRow * indexPath.row;
    NSInteger numberOfAssetsToSet = (offset + numberOfAssetsInRow > self.petArrayForTable.count) ? (self.petArrayForTable.count - offset) : numberOfAssetsInRow;
    
    NSMutableArray *assets = [NSMutableArray array];
    
    // Add assets
    for (NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        CATPet *asset = [self.petArrayForTable objectAtIndex:(offset + i)];
        
        [assets addObject:asset];
    }
    
    [(QBImagePickerAssetCell *)cell assignAssets:assets];
    
    // Set selection states
    for (NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        CATPet *asset = [self.petArrayForTable objectAtIndex:(offset + i)];
        
        if([self.selectedPets containsObject:asset]) {
            [(QBImagePickerAssetCell *)cell selectAssetAtIndex:i];
        } else {
            [(QBImagePickerAssetCell *)cell deselectAssetAtIndex:i];
        }
    }

    if (indexPath.row == 0)
    {
        for (UIView *currentView in cell.subviews) {
            if ([NSStringFromClass([currentView class]) isEqualToString:@"UITableViewCellScrollView"]) {
                UIScrollView *svTemp = (UIScrollView *) currentView;
                [svTemp setDelaysContentTouches:NO];
                break;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - QBImagePickerAssetCellDelegate -

- (BOOL)assetCell:(QBImagePickerAssetCell *)assetCell canSelectAssetAtIndex:(NSUInteger)index
{
    // Skip in add new pet button
    NSIndexPath *indexPath = [self.petlistTable indexPathForCell:assetCell];
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    if (assetIndex == 0)
        return NO;
    
    return self.isEditMode;
}

- (void)assetCell:(QBImagePickerAssetCell *)assetCell didChangeAssetSelectionState:(BOOL)selected atIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [self.petlistTable indexPathForCell:assetCell];
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    
    // In case of add new pet button, add new pet.
    if (assetIndex == 0)
    {
        if (!self.isEditMode)
            [self addPet:nil];
        return;
    }
    
    // In case of pets
    CATPet *selectedPet = [self.petArray objectAtIndex:assetIndex];
    
    if (selected)
    {
        [self.selectedPets addObject:selectedPet];
    }
    else
    {
        [self.selectedPets removeObject:selectedPet];
    }
    
    if (!self.isEditMode)
    {
        NSString * storyboardName = @"Main_iPhone";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        CATPetDetailViewController * petdetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"CATPetDetailViewController"];
        petdetailViewController.selectedPet = selectedPet;
        petdetailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:petdetailViewController animated:YES];
    }
}

#pragma mark - QBImagePickerAssetCellDelegate -

- (void)yCameraControllerDidDoneWithImage:(UIImage *) petImage lefteyePoint:(CGPoint) lefteyePoint righteyePoint:(CGPoint) righteyePoint nosePoint:(CGPoint) nosePoint petName:(NSString *) petName
{
    CATPet* newPet = [CATPet new];
    newPet.petName = petName;
    newPet.lefteyePoint = lefteyePoint;
    newPet.righteyePoint = righteyePoint;
    newPet.nosePoint = nosePoint;
    newPet.petShareImage = [CATUtility fixOrientation:petImage];
    
    CGFloat thumbWidth, thumbHeight, shareWidth, shareHeight;
    if (petImage.size.width > petImage.size.height)
    {
        thumbHeight = 100;
        shareHeight = 1136;
        thumbWidth = thumbHeight * (petImage.size.width / petImage.size.height);
        shareWidth = shareHeight * (petImage.size.width / petImage.size.height);
    }
    else
    {
        thumbWidth = 100;
        shareWidth = 1136;
        thumbHeight = thumbWidth * (petImage.size.height / petImage.size.width);
        shareHeight = shareWidth * (petImage.size.height / petImage.size.width);
    }
    newPet.petThumbImage = [CATUtility thumbnail:petImage scaledToSize:CGSizeMake(thumbWidth, thumbHeight)];
    newPet.petImage = [CATUtility thumbnail:petImage scaledToSize:CGSizeMake(shareWidth, shareHeight)];
    
    NSString * storyboardName = @"Main_iPhone";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CATPetDetailViewController * petdetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"CATPetDetailViewController"];
    petdetailViewController.hidesBottomBarWhenPushed = YES;
    petdetailViewController.selectedPet = newPet;
    [self.navigationController pushViewController:petdetailViewController animated:YES];
}

//- (void) logPetCount
//{
//    NSNumber *petedCountNumber = [NSNumber numberWithInteger:[self.petArray count]];
//    NSDictionary *petedCountParam = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     petedCountNumber, @"Pet_Count",
//                                     nil];
//    [Flurry logEvent:@"PET_COUNT" withParameters:petedCountParam];
//}
//
#pragma mark - GKGameCenterControllerDelegate -

-(BOOL)isGameCentreAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

-(void) authenticateLocalUser
{
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
        
        localPlayer.authenticateHandler = ^(UIViewController *gcvc,NSError *error) {
            if (gcvc != nil)
            {
                [self presentViewController:gcvc animated:YES completion:nil];
            }
            else
            {
                if ([GKLocalPlayer localPlayer].authenticated) {
                    _gameCenterFeaturesEnabled = YES;
                }
                else {
                    _gameCenterFeaturesEnabled = NO;
                }
            }
        };
    }
    
    else if ([GKLocalPlayer localPlayer].authenticated == YES){
        _gameCenterFeaturesEnabled = YES;
    }
    
}

- (void) gameCenterViewControllerDidFinish:(GKGameCenterViewController*) gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertView Delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.color = [UIColor colorWithRed:0.99 green:0.39 blue:0.39 alpha:0.90];
        HUD.delegate = self;
        HUD.labelText = @"Deleting...";
        [HUD showWhileExecuting:@selector(removePetOnServer) onTarget:self withObject:nil animated:YES];
    }
}

@end
