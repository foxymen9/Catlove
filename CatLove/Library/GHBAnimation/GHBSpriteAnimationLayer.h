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
 * GHBSpriteAnimationLayer.h
 *
 * Created by Gerhard Bos on 23-03-13.
 * http://gerhard.nl
 * Copyright (c) 2013 Gerhard Bos. All rights reserved.
 */

#import <QuartzCore/QuartzCore.h>

@interface GHBSpriteAnimationLayer : CALayer
{
    NSMutableDictionary *spriteAnimations;
    
}

@property (readwrite, nonatomic) NSMutableDictionary *spriteAnimations;


/**
 Init with sprite ref & add to CALayer
 
 @param spriteRef       CGImageRef of sprite
 @param displaySize     Size of the first frame to show

 */
- (id) initWithSprite:(CGImageRef)spriteRef withSize:(CGSize)displaySize;

/**
 Adds a animation to the sprite
 @param name            Name of sprite animation
 @param frames          Number of frames in sprite, 1,2,3,0 (always end with 0)
 */
- (void) addSpriteAnimationWithName:(NSString *)name
                         withFrames:(int)firstFrame,...;

/**
 Plays animation
 @param name            Name of sprite animation
 @param fps             Framerate
 @param loop            Set to YES for looping of animation
 */
- (void) playSpriteAnimationWithName:(NSString *)name atFramerate:(int)fps looping:(BOOL)loop;

/**
 Stops animation
 */
- (void) stopSpriteAnimation;

@end
