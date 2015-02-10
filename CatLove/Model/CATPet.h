//
//  CATPet.h
//  CatLove
//
//  Created by astraea on 6/27/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface CATPet : NSObject
@property (nonatomic, strong) UIImage *petImage;
@property (nonatomic, strong) UIImage *petThumbImage;
@property (nonatomic, strong) UIImage *petShareImage;
@property (nonatomic, strong) NSString *petName;
@property (nonatomic, strong) PFObject *petOwner;
@property (nonatomic, assign) CGPoint lefteyePoint;
@property (nonatomic, assign) CGPoint righteyePoint;
@property (nonatomic, assign) CGPoint nosePoint;
@property (nonatomic, assign) NSString *petID;
@property (nonatomic, assign) NSInteger petedCount;
@property (nonatomic, assign) NSInteger petedCountByMe;
@property (nonatomic, assign) NSInteger petFlagCount;
@property (nonatomic, assign) NSInteger petType;
@property (nonatomic, assign) NSString *petImagePath;
@property (nonatomic, assign) NSString *petThumbImagePath;
@property (nonatomic, strong) UIButton *addNewButton;
@property (nonatomic, assign) BOOL isBorrowed;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, assign) BOOL isHiddenFromGroup;
@property (nonatomic, assign) BOOL isHiddenFromAll;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, strong) PFObject *petObject;

- (UIImage *) thumbnail;
- (id) initWithPFObject:(PFObject *) petObject;
- (id) initWithObjectId:(NSString *) objectId;
- (BOOL) isMyPet;
- (void) getPettedCount;
- (NSString *) getObjectId;

@end
