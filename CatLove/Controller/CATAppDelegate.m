//
//  CATAppDelegate.m
//  CatLove
//
//  Created by astraea on 6/24/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATAppDelegate.h"
#import "Flurry.h"
#import <GameKit/GameKit.h>
#import "Parse/Parse.h"
#import "CATConstant.h"
#import "CATPetManager.h"
#import "Reachability.h"

@implementation CATAppDelegate
{
    BOOL isSignedUp;
}

+ (CATAppDelegate*) get
{
	return (CATAppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
 
    //! Flurry
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"G55D4JHCNXNF4SNB6H5J"];
    //[Flurry setDebugLogEnabled:YES];
    
    //! Parse.com
    [Parse setApplicationId:@"5B9HIjV86R8JHuqOiwQa5g9bxYszif9t15e1KwXh"
                  clientKey:@"HMcGDiampPJeGeCZkUBDbRVOKrDkeN574H2wUVVX"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.userManager = [CATUserManager new];
    self.petManager = [CATPetManager new];
    self.backendManager = [CATBackEndManager new];

    self.instructionShown = NO;
    self.lastScreen = NO;
    isSignedUp = NO;
    
    // Desired search radius:
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults doubleForKey:defaultsFilterDistanceKey]) {
		// use the ivar instead of self.accuracy to avoid an unnecessary write to NAND on launch.
		self.searchDistance = [userDefaults doubleForKey:defaultsFilterDistanceKey];
	} else {
		// if we have no accuracy in defaults, set it to 10 miles.
		self.searchDistance = 10;
	}
    
    // Last seen screen:
	if ([userDefaults integerForKey:lastSeenScreenKey]) {
		self.lastScreen = [userDefaults doubleForKey:lastSeenScreenKey];
	} else {
		self.lastScreen = 0;
	}
    
    // Guide Cat shown:
	if ([userDefaults integerForKey:guideCatShownKey]) {
		self.isGuideCatShown = [userDefaults boolForKey:guideCatShownKey];
	} else {
		self.isGuideCatShown = NO;
	}

    // Borrow Guide Cat shown:
	if ([userDefaults integerForKey:adoptGuideCatShownKey]) {
		self.isBorrowGuideCatShown = [userDefaults boolForKey:adoptGuideCatShownKey];
	} else {
		self.isBorrowGuideCatShown = NO;
	}

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //! notification for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    self.isInternetConnected = YES;
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isInternetConnected = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isInternetConnected = NO;
        });
    };
    
    [reach startNotifier];
    
    // FurrToGrapher
    //[self.petManager addFurrTOGRAPHERPhotos];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        self.isInternetConnected = YES;
    }
    else
    {
//        [CATUtility showMessage:@"Your internet connection is disconnected. Please confirm you have an internet connection and try again in a moment." title:@"Error" cancel:@"Dismiss"];
        self.isInternetConnected = NO;
    }
}

#pragma mark - User Management -

- (void) saveProfileData
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    
    [defaultData setObject:self.email forKey:@"email"];
    [defaultData setObject:self.password forKey:@"password"];
    [defaultData synchronize];
}

- (void) loadProfileData
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    
    self.email = [defaultData objectForKey:@"email"];
    self.password = [defaultData objectForKey:@"password"];
}

- (void) signedIn:(BOOL)isSuccess error:(NSString *)error
{
    if (isSuccess)
    {
        [self saveProfileData];
    }
    if (isSignedUp)
        [self.signUpViewController signedUp:isSuccess error:error];
    else
        [self.signInViewController signedIn:isSuccess error:error];
}

- (void) signedUp:(BOOL)isSuccess error:(NSString *)error
{
    if (isSuccess)
    {
        isSignedUp = YES;
        [self signInWithEmail:self.email Password:self.password];
    }
    else
    {
        [self.signUpViewController signedUp:isSuccess error:error];
    }
}

- (void) signInWithEmail:(NSString*)email_ Password:(NSString*)password_
{
    self.userManager.delegate = self;
    self.email = email_;
    self.password = password_;
    [self.userManager signInWithUsername:email_ Password:password_];
}

- (void) signUpWithEmail:(NSString*)email_ Password:(NSString*)password_
{
    self.userManager.delegate = self;
    self.email = email_;
    self.password = password_;
    [self.userManager signUpWithUsername:email_ Password:password_];
}

- (void) forgotPassword:(NSString*)email_
{
    self.userManager.delegate = self;
    [self.userManager forgotPassword:email_];
}


#pragma mark - Location Change Notification -

- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance
{
    if (abs(self.searchDistance - aFilterDistance) < 1)
        return;
    NSLog(@"Current Distance:%f and New distance:%f", self.searchDistance, aFilterDistance);
    
	self.searchDistance = aFilterDistance;
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:self.searchDistance forKey:defaultsFilterDistanceKey];
	[userDefaults synchronize];
    
	// Notify the app of the filterDistance change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:self.searchDistance] forKey:kPAWFilterDistanceKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kPAWFilterDistanceChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)setPresentLocation:(CLLocation *)aCurrentLocation
{
	self.currentLocation = aCurrentLocation;
    NSLog(@"Location Changed");
    
	// Notify the app of the location change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentLocation forKey:kPAWLocationKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kPAWLocationChangeNotification object:nil userInfo:userInfo];
	});
}

#pragma mark - Setting Information - 

- (void)setGuideCatHidden
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    [defaultData setBool:YES forKey:guideCatShownKey];
	[defaultData synchronize];
    self.isGuideCatShown = YES;
}

- (void)setAdoptGuideCatHidden
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    [defaultData setBool:YES forKey:adoptGuideCatShownKey];
	[defaultData synchronize];
    self.isBorrowGuideCatShown = YES;
}

- (void)updateLastSeenScreen:(NSInteger) lastSeenScreen
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    [defaultData setInteger:lastSeenScreen forKey:lastSeenScreenKey];
	[defaultData synchronize];
    self.lastScreen = lastSeenScreen;
}

- (void)signOut
{
    [self.nearbyViewController removeNotification];
    
    [self.petManager clearAll];
    [self.userManager signOut];
}

- (BOOL)changePassword:(NSString *) oldPassword newPassword:(NSString *) newPassword
{
    NSString *currentEmail = [PFUser currentUser].username;
    PFUser *user = [PFUser logInWithUsername:currentEmail password:oldPassword];
    user.password = newPassword;
    return [user save];
}

- (BOOL)changeEmail:(NSString *)newEmail password:(NSString *)password
{
    NSString *currentEmail = [PFUser currentUser].username;
    PFUser *user = [PFUser logInWithUsername:currentEmail password:password];
    if (!user)
        return NO;
    user.email = newEmail;
    return [user save];
}

- (BOOL)isPurchased
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"purchased"])
		return [userDefaults boolForKey:@"purchased"];
    return NO;
}

- (NSString *) getLastViewedPetObjectId
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    
    return [defaultData objectForKey:@"lastobjectid"];
}

- (void) setLastViewedPetObjectId:(NSString *) objectId
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    
    [defaultData setObject:objectId forKey:@"lastobjectid"];
    [defaultData synchronize];
}

@end
