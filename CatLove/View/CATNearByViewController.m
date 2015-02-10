//
//  CATNearByViewController.m
//  CatLove
//
//  Created by astraea on 7/18/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATNearByViewController.h"
#import "QBImagePickerAssetCell.h"
#import "CATPet.h"
#import "CATPetDetailViewController.h"
#import "CATUtility.h"
#import "Flurry.h"
#import "CATConstant.h"
#import "CATAppDelegate.h"
#import "CATPetManager.h"
#import "MBProgressHUD.h"
#import "ODRefreshControl.h"
#include <objc/runtime.h>
#import "Reachability.h"


@interface CATNearByViewController ()
{
    BOOL animating;
}
@property (nonatomic, strong) NSMutableArray *petArray;
@property (nonatomic, strong) NSMutableArray *petArrayForTable;
@property (nonatomic, strong) NSMutableOrderedSet *selectedPets;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSLock* theLock;
@property (nonatomic, assign) BOOL isFirstLaunch;
@property (nonatomic, assign) BOOL isReloading;
@end

@implementation CATNearByViewController

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
    [CATAppDelegate get].nearbyViewController = self;
    
    // Do any additional setup after loading the view.
    
    self.petArray = nil;
    
    self.selectedPets = [NSMutableOrderedSet orderedSet];
    self.imageSize = CGSizeMake(100, 100);
    self.isEditMode = NO;
    self.theLock = [[NSLock alloc] init];
    self.isFirstLaunch = YES;

    [self startStandardUpdates];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kPAWLocationChangeNotification object:nil];

    if ([CATAppDelegate get].lastScreenShown == NO)
    {
        if ([CATAppDelegate get].lastScreen != 4)
        {
            [CATAppDelegate get].lastScreenShown = YES;
            [self.tabBarController setSelectedIndex:0];
        }
        else
        {
            NSString * storyboardName = @"Main_iPhone";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            CATPetDetailViewController * petdetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"CATPetDetailViewController"];
            petdetailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:petdetailViewController animated:YES];
        }
    }
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.petlistTable];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    //! notification for internet disconnection
    self.disconnectLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:16];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        self.disconnectView.hidden = YES;
        [self reloadPets];
    }
    else
    {
        self.disconnectView.hidden = NO;
        [HUD hide:NO];
    }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kPAWLocationChangeNotification
                                                  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([CATAppDelegate get].lastScreenShown == YES)
    {
        [[CATAppDelegate get] updateLastSeenScreen:0];
    }
    
	[super viewWillAppear:animated];

    // Status Bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self.locationManager startUpdatingLocation];
    
    // Navigation Bar
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Nearby29x86"]];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0x7E green:0xE1 blue:0xD3 alpha:1];
    
    if (animating)
    {
        [self stopSpin];
        [self startSpin];
    }
    NSLog(@"Animating:%d", animating);
    
    self.disconnectView.hidden = [CATAppDelegate get].isInternetConnected;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self.locationManager stopUpdatingLocation];

	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
}

- (void)dealloc
{
	[self.locationManager stopUpdatingLocation];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    if (self.locationManager.location != nil)
        [self reloadPetsForceReload];
    [refreshControl endRefreshing];
}

- (void)reloadPets:(BOOL) isForceReloaded
{
    if (![CATAppDelegate get].isInternetConnected)
        return;
    
    NSLog(@"isReloading:(%d)", (int)self.isReloading);
    if (self.isReloading == YES)
        return;
    
    [self.theLock lock];
    self.isReloading = YES;
    NSLog(@"Start Nearby getting:(%d)", (int)self.isReloading);
    self.petArray = [[CATAppDelegate get].petManager getNearbyPetArray:isForceReloaded location:[CATAppDelegate get].currentLocation radius:[CATAppDelegate get].searchDistance];
    
    NSDate *methodStart = [NSDate date];
    [self.petlistTable reloadData];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime(Nearby UI) = %f", executionTime);
    
    NSLog(@"End Nearby getting:(%d)", (int)self.isReloading);
    self.isReloading = NO;
    [self.theLock unlock];
    NSLog(@"Thread unlock:(%d)", (int)self.isReloading);
    
//    [self stopSpin];
    
    //! show guide cat
    NSLog(@"Current Location:%@", [CATAppDelegate get].currentLocation);
    if ([CATAppDelegate get].isGuideCatShown == NO && [CATAppDelegate get].currentLocation != nil)
    {
        self.guidecatImageView.image = [UIImage imageNamed:@"guidecat_one_320x260"];
        self.hideGuideCatButton.hidden = NO;
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
}

- (void)reloadPets
{
    //! if user was on detail view, then do not show nearby progress activity
    if ([CATAppDelegate get].lastScreen != 0)
    {
        [self performSelector:@selector(reloadPets:) withObject:0];
        return;
    }
    
    [self showActivity];
//    [self startSpin];
	[HUD showWhileExecuting:@selector(reloadPets:) onTarget:self withObject:0 animated:YES];
}

- (void)reloadPetsForceReload
{
    //! if user was on detail view, then do not show nearby progress activity
    if ([CATAppDelegate get].lastScreen != 0)
    {
        [self performSelector:@selector(reloadPets:) withObject:@YES];
        return;
    }
    [self showActivity];
//    [self startSpin];
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
	HUD.mode = MBProgressHUDModeCustomViewRotating;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner90x90"]];
	HUD.delegate = self;
}

#pragma mark - Buttons Actions -

- (IBAction)hideGuideCat:(id)sender
{
    [[CATAppDelegate get] setGuideCatHidden];
    self.hideGuideCatButton.hidden = YES;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
        self.guidecatImageView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)selectPet: (id) sender
{
    self.isEditMode = YES;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPet:)];
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)cancelPet: (id) sender
{
    self.isEditMode = NO;
    
    UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(selectPet:)];
    [self.navigationItem setLeftBarButtonItem:selectButton animated:NO];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self.selectedPets removeAllObjects];
    [self reloadPets];
}

- (void)removePet: (id) sender
{
    [self cancelPet: sender];
    [self reloadPets];
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

- (void)logAllProperties : (id) object
{
    unsigned int count;
    Ivar *ivars = class_copyIvarList([object class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        
        if (strncmp(type, "i", 1) == 0) {
            int intValue = *(int*)((uintptr_t)object + offset);
            NSLog(@"%s = %i", name, intValue);
        } else if (strncmp(type, "f", 1) == 0) {
            float floatValue = *(float*)((uintptr_t)object + offset);
            NSLog(@"%s = %f", name, floatValue);
        } else if (strncmp(type, "@", 1) == 0) {
            id value = object_getIvar(object, ivar);
            NSLog(@"%s = %@", name, value);
        }
        // And the rest for other type encodings
    }
    free(ivars);
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
            
            cell = [[QBImagePickerAssetCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier imageSize:self.imageSize numberOfAssets:numberOfAssetsInRow margin:margin];
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
        NSLog(@"Pet Info(%ld+%lu), %@, %@", (long)offset, (unsigned long)i, asset.petName, asset.petThumbImage);
        
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

#pragma mark - Location Change - 

- (void)startStandardUpdates
{
	if (nil == self.locationManager) {
		self.locationManager = [[CLLocationManager alloc] init];
	}
    
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	// Set a movement threshold for new events.
	self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager requestWhenInUseAuthorization];
	[self.locationManager startUpdatingLocation];
    
	CLLocation *currentLocation = self.locationManager.location;
	if (currentLocation) {
		CATAppDelegate *appDelegate = [CATAppDelegate get];
		appDelegate.currentLocation = currentLocation;
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			[self.locationManager startUpdatingLocation];
            self.backgroundImageView.hidden = YES;
            self.petlistTable.hidden = NO;
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
            self.backgroundImageView.hidden = NO;
            self.petlistTable.hidden = YES;
			break;
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
//            self.backgroundImageView.hidden = NO;
            self.petlistTable.hidden = YES;
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
            self.backgroundImageView.hidden = NO;
            self.petlistTable.hidden = YES;
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
    if (meters > 100 || self.isFirstLaunch == YES)
    {
        NSLog(@"LOCATION>>>%s", __PRETTY_FUNCTION__);
        
        self.isFirstLaunch = NO;
        
        CATAppDelegate *appDelegate = [CATAppDelegate get];
        [appDelegate setPresentLocation:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);
    
	if (error.code == kCLErrorDenied) {
		[self.locationManager stopUpdatingLocation];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:[error description]
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	}
}

#pragma mark - NSNotificationCenter notification handlers

- (void)distanceFilterDidChange:(NSNotification *)note
{
	[self reloadPetsForceReload];
}

- (void)locationDidChange:(NSNotification *)note
{
	[self reloadPetsForceReload];
}
@end
