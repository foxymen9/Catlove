//
//  CATSignInViewController.m
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATSignInViewController.h"
#import "CATAppDelegate.h"
#import "CATPetViewController.h"
#import "CATUtility.h"

@interface CATSignInViewController ()

@end

@implementation CATSignInViewController

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
    
    // Load previous login data
    CATAppDelegate *delegate = (CATAppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.signInViewController = self;
    self.email.text = delegate.email;
    self.password.text = delegate.password;
    self.lockView.hidden = YES;
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:18];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.email becomeFirstResponder];
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

- (IBAction)signIn:(id)sender
{
    self.email.text = [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.email.text == nil || self.email.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User name!" message:@"Please input user name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (self.password.text == nil || self.password.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password!" message:@"Please input the Password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    // Loading UI Show
    self.lockView.hidden = NO;
    
    CATAppDelegate *delegate = (CATAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate signInWithEmail:self.email.text Password:self.password.text];
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
        [self signIn:textField];
    }
    return TRUE;
}

#pragma mark - AppDelegate Result - 

- (void) signedIn:(BOOL)isSuccess error:(NSString *)error
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
        [CATUtility showMessage:@"Please ensure you have entered a valid username and password" title:@"Fail" cancel:@"Dismiss"];
    }
}
@end
