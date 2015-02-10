/*!
 @header    TWSession.h
 @abstract  Twitter iOS SDK Source
 @copyright Copyright 2013 BPT Softs. All rights reserved.
 @version   1.0
 */

#import <Foundation/Foundation.h>

@interface TWSession : NSObject{
@private
    NSURL       *urlRequestToken;
    NSURL       *urlAccessToken;
    NSURL       *urlAuthorize;
    NSString    *consumerKey;
    NSString    *consumerSecret;
    NSString    *accessToken;
    NSString    *accessTokenSecret;
    NSString    *verifier;
    NSString    *screeName;
}
/*!
 * @property <urlAccessToken> Attribute readonly. Return URL that be used 
 * to get RequestToken.
 *
 * @attribute Default is : https://api.twitter.com/oauth/access_token
 */
@property (readonly)    NSURL       *urlRequestToken;

/*!
 * @property <urlAccessToken> Attribute readonly. Return URL that be used
 * to get AccessToken.
 *
 * @attribute Default is : https://api.twitter.com/oauth/access_token
 */
@property (readonly)    NSURL       *urlAccessToken;

/*!
 * @property <urlAuthorize> Attribute readonly. Return URL that be used
 * to get Authorize.
 *
 * @attribute Default is : https://api.twitter.com/oauth/access_token
 */
@property (readonly)    NSURL       *urlAuthorize;

/*!
 * @property <consumerKey> Attribute readonly. Return consumerKey that be 
 * set up in AppDelegate.
 */
@property (readonly)    NSString    *consumerKey;

/*!
 * @property <consumerSecret> Attribute readonly. Return consumerSecret
 * that be set up in AppDelegate.
 */
@property (readonly)    NSString    *consumerSecret;

/*!
 * @property <accessToken> Attribute readonly. Return Access Token from 
 * Twitter after login successfully.
 */
@property (readonly)    NSString    *accessToken;

/*!
 * @property <accessToken> Attribute readonly. Return Access Token Secret 
 * from Twitter after login successfully.
 */
@property (readonly)    NSString    *accessTokenSecret;

/*!
 * @property <accessToken> Attribute readonly. Return Verifier from Twitter 
 * after login successfully.
 */
@property (readonly)    NSString    *verifier;

/*!
 * @property <accessToken> Attribute readonly. Return ScreeName from 
 * Twitter after login successfully.
 */
@property (readonly)    NSString    *screeName;

/*!
 * @abstract Get seesion of Twitter in application.
 *
 * @return Session Object.
 */
+ (TWSession *) session;

/*!
 * @abstract Delete all seesions of Twitter in application.
 */
+ (void) clearSessions;

/*!
 * @abstract Check exsit session in application.
 */
- (BOOL) isVaild;

@end