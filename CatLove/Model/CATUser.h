//
//  CATUser.h
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
@interface CATUser : NSObject

@property (nonatomic, strong) PFUser *mePF;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) BOOL privateUser;

- (id) initWithPFUser: (PFUser*) user;

@end
