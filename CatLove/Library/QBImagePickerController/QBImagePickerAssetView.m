/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QBImagePickerAssetView.h"

// Views
#import "QBImagePickerVideoInfoView.h"

@interface QBImagePickerAssetView ()
{
    NSMutableData *receivedData;
    long long expectedLength;
	long long currentLength;
    BOOL shouldStopLoadingImage;
    BOOL isLoadingImage;
    NSURLConnection *urlconnection;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) QBImagePickerVideoInfoView *videoInfoView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIImage *tintImage;
@property (nonatomic, strong) UIImage *usualImage;
@property (nonatomic, strong) NSThread *currentThread;
@end

@implementation QBImagePickerAssetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        shouldStopLoadingImage = NO;
        isLoadingImage = NO;
        self.tintImage = nil;
        self.usualImage = nil;
        self.currentThread = nil;
        /* Initialization */
        // Image View
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // Video Info View
        QBImagePickerVideoInfoView *videoInfoView = [[QBImagePickerVideoInfoView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 17, self.bounds.size.width, 17)];
        videoInfoView.hidden = YES;
        videoInfoView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:videoInfoView];
        self.videoInfoView = videoInfoView;
        
        // Overlay Image View
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        overlayImageView.clipsToBounds = YES;
        overlayImageView.image = [UIImage imageNamed:@"overlay100x100"];
        overlayImageView.hidden = YES;
        overlayImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:overlayImageView];
        self.overlayImageView = overlayImageView;
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.activity];
        self.activity.frame = CGRectMake((self.frame.size.width - self.activity.frame.size.width) / 2, (self.frame.size.height - self.activity.frame.size.height) / 2, self.activity.frame.size.width, self.activity.frame.size.height);
    }
    
    return self;
}

- (void)assignAsset:(CATPet *)asset
{
    self.asset = asset;
    
    // Set thumbnail image
    [self loadImage];
    
    // Add New Button
    if (asset.addNewButton != nil)
    {
        asset.addNewButton.frame = CGRectMake(0, 0, 100, 100);
        asset.addNewButton.hidden = NO;
        [self addSubview:asset.addNewButton];
        [self bringSubviewToFront:asset.addNewButton];
    }
}

- (void)setSelected:(BOOL)selected
{
    if(self.allowsMultipleSelection) {
        self.overlayImageView.hidden = !selected;
    }
}

- (BOOL)selected
{
    return !self.overlayImageView.hidden;
}

- (void)dealloc
{
}


#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate assetViewCanBeSelected:self] && !self.allowsMultipleSelection) {
        self.imageView.image = self.tintImage;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate assetViewCanBeSelected:self]) {
        self.selected = !self.selected;
        
        if(self.allowsMultipleSelection) {
            self.imageView.image = self.usualImage;
        } else {
            self.imageView.image = self.tintImage;
        }
        
        [self.delegate assetView:self didChangeSelectionState:self.selected];
    } else {
        if(self.allowsMultipleSelection && self.selected) {
            self.selected = !self.selected;
            self.imageView.image = self.usualImage;
            
            [self.delegate assetView:self didChangeSelectionState:self.selected];
        } else {
            self.imageView.image = self.usualImage;
        }
        
        [self.delegate assetView:self didChangeSelectionState:self.selected];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.imageView.image = self.usualImage;
}

#pragma mark - NSDataDelegate - 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (shouldStopLoadingImage == YES)
    {
        [connection cancel];
        [self.activity performSelectorOnMainThread: @selector(stopAnimating) withObject: nil waitUntilDone: YES];
        shouldStopLoadingImage = NO;
        isLoadingImage = NO;
        receivedData = nil;
    }
    else
    {
        expectedLength = MAX([response expectedContentLength], 1);
        currentLength = 0;
        [receivedData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (shouldStopLoadingImage == YES)
    {
        [connection cancel];
        [self.activity performSelectorOnMainThread: @selector(stopAnimating) withObject: nil waitUntilDone: YES];
        shouldStopLoadingImage = NO;
        isLoadingImage = NO;
        receivedData = nil;
    }
    else
    {
        currentLength += [data length];
        [receivedData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (shouldStopLoadingImage == NO)
    {
        UIImage *image = [UIImage imageWithData:receivedData];
        if (image)
        {
            [self performSelectorOnMainThread: @selector(setImage:) withObject: image waitUntilDone: YES];
        }
    }
    [self.activity performSelectorOnMainThread: @selector(stopAnimating) withObject: nil waitUntilDone: YES];
    isLoadingImage = NO;
    shouldStopLoadingImage = NO;

    receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Image Loading failed");
}


#pragma mark - Instance Methods

- (void) loadImage
{
    NSLog(@"Pet Loading(%@, %@)", self.asset.petName, self.asset.petThumbImage);
    if (isLoadingImage) {
        [urlconnection cancel];
        urlconnection = nil;
        shouldStopLoadingImage = YES;
    }
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:nil waitUntilDone:YES];
    if (self.asset.petThumbImage == nil)
    {
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:nil waitUntilDone:YES];
        [self.activity performSelectorOnMainThread: @selector(startAnimating) withObject: nil waitUntilDone: YES];
        if (self.asset.petThumbImagePath != nil)
        {
//            self.currentThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoadImage:) object:self.asset.petThumbImagePath];
//            [self.currentThread start];
//            [self threadLoadImage:self.asset.petThumbImagePath];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self threadLoadImage:self.asset.petThumbImagePath];
//            });
            [self performSelectorOnMainThread:@selector(threadLoadImage:) withObject:self.asset.petThumbImagePath waitUntilDone:YES];
        }
    }
    else
    {
        [self.activity performSelectorOnMainThread: @selector(stopAnimating) withObject: nil waitUntilDone: YES];
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:self.asset.petThumbImage waitUntilDone:YES];
    }
}

- (void) threadLoadImage: (NSString*) sImage
{
    UIImage* image = self.asset.petThumbImage;
    if (image == nil)
    {
        isLoadingImage = YES;
        shouldStopLoadingImage = NO;
        NSURL *URL = [NSURL URLWithString:sImage];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        receivedData = [NSMutableData dataWithCapacity: 0];
        
        urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [urlconnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [urlconnection start];
    }
}

- (void)setImage:(UIImage *) image
{
    self.imageView.image = image;
    self.asset.petThumbImage = image;
    self.usualImage = image;
    UIGraphicsBeginImageContext(image.size);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rect];
    
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceAtop);
    
    self.tintImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

//- (void)thumbnail
//{
//    if (self.usualImage == nil)
//        
//    if ([self.asset thumbnail] != nil)
//        self.imageView.image = [self.asset thumbnail];
//    else
//        [self loadImage];
//}
//
//- (void)tintedThumbnail
//{
//    UIImage *thumbnail = [self thumbnail];
//    
//    UIGraphicsBeginImageContext(thumbnail.size);
//    
//    CGRect rect = CGRectMake(0, 0, thumbnail.size.width, thumbnail.size.height);
//    [thumbnail drawInRect:rect];
//    
//    [[UIColor colorWithWhite:0 alpha:0.5] set];
//    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceAtop);
//    
//    UIImage *tintedThumbnail = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return tintedThumbnail;
//}

@end
