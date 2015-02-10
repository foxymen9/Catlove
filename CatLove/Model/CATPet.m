//
//  CATPet.m
//  CatLove
//
//  Created by astraea on 6/27/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATPet.h"
#import "CATConstant.h"

@implementation CATPet

- (id) init
{
    if (self) {
        self.petImage = nil;
        self.petThumbImage = nil;
        self.lefteyePoint = CGPointMake(0, 0);
        self.righteyePoint = CGPointMake(0, 0);
        self.nosePoint = CGPointMake(0, 0);
        self.petID = nil;
        self.petedCount = 0;
        self.petedCountByMe = 0;
        self.petImagePath = nil;
        self.addNewButton = nil;
        self.petOwner = nil;
        self.petName = nil;
        self.petObject = nil;
        self.isBorrowed = NO;
        self.isDeleted = NO;
        self.isHiddenFromAll = NO;
        self.isHiddenFromGroup = NO;
    }
    return self;
}

- (id) initWithObjectId:(NSString *) objectId
{
    if (self) {
        PFQuery *query = [PFQuery queryWithClassName:kFPetClassKey];
        PFObject *petObject = [query getObjectWithId:objectId];
        
        return [self initWithPFObject:petObject];
    }
    return self;
}

- (id) initWithPFObject:(PFObject *) petObject
{
    if (self) {
        NSNumber *leftEyePointXNumber = [petObject objectForKey:kFPetLeftEyeXFieldKey];
        NSNumber *leftEyePointYNumber = [petObject objectForKey:kFPetLeftEyeYFieldKey];
        NSNumber *rightEyePointXNumber = [petObject objectForKey:kFPetRightEyeXFieldKey];
        NSNumber *rightEyePointYNumber = [petObject objectForKey:kFPetRightEyeYFieldKey];
        NSNumber *nosePointXNumber = [petObject objectForKey:kFPetNoseXFieldKey];
        NSNumber *nosePointYNumber = [petObject objectForKey:kFPetNoseYFieldKey];
        self.lefteyePoint = CGPointMake([leftEyePointXNumber floatValue], [leftEyePointYNumber floatValue]);
        self.righteyePoint = CGPointMake([rightEyePointXNumber floatValue], [rightEyePointYNumber floatValue]);
        self.nosePoint = CGPointMake([nosePointXNumber floatValue], [nosePointYNumber floatValue]);
        self.petID = [petObject objectId];
        self.petOwner = [petObject objectForKey:kFPetOwnerFieldKey];
        self.petName = [petObject objectForKey:kFPetNameFieldKey];
        self.petType = [petObject[kFPetTypeFieldKey] integerValue];
        self.petedCount= [petObject[kFPetCountFieldKey] integerValue];
        self.petObject = petObject;
        self.isDeleted = [petObject[kFPetDeletedFieldKey] boolValue];
        self.isHiddenFromAll = [petObject[kFPetHiddenFromAllFieldKey] boolValue];
        self.isHiddenFromGroup = [petObject[kFPetHiddenFromGroupFieldKey] boolValue];
        self.isPrivate = [petObject[kFPetPrivateFieldKey] boolValue];
        self.petFlagCount = [petObject[kFPetFlagCountFieldKey] integerValue];
        self.petImagePath = petObject[kFPetPhotoFieldKey];
        self.petThumbImagePath = petObject[kFPetThumbPhotoFieldKey];
        self.addNewButton = nil;
    }
    return self;
}

- (void) getPettedCount
{
    if (self.petObject == nil)
        return;
    
    //! calculate all petted count
    PFQuery *query = [PFQuery queryWithClassName:kFPettingClassKey];
    [query whereKey:kFPettingUserFieldKey equalTo:[PFUser currentUser]];
    [query whereKey:kFPettingPetFieldKey equalTo:self.petObject];
    NSArray *objectArray = [query findObjects];
    if (objectArray == nil)
    {
        NSLog(@"You never pet this Cat yet!");
    }
    else
    {
        if ([objectArray count] > 0)
        {
            PFObject *petting = [objectArray objectAtIndex:0];
            self.petedCountByMe = [petting[kFPettingCountFieldKey] integerValue];
            self.isBorrowed = [petting[kFPettingBorrowFieldKey] boolValue];
        }
    }
}

- (UIImage *) thumbnail
{
    if (self.petImage == nil)
        return nil;
    
    float oldWidth = self.petImage.size.width;
    float scaleFactor = 200 / oldWidth;
    
    float newHeight = self.petImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self.petImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL) isMyPet
{
    return [self.petOwner.objectId isEqualToString:[PFUser currentUser].objectId];
}

- (NSString *) getObjectId
{
    return self.petObject.objectId;
}
@end
