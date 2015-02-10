/*!
 @header    TwitterShareView.h
 @abstract  Twitter iOS SDK Source
 @copyright Copyright 2013 BPT Softs. All rights reserved.
 @version   1.0
 */


#import <UIKit/UIKit.h>

/*!
 * @function
 * This block will return after this view have been canceled or status have
 * been posted to Twitter.
 */
typedef void(^TweetSend)(BOOL success);

@interface TwitterShareView : UIView

/*!
 * @abstract Open view without message and photo attachment.
 *
 * @param <delegate> The mandatory kind of "delegate" is UIViewController.
 * @param <block> It's a Block. TweetSend block have been called after 
 * dismissing this viewController.
 *
 * @discussion Post status with message and photo have been added by user.
 *
 */
+ (void) showTwitterViewWithDelegate:(id)delegate
                          completion:(TweetSend)block;

/*!
 * @abstract Open view with message and photo attachment.
 *
 * @param <msg> It's a kind of NSString. Message must be NOT NULL.
 *
 * @param <img> It's a kind of UIImage. Photo must be NOT NULL.
 *
 * @param <delegate> The mandatory kind of "delegate" is UIViewController.
 *
 * @param <block> It's a block. TweetSend block have been called after 
 * dismissing this viewController.
 *
 * @discussion
 * Post status with message and photo have been added default. User can
 * edit them.
 *
 */
+ (void) showTwitterViewWithMessage:(NSString *)msg
                              photo:(UIImage *)img
                           delegate:(id)delegate
                         completion:(TweetSend)block;

@end
