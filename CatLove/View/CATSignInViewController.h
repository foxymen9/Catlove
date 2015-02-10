//
//  CATSignInViewController.h
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CATSignInViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) IBOutlet UIView *lockView;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

- (void) signedIn:(BOOL)isSuccess error:(NSString *)error;
@end
