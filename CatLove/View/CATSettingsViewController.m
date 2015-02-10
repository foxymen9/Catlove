//
//  CATSettingsViewController.m
//  CatLove
//
//  Created by astraea on 7/18/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATSettingsViewController.h"
#import "CATAppDelegate.h"
#import "CATViewController.h"
#import "CATUtility.h"
#import "CATConstant.h"
#import "MBProgressHUD.h"

@interface CATSettingsViewController ()
@property (readwrite, nonatomic, strong) FBFrictionlessRecipientCache *friendCache;
@end

@implementation CATSettingsViewController

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
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Settings29x86"]];
    // Do any additional setup after loading the view.
    [self.scrollView setContentSize:CGSizeMake(320, 680)];
    self.email.text = [[CATAppDelegate get].userManager getEmail];
    if (self.email.text == nil || self.email.text.length == 0)
        self.email.text = @"Add Email";
    self.radius.minimumValue = 1;
    self.radius.maximumValue = 100;
    if ((long)[CATAppDelegate get].searchDistance < 100)
        self.radiusLabel.text = [NSString stringWithFormat:@"%ld Mi", (long)[CATAppDelegate get].searchDistance];
    else
        self.radiusLabel.text = @"Unlimited";
    [self.radius setValue:[CATAppDelegate get].searchDistance animated:YES];
    if ([[CATAppDelegate get] isPurchased])
    {
        _buyView.hidden = YES;
        _restoreView.hidden = YES;
    }
    self.isPurchased = [[CATAppDelegate get] isPurchased];
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[CATAppDelegate get] updateLastSeenScreen:3];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0x7E green:0xE1 blue:0xD3 alpha:1];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.privateSwitch setOn:[[CATAppDelegate get].userManager isPrivateUser]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Button Actions -

- (IBAction)signOut:(id)sender
{
    [[CATAppDelegate get] signOut];
    
    NSString * storyboardName = @"Main_iPhone";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CATViewController *firstViewController = [storyboard instantiateViewControllerWithIdentifier:@"CATViewController"];
    firstViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:firstViewController animated:YES];
}

- (IBAction)changeEmail:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input new email and current password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    av.delegate = self;
    av.tag = 100;
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    // Alert style customization
    [[av textFieldAtIndex:0] setSecureTextEntry:YES];
    [[av textFieldAtIndex:1] setSecureTextEntry:NO];
    [[av textFieldAtIndex:0] setPlaceholder:@"Password"];
    [[av textFieldAtIndex:1] setPlaceholder:@"New email"];
    [av show];
}

- (IBAction)changePassword:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input current password and new password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    av.delegate = self;
    av.tag = 101;
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    // Alert style customization
    [[av textFieldAtIndex:0] setSecureTextEntry:YES];
    [[av textFieldAtIndex:1] setSecureTextEntry:YES];
    [[av textFieldAtIndex:0] setPlaceholder:@"Current password"];
    [[av textFieldAtIndex:1] setPlaceholder:@"New password"];
    [av show];
}

- (IBAction)inviteFacebookFriends:(id)sender
{
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Please come play PetLove with me!"
                                                    title:@"Invite a Friend"
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (result == FBWebDialogResultDialogCompleted) {
                                                          NSLog(@"Web dialog complete: %@", resultURL);
                                                      } else {
                                                          NSLog(@"Web dialog not complete, error: %@", error.description);
                                                      }
                                                  }
                                              friendCache:self.friendCache];

}

- (IBAction)restorePurchases:(id)sender
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// Set the hud to display with a color
	HUD.color = [UIColor colorWithRed:0.99 green:0.39 blue:0.39 alpha:0.90];
	
	HUD.delegate = self;
    HUD.labelText = @"Connecting iTunes Store...";
    [HUD show:YES];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)followMoreCats:(id)sender
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// Set the hud to display with a color
	HUD.color = [UIColor colorWithRed:0.99 green:0.39 blue:0.39 alpha:0.90];
	
	HUD.delegate = self;
    HUD.labelText = @"Connecting iTunes Store...";
    [HUD show:YES];

    if ([SKPaymentQueue canMakePayments])
    {
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:@"_follow_unlimited_cats_no_ads_"]];
        request.delegate = self;
        
        [request start];
    }
    else
        NSLog(@"Please enable In App Purchase in Settings");

}

- (IBAction)sendFeedback:(id)sender
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setToRecipients:@[@"tiff@gopetlove.com"]];
    [picker setSubject:@"PetLove Feedback!"];
    NSString *emailBody = @"";
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (IBAction)thefurrtographer:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://thefurrtographer.com/"];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    if ((long)sender.value < 100)
        self.radiusLabel.text = [NSString stringWithFormat:@"%ld Mi", (long)sender.value];
    else
        self.radiusLabel.text = @"Unlimited";
    [[CATAppDelegate get] setFilterDistance:(NSInteger)sender.value];
}

- (IBAction)switchChanged:(id)sender
{
    NSString *privateMessage = nil;
    if (self.privateSwitch.on)
        privateMessage = @"You're about to turn privacy on. This means only you will be able to see your pets. Are you sure you want to turn privacy on?";
    else
        privateMessage = @"You're about to turn privacy off. This means anyone can see your pets. Are you sure you want to turn privacy off?";
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:privateMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 102;
    [alert show];
}

- (void) setPrivateUser
{
    [[CATAppDelegate get].userManager setPrivateUser:self.privateSwitch.on];
}

#pragma mark - MailComposeDelegate - 

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result != MFMailComposeResultCancelled)
    {
        NSString *message = @"";
        
        if (result ==  MFMailComposeResultSaved)
        {
            message = @"Feedback mail saved.";
        }
        else if (result == MFMailComposeResultSent)
        {
            message = @"Feedback mail sent.";
        }
        else if (result == MFMailComposeResultFailed)
        {
            message = @"Feedback mail sending failed.";
        }
        else
        {
            message = @"Feedback mail not sent.";
        }
        
        UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [stop show];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIAlertView Delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (alertView.tag == 100)
        {
            NSString *pasword = [[alertView textFieldAtIndex:0] text];
            NSString *newEmail = [[alertView textFieldAtIndex:1] text];
            if ([CATUtility validateEmail:newEmail] == NO)
            {
                UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [stop show];
            }
            else
            {
                if ([[CATAppDelegate get] changeEmail:newEmail password:pasword] == NO)
                {
                    UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"Fail to change email" message:@"Please input valid password or email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [stop show];
                }
                else
                {
                    self.email.text = newEmail;
                }
            }
        }
        else if (alertView.tag == 101)
        {
            NSString *currentPassword = [[alertView textFieldAtIndex:0] text];
            NSString *newPassword = [[alertView textFieldAtIndex:1] text];
            if (newPassword.length <= 0)
            {
                UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input new password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [stop show];
            }
            else
            {
                if ([[CATAppDelegate get] changePassword:currentPassword newPassword:newPassword] == NO)
                {
                    UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input correct current password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [stop show];
                }
                else
                {
                    UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:@"Your password has been changed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [stop show];
                }
            }
        }
        else if (alertView.tag == 102)
        {
            [self performSelectorInBackground:@selector(setPrivateUser) withObject:nil];
        }
    }
    else if (buttonIndex == 0)
    {
        if (alertView.tag == 102)
        {
            [self.privateSwitch setOn:!self.privateSwitch.on];
        }
    }
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        _product = products[0];
        SKPayment *payment = [SKPayment paymentWithProduct:_product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        self.buyView.hidden = NO;
    } else {
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    [HUD hide:YES];
    NSLog(@"Updated Transactions");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [self unlockFeature];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                NSLog(@"Transaction status: %d", transaction.transactionState);
                break;
        }
    }
}

-(void)unlockFeature
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    [defaultData setInteger:1 forKey:@"purchased"];
	[defaultData synchronize];
    
    _buyView.hidden = YES;
    _restoreView.hidden = YES;
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [HUD hide:YES];
    NSLog(@"%@",queue );
    NSLog(@"Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        NSLog (@"product id is %@" , productID);
        [self unlockFeature];
    }
}
@end
