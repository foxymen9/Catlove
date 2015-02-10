//
//  CATPetDetailViewController.m
//  CatLove
//
//  Created by astraea on 6/29/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATPetDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "CATOpenInAppActivity.h"
#import <GameKit/GameKit.h>
#import "Flurry.h"
#import "CATPetManager.h"
#import "CATAppDelegate.h"
#import "MBProgressHUD.h"
#import "CATUtility.h"
#import "CATConstant.h"
#import "GHBSpriteAnimationLayer.h"
#import <SpriteKit/SpriteKit.h>
#import "THLabel.h"
#import "CATPetDetailScene.h"

@interface CATPetDetailViewController ()
{
    long long expectedLength;
	long long currentLength;
    MBProgressHUD *HUD;
    NSMutableData *receivedData;
    BOOL animating;
}
@property (nonatomic, assign) SystemSoundID pet10Sound;
@property (nonatomic, assign) SystemSoundID pet20Sound;
@property (nonatomic, assign) SystemSoundID pet01Sound;
@property (nonatomic, assign) SystemSoundID pet02Sound;
@property (nonatomic, assign) CGPoint firstPosition;
@end

@implementation CATPetDetailViewController

- (void)initSound
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/meow001.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &_pet10Sound);
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/purr001.mp3", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &_pet20Sound);
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/pet1.m4a", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &_pet01Sound);
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/pet2.m4a", [[NSBundle mainBundle] resourcePath]]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &_pet02Sound);
}

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

#pragma mark -
#pragma mark NSURLConnectionDelegete -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	expectedLength = MAX([response expectedContentLength], 1);
	currentLength = 0;
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	currentLength += [data length];
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [UIImage imageWithData:receivedData];
//    [self.petImageView performSelectorOnMainThread: @selector(setImage:) withObject: image waitUntilDone: YES];
//    [self.scene loadPetImage:image];
    [self.scene performSelectorOnMainThread:@selector(loadPetImage:) withObject:image waitUntilDone:YES];
    
    self.selectedPet.petImage = image;
    receivedData = nil;

    [self.selectedPet getPettedCount];
    self.borrowButton.hidden = [self.selectedPet isMyPet];
    self.reportButton.hidden = self.borrowButton.hidden;
    [self.borrowButton setSelected:self.selectedPet.isBorrowed];
    if (self.selectedPet.petedCountByMe == 0)
    {
        self.pettingLabel.hidden = YES;
        self.totalPettedCount.hidden = YES;
        self.petMeAnimationImageView = [[UIImageView alloc] initWithFrame:self.petMeImageView.frame];
        [self.view addSubview:self.petMeAnimationImageView];
//        [self loadAnimation:self.petMeAnimationImageView sheetImageName:@"pleasepetme_spritesheet_300x120" duration:2 count:0 step:2];
        self.petMeAnimationImageView.image = [UIImage imageNamed:@"pleasepetme300x112"];
        self.borrowButton.hidden = YES;
    }
    else
    {
        self.pettingLabel.hidden = NO;
        self.pettingLabel.text = [NSString stringWithFormat:@"%ld pets!", (long)self.selectedPet.petedCountByMe];
        self.totalPettedCount.hidden = NO;
    }
    self.moewLabel.hidden = YES;

    //! refresh total petted count
    [CATAppDelegate get].petManager.delegate = self;
    [[CATAppDelegate get].petManager refreshPettedCount:self.selectedPet.petID];

    [self stopSpin];
    [HUD hide:YES];
    self.tempView.hidden = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopSpin];
	[HUD hide:YES];
    self.tempView.hidden = YES;
}

- (void)loadFullImage
{
    NSURL *URL = [NSURL URLWithString:self.selectedPet.petImagePath];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    receivedData = [NSMutableData dataWithCapacity: 0];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];

	self.tempView.hidden = NO;
	HUD = [MBProgressHUD showHUDAddedTo:self.tempView animated:YES];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner90x90"]];
    [self startSpin];
	HUD.delegate = self;
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         HUD.customView.transform = CGAffineTransformRotate(HUD.customView.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

#pragma mark - View -

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CATAppDelegate get].petManager.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //! show last petted pet.
    if ([CATAppDelegate get].lastScreen == 4 && [CATAppDelegate get].lastScreenShown == NO)
    {
        self.selectedPet = [[CATPet alloc] initWithObjectId:[[CATAppDelegate get] getLastViewedPetObjectId]];
        [CATAppDelegate get].lastScreenShown = YES;
    }
    [[CATAppDelegate get] updateLastSeenScreen:4];
    if ([self.selectedPet getObjectId] != nil)
        [[CATAppDelegate get] setLastViewedPetObjectId:[self.selectedPet getObjectId]];

    //! navigation bar
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //! hide buttons based on previous view
    self.moewLabel.hidden = YES;
    self.pettingLabel.hidden = YES;
    self.borrowButton.hidden = YES;
    self.reportButton.hidden = YES;
    self.tempView.hidden = YES;
    
    //! pet name
    self.petNameLabel.text = self.selectedPet.petName;
    
    //! pet image
    if (self.selectedPet.petImage == nil)
    {
        //! if it is not loaded before, it needs to be loaded
//        self.petImageView.image = self.selectedPet.petThumbImage;
        [self.scene performSelectorOnMainThread:@selector(loadPetImage:) withObject:self.selectedPet.petThumbImage waitUntilDone:YES];
//        [self loadFullImage];
    }
    else
    {
        if (self.selectedPet.petedCountByMe == 0)
            [self.selectedPet getPettedCount];
        
//        self.petImageView.image = self.selectedPet.petImage;
//        [self.scene loadPetImage:self.selectedPet.petImage];
        [self.scene performSelectorOnMainThread:@selector(loadPetImage:) withObject:self.selectedPet.petImage waitUntilDone:YES];

        self.borrowButton.hidden = [self.selectedPet isMyPet];
        [self.borrowButton setSelected:self.selectedPet.isBorrowed];
        self.reportButton.hidden = self.borrowButton.hidden;
        if (self.selectedPet.petedCountByMe == 0)
        {
            self.pettingLabel.hidden = YES;
            self.petMeAnimationImageView = [[UIImageView alloc] initWithFrame:self.petMeImageView.frame];
            [self.view addSubview:self.petMeAnimationImageView];
//            [self loadAnimation:self.petMeAnimationImageView sheetImageName:@"pleasepetme_spritesheet_300x120" duration:2 count:0 step:2];
            self.petMeAnimationImageView.image = [UIImage imageNamed:@"pleasepetme300x112"];
            self.borrowButton.hidden = YES;
            self.reportButton.hidden = YES;
        }
        else
        {
            self.pettingLabel.hidden = NO;
            self.pettingLabel.text = [NSString stringWithFormat:@"%ld pets!", (long)self.selectedPet.petedCountByMe];
        }
        self.moewLabel.hidden = YES;

        //! refresh total petted count
        if (self.selectedPet.petImage != nil && self.selectedPet.petImagePath != nil)
        {
            [CATAppDelegate get].petManager.delegate = self;
            [[CATAppDelegate get].petManager refreshPettedCount:self.selectedPet.petID];
        }
    }

    //! ads
    [self restoreAdsBar];
    
    //! if selected pet's petimage is not nil and pet image path is nil, then it means it should upload new pet.
    if (self.selectedPet.petImage != nil && self.selectedPet.petImagePath == nil)
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        HUD.mode = MBProgressHUDModeCustomViewRotating;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner90x90"]];
        HUD.labelText = @"Uploading pet...";
        [HUD showWhileExecuting:@selector(addNewPet:) onTarget:self withObject:self.selectedPet animated:YES];
    }
    
}

- (void) loadAnimation:(UIImageView *) imageview sheetImageName:(NSString *) sheetImageName duration:(float) duration count:(NSInteger) count step:(NSInteger) step
{
    UIImage *sheetImage = [UIImage imageNamed:sheetImageName];
    CGRect frame = CGRectMake(0.0, 0.0, imageview.frame.size.width, imageview.frame.size.height);
    NSMutableArray *imageArray = [NSMutableArray new];
    for (int i = 0; i < sheetImage.size.height / frame.size.height; i+=step) {
        for (int j = 0; j < sheetImage.size.width / frame.size.width; j+=step) {
            UIImage *piece = [CATUtility imageCroppedWithRect:frame image:sheetImage];
            [imageArray addObject:piece];
            frame.origin.x += frame.size.width * step;
        }
        frame.origin.x = 0.0;
        frame.origin.y += frame.size.height * step;
    }
    sheetImage = nil;

    imageview.animationImages = imageArray;
    imageview.animationDuration = duration;
    imageview.animationRepeatCount = count;
    [imageview startAnimating];
}

- (void) unloadAnimation:(UIImageView *) imageview
{
    [imageview stopAnimating];
    [self.view.layer removeAllAnimations];
}

- (void) addNewPet:(CATPet *)newPet
{
    if (![[CATAppDelegate get].petManager addPet:newPet location:[CATAppDelegate get].currentLocation progress:HUD])
    {
        NSLog(@"Failed to add new pet.");
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Failed to add new pet.";
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:3];
    }
    else
    {
        [[CATAppDelegate get] setLastViewedPetObjectId:[self.selectedPet getObjectId]];
        [CATAppDelegate get].petManager.delegate = self;
        [[CATAppDelegate get].petManager refreshPettedCount:self.selectedPet.petID];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.petMeAnimationImageView = nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //! font for labels
    self.moewLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:33];
    self.petNameLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:27];
    self.pettingLabel.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:23];
    self.totalPettedCount.font = [UIFont fontWithName:@"HelveticaRoundedLTStd-Bd" size:18];
    self.pettingLabel.shadowColor = kShadowColor2;
	self.pettingLabel.shadowOffset = kShadowOffset1;
	self.pettingLabel.shadowBlur = kShadowBlur1;
    self.totalPettedCount.shadowColor = kShadowColor2;
	self.totalPettedCount.shadowOffset = kShadowOffset1;
	self.totalPettedCount.shadowBlur = kShadowBlur1;
    self.petNameLabel.shadowColor = kShadowColor2;
	self.petNameLabel.shadowOffset = kShadowOffset1;
	self.petNameLabel.shadowBlur = kShadowBlur1;
    
    //! create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.skview addGestureRecognizer:pan];
    pan.delegate = self;
    
    //! sound
    [self initSound];
    
    //! in-app-purchase
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    //! background
    self.skview.showsFPS = YES;
    self.skview.showsNodeCount = YES;
    self.scene = [CATPetDetailScene sceneWithSize:self.skview.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.backgroundColor = [UIColor clearColor];
    [self.skview presentScene:self.scene];
}

- (void)restoreAdsBar
{
    self.adsBannerView.hidden = [[CATAppDelegate get] isPurchased];
    if ([[CATAppDelegate get] isPurchased])
    {
        if (self.backButton.frame.origin.y > 45)
        {
            self.backButton.frame = CGRectMake(self.backButton.frame.origin.x, self.backButton.frame.origin.y - 45, self.backButton.frame.size.width, self.backButton.frame.size.height);
            self.shareButton.frame = CGRectMake(self.shareButton.frame.origin.x, self.shareButton.frame.origin.y - 45, self.shareButton.frame.size.width, self.shareButton.frame.size.height);
            self.petNameLabel.frame = CGRectMake(self.petNameLabel.frame.origin.x, self.petNameLabel.frame.origin.y - 45, self.petNameLabel.frame.size.width, self.petNameLabel.frame.size.height);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) attachPopUpAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [self.purchaseView.layer addAnimation:animation forKey:@"popup"];
}

#pragma mark - Button Actions -
- (IBAction) report:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to report this photo as NSFW?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, it's bad", nil];
    [alert show];
}

- (IBAction) borrow:(id)sender
{
    [self.borrowButton setSelected:![self.borrowButton isSelected]];
    [self performSelectorInBackground:@selector(borrowPet) withObject:self];
}

- (IBAction) back:(UIButton *) sender
{
    [HUD hide:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) share:(UIButton *) sender
{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner90x90"]];
    [self startSpin];
	HUD.delegate = self;
    
    [self performSelectorInBackground:@selector(showShareSheet:) withObject:sender];
}

- (void) showShareSheet:(UIButton *) sender
{
    NSString *textToShare = @"Meow! Made with PetLove!";
    UIImage *imageToShare = [self getShareImage];
    NSArray *itemsToShare = @[textToShare, imageToShare];
    CATOpenInAppActivity *instagramActivity = [[CATOpenInAppActivity alloc] initWithView:self.view andRect:((UIButton *)sender).frame andImage:self.selectedPet.petImage andText:@"#PetLove" andTitle:@"Instagram" andURL:nil];
    CATOpenInAppActivity *pinteresetActivity = [[CATOpenInAppActivity alloc] initWithView:self.view andRect:((UIButton *)sender).frame andImage:self.selectedPet.petImage andText:@"Meow~~~!!!" andTitle:@"Pinterest" andURL:[NSURL URLWithString:self.selectedPet.petImagePath]];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:@[instagramActivity, pinteresetActivity]];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
    instagramActivity.superViewController = activityViewController;
    pinteresetActivity.superViewController = activityViewController;
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        NSLog(@"%@, %d", activityType, completed);
        if (completed != 0)
        {
            NSDictionary *shareParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                        activityType, @"Share_Type",
                                        nil];
            [Flurry logEvent:@"PET_SHARE" withParameters:shareParam];
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:^{
        [self stopSpin];
        [HUD hide:YES];
    }];
}

#pragma mark - Gesture Actions -
- (void)soundPet
{
    if (arc4random() % 2 == 0)
        AudioServicesPlaySystemSound(self.pet01Sound);
    else
        AudioServicesPlaySystemSound(self.pet02Sound);
}
- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        // If we're starting a pan, make sure we're inside the circle.
        // So, calculate the distance between the circle's center and
        // the gesture start location and we'll compare that to the
        // radius of the circle.
        
        self.firstPosition = [gesture locationInView:gesture.view];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint newPosiiton = [gesture locationInView:gesture.view];
        CGFloat x = self.firstPosition.x - newPosiiton.x;
        CGFloat y = self.firstPosition.y - newPosiiton.y;
        CGFloat distance = sqrtf(x * x + y * y);
        
        if (distance > 75)
        {
            [self performSelectorInBackground:@selector(soundPet) withObject:self];
            
            //! remove petmeanimation
//            [self.petMeAnimationImageView stopAnimating];
            [self.view.layer removeAllAnimations];
            [self.petMeAnimationImageView removeFromSuperview];
            self.petMeAnimationImageView = nil;
            
            //! show petted count and borrow and report buttons
            self.pettingLabel.hidden = NO;
            self.totalPettedCount.hidden = NO;
            if ([self.selectedPet isMyPet] == NO)
            {
                self.borrowButton.hidden = NO;
                self.reportButton.hidden = NO;
            }
            
            //! update petted count
            self.selectedPet.petedCountByMe++;
            self.selectedPet.petedCount++;
            self.pettingLabel.text = [NSString stringWithFormat:@"%ld pets!", (long)self.selectedPet.petedCountByMe];
            
            //! petting fx
            if (self.selectedPet.petedCountByMe >= 10 && self.selectedPet.petedCountByMe % 10 == 0)
            {
                if (self.selectedPet.petedCountByMe % 20 == 0)
                {
                    AudioServicesPlaySystemSound(self.pet20Sound);
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    
                    if (self.sparkleImageView == nil && self.blush2ImageView == nil)
                    {
                    
//                    self.purrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
                        self.purrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 63)];
                        self.heartsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 160)];
                        self.sparkleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];

                        self.purrImageView.frame = CGRectMake(arc4random() % 90, arc4random() % 200 + 100, self.purrImageView.frame.size.width, self.purrImageView.frame.size.height);
                        self.heartsImageView.frame = CGRectMake(self.selectedPet.nosePoint.x - self.heartsImageView.frame.size.width / 2, self.selectedPet.nosePoint.y - self.heartsImageView.frame.size.height / 2, self.heartsImageView.frame.size.width, self.heartsImageView.frame.size.height); //CGRectMake(arc4random() % 253, arc4random() % 250 + 100, self.heartsImageView.frame.size.width, self.heartsImageView.frame.size.height);
                        if (arc4random() % 2 == 0) // left eye
                        {
                            self.sparkleImageView.frame = CGRectMake(self.selectedPet.lefteyePoint.x - self.sparkleImageView.frame.size.width / 2, self.selectedPet.lefteyePoint.y - self.sparkleImageView.frame.size.height / 2, self.sparkleImageView.frame.size.width, self.sparkleImageView.frame.size.height);
                        }
                        else
                        {
                            self.sparkleImageView.frame = CGRectMake(self.selectedPet.righteyePoint.x - self.sparkleImageView.frame.size.width / 2, self.selectedPet.righteyePoint.y - self.sparkleImageView.frame.size.height / 2, self.sparkleImageView.frame.size.width, self.sparkleImageView.frame.size.height);
                        }
                        [self unoverlap];
                        [self resizeHeight];

                        [self.view addSubview:self.purrImageView];
                        [self.view addSubview:self.heartsImageView];
                        [self.view addSubview:self.sparkleImageView];

                        self.purrImageView.alpha = 0.1f;
                        self.heartsImageView.alpha = 0.1f;
                        self.sparkleImageView.alpha = 0.1f;
    //                    [self loadAnimation:self.purrImageView sheetImageName:@"purr_spritesheet_150x100" duration:2 count:1 step:4];
                        self.purrImageView.image = [UIImage imageNamed:@"purr160x63"];
                        [self loadAnimation:self.heartsImageView sheetImageName:@"heart_spritesheet_100x160" duration:1 count:1 step:1];
                        [self loadAnimation:self.sparkleImageView sheetImageName:@"sparkle_spritesheet_50x50" duration:1 count:1 step:1];

                        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                            self.purrImageView.alpha = 1.0f;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:1.f delay:0.0 options:0 animations:^{
                                self.purrImageView.alpha = 0;
                            } completion:^(BOOL finished) {
                            }];
                        }];
                        
                        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
    //                        self.purrImageView.alpha = 0.9f;
                            self.heartsImageView.alpha = 0.9f;
                            self.sparkleImageView.alpha = 0.9f;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:3 delay:0.0 options:0 animations:^{
    //                            self.purrImageView.alpha = 1.f;
                                self.heartsImageView.alpha = 1.f;
                                self.sparkleImageView.alpha = 1.f;
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
    //                                self.purrImageView.alpha = 0.f;
                                    self.heartsImageView.alpha = 0.f;
                                    self.sparkleImageView.alpha = 0.f;
    //                                [self.purrImageView stopAnimating];
                                    [self.heartsImageView stopAnimating];
                                    [self.sparkleImageView stopAnimating];
                                    [self.view.layer removeAllAnimations];
                                    [self.purrImageView removeFromSuperview];
                                    [self.heartsImageView removeFromSuperview];
                                    [self.sparkleImageView removeFromSuperview];
                                    self.purrImageView = nil;
                                    self.heartsImageView = nil;
                                    self.sparkleImageView = nil;
                                } completion:nil];
                            }];
                        }];
                    }
                }
                else
                {
                    AudioServicesPlaySystemSound(self.pet10Sound);
                    
                    if (self.blush2ImageView == nil && self.sparkleImageView == nil)
                    {
//                    self.meowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
                        self.meowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
                        self.blush1ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 50)];
                        self.blush2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 50)];
                        
                        self.meowImageView.frame = CGRectMake(arc4random() % 90, arc4random() % 200 + 100, self.meowImageView.frame.size.width, self.meowImageView.frame.size.height);
                        self.blush1ImageView.frame = CGRectMake(self.selectedPet.lefteyePoint.x - self.blush1ImageView.frame.size.width / 2, self.selectedPet.lefteyePoint.y - self.blush1ImageView.frame.size.height / 2 + 40, self.blush1ImageView.frame.size.width, self.blush1ImageView.frame.size.height);
                        self.blush2ImageView.frame = CGRectMake(self.selectedPet.righteyePoint.x - self.blush2ImageView.frame.size.width / 2, self.selectedPet.righteyePoint.y - self.blush2ImageView.frame.size.height / 2 + 40, self.blush2ImageView.frame.size.width, self.blush2ImageView.frame.size.height);
                        [self unoverlap];
                        [self resizeHeight];
                        
                        [self.view addSubview:self.meowImageView];
                        [self.view addSubview:self.blush1ImageView];
                        [self.view addSubview:self.blush2ImageView];
                        
                        self.meowImageView.alpha = 0.1f;
                        self.blush1ImageView.alpha = 0.1f;
                        self.blush2ImageView.alpha = 0.1f;
                        [self loadAnimation:self.blush1ImageView sheetImageName:@"blush_spritesheet_65x50" duration:1 count:1 step:1];
                        [self loadAnimation:self.blush2ImageView sheetImageName:@"blush_spritesheet_65x50" duration:1 count:1 step:1];
    //                    [self loadAnimation:self.meowImageView sheetImageName:@"meow_spritesheet_150x150" duration:1 count:1 step:4];
                        self.meowImageView.image = [UIImage imageNamed:@"meow150x50"];
                        
                        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                            self.meowImageView.alpha = 1.0f;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:1.f delay:0.0 options:0 animations:^{
                                self.meowImageView.alpha = 0;
                            } completion:^(BOOL finished) {
                            }];
                        }];
                        
                        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
    //                        self.meowImageView.alpha = 1.0f;
                            self.blush1ImageView.alpha = 1.0f;
                            self.blush2ImageView.alpha = 1.0f;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:2 delay:0.0 options:0 animations:^{
    //                            self.meowImageView.alpha = 0.9f;
                                self.blush1ImageView.alpha = 0.9f;
                                self.blush2ImageView.alpha = 0.9f;
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
    //                                self.meowImageView.alpha = 0.f;
                                    self.blush1ImageView.alpha = 0.f;
                                    self.blush2ImageView.alpha = 0.f;
    //                                [self.meowImageView stopAnimating];
                                    [self.blush1ImageView stopAnimating];
                                    [self.blush2ImageView stopAnimating];
                                    [self.view.layer removeAllAnimations];
                                    [self.meowImageView removeFromSuperview];
                                    [self.blush1ImageView removeFromSuperview];
                                    [self.blush2ImageView removeFromSuperview];
                                    self.meowImageView = nil;
                                    self.blush1ImageView = nil;
                                    self.blush2ImageView = nil;
                                } completion:nil];
                            }];
                        }];
                    }
                }
                [self performSelectorInBackground:@selector(savePetedCount) withObject:self];
            }
        }
    }
}

- (void) resizeHeight
{
    CGFloat rateY = 1;
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        rateY = 0.76;
    }

    self.purrImageView.frame = CGRectOffset(self.purrImageView.frame, 0, self.purrImageView.frame.origin.y * (rateY - 1));
    self.blush1ImageView.frame = CGRectOffset(self.blush1ImageView.frame, 0, self.blush1ImageView.frame.origin.y * (rateY - 1));
    self.blush2ImageView.frame = CGRectOffset(self.blush2ImageView.frame, 0, self.blush2ImageView.frame.origin.y * (rateY - 1));
    self.meowImageView.frame = CGRectOffset(self.meowImageView.frame, 0, self.meowImageView.frame.origin.y * (rateY - 1));
    self.heartsImageView.frame = CGRectOffset(self.heartsImageView.frame, 0, self.heartsImageView.frame.origin.y * (rateY - 1));
    self.sparkleImageView.frame = CGRectOffset(self.sparkleImageView.frame, 0, self.sparkleImageView.frame.origin.y * (rateY - 1));
}

- (void) unoverlap
{
    if (self.selectedPet.petedCountByMe % 20 == 0)
    {
//        CGRect rect = self.sparkleImageView.frame;
//        UIImageView *effectImageView[3] = {self.purrImageView, self.heartsImageView, self.sparkleImageView};
//        for (NSInteger i = 0; i < 3; i++) {
//            for (NSInteger j = i; j < 3; j++) {
//                if (effectImageView[i].frame.origin.y > effectImageView[j].frame.origin.y)
//                {
//                    UIImageView *tempImageView = effectImageView[i];
//                    effectImageView[i] = effectImageView[j];
//                    effectImageView[j] = tempImageView;
//                }
//            }
//        }
//        if (effectImageView[1].frame.origin.y - effectImageView[0].frame.origin.y < effectImageView[0].frame.size.height)
//        {
//            effectImageView[1].frame = CGRectMake(effectImageView[1].frame.origin.x, effectImageView[0].frame.origin.y + effectImageView[0].frame.size.height + 10, effectImageView[1].frame.size.width, effectImageView[1].frame.size.height);
//            effectImageView[2].frame = CGRectMake(effectImageView[2].frame.origin.x, effectImageView[2].frame.origin.y + effectImageView[0].frame.size.height + 10, effectImageView[2].frame.size.width, effectImageView[2].frame.size.height);
//        }
//        if (effectImageView[2].frame.origin.y - effectImageView[1].frame.origin.y < effectImageView[1].frame.size.height)
//        {
//            effectImageView[2].frame = CGRectMake(effectImageView[2].frame.origin.x, effectImageView[2].frame.origin.y + effectImageView[1].frame.size.height + 10, effectImageView[2].frame.size.width, effectImageView[2].frame.size.height);
//        }
//        
//        float offset = rect.origin.y - self.sparkleImageView.frame.origin.y;
//        for (NSInteger i = 0; i < 3; i++)
//        {
//            effectImageView[i].frame = CGRectMake(effectImageView[i].frame.origin.x, effectImageView[i].frame.origin.y + offset, effectImageView[i].frame.size.width, effectImageView[i].frame.size.height);
//        }
        UIImageView *minView, *maxView;
        if (self.sparkleImageView.frame.origin.y < self.heartsImageView.frame.origin.y)
        {
            minView = self.sparkleImageView;
            maxView = self.heartsImageView;
        }
        else
        {
            minView = self.heartsImageView;
            maxView = self.sparkleImageView;
        }
        if (self.purrImageView.frame.origin.y > minView.frame.origin.y - minView.frame.size.height && self.purrImageView.frame.origin.y < maxView.frame.origin.y + maxView.frame.size.height)
        {
            self.purrImageView.frame = CGRectMake(self.purrImageView.frame.origin.x, maxView.frame.origin.y + maxView.frame.size.height, self.purrImageView.frame.size.width, self.purrImageView.frame.size.height);
        }
    }
    else
    {
        UIImageView *blushImageMin, *blushImageMax;
        if (self.blush1ImageView.frame.origin.y < self.blush2ImageView.frame.origin.y)
        {
            blushImageMin = self.blush1ImageView;
            blushImageMax = self.blush2ImageView;
        }
        else
        {
            blushImageMin = self.blush2ImageView;
            blushImageMax = self.blush1ImageView;
        }
        if (self.meowImageView.frame.origin.y > blushImageMin.frame.origin.y - blushImageMin.frame.size.height && self.meowImageView.frame.origin.y < blushImageMax.frame.origin.y + blushImageMax.frame.size.height)
        {
            self.meowImageView.frame = CGRectMake(self.meowImageView.frame.origin.x, blushImageMax.frame.origin.y + blushImageMax.frame.size.height, self.meowImageView.frame.size.width, self.meowImageView.frame.size.height);
        }
    }
}

- (void) borrowPet
{
    if ([[CATAppDelegate get].userManager borrowedCount] >= kMAXLIMITEDBORROWABLECOUNT && [[CATAppDelegate get] isPurchased] == NO && self.selectedPet.isBorrowed == NO)
    {
        self.purchaseView.hidden = NO;
        self.purchaseView.alpha = 1.0;
        [self attachPopUpAnimation];
    
        return;
    }
    self.selectedPet.isBorrowed = [self.borrowButton isSelected];
    [[CATAppDelegate get].petManager updatePet:self.selectedPet increasedPettedCount:0];
    if (self.selectedPet.isBorrowed)
        [[CATAppDelegate get].userManager updateUser:[[CATAppDelegate get].userManager borrowedCount] + 1];
    else
        [[CATAppDelegate get].userManager updateUser:[[CATAppDelegate get].userManager borrowedCount] - 1];
    
    [self performSelectorOnMainThread:@selector(showAdoptedMessage) withObject:nil waitUntilDone:YES];
}

- (void) showAdoptedMessage
{
    if (!self.isViewLoaded || !self.view.window)
        return;
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (!self.isViewLoaded || !self.view.window)
        return;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(self.selectedPet.isBorrowed) ? @"adopted150x150" : @"released150x150"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.removeFromSuperViewOnHide = YES;

    [HUD hide:YES afterDelay:1.5];
}

- (void) savePetedCount
{
    [[CATAppDelegate get].userManager updateUser:self.selectedPet.petedCountByMe increasedPettedCount:10];
    [[CATAppDelegate get].petManager updatePet:self.selectedPet increasedPettedCount:10];
    
    [self submitScore];
    [self logPetedCount];
}

- (void) logPetedCount
{
    NSNumber *petedCountNumber = [NSNumber numberWithInteger:self.selectedPet.petedCountByMe];
    NSDictionary *petedCountParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                   petedCountNumber, @"Petted_Count",
                                   nil];
    [Flurry logEvent:@"PETTED_COUNT" withParameters:petedCountParam];
}

- (void) submitScore
{
    GKScore *topPettedCatsScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"TOP_PETTED_CATS"];
    topPettedCatsScore.value = [[CATAppDelegate get].userManager getTopPettedCount];

    GKScore *totalPettedCatsScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"TOTAL_AMOUNT_PETS"];
    totalPettedCatsScore.value = [[CATAppDelegate get].userManager getTotalPettedCount];
    
    [GKScore reportScores:@[topPettedCatsScore, totalPettedCatsScore] withCompletionHandler:^(NSError *error) {
        if(error != nil){
            NSLog(@"Score Submission Failed");
        } else {
            NSLog(@"Score Submitted");
        }
    }];
}

- (UIImage *) getShareImage
{
    UIFont *font = [UIFont boldSystemFontOfSize:46 * (self.selectedPet.petImage.size.width / 640)];
    NSDictionary *dictionary = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: [NSMutableParagraphStyle defaultParagraphStyle],
                                  NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSString *stringToDraw = [NSString stringWithFormat:@" %@ ", self.totalPettedCount.text];
    CGSize stringSize = [stringToDraw sizeWithAttributes:dictionary];
    return [self drawText:stringToDraw inImage:self.selectedPet.petImage atPoint:CGPointMake((self.selectedPet.petImage.size.width - stringSize.width) / 2, (self.selectedPet.petImage.size.height * 960 / 1136))];
}

- (UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:46 * (image.size.width / 640)];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    NSDictionary *dictionary = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: [NSMutableParagraphStyle defaultParagraphStyle],
                                  NSForegroundColorAttributeName: [UIColor whiteColor],
                                  NSBackgroundColorAttributeName: [[UIColor darkGrayColor] colorWithAlphaComponent:0.7]};
    [text drawInRect:CGRectIntegral(rect) withAttributes:dictionary];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - UIAlertView Delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])
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
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes, it's bad"])
    {
        [[CATAppDelegate get].petManager reportPet:self.selectedPet];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Reported";
        hud.color = [UIColor colorWithRed:0.99 green:0.39 blue:0.39 alpha:0.90];
        hud.mode = MBProgressHUDModeCustomView;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }
}

- (IBAction)clickOK:(id)sender
{
    [self hidePurchaseAlert];

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

- (IBAction)clickCancel:(id)sender
{
    [self.borrowButton setSelected:![self.borrowButton isSelected]];
    [self hidePurchaseAlert];
}

- (void)hidePurchaseAlert
{
    [UIView beginAnimations:@"hideAlert" context:nil];
    [UIView setAnimationDelegate:self];
    self.purchaseView.alpha = 0;
    [UIView commitAnimations];
}

#pragma mark - SKProductsRequestDelegate -

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        _product = products[0];
        SKPayment *payment = [SKPayment paymentWithProduct:_product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}

#pragma mark - SKPaymentTransactionObserver -

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    [HUD hide:YES];
    NSLog(@"Updated Transactions");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self unlockFeature];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
            case SKPaymentTransactionStateRestored:
                [self unlockFeatureForRestore];
                break;
                
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

-(void)unlockFeatureForRestore
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    [defaultData setInteger:1 forKey:@"purchased"];
	[defaultData synchronize];
    [self restoreAdsBar];
}

-(void)unlockFeature
{
    NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
    [defaultData setInteger:1 forKey:@"purchased"];
	[defaultData synchronize];
    [self performSelectorInBackground:@selector(borrowPet) withObject:nil];
    [self restoreAdsBar];
}

#pragma mark - CATPetManagerDelegate - 

- (void)refreshedPettedCount:(NSInteger)pettedCount
{
    if (self.view != nil)
    {
        self.selectedPet.petedCount = pettedCount;
        if (self.selectedPet.petedCount != 0)
        {
            //self.totalPettedCount.hidden = NO;
            self.totalPettedCount.text = [NSString stringWithFormat:@"%ld total pets!", (long)self.selectedPet.petedCount];
        }
    }
    typeof(self) __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TOTAL_PETTED_COUNT_REFRESH_TIME * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (weakSelf) {
            [[CATAppDelegate get].petManager refreshPettedCount:weakSelf.selectedPet.petID];
        }
    });
}
@end
