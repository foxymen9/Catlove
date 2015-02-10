//
//  CATForgotPasswordViewController.m
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATForgotPasswordViewController.h"
#import "CATAppDelegate.h"
#import "CATPetViewController.h"
#import "CATUtility.h"

@interface CATForgotPasswordViewController ()

@end

@implementation CATForgotPasswordViewController

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
    self.lockView.hidden = YES;
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

- (IBAction)forgotPassword:(id)sender
{
    self.email.text = [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.email.text == nil || self.email.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email address!" message:@"Please input Email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 100;
        [alert show];
        return;
    }

    CATAppDelegate *delegate = (CATAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate forgotPassword:self.email.text];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Request Sent" message:@"Please check your email and click the link to reset your password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 101;
    [alert show];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField Delegate - 

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.email) {
        [self forgotPassword:textField];
    }
    return TRUE;
}

#pragma mark - UIAlertView Delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"])
    {
        if (alertView.tag == 101)
            [self.navigationController popViewControllerAnimated:YES];
    }
}

@end