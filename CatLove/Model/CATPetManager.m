//
//  CATPetManager.m
//  CatLove
//
//  Created by astraea on 7/20/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATPetManager.h"
#import "Parse/Parse.h"
#import "CATConstant.h"
#import "CATPet.h"
#import "CATUtility.h"
#import "CATAppDelegate.h"

@implementation CATPetManager

- (id) init
{
    if (self) {
        self.myPets = nil;
        self.nearbyPets = nil;
        self.borrowedPets = nil;
    }
    return self;
}

- (NSMutableArray *) getNearbyPetArray:(BOOL) isForceReload location:(CLLocation *) location radius:(float) radius
{
    if (location == nil)
    {
        self.nearbyPets = nil;
        return nil;
    }
    if (self.nearbyPets == nil || isForceReload)
    {
        if (!self.nearbyPets)
            self.nearbyPets = [NSMutableArray new];
        else
            [self.nearbyPets removeAllObjects];
        
        //! load nearby pet array of current user
        NSDate *methodStart = [NSDate date];
        PFQuery *query = [PFQuery queryWithClassName:kFPetClassKey];
        [query whereKey:kFPetOwnerFieldKey notEqualTo:[PFUser currentUser]];
        if (radius < 100)
            [query whereKey:kFPetLocationFieldKey nearGeoPoint:[PFGeoPoint geoPointWithLocation:location] withinMiles:radius];
        [query whereKey:kFPetDeletedFieldKey notEqualTo:@YES];
        [query whereKey:kFPetHiddenFromGroupFieldKey notEqualTo:@YES];
        [query whereKey:kFPetPrivateFieldKey notEqualTo:@YES];
        [query orderByDescending:@"createdAt"];
        NSArray *objectArray = [query findObjects];
        NSMutableArray *objectIdArray = [NSMutableArray new];
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];

        methodStart = [NSDate date];
        if ([objectArray count] <= 0)
        {
            NSLog(@"You have no pet nearby %f miles.", radius);
        }
        else
        {
            for (PFObject *petObj in objectArray)
            {
                CATPet *pet = [[CATPet alloc] initWithPFObject:petObj];
                [self.nearbyPets addObject:pet];
                [objectIdArray addObject:petObj.objectId];
            }
        }
        methodFinish = [NSDate date];
        executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        
        //! load pets of worldwide users
        query = [PFQuery queryWithClassName:kFPetClassKey];
        [query whereKey:kFPetOwnerFieldKey notEqualTo:[PFUser currentUser]];
        if (objectIdArray.count > 0)
            [query whereKey:@"objectId" notContainedIn:objectIdArray];
        [query whereKey:kFPetDeletedFieldKey notEqualTo:@YES];
        [query whereKey:kFPetRangeFieldKey equalTo:@1];
        [query whereKey:kFPetHiddenFromGroupFieldKey notEqualTo:@YES];
        [query whereKey:kFPetPrivateFieldKey notEqualTo:@YES];
        [query orderByDescending:@"createdAt"];
        [query setLimit:kMAXLIMITEDWORLDPETCOUNT];
        objectArray = [query findObjects];
        
        if ([objectArray count] <= 0)
        {
            NSLog(@"There is no world wide pets");
        }
        else
        {
            for (PFObject *petObj in objectArray)
            {
                CATPet *pet = [[CATPet alloc] initWithPFObject:petObj];
                [self.nearbyPets addObject:pet];
            }
        }
    }
    return self.nearbyPets;
}

- (NSMutableArray *) getMyPetArray:(BOOL) isForceReload
{
    if (self.myPets == nil || isForceReload)
    {
        if (!self.myPets)
            self.myPets = [NSMutableArray new];
        else
            [self.myPets removeAllObjects];
        
        //! load pet array of current user
        PFQuery *query = [PFQuery queryWithClassName:kFPetClassKey];
        [query whereKey:kFPetOwnerFieldKey equalTo:[PFUser currentUser]];
        [query whereKey:kFPetDeletedFieldKey notEqualTo:@YES];
        [query whereKey:kFPetHiddenFromAllFieldKey notEqualTo:@YES];
        [query orderByDescending:@"createdAt"];
        NSArray *objectArray = [query findObjects];

        if ([objectArray count] <= 0)
        {
            NSLog(@"You have no pet.");
        }
        else
        {
            for (PFObject *petObj in objectArray)
            {
                CATPet *pet = [[CATPet alloc] initWithPFObject:petObj];
                [self.myPets addObject:pet];
            }
        }
    }
    return self.myPets;
}

- (NSMutableArray *) getBorrowedPetArray:(BOOL) isForceReload
{
    if (self.borrowedPets == nil || isForceReload)
    {
        if (!self.borrowedPets)
            self.borrowedPets = [NSMutableArray new];
        else
            [self.borrowedPets removeAllObjects];
        
        //! load borrowed pet array of current user
        PFQuery *query = [PFQuery queryWithClassName:kFPettingClassKey];
        [query whereKey:kFPettingUserFieldKey equalTo:[PFUser currentUser]];
        [query whereKey:kFPettingBorrowFieldKey equalTo:@YES];
        [query whereKey:kFPetHiddenFromGroupFieldKey notEqualTo:@YES];
        [query orderByDescending:@"createdAt"];
        NSArray *objectArray = [query findObjects];
        
        if ([objectArray count] <= 0)
        {
            NSLog(@"You have no pet borrowed.");
        }
        else
        {
            for (PFObject *petObj in objectArray)
            {
                NSLog(@"Pet Object Id:%@", [petObj[kFPettingPetFieldKey] objectId]);
                if ([petObj[kFPettingPetFieldKey] objectId])
                {
                    PFQuery *query2 = [PFQuery queryWithClassName:kFPetClassKey];
                    PFObject *petObject = [query2 getObjectWithId:[petObj[kFPettingPetFieldKey] objectId]];
                    if (petObject)
                    {
                        CATPet *pet = [[CATPet alloc] initWithPFObject:petObject];
                        [self.borrowedPets addObject:pet];
                    }
                }
            }
        }
    }
    return self.borrowedPets;
}

- (BOOL) addPet:(CATPet *) pet location:(CLLocation *) location progress:(MBProgressHUD *) HUD
{
    pet.petOwner = [PFUser currentUser];
    
    PFObject *petObject = [PFObject objectWithClassName:kFPetClassKey];
    petObject[kFPetNameFieldKey] = pet.petName;
    petObject[kFPetLocationFieldKey] = [PFGeoPoint geoPointWithLocation:location];
    petObject[kFPetCountFieldKey] = @0;
    petObject[kFPetLeftEyeXFieldKey] = @(pet.lefteyePoint.x);
    petObject[kFPetLeftEyeYFieldKey] = @(pet.lefteyePoint.y);
    petObject[kFPetRightEyeXFieldKey] = @(pet.righteyePoint.x);
    petObject[kFPetRightEyeYFieldKey] = @(pet.righteyePoint.y);
    petObject[kFPetNoseXFieldKey] = @(pet.nosePoint.x);
    petObject[kFPetNoseYFieldKey] = @(pet.nosePoint.y);
    petObject[kFPetOwnerFieldKey] = [PFUser currentUser];
    petObject[kFPetTypeFieldKey] = @0;
    petObject[kFPetDeletedFieldKey] = @NO;
    petObject[kFPetPrivateFieldKey] = @([[PFUser currentUser][kFUserPrivateFieldKey] boolValue]);
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    PFObject *object = [query getFirstObject];
    if ([[object objectForKey:kFUserRoleFieldKey] integerValue] == 1)
    {
        petObject[kFPetRangeFieldKey] = @1;
    }
    petObject[kFPetPhotoFieldKey] = [[CATAppDelegate get].backendManager uploadPicture:pet.petImage strName:pet.petName];
    petObject[kFPetThumbPhotoFieldKey] = [[CATAppDelegate get].backendManager uploadPicture:pet.petThumbImage strName:[NSString stringWithFormat:@"%@_thumbnail", pet.petThumbImage]];
    petObject[kFPetSharePhotoFieldKey] = [[CATAppDelegate get].backendManager uploadPicture:pet.petShareImage strName:[NSString stringWithFormat:@"%@_share", pet.petName]];
    [petObject save];
    pet.petObject = petObject;
    pet.petImagePath = petObject[kFPetPhotoFieldKey];
    pet.petThumbImagePath = petObject[kFPetThumbPhotoFieldKey];
    pet.petID = [petObject objectId];
    [self.myPets addObject:pet];
    
    return YES;
}

- (NSInteger) getIncreasedPettedCount:(CATPet *) pet
{
    return pet.petedCount - [pet.petObject[kFPetCountFieldKey] integerValue];
}

- (BOOL) reportPet:(CATPet *) pet
{
    pet.petFlagCount++;
    pet.petObject[kFPetFlagCountFieldKey] = @(pet.petFlagCount);
    [pet.petObject save];
    return YES;
}

- (void) refreshPettedCount:(NSString *) petID
{
    PFQuery *query = [PFQuery queryWithClassName:kFPetClassKey];
    [query getObjectInBackgroundWithId:petID block:^(PFObject *object, NSError *error) {
        [_delegate refreshedPettedCount:[object[kFPetCountFieldKey] integerValue]];
    }];
}

- (BOOL) updatePet:(CATPet *) pet increasedPettedCount:(NSInteger) increasedPettedCount
{
    PFQuery *query = [PFQuery queryWithClassName:kFPettingClassKey];
    [query whereKey:kFPettingUserFieldKey equalTo:[PFUser currentUser]];
    [query whereKey:kFPettingPetFieldKey equalTo:pet.petObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //! update petting count and borrow flag
        PFObject *petting = nil;
        if (objects == nil || [objects count] <= 0)
        {
            petting = [PFObject objectWithClassName:kFPettingClassKey];
            petting[kFPettingCountFieldKey] = @(pet.petedCountByMe);
            petting[kFPettingPetFieldKey] = pet.petObject;
            petting[kFPettingUserFieldKey] = [PFUser currentUser];
            petting[kFPettingBorrowFieldKey] = @(pet.isBorrowed);
        }
        else
        {
            petting = [objects objectAtIndex:0];
            petting[kFPettingBorrowFieldKey] = @(pet.isBorrowed);
            petting[kFPettingCountFieldKey] = @(pet.petedCountByMe);
        }
        [petting saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //! update total petted count
            if (succeeded == YES && increasedPettedCount > 0)
            {
                //! load current petted count again
                PFQuery *query = [PFQuery queryWithClassName:kFPetClassKey];
                [query getObjectInBackgroundWithId:pet.petID block:^(PFObject *object, NSError *error) {
                    pet.petObject[kFPetCountFieldKey] = @([object[kFPetCountFieldKey] integerValue] + increasedPettedCount);
                    [pet.petObject saveInBackground];
                }];
            }
        }];

    }];
    return YES;
}

- (BOOL) removePets:(NSArray *) petArray
{
    // remove from pet table
    NSMutableArray *petIdArray = [NSMutableArray new];
    for (CATPet *pet in petArray)
    {
        [petIdArray addObject:pet.petObject.objectId];
    }
    PFQuery *query = [PFQuery queryWithClassName:kFPetClassKey];
    [query whereKey:@"objectId" containedIn:petIdArray];
    NSArray *petObjectArray = [query findObjects];
    for (PFObject *petObject in petObjectArray)
    {
        petObject[kFPetDeletedFieldKey] = @YES;
        [petObject save];
    }
    
    return YES;
}

- (BOOL) releasePets:(NSArray *) petArray
{
    NSMutableArray *petObjectArray = [NSMutableArray new];
    for (CATPet *pet in petArray)
    {
        [petObjectArray addObject:pet.petObject];
    }
    PFQuery *query = [PFQuery queryWithClassName:kFPettingClassKey];
    [query whereKey:kFPettingUserFieldKey equalTo:[PFUser currentUser]];
    [query whereKey:kFPettingPetFieldKey containedIn:petObjectArray];
    NSArray *objectArray = [query findObjects];
    for (PFObject *petObject in objectArray)
    {
        petObject[kFPettingBorrowFieldKey] = @NO;
        [petObject save];
    }
    
    return YES;
}

- (void) clearAll
{
    [self.nearbyPets removeAllObjects];
    [self.borrowedPets removeAllObjects];
    [self.myPets removeAllObjects];
    self.nearbyPets = nil;
    self.borrowedPets = nil;
    self.myPets = nil;
}

- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath{
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        
        // If we have the right type of file, add it to the list
        // Make sure to prepend the directory path
        if([[filePath pathExtension] isEqualToString:type]){
            [filePaths addObject:[directoryPath stringByAppendingPathComponent:filePath]];
        }
    }
    
    return filePaths;
}

- (void) addFurrTOGRAPHERPhotos
{
    NSArray *filepaths = [self recursivePathsForResourcesOfType:@"jpg" inDirectory:[[NSBundle mainBundle] bundlePath]];
    NSInteger i = 0;
    for (NSString *filepath in filepaths) {
        NSString *imageName = [[filepath lastPathComponent] stringByDeletingPathExtension];
//        UIImage *image = [UIImage imageNamed:imageName];
        UIImage *image = [UIImage imageWithContentsOfFile:filepath];
        if (image != nil)
        {
            NSLog(@"%f Done: %@ is being processed", (float)i / 10000.0f, imageName);
            CATPet* newPet = [CATPet new];
            newPet.petName = imageName;
            newPet.lefteyePoint = CGPointMake(98, 201.5);
            newPet.righteyePoint = CGPointMake(176, 213.5);
            newPet.nosePoint = CGPointMake(96.5, 258);
            newPet.petShareImage = [CATUtility fixOrientation:image];
            
            CGFloat thumbWidth, thumbHeight, shareWidth, shareHeight;
            if (image.size.width > image.size.height)
            {
                thumbHeight = 100;
                shareHeight = 1136;
                thumbWidth = thumbHeight * (image.size.width / image.size.height);
                shareWidth = shareHeight * (image.size.width / image.size.height);
            }
            else
            {
                thumbWidth = 100;
                shareWidth = 1136;
                thumbHeight = thumbWidth * (image.size.height / image.size.width);
                shareHeight = shareWidth * (image.size.height / image.size.width);
            }
            newPet.petThumbImage = [CATUtility thumbnail:image scaledToSize:CGSizeMake(thumbWidth, thumbHeight)];
            newPet.petImage = [CATUtility thumbnail:image scaledToSize:CGSizeMake(shareWidth, shareHeight)];
            [self addPet:newPet location:[CATAppDelegate get].currentLocation progress:nil];
            newPet = nil;
        }
    }
    NSLog(@"All Done!");
}

@end
