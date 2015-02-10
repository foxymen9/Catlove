//
//  CATBorrowViewController.m
//  CatLove
//
//  Created by astraea on 7/18/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATBorrowViewController.h"
#import "CATNearByViewController.h"
#import "QBImagePickerAssetCell.h"
#import "CATPet.h"
#import "CATPetDetailViewController.h"
#import "CATUtility.h"
#import "Flurry.h"
#import "CATAppDelegate.h"
#import "ODRefreshControl.h"
#import "Reachability.h"

@interface CATBorrowViewController ()
{
    BOOL animating;
    ODRefreshControl *refreshControl;
}
@property (nonatomic, strong) NSMutableArray *petArray;
@property (nonatomic, strong) NSMutableOrderedSet *selectedPets;
@property (nonatomic, strong) NSMutableArray *selectedPetsForRelease;
@property (nonatomic, assign) BOOL isEditMode;

@end

@implementation CATBorrowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.petArray = [NSMutableArray array];
    
    self.selectedPets = [NSMutableOrderedSet orderedSet];
    self.selectedPetsForRelease = [NSMutableArray new];
    self.imageSize = CGSizeMake(100, 100);
    self.isEditMode = NO;
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.petlistTable];
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
    [[CATAppDelegate get] updateLastSeenScreen:1];
    
    // Status Bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    // Navigation Bar
    UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(selectPet:)];
    [selectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:selectButton animated:NO];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Adopted29x86"]];
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
    [self reloadPetsForceReload];
    
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

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl_
{
    [self reloadPetsForceReload];
    [refreshControl endRefreshing];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        self.disconnectView.hidden = YES;
        [self reloadPets];
        if (self.petArray.count > 0)
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

- (void)reloadPetsWithArray:(NSMutableArray *) petArray
{
    if (![CATAppDelegate get].isInternetConnected)
        return;
    
    self.petArray = petArray;
    [self.petlistTable reloadData];
    
    //! hide edit button if there is no pets adopted
    if (self.petArray.count == 0)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.backgroundImageView.hidden = NO;
        [refreshControl setEnabled:NO];
    }
    else
    {
        self.backgroundImageView.hidden = YES;
        [refreshControl setEnabled:YES];
    }
}

- (void)reloadPets:(BOOL) isForceReloaded
{
    self.petArray = [[CATAppDelegate get].petManager getBorrowedPetArray:isForceReloaded];
    [self.petlistTable reloadData];
    
    //! hide edit button if there is no pets adopted
    if (self.petArray.count == 0)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.backgroundImageView.hidden = NO;
        [refreshControl setEnabled:NO];
        self.guidecatImageView.hidden = YES;
    }
    else
    {
        self.backgroundImageView.hidden = YES;
        [refreshControl setEnabled:YES];
    }
    
    //! show guide cat
    if ([CATAppDelegate get].isBorrowGuideCatShown == NO)
    {
        self.guidecatImageView.image = [UIImage imageNamed:@"guidecat_adopt_320x260"];
        self.hideGuideCatButton.hidden = NO;
        if (self.petArray.count > 0)
            self.guidecatImageView.hidden = NO;
        self.guidecatImageView.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
            self.guidecatImageView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
    else
    {
        self.guidecatImageView.hidden = YES;
        self.hideGuideCatButton.hidden = YES;
    }
    //! hide spin
    [self stopSpin];
}

- (void)reloadPets
{
    if (![CATAppDelegate get].isInternetConnected)
        return;
    
    self.backgroundImageView.hidden = YES;
    self.guidecatImageView.hidden = YES;
    self.hideGuideCatButton.hidden = YES;
    [self showActivity];
    [self startSpin];
	[HUD showWhileExecuting:@selector(reloadPets:) onTarget:self withObject:0 animated:YES];
}

- (void)reloadPetsForceReload
{
    if (![CATAppDelegate get].isInternetConnected)
        return;
    
    self.backgroundImageView.hidden = YES;
    self.guidecatImageView.hidden = YES;
    self.hideGuideCatButton.hidden = YES;
    if (!animating)
    {
        [self showActivity];
        [self startSpin];
        [HUD showWhileExecuting:@selector(reloadPets:) onTarget:self withObject:@YES animated:YES];
    }
    else
    {
        [self stopSpin];
        [self startSpin];
    }
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
        [HUD.customView.layer removeAllAnimations];
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

- (void) showActivity
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:HUD];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner90x90"]];
	HUD.delegate = self;
}

#pragma mark - Buttons Actions -

- (IBAction)hideGuideCat:(id)sender
{
    [[CATAppDelegate get] setAdoptGuideCatHidden];
    self.hideGuideCatButton.hidden = YES;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
        self.guidecatImageView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)selectPet: (id) sender
{
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    [self setTabBarVisible:NO animated:YES];

    self.isEditMode = YES;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPet:)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.navigationController.toolbar.frame = CGRectOffset(self.navigationController.toolbar.frame, 0, self.tabBarController.tabBar.frame.size.height);
}

- (void)cancelPet: (id) sender
{
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    [self setTabBarVisible:YES animated:YES];

    self.isEditMode = NO;
    
    UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(selectPet:)];
    [selectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:selectButton animated:NO];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.navigationController.toolbar.frame = CGRectOffset(self.navigationController.toolbar.frame, 0, - self.tabBarController.tabBar.frame.size.height);
    
    [self.selectedPets removeAllObjects];
    [self reloadPetsWithArray:self.petArray];
}

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
    
    // bail if the current state matches the desired state
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

- (void)removePet: (id) sender
{
    if ([self.selectedPets count] <= 0)
        return;
    
    NSString *deleteString = nil;
    if ([self.selectedPets count] > 1)
        deleteString = @"Are you sure you want to release selected Pets?";
    else
        deleteString = [NSString stringWithFormat:@"Are you sure you want to release %@?", [(CATPet *)[self.selectedPets objectAtIndex:0] petName]];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:deleteString delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)releasePetOnServer:(NSNumber *) selectedCount
{
    [[CATAppDelegate get].petManager releasePets:self.selectedPetsForRelease];
    [[CATAppDelegate get].userManager updateUser:[[CATAppDelegate get].userManager borrowedCount] - [selectedCount integerValue]];
    [[CATAppDelegate get].nearbyViewController reloadPetsForceReload];
}

- (void)showReleasedMessage
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"released150x150"]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
    HUD.hidden = YES;
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
    numberOfRowsInSection = self.petArray.count / numberOfAssetsInRow;
    if((self.petArray.count - numberOfRowsInSection * numberOfAssetsInRow) > 0) numberOfRowsInSection++;
    
    // temperary code! it should be changed!
    if (self.petArray.count < 12)
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
    if (indexPath.row > self.petArray.count / 3 || self.petArray.count == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:dummycellIdentifier];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    if (cell == nil) {
        if (indexPath.row > self.petArray.count / 3 || self.petArray.count == 0)
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
    
    if (indexPath.row > self.petArray.count / 3 || self.petArray.count == 0)
    {
        return cell;
    }
    
    // Set assets
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger offset = numberOfAssetsInRow * indexPath.row;
    NSInteger numberOfAssetsToSet = (offset + numberOfAssetsInRow > self.petArray.count) ? (self.petArray.count - offset) : numberOfAssetsInRow;
    
    NSMutableArray *assets = [NSMutableArray array];
    
    // Add assets
    for (NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        CATPet *asset = [self.petArray objectAtIndex:(offset + i)];
        
        [assets addObject:asset];
    }
    
    [(QBImagePickerAssetCell *)cell assignAssets:assets];
    
    // Set selection states
    for (NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        CATPet *asset = [self.petArray objectAtIndex:(offset + i)];
        
        if([self.selectedPets containsObject:asset]) {
            [(QBImagePickerAssetCell *)cell selectAssetAtIndex:i];
        } else {
            [(QBImagePickerAssetCell *)cell deselectAssetAtIndex:i];
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
//    NSIndexPath *indexPath = [self.petlistTable indexPathForCell:assetCell];
//    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
//    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
//    if (assetIndex == 0)
//        return NO;
    
    return self.isEditMode;
}

- (void)assetCell:(QBImagePickerAssetCell *)assetCell didChangeAssetSelectionState:(BOOL)selected atIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [self.petlistTable indexPathForCell:assetCell];
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    
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

#pragma mark - UIAlertView Delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])
    {
        self.selectedPetsForRelease = [NSMutableArray arrayWithArray:[self.selectedPets array]];
        [self performSelectorInBackground:@selector(releasePetOnServer:) withObject:@(self.selectedPets.count)];
        NSMutableArray *newPetArray = [NSMutableArray new];
        for (CATPet *pet in self.petArray) {
            BOOL isSelected = NO;
            for (CATPet *selpet in self.selectedPets) {
                if ([pet.petName isEqualToString:selpet.petName])
                {
                    isSelected = YES;
                    break;
                }
            }
            if (!isSelected)
                [newPetArray addObject:pet];
        }
        self.petArray = nil;
        self.petArray = newPetArray;
        
        [self cancelPet: nil];
        [self reloadPetsWithArray:newPetArray];
        
        [self performSelectorOnMainThread:@selector(showReleasedMessage) withObject:self waitUntilDone:YES];

    }
}

@end
