//
//  CATUser.m
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATUser.h"
#import "CATConstant.h"

@implementation CATUser
- (id) initWithPFUser: (PFUser*) user
{
    if (self) {
        self.mePF = user;
        
        self.email = user.email;
        self.password = user.password;
        self.role = [user[kFUserRoleFieldKey] integerValue];
        self.privateUser = [user[kFUserPrivateFieldKey] boolValue];
    }
    return self;
}

@end
