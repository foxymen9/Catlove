/*!
 @header    Twitter.h
 @abstract  Twitter iOS SDK Source
 @copyright Copyright 2013 BPT Softs. All rights reserved.
 @version   1.0
 */


#import <Foundation/Foundation.h>
#import <TwitterSDK/TwitterShareView.h>
#import <TwitterSDK/TwitterViewController.h>
#import <TwitterSDK/TWRequest.h>
#import <TwitterSDK/TWSession.h>

@interface Twitter : NSObject

/*!
 * @abstract Setting "Consumer key" & "Consumer secrect" with Application
 *
 * @param <key>   Consumerkey is provided by Twitter
 * @param <secret> ConsumerSecret are provided by Twitter
 *
 * @discussion
 * @link Please visit site : https://dev.twitter.com/ .
 *
 * Sign up and select application (if you don't have application, you need
 * create it).
 *
 * Get "Consumer key" & "Consumer secrect"
 *
 */
+ (void) registerWithConsumerkey:(NSString *)key
               AndConsumerSecret:(NSString *)secret;

@end
