//
//  CATRegisterViewController.m
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATRegisterViewController.h"
#import "CATUtility.h"
#import "CATAppDelegate.h"
#import "CATPetViewController.h"

@interface CATRegisterViewController ()

@end

@implementation CATRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CATAppDelegate *delegate = (CATAppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.signUpViewController = self;
//    self.email.text = @"qinghan910@hotmail.com";
//    self.password.text = @"petlove";
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:18];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.email becomeFirstResponder];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions - 

- (IBAction) onSignUp
{
    self.email.text = [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.password.text == nil || self.password.text.length == 0)
    {
        [CATUtility showMessage:@"Please input the Password." title:@"Password!" cancel:@"Dismiss"];
        return;
    }
    
    if (self.email.text == nil || self.email.text.length == 0)
    {
        [CATUtility showMessage:@"Please input user name." title:@"User name!" cancel:@"Dismiss"];
        return;
    }
    
    self.emailString = self.email.text;
    self.passwordString = self.password.text;
    
    // Loading UI Show
    self.lockView.hidden = NO;

    CATAppDelegate *delegate = (CATAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate signUpWithEmail:self.email.text Password:self.password.text];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField Delegate -

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.email) {
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [self onSignUp];
    }
    return TRUE;
}

#pragma mark - AppDelegate Result - 

- (void) signedUp:(BOOL)isSuccess error:(NSString *)error
{
    // Loading UI Hide
    self.lockView.hidden = YES;
    
    if (isSuccess)
    {
        NSString * storyboardName = @"Main_iPhone";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UITabBarController * tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
                                                 forState:UIControlStateSelected];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
                                                 forState:UIControlStateNormal];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbarbg80x49"]];
        UITabBarItem *tabBarItem0 = [tabBarController.tabBar.items objectAtIndex:0];
        tabBarItem0.image = [[UIImage imageNamed:@"nearby30x30-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem0.selectedImage = [[UIImage imageNamed:@"nearby30x30-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *tabBarItem1 = [tabBarController.tabBar.items objectAtIndex:1];
        tabBarItem1.image = [[UIImage imageNamed:@"adopted30x30"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem1.selectedImage = [[UIImage imageNamed:@"adopted30x30"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *tabBarItem2 = [tabBarController.tabBar.items objectAtIndex:2];
        tabBarItem2.image = [[UIImage imageNamed:@"mycats30x30-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem2.selectedImage = [[UIImage imageNamed:@"mycats30x30-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *tabBarItem3 = [tabBarController.tabBar.items objectAtIndex:3];
        tabBarItem3.image = [[UIImage imageNamed:@"settings30x30-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem3.selectedImage = [[UIImage imageNamed:@"settings30x30-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.navigationController pushViewController:tabBarController animated:YES];
    }
    else
    {
        [CATUtility showMessage:error title:@"Fail" cancel:@"Dismiss"];
    }
}
@end
