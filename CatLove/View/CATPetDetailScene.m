//
//  CATPetDetailScene.m
//  CatLove
//
//  Created by astraea on 9/12/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATPetDetailScene.h"
#import "CATUtility.h"

@implementation CATPetDetailScene

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.scene.backgroundColor = [UIColor grayColor];

        self.backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"pettingbg320x568"];
        if ([[UIScreen mainScreen] bounds].size.height == 480)
            self.backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"pettingbg320x480"];
        [self addChild:self.backgroundNode];
        self.backgroundNode.position = CGPointMake(self.size.width/2, self.size.height/2);
        
        self.petNode = [SKSpriteNode spriteNodeWithImageNamed:@"pettingbg320x568"];
        [self addChild:self.petNode];
        self.petNode.position = CGPointMake(self.size.width/2, self.size.height/2);
        
//        UIImage *sheetImage = [UIImage imageNamed:@"heart_spritesheet_100x160.png"];
//        CGRect frame = CGRectMake(0.0, 0.0, 100, 160);
//        NSInteger step = 1;
//        NSMutableArray *imageArray = [NSMutableArray new];
//        for (int i = 0; i < sheetImage.size.height / frame.size.height; i+=step) {
//            for (int j = 0; j < sheetImage.size.width / frame.size.width; j+=step) {
//                UIImage *piece = [MyScene imageCroppedWithRect:frame image:sheetImage];
//                [imageArray addObject:piece];
//                frame.origin.x += frame.size.width * step;
//            }
//            frame.origin.x = 0.0;
//            frame.origin.y += frame.size.height * step;
//        }
//        
//        self.sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:imageArray[0]]];
//        self.sprite.position = CGPointMake(self.size.width/2, self.size.height/2);
//        
//        [self addChild:self.sprite];
//        
//        NSMutableArray *textures = [NSMutableArray new];
//        
//        for (UIImage *image in imageArray) {
//            SKTexture *texture =
//            [SKTexture textureWithImage:image];
//            [textures addObject:texture];
//        }
//        
//        self.spriteAnimation =
//        [SKAction animateWithTextures:textures timePerFrame:0.02];
//        
//        SKAction *repeat = [SKAction repeatActionForever:self.spriteAnimation];
//        [self.sprite runAction:repeat];
    }
    
    return self;
}

- (void) loadPetImage:(UIImage *) petImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.png"];
    [UIImagePNGRepresentation(petImage) writeToFile:filePath atomically:YES];
    
    UIImage *tempImage = [UIImage imageWithContentsOfFile:filePath];
    
    UIImage *newImage = [UIImage imageNamed:@"SpotPlacement-LeftEye"];// [self imageWithBrightness:0.0001 image:petImage];
    [self.petNode setTexture:[SKTexture textureWithImage:newImage]];
//    self.petNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:petImage]];
}

- (UIImage*) imageWithBrightness:(CGFloat)brightnessFactor image:(UIImage *) image
{
//    
//    if ( brightnessFactor == 0 ) {
//        return image;
//    }
    
    CGImageRef imgRef = [image CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    
    //Allocate Image space
    uint8_t* rawData = malloc(totalBytes);
    
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    //Perform Brightness Manipulation
    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0,roundf(*red + (*red * brightnessFactor))));
        *green = MIN(255,MAX(0,roundf(*green + (*green * brightnessFactor))));
        *blue = MIN(255,MAX(0,roundf(*blue + (*blue * brightnessFactor))));
        
    }
    
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    //Create UIImage struct around image
    UIImage* imageNew = [UIImage imageWithCGImage:newImg];
    
    //Release our hold on the image
    CGImageRelease(newImg);
    
    //return new image!
    return imageNew;
    
}
@end
