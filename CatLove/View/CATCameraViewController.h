//
//  CATCameraViewController.h
//  Adding Pet using camera or picture gallery
//
//  Created by astraea on 08/01/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

//
//  ARC Helper
#ifndef ah_retain
#if __has_feature(objc_arc)
#define ah_retain self
#define ah_dealloc self
#define release self
#define autorelease self
#else
#define ah_retain retain
#define ah_dealloc dealloc
#define __bridge
#endif
#endif

//  ARC Helper ends

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@protocol CATCameraViewControllerDelegate;

@interface CATCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>{
    
    UIImagePickerController *imgPicker;
    BOOL pickerDidShow;
    
    BOOL FrontCamera;
    BOOL haveImage;
    BOOL initializeCamera, photoFromCam;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
    UIImage *croppedImageWithoutOrientation;
    
    CGPoint lefteyePoint;
    CGPoint righteyePoint;
    CGPoint nosePoint;
}
@property (nonatomic, readwrite) BOOL dontAllowResetRestaurant;
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSString *petName;

@property (nonatomic, strong) IBOutlet UIButton *photoCaptureButton;
@property (nonatomic, strong) IBOutlet UIButton *helpButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *retakeButton;
@property (nonatomic, strong) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic, strong) IBOutlet UIButton *libraryToggleButton;
@property (nonatomic, strong) IBOutlet UIButton *flashToggleButton;
@property (retain, nonatomic) IBOutlet UIImageView *ImgViewGrid;
@property (nonatomic, strong) IBOutlet UIView *photoBar;
@property (nonatomic, strong) IBOutlet UIView *topBar;
@property (nonatomic, strong) IBOutlet UIView *controlBar;
@property (retain, nonatomic) IBOutlet UIView *imagePreview;
@property (nonatomic, strong) IBOutlet UIView *instructionView;
@property (strong, nonatomic) IBOutlet UIImageView *captureImage;
@property (strong, nonatomic) IBOutlet UIImageView *lefteyecircleImage;
@property (strong, nonatomic) IBOutlet UIImageView *righteyecircleImage;
@property (strong, nonatomic) IBOutlet UIImageView *nosecircleImage;
@property (nonatomic, strong) IBOutlet UIImageView* instructionImageView;

@property (nonatomic) CGPoint circleCenter;
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGRect oldPosition;

@end

@protocol CATCameraViewControllerDelegate
- (void)yCameraControllerDidDoneWithImage:(UIImage *) petImage lefteyePoint:(CGPoint) lefteyePoint righteyePoint:(CGPoint) righteyePoint nosePoint:(CGPoint) nosePoint petName:(NSString *) petName;
@optional
- (void)didFinishPickingImage:(UIImage *)image;
- (void)yCameraControllerdidSkipped;
@end
