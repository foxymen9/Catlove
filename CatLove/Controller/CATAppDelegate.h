//
//  CATAppDelegate.h
//  CatLove
//
//  Created by astraea on 6/24/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATUserManager.h"
#import "CATSignInViewController.h"
#import "CATRegisterViewController.h"
#import "CATPetManager.h"
#import "CATViewController.h"
#import "CATNearByViewController.h"
#import "CATBackEndManager.h"

@interface CATAppDelegate : UIResponder <UIApplicationDelegate, CATUserManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL instructionShown;
@property (nonatomic, assign) BOOL lastScreenShown;
@property (nonatomic, assign) BOOL isInternetConnected;
@property (nonatomic, assign) BOOL isGuideCatShown;
@property (nonatomic, assign) BOOL isBorrowGuideCatShown;
@property (nonatomic, assign) NSInteger lastScreen;

@property (strong, nonatomic) CATViewController *firstViewController;
@property (strong, nonatomic) CATSignInViewController *signInViewController;
@property (strong, nonatomic) CATRegisterViewController *signUpViewController;
@property (strong, nonatomic) CATNearByViewController *nearbyViewController;

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) CATUserManager *userManager;
@property (strong, nonatomic) CATPetManager *petManager;
@property (strong, nonatomic) CATBackEndManager *backendManager;
@property (nonatomic, assign) CLLocationAccuracy searchDistance;
@property (nonatomic, strong) CLLocation *currentLocation;

- (void) signInWithEmail:(NSString*)email_ Password:(NSString*)password_;
- (void) signUpWithEmail:(NSString*)email_ Password:(NSString*)password_;
- (void) setFilterDistance:(CLLocationAccuracy)aFilterDistance;
- (void) setPresentLocation:(CLLocation *)aCurrentLocation;
- (void) updateLastSeenScreen:(NSInteger) lastSeenScreen;
- (void) signOut;
- (BOOL) changePassword:(NSString *) oldPassword newPassword:(NSString *) newPassword;
- (BOOL) changeEmail:(NSString *)newEmail password:(NSString *)password;
- (BOOL) isPurchased;
- (NSString *) getLastViewedPetObjectId;
- (void) setLastViewedPetObjectId:(NSString *) objectId;
- (void) forgotPassword:(NSString*)email_;
- (void) setGuideCatHidden;
- (void) setAdoptGuideCatHidden;

+ (CATAppDelegate*) get;

@end
