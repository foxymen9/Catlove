//
//  CATViewController.m
//  CatLove
//
//  Created by astraea on 6/24/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATViewController.h"
#import "CATPetViewController.h"
#import "CATAppDelegate.h"

@interface CATViewController ()

@end

@implementation CATViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES];
    [self.tabBarController setHidesBottomBarWhenPushed:YES];

    // If we have a cached user, we'll get it back here
    if ([[CATAppDelegate get].userManager isLoggedIn])
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CATAppDelegate get].firstViewController = self;
	// Do any additional setup after loading the view, typically from a nib.
    self.signinButton.titleLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:18];
    self.signupButton.titleLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:18];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        self.background.image = [UIImage imageNamed:@"splashbg320x480"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction) signIn:(id)sender
{
    
}

- (IBAction) signUp:(id)sender
{
    
}

@end
