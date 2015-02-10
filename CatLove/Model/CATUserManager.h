//
//  CATUserManager.h
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CATUser.h"
#import "Parse/Parse.h"

@protocol CATUserManagerDelegate;

@interface CATUserManager : NSObject

@property (nonatomic, strong) id<CATUserManagerDelegate> delegate;
@property (nonatomic, strong) CATUser* me;
@property (nonatomic, strong) NSString *domain;

- (void) signInWithUsername:(NSString *) username Password:(NSString *) password;
- (void) signUpWithUsername:(NSString *) username Password:(NSString *) password;
- (void) signOut;
- (NSString *) getUserName;
- (void) updateUser:(NSInteger) borrowedCount;
- (NSInteger) borrowedCount;
- (void) updateUser:(NSInteger) maxPettedCount increasedPettedCount:(NSInteger) increasedPettedCount;
- (NSInteger) getTopPettedCount;
- (NSInteger) getTotalPettedCount;
- (BOOL) isLoggedIn;
- (NSString *) getDomainName;
- (BOOL) isPrivateUser;
- (void) setPrivateUser: (BOOL) isPrivate;
- (void) forgotPassword:(NSString *) email;
- (NSString *) getEmail;

@end

@protocol CATUserManagerDelegate <NSObject>

- (void) signedIn:(BOOL) isSuccess error:(NSString *)error;
- (void) signedUp:(BOOL) isSuccess error:(NSString *)error;

@optional
- (void) signedInWithFacebook:(BOOL) isSuccess error:(NSString *)eror;
- (void) loadedUserData:(BOOL) isSuccess error:(NSString *)error;

@end
