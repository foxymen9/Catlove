//
//  CATConstant.h
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#ifndef CatLove_CATConstant_h
#define CatLove_CATConstant_h

static NSString * const kFSettingsClassKey = @"Settings";
static NSString * const kFSettingsKeyFieldKey = @"key";
static NSString * const kFSettingsValueFieldKey = @"value";
static NSString * const kFSettingsKeyValueKey = @"domainImageStore";

static NSString * const kFUserLocationFieldKey = @"location";
static NSString * const kFUserRoleFieldKey = @"role";
static NSString * const kFUserPrivateFieldKey = @"private";
static NSString * const kFUserBorrowedCountFieldKey = @"borrow_count";
static NSString * const kFUserMaxPettedCountFieldKey = @"max_petted_count";
static NSString * const kFUserTotalPettedCountFieldKey = @"total_petted_count";

static NSString * const kFPetClassKey = @"Pet";
static NSString * const kFPetNameFieldKey = @"name";
static NSString * const kFPetOwnerFieldKey = @"owner";
static NSString * const kFPetDeletedFieldKey = @"deleted";
static NSString * const kFPetFlagCountFieldKey = @"flagCnt";
static NSString * const kFPetHiddenFromGroupFieldKey = @"hiddenFromPublic";
static NSString * const kFPetHiddenFromAllFieldKey = @"hiddenFromAll";
static NSString * const kFPetPrivateFieldKey = @"private";
static NSString * const kFPetRangeFieldKey = @"range";
static NSString * const kFPetPhotoFieldKey = @"photo";
static NSString * const kFPetSharePhotoFieldKey = @"share";
static NSString * const kFPetThumbPhotoFieldKey = @"thumbnail";
static NSString * const kFPetTypeFieldKey = @"type";
static NSString * const kFPetCountFieldKey = @"count";
static NSString * const kFPetLeftEyeXFieldKey = @"leftEyeX";
static NSString * const kFPetLeftEyeYFieldKey = @"leftEyeY";
static NSString * const kFPetRightEyeXFieldKey = @"rightEyeX";
static NSString * const kFPetRightEyeYFieldKey = @"rightEyeY";
static NSString * const kFPetNoseXFieldKey = @"noseX";
static NSString * const kFPetNoseYFieldKey = @"noseY";
static NSString * const kFPetLocationFieldKey = @"location";

static NSString * const kFPettingClassKey = @"Petting";
static NSString * const kFPettingUserFieldKey = @"user";
static NSString * const kFPettingPetFieldKey = @"pet";
static NSString * const kFPettingCountFieldKey = @"count";
static NSString * const kFPettingBorrowFieldKey = @"borrow";

static NSString * const lastSeenScreenKey = @"lastSeenScreen";
static NSString * const guideCatShownKey = @"guidecatshown";
static NSString * const adoptGuideCatShownKey = @"adoptguidecatshown";
static NSString * const defaultsFilterDistanceKey = @"filterDistance";
static NSString * const defaultsLocationKey = @"currentLocation";
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";
static NSString * const kPAWFilterDistanceChangeNotification = @"kPAWFilterDistanceChangeNotification";
static NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";
static NSString * const kPAWPostCreatedNotification = @"kPAWPostCreatedNotification";

static double const kPAWFeetToMeters = 0.3048;
static double const kPAWFeetToMiles = 5280.0;
static double const kPAWMetersInAKilometer = 1000.0;
static NSInteger const kMAXLIMITEDBORROWABLECOUNT = 2;
static NSInteger const kMAXLIMITEDWORLDPETCOUNT = 50;

#define kShadowColor1		[UIColor blackColor]
#define kShadowColor2		[UIColor colorWithWhite:0.0 alpha:0.75]
#define kShadowOffset1		CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)
#define kShadowOffset2		CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.0 : 1.0)
#define kShadowBlur1		(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 8.0 : 4.0)
#define kShadowBlur2		(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)

#define M_PI   3.14159265358979323846264338327950288   /* pi */
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)
#define TOTAL_PETTED_COUNT_REFRESH_TIME 3

#endif
