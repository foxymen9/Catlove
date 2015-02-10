/*!
 @header    TWObject.h
 @abstract  Twitter iOS SDK Source
 @copyright Copyright 2013 BPT Softs. All rights reserved.
 @version   1.0
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * @abstract Returned after requesting with OAuth.
 *
 * @param <sucess> It's BOOL value. Result from sever.
 * @param <data> It's a kind of NSData. This data contain JSON formater.
 */
typedef void(^TWRequestGraphHandler)(BOOL success, NSData *data);

@interface TWRequest : NSObject{
    
}

/*!
 * @abstract
 * Initialize TWRequest.
 *
 * @return
 * TWRequest Object.
 */
+ (TWRequest *) shared;

/*!
 * @abstract Request to get Profile from Twitter.
 *
 * @param <block> It's a block. TWRequestGraphHandler block have been 
 * called after Twitter response data.
 *
 */
- (void) requestForMe:(TWRequestGraphHandler)handler;

/*!
 * @abstract Request to Twitter.
 *
 * @param <graphPath> It's a kind of NSString. URL request must be NOT
 * NULL.
 *
 * @param <HTTPMethod> It's a kind of NSString. HTTP method must be NOT
 * NULL.
 *
 * @param <parameters> It's a kind of NSDictionary. It contain key and
 * value for requesting.
 *
 * @param <block> It's a block. TWRequestGraphHandler block have been
 * called after Twitter response data.
 *
 * @link https://dev.twitter.com/docs/api/1.1 This link contain all method.
 *
 */
- (void )requestWithGraphPath:(NSString*)graphPath
                   HTTPMethod:(NSString*)HTTPMethod
                   parameters:(NSDictionary *)parameters
                   completion:(TWRequestGraphHandler)handler;

/*!
 * @abstract Request to post message&photo on Twitter's wall.
 *
 * @param <msg> It's a kind of NSString. Message must be NOT NULL. Limit 
 * 140 characters.
 *
 * @param <photo> It's a kind of UIImage. UIImage must be NOT NULL.
 *
 * @param <parameters> It's a kind of NSDictionary. It contain key and
 * value for requesting.
 *
 * @param <block> It's a block. TWRequestGraphHandler block have been
 * called after Twitter response data.
 *
 * @discussion
 * Post status with message and photo.
 */
- (void )requestPostMessage:(NSString *)msg
                      photo:(UIImage *)photo
                 parameters:(NSDictionary *)parameters
                 completion:(TWRequestGraphHandler)handler;

/*!
 * @abstract Request to post only message on Twitter's wall.
 *
 * @param <msg> It's a kind of NSString. Message must be NOT NULL. Limit
 * 140 characters.
 *
 * @param <parameters> It's a kind of NSDictionary. It contain key and
 * value for requesting.
 *
 * @param <block> It's a block. TWRequestGraphHandler block have been 
 * called after Twitter response data.
 *
 * @discussion
 * Post status with message.
 */
- (void )requestPostOnlyMessage:(NSString *)msg
                     parameters:(NSDictionary *)parameters
                     completion:(TWRequestGraphHandler)handler;

/*!
 * @abstract Request to get friends list on Twitter.
 *
 * @param <parameters> It's a kind of NSDictionary. It contain key and
 * value for requesting. It can be NULL.
 *
 * @param <block> It's a block. TWRequestGraphHandler block have been
 * called after Twitter response data.
 *
 * @discussion
 * Get friends list from Twitter.
 */
- (void )requestGetFriendsWithParameters:(NSDictionary *)parameters
                              completion:(TWRequestGraphHandler)handler;


@end
