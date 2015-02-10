//
//  CATUtility.h
//  CatLove
//
//  Created by astraea on 7/13/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATUtility : NSObject

+ (void) showMessage: (NSString *) message title:(NSString *) title cancel:(NSString *)cancel;
+ (BOOL) validateEmail:(NSString *)email;
+ (UIImage *)fixOrientation:(UIImage *) image;
+ (UIImage *)thumbnail:(UIImage *) image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageCroppedWithRect:(CGRect)rect image:(UIImage *) image;

@end
