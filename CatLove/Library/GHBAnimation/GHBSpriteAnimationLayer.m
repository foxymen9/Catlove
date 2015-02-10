/*
 Copyright (c) 2013, Gerhard Bos
 All rights reserved.
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

/*
 * GHBSpriteAnimationLayer.m
 *
 * Created by Gerhard Bos on 23-03-13.
 * http://gerhard.nl
 * Copyright (c) 2013 Gerhard Bos. All rights reserved.
 */

#import "GHBSpriteAnimationLayer.h"

@implementation GHBSpriteAnimationLayer
@synthesize spriteAnimations;

- (id) initWithSprite:(CGImageRef)spriteRef withSize:(CGSize)displaySize
{
    if((self = [super init])) {
        // sprite animations dict
        self.spriteAnimations = [NSMutableDictionary dictionary];
        
        // set contents to spriteRef
        self.contents = (__bridge id)(spriteRef);
        
        // set Frame to displaySize
        self.frame = CGRectMake(0, 0, displaySize.width, displaySize.height);
        
        // set content rect for first frame
        float zoom = CGImageGetWidth(spriteRef)/displaySize.width;
        CGSize frameSize = CGSizeMake((displaySize.width*zoom)/CGImageGetWidth(spriteRef),
                                      (displaySize.height*zoom)/CGImageGetHeight(spriteRef));
        
        self.contentsRect = CGRectMake(0, 0, frameSize.width, frameSize.height);
    }
    
    return self;
}

// add sprite for animation
- (void) addSpriteAnimationWithName:(NSString *)name
                         withFrames:(int)firstFrame,...
{
    // frames
    NSMutableArray *frames = [NSMutableArray array];
    
    va_list args;
    va_start(args, firstFrame);
    for (; firstFrame != 0; firstFrame = va_arg(args, int)) {
        CGRect rect = CGRectMake(
                                 ((firstFrame - 1) % (int)(1/self.contentsRect.size.width)) * self.contentsRect.size.width,
                                 ((firstFrame - 1) / (int)(1/self.contentsRect.size.width)) * self.contentsRect.size.height,
                                 self.contentsRect.size.width, self.contentsRect.size.height);
        
        [frames addObject:[NSValue valueWithCGRect:rect]];
    }
    va_end(args);

    // Setup CABasicAnimation
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"contentsRect"];
    
    // Set values of content rects
    anim.values = frames;
    
    // save animation
    [self.spriteAnimations setObject:anim forKey:name];

    
}

// play animation
- (void) playSpriteAnimationWithName:(NSString *)name atFramerate:(int)fps looping:(BOOL)loop
{
    CAKeyframeAnimation *anim = [self.spriteAnimations objectForKey:name];
    if (anim == nil)
        return;
    
    // Set up duration
    anim.duration = (float)anim.values.count / fps;
    
    // animation loop
    if (loop)
        anim.repeatCount = HUGE_VALF;
    
    // params
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.calculationMode = kCAAnimationDiscrete;
    
    // start
    anim.delegate = self;
    [self addAnimation:anim forKey:@"GHBSpriteAnimation"];

}

// Stop animation
- (void) stopSpriteAnimation
{
    if([self animationForKey:@"GHBSpriteAnimation"]) {
        [self removeAnimationForKey:@"GHBSpriteAnimation"];
    }
}


@end
