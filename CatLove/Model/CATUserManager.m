//
//  CATUserManager.m
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATUserManager.h"
#import "CATConstant.h"

@implementation CATUserManager

- (BOOL) isLoggedIn
{
    return [PFUser currentUser] != nil;
}

- (NSString *) getDomainName
{
    if (![self isLoggedIn])
        return nil;
    
    if (self.domain != nil)
        return self.domain;
    
    PFQuery *query = [PFQuery queryWithClassName:kFSettingsClassKey];
    [query whereKey:kFSettingsKeyFieldKey equalTo:kFSettingsKeyValueKey];
    PFObject *object = [query getFirstObject];
    
    self.domain = [object objectForKey:kFSettingsValueFieldKey];
    return self.domain;
}

- (void) signInWithUsername:(NSString *) username Password:(NSString *) password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        BOOL isSuccess;
        NSString *errorString;
		if (user) {
            isSuccess = YES;
		} else {
			if (error == nil)
            {
				//! the username or password is probably wrong.
                errorString = @"Please make sure to input the valid username or password.";
			}
            else
            {
                NSNumber *numberErrorCode = [[error userInfo] objectForKey:@"code"];
                if (numberErrorCode.integerValue == 101)
                    errorString = @"Please make sure to input the valid username or password.";
                else
                    errorString = @"Please make sure to be connected Internet.";
			}
            
            NSLog(@"%@", error);
            isSuccess = NO;
		}
        if (isSuccess)
        {
            self.me = [[CATUser alloc] initWithPFUser:user];
        }
        
        [self.delegate signedIn:isSuccess error:errorString];
	}];
}

- (void) signUpWithUsername:(NSString *) username Password:(NSString *) password
{
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSString *errorString;
        if (!error)
        {
            succeeded = YES;
        }
        else
        {
            succeeded = NO;

            errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Sign up error occured:%@", errorString);
        }
        
        [self.delegate signedUp:succeeded error:errorString];
    }];
}

- (void) signOut
{
    [PFUser logOut];
}

- (void) forgotPassword:(NSString *) email
{
    [PFUser requestPasswordResetForEmailInBackground:email];
}

- (NSString *) getEmail
{
    return [PFUser currentUser].email;
}

- (NSString *) getUserName
{
    return [PFUser currentUser].username;
}

- (BOOL) isWorldUser
{
    return [[PFUser currentUser][kFUserRoleFieldKey] integerValue] == 1;
}

- (BOOL) isPrivateUser
{
    return [[PFUser currentUser][kFUserPrivateFieldKey] boolValue] == YES;
}

- (void) setPrivateUser: (BOOL) isPrivate
{
    //! make user private
    [PFUser currentUser][kFUserPrivateFieldKey] = @(isPrivate);
    [[PFUser currentUser] save];
    
    //! make all users pets private
    //! load pet array of current user
    PFQuery *query = [PFQuery queryWithClassName:kFPetClassKey];
    [query whereKey:kFPetOwnerFieldKey equalTo:[PFUser currentUser]];
    [query whereKey:kFPetDeletedFieldKey notEqualTo:@YES];
    NSArray *objectArray = [query findObjects];
    
    if ([objectArray count] <= 0)
    {
        NSLog(@"You have no pets to make private.");
    }
    else
    {
        for (PFObject *petObj in objectArray)
        {
            petObj[kFPetPrivateFieldKey] = @(isPrivate);
            [petObj save];
        }
    }
}

- (NSInteger) borrowedCount
{
//    PFQuery *query= [PFUser query];
//    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
//    PFObject *object = [query getFirstObject];
//
    return [[[PFUser currentUser] objectForKey:kFUserBorrowedCountFieldKey] integerValue];
}

- (void) updateUser:(NSInteger) borrowedCount
{
    [PFUser currentUser][kFUserBorrowedCountFieldKey] = @(borrowedCount);
    [[PFUser currentUser] save];
}

- (void) updateUser:(NSInteger) maxPettedCount increasedPettedCount:(NSInteger) increasedPettedCount
{
    if ([[PFUser currentUser][kFUserMaxPettedCountFieldKey] integerValue] < maxPettedCount)
        [PFUser currentUser][kFUserMaxPettedCountFieldKey] = @(maxPettedCount);
    [PFUser currentUser][kFUserTotalPettedCountFieldKey] = @(increasedPettedCount + [[PFUser currentUser][kFUserTotalPettedCountFieldKey] integerValue]);
    [[PFUser currentUser] saveInBackground];
}

- (NSInteger) getTopPettedCount
{
    return [[PFUser currentUser][kFUserMaxPettedCountFieldKey] integerValue];
}

- (NSInteger) getTotalPettedCount
{
    return [[PFUser currentUser][kFUserTotalPettedCountFieldKey] integerValue];
}

@end
