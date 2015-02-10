//
//  CATPetManager.h
//  CatLove
//
//  Created by astraea on 7/20/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CATPet.h"
#import "MBProgressHUD.h"

@protocol CATPetManagerDelegate;

@interface CATPetManager : NSObject

@property (nonatomic, strong) NSMutableArray *nearbyPets;
@property (nonatomic, strong) NSMutableArray *borrowedPets;
@property (nonatomic, strong) NSMutableArray *myPets;
@property (nonatomic, strong) id<CATPetManagerDelegate>  delegate;

- (NSMutableArray *) getNearbyPetArray:(BOOL) isForceReload location:(CLLocation *) location radius:(float) radius;
- (NSMutableArray *) getMyPetArray:(BOOL) isForceReload;
- (NSMutableArray *) getBorrowedPetArray:(BOOL) isForceReload;
- (BOOL) updatePet:(CATPet *) pet increasedPettedCount:(NSInteger) increasedPettedCount;
- (BOOL) addPet:(CATPet *) pet location:(CLLocation *) location progress:(MBProgressHUD *) progress;
- (BOOL) removePets:(NSArray *) petArray;
- (BOOL) releasePets:(NSArray *) petArray;
- (void) clearAll;
- (NSInteger) getIncreasedPettedCount:(CATPet *) pet;
- (BOOL) reportPet:(CATPet *) pet;
- (void) refreshPettedCount:(NSString *) petID;

- (void) addFurrTOGRAPHERPhotos;
@end

@protocol CATPetManagerDelegate <NSObject>

@optional

- (void)refreshedPettedCount:(NSInteger) pettedCount;

@end
