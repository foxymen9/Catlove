//
//  CATPrivacyViewController.m
//  CatLove
//
//  Created by astraea on 8/19/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATPrivacyViewController.h"

@interface CATPrivacyViewController ()

@end

@implementation CATPrivacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"privacy_policy140x29"]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSString* url = @"http://gopetlove.com/privacypolicy.php";
    NSURL* nsUrl = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    [self.webview loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
