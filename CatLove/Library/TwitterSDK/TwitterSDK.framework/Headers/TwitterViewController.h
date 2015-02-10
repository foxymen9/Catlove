/*!
 @header    TwitterViewController.h
 @abstract  Twitter iOS SDK Source
 @copyright Copyright 2013 BPT Softs. All rights reserved.
 @version   1.0
 */


#import <UIKit/UIKit.h>
@class TWSession;

/*!
 * @abstract This block will return after dismiss ViewController login.
 *
 * @param <sucess> It's BOOL value. Result from sever.
 * @param <session> It's a kind of NSObject. Session of twitter (such as: 
 * access token, access token secret, ...).
 *
 */
typedef void (^TWSessionAuthorizeResultHandler)(BOOL sucess,TWSession *session);

@interface TwitterViewController : UIViewController

/*!
 * @property twitterWebview Setup webview to connect with Twitter.
 *
 * @property leftBarButton  Setup NavigationBar.
 * 
 * @property leftBarButton  Setup UIBarButtonItem.
 */
@property (nonatomic, weak)     IBOutlet UIWebView       *twitterWebview;

/*!
 * @property <indicatorTitle> Setup Title for indicator label.
 */
@property (nonatomic, strong)   NSString    *indicatorTitle;

/*!
 * @property <urlRequestToken> Setup URL to request requestToken.
 *
 * @attribute Default is : https://api.twitter.com/oauth/request_token
 */
@property (nonatomic, strong)   NSURL       *urlRequestToken;

/*!
 * @property <urlAccessToken> Setup URL to request AccessToken.
 *
 * @attribute Default is : https://api.twitter.com/oauth/access_token
 */
@property (nonatomic, strong)   NSURL       *urlAccessToken;

/*!
 * @property <urlAuthorize> Setup URL to request Authorize.
 *
 * @attribute Default is : https://api.twitter.com/oauth/authorize
 */
@property (nonatomic, strong)   NSURL       *urlAuthorize;

/*!
 * @abstract
 * Initialize TwitterViewController.
 *
 * @return
 * TwitterViewController Object.
 */
+ (TwitterViewController *) shared;

/*!
 * @abstract Open webview login to Twitter.
 *
 * @param <delegate> The mandatory kind of "delegate" is UIViewController.
 * Delegate must be NOT NULL.
 * 
 * @param <block> It's a Block. TWSessionAuthorizeResultHandler block have
 * been called after dismissing this viewController.
 *
 * @discussion
 * Open webview, login and get information from Twitter.
 *
 * @result
 * Return TWSessionAuthorizeResultHandler block.
 */
- (void) openTwitterWithDelegate:(id)delegate
                          result:(TWSessionAuthorizeResultHandler)block;

@end
