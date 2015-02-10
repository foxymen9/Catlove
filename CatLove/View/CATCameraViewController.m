//
//  CATCameraViewController.m
//  Adding Pet using camera or picture gallery
//
//  Created by astraea on 08/01/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATCameraViewController.h"
#import "CATAppDelegate.h"
#import <ImageIO/ImageIO.h>
#import "MBProgressHUD.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface CATCameraViewController (){
    UIInterfaceOrientation orientationLast, orientationAfterProcess;
    CMMotionManager *motionManager;
}
@end

@implementation CATCameraViewController
@synthesize delegate;

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
    
    [self.navigationController setNavigationBarHidden:YES];
    
	// Do any additional setup after loading the view.
    pickerDidShow = NO;
    FrontCamera = NO;
    self.captureImage.hidden = YES;
    
    // Setup UIImagePicker Controller
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES;
    
    croppedImageWithoutOrientation = [[UIImage alloc] init];
    
    initializeCamera = YES;
    photoFromCam = YES;
    
    // Initialize Motion Manager
    [self initializeMotionManager];
    
    // create tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setNumberOfTouchesRequired:1];
    [self.captureImage addGestureRecognizer:tap];
    tap.delegate = self;
    
    // create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.captureImage addGestureRecognizer:pan];
    pan.delegate = self;
    
    // create pinch gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.captureImage addGestureRecognizer:pinch];
    pinch.delegate = self;
    
    // change size according to iphone type
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        self.instructionImageView.image = [UIImage imageNamed:@"instructions320x480"];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"takecatphoto150x150"]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:3];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    self.nosecircleImage.hidden = YES;
    self.righteyecircleImage.hidden = YES;
    self.lefteyecircleImage.hidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (initializeCamera){
        initializeCamera = NO;
        
        // Initialize camera
        [self initializeCamera];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) dealloc
{
    _imagePreview = nil;
    _captureImage = nil;
    imgPicker = nil;
    
    if (session)
        session=nil;
    
    if (captureVideoPreviewLayer)
        captureVideoPreviewLayer=nil;
    
    if (stillImageOutput)
        stillImageOutput=nil;
}

#pragma mark - Tap Gesture - 

// Create a UIBezierPath which is a circle at a certain location of a certain radius.
// This also saves the circle's center and radius to class properties for future reference.

- (UIBezierPath *)makeCircleAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    self.circleCenter = location;
    self.circleRadius = radius;
    NSLog(@"%f", radius);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.circleCenter
                    radius:self.circleRadius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    return path;
}

// Create a CAShapeLayer for our circle on tap on the screen

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if (self.imagePreview.hidden == NO)
        return;
    
    CGPoint location = [gesture locationInView:gesture.view];
    
    if (self.lefteyecircleImage.hidden)
    {
        lefteyePoint = location;
        self.lefteyecircleImage.frame = CGRectMake(location.x - self.lefteyecircleImage.image.size.width / 2, location.y - self.lefteyecircleImage.image.size.height / 2, self.lefteyecircleImage.image.size.width, self.lefteyecircleImage.image.size.height);
        [self setHiddenAnimated:self.lefteyecircleImage hide:NO];
        self.lefteyecircleImage.hidden = NO;
    }
    else if (self.righteyecircleImage.hidden)
    {
        righteyePoint = location;
        self.righteyecircleImage.frame = CGRectMake(location.x - self.righteyecircleImage.image.size.width / 2, location.y - self.righteyecircleImage.image.size.height / 2, self.righteyecircleImage.image.size.width, self.righteyecircleImage.image.size.height);
        [self setHiddenAnimated:self.righteyecircleImage hide:NO];
    }
    else if (self.nosecircleImage.hidden)
    {
        nosePoint = location;
        self.nosecircleImage.frame = CGRectMake(location.x - self.nosecircleImage.image.size.width / 2, location.y - self.nosecircleImage.image.size.height / 2, self.nosecircleImage.image.size.width, self.nosecircleImage.image.size.height);
        [self setHiddenAnimated:self.nosecircleImage hide:NO];
        
        self.doneButton.hidden = NO;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.captureImage];
    UIImageView *currentImage = nil;
    NSInteger selectedPosition = 0;
    if (CGRectContainsPoint(self.lefteyecircleImage.frame, location))
    {
        currentImage = self.lefteyecircleImage;
        selectedPosition = 1;
    }
    else if (CGRectContainsPoint(self.righteyecircleImage.frame, location))
    {
        currentImage = self.righteyecircleImage;
        selectedPosition = 2;
    }
    else if (CGRectContainsPoint(self.nosecircleImage.frame, location))
    {
        currentImage = self.nosecircleImage;
        selectedPosition = 3;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if (currentImage)
        {
            self.oldPosition = currentImage.frame;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        if (currentImage)
        {
            CGPoint translation = [gesture translationInView:gesture.view];
            CGRect newRect = CGRectMake(self.oldPosition.origin.x + translation.x, self.oldPosition.origin.y + translation.y, self.oldPosition.size.width, self.oldPosition.size.height);
            currentImage.frame = newRect;
            switch (selectedPosition) {
                case 1:
                    lefteyePoint = CGPointMake(newRect.origin.x + newRect.size.width / 2, newRect.origin.y + newRect.size.height / 2);
                    break;
                case 2:
                    righteyePoint = CGPointMake(newRect.origin.x + newRect.size.width / 2, newRect.origin.y + newRect.size.height / 2);
                    break;
                case 3:
                    nosePoint = CGPointMake(newRect.origin.x + newRect.size.width / 2, newRect.origin.y + newRect.size.height / 2);
                    break;
                default:
                    break;
            }
        }
    }

}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
}

#pragma mark - CoreMotion Task - 

- (void)initializeMotionManager
{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = .2;
    motionManager.gyroUpdateInterval = .2;
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                        withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                            if (!error) {
                                                [self outputAccelertionData:accelerometerData.acceleration];
                                            }
                                            else{
                                                NSLog(@"%@", error);
                                            }
                                        }];
}

#pragma mark - UIAccelerometer callback

- (void)outputAccelertionData:(CMAcceleration)acceleration{
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == orientationLast)
        return;
    
    //    NSLog(@"Going from %@ to %@!", [[self class] orientationToText:orientationLast], [[self class] orientationToText:orientationNew]);
    
    orientationLast = orientationNew;
}

#ifdef DEBUG
+(NSString*)orientationToText:(const UIInterfaceOrientation)ORIENTATION {
    switch (ORIENTATION) {
        case UIInterfaceOrientationPortrait:
            return @"UIInterfaceOrientationPortrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"UIInterfaceOrientationPortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"UIInterfaceOrientationLandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"UIInterfaceOrientationLandscapeRight";
    }
    return @"Unknown orientation!";
}
#endif

#pragma mark - Camera Initialization

- (void) initializeCamera
{
    if (session)
        session=nil;
    
    session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetPhoto;
	
    if (captureVideoPreviewLayer)
        captureVideoPreviewLayer=nil;
    
	captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
	captureVideoPreviewLayer.frame = self.imagePreview.bounds;
	[self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
	
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera=nil;
    AVCaptureDevice *backCamera=nil;
    
    // check if device available
    if (devices.count==0)
    {
        NSLog(@"No Camera Available");
        [self disableCameraDeviceControls];
        return;
    }
    
    for (AVCaptureDevice *device in devices)
    {
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    if (!FrontCamera) {
        
        if ([backCamera hasFlash]){
            [backCamera lockForConfiguration:nil];
            if (self.flashToggleButton.selected)
                [backCamera setFlashMode:AVCaptureFlashModeOn];
            else
                [backCamera setFlashMode:AVCaptureFlashModeOff];
            [backCamera unlockForConfiguration];
            
            [self.flashToggleButton setEnabled:YES];
        }
        else{
            if ([backCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
                [backCamera lockForConfiguration:nil];
                [backCamera setFlashMode:AVCaptureFlashModeOff];
                [backCamera unlockForConfiguration];
            }
            [self.flashToggleButton setEnabled:NO];
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (FrontCamera) {
        [self.flashToggleButton setEnabled:NO];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (stillImageOutput)
        stillImageOutput=nil;
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
	[session startRunning];
}

- (IBAction)snapImage:(id)sender
{
    [self.photoCaptureButton setEnabled:NO];
    
    if (!haveImage) {
        self.captureImage.image = nil; //remove old image from view
        self.captureImage.hidden = NO; //show the captured image view
        self.imagePreview.hidden = YES; //hide the live video feed
        [self capImage];
    }
    else {
        self.captureImage.hidden = YES;
        self.imagePreview.hidden = NO;
        haveImage = NO;
    }
}

- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    }];
}

- (UIImage*)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) processImage:(UIImage *)image //process captured image, crop, resize and rotate
{
    haveImage = YES;
    photoFromCam = YES;
    
    UIImage *smallImage = [self imageByScalingAndCroppingForSize:image targetSize:CGSizeMake(640, 1136)];
    CGRect cropRect = CGRectMake(0, 40, 640, 1136);
    CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
    
    croppedImageWithoutOrientation = [[UIImage imageWithCGImage:imageRef] copy];
    
    UIImage *croppedImage = nil;
    
    // adjust image orientation
    orientationAfterProcess = orientationLast;
    switch (orientationLast) {
        case UIInterfaceOrientationPortrait:
            NSLog(@"UIInterfaceOrientationPortrait");
            croppedImage = [UIImage imageWithCGImage:imageRef];
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
            croppedImage = [[UIImage alloc] initWithCGImage: imageRef
                                                       scale: 1.0
                                                 orientation: UIImageOrientationDown];
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"UIInterfaceOrientationLandscapeLeft");
            croppedImage = [[UIImage alloc] initWithCGImage: imageRef
                                                       scale: 1.0
                                                 orientation: UIImageOrientationRight];
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"UIInterfaceOrientationLandscapeRight");
            croppedImage = [[UIImage alloc] initWithCGImage: imageRef
                                                       scale: 1.0
                                                 orientation: UIImageOrientationLeft];
            break;
            
        default:
            croppedImage = [UIImage imageWithCGImage:imageRef];
            break;
    }
    
    CGImageRelease(imageRef);
    
    [self.captureImage setImage:smallImage];
    
    [self setCapturedImage];
}

- (void)setCapturedImage
{
    // Stop capturing image
    [session stopRunning];
    
    // Hide Top/Bottom controller after taking photo for editing
    [self hideControllers];
}

#pragma mark - Device Availability Controls -

- (void)disableCameraDeviceControls
{
    self.cameraToggleButton.enabled = NO;
    self.flashToggleButton.enabled = NO;
    self.photoCaptureButton.enabled = NO;
}

#pragma mark - UIImagePicker Delegate -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (info) {
        photoFromCam = NO;
        
        UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (outputImage == nil) {
            outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        if (outputImage) {
            self.captureImage.hidden = NO;
            self.captureImage.image = outputImage;
            self.imagePreview.hidden = YES;
            
            if ([delegate respondsToSelector:@selector(didFinishPickingImage:)])
            {
                [delegate didFinishPickingImage:self.captureImage.image];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            
            // Hide Top/Bottom controller after taking photo for editing
            [self hideControllers];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    initializeCamera = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button clicks -

- (IBAction)doneAdd:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"What is your cat's name?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alert show];
}

- (IBAction)helpInstruction:(id)sender
{
    [self setHiddenAnimated:self.instructionView hide:NO];
    self.helpButton.hidden = YES;
    self.retakeButton.hidden = YES;
    self.doneButton.hidden = YES;
}

- (IBAction)hideInstruction:(id)sender
{
    self.retakeButton.hidden = NO;
    [self setHiddenAnimated:self.instructionView hide:YES];
    self.helpButton.hidden = NO;
    if ((self.lefteyecircleImage.hidden == NO) && (self.righteyecircleImage.hidden == NO) && (self.nosecircleImage.hidden == NO))
        self.doneButton.hidden = NO;
}

- (void)setHiddenAnimated:(UIView *)view hide:(BOOL)hide
{
    if (!hide)
        view.alpha = 0;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
         if (hide)
             view.alpha=0;
         else
         {
             view.hidden= NO;
             view.alpha=1;
         }
     }
                     completion:^(BOOL b)
     {
         if (hide)
             view.hidden= YES;
     }
     ];
}

- (IBAction)gridToogle:(UIButton *)sender
{
    if (sender.selected)
    {
        sender.selected = NO;
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            self.ImgViewGrid.alpha = 1.0f;
        } completion:nil];
    }
    else
    {
        sender.selected = YES;
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            self.ImgViewGrid.alpha = 0.0f;
        } completion:nil];
    }
}

- (IBAction)switchToLibrary:(id)sender
{
    if (session)
    {
        [session stopRunning];
    }
    
    self.captureImage.image = nil;
    
    imgPicker.allowsEditing = NO;
    [self presentViewController:imgPicker animated:YES completion:NULL];
}

- (IBAction)skipped:(id)sender
{
    if ([delegate respondsToSelector:@selector(yCameraControllerdidSkipped)])
    {
        [delegate yCameraControllerdidSkipped];
    }
    
    // Dismiss self view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) done:(id)sender
{
    if ([delegate respondsToSelector:@selector(yCameraControllerDidDoneWithImage:lefteyePoint:righteyePoint:nosePoint:petName:)])
    {
        [delegate yCameraControllerDidDoneWithImage:[self.captureImage image] lefteyePoint:lefteyePoint righteyePoint:righteyePoint nosePoint:nosePoint petName:self.petName];
    }
    
    // Dismiss self view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donePhotoCapture:(id)sender
{
    if ([delegate respondsToSelector:@selector(didFinishPickingImage:)])
    {
        [delegate didFinishPickingImage:self.captureImage.image];
    }
    
    // Dismiss self view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retakePhoto:(id)sender
{
    [self.photoCaptureButton setEnabled:YES];
    self.captureImage.image = nil;
    self.imagePreview.hidden = NO;
    self.lefteyecircleImage.hidden = YES;
    self.righteyecircleImage.hidden = YES;
    self.nosecircleImage.hidden = YES;
    self.helpButton.hidden = YES;
    self.doneButton.hidden = YES;
    
    // Show Camera device controls
    [self showControllers];
    
    haveImage=NO;
    FrontCamera = NO;
    [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
}

- (IBAction)switchCamera:(UIButton *)sender //switch cameras front and rear cameras
{
    // Stop current recording process
    [session stopRunning];
    
    if (sender.selected) {  // Switch to Back camera
        sender.selected = NO;
        FrontCamera = NO;
        [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
    }
    else {                  // Switch to Front camera
        sender.selected = YES;
        FrontCamera = YES;
        [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
    }
}

- (IBAction)toogleFlash:(UIButton *)sender{
    if (!FrontCamera) {
        if (sender.selected) { // Set flash off
            [sender setSelected:NO];
            
            NSArray *devices = [AVCaptureDevice devices];
            for (AVCaptureDevice *device in devices) {
                
                NSLog(@"Device name: %@", [device localizedName]);
                
                if ([device hasMediaType:AVMediaTypeVideo]) {
                    
                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        if ([device hasFlash]){
                            
                            [device lockForConfiguration:nil];
                            [device setFlashMode:AVCaptureFlashModeOff];
                            [device unlockForConfiguration];
                            
                            break;
                        }
                    }
                }
            }
            
        }
        else{                  // Set flash on
            [sender setSelected:YES];
            
            NSArray *devices = [AVCaptureDevice devices];
            for (AVCaptureDevice *device in devices) {
                
                NSLog(@"Device name: %@", [device localizedName]);
                
                if ([device hasMediaType:AVMediaTypeVideo]) {
                    
                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        if ([device hasFlash]){
                            
                            [device lockForConfiguration:nil];
                            [device setFlashMode:AVCaptureFlashModeOn];
                            [device unlockForConfiguration];
                            
                            break;
                        }
                    }
                }
            }
            
        }
    }
}

#pragma mark - UI Control Helpers - 

- (void)hideControllers
{
    [UIView animateWithDuration:0.2 animations:^{
        self.photoBar.center = CGPointMake(self.photoBar.center.x, self.photoBar.center.y+116.0);
        self.topBar.center = CGPointMake(self.topBar.center.x, self.topBar.center.y-54.0);
        self.controlBar.hidden = NO;
    } completion:nil];
    CATAppDelegate *appDelegate = [CATAppDelegate get];
    if (appDelegate.instructionShown == NO)
    {
        self.instructionView.hidden = NO;
        self.retakeButton.hidden = YES;
        [self.view bringSubviewToFront:self.instructionView];
        appDelegate.instructionShown = YES;
        self.helpButton.hidden = YES;
    }
    else
        self.helpButton.hidden = NO;
}

- (void)showControllers
{
    [UIView animateWithDuration:0.2 animations:^{
        self.photoBar.center = CGPointMake(self.photoBar.center.x, self.photoBar.center.y-116.0);
        self.topBar.center = CGPointMake(self.topBar.center.x, self.topBar.center.y+54.0);
        self.controlBar.hidden = YES;
    } completion:nil];
}

#pragma mark - UIAlertView Delegate - 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.petName = [[alertView textFieldAtIndex:0] text];
        if ([self.petName length] <= 0)
        {
            self.petName = @"Unnamed";
        }
        [self performSelector:@selector(done:) withObject:nil afterDelay:0.01];
    }
}

@end
