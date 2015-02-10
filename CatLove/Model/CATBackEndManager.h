//
//  CATBackEndManager.h
//  CATLove
//
//  Created by astraea on 8/10/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CATBackEndDelegate;

@interface JigRect : NSObject
@property (nonatomic, assign) CGRect rect;
@end

@interface CATBackEndManager : NSObject
{
    id<CATBackEndDelegate>  delegate_;
    NSDictionary *m_dictParseData;
    
    NSString *m_strUserId;
}

@property (nonatomic, strong) id<CATBackEndDelegate> delegate;
@property (nonatomic, assign) BOOL m_isLoggedin;

- (void) login:(NSString *) strFacebookID strMailAddress:(NSString *) strMailAddress strPassword:(NSString *)strPassword;
- (NSString *) uploadPicture:(UIImage*)image strName:(NSString *) strName;
@end

@protocol CATBackEndDelegate <NSObject>
@optional
- (void) webApiFailWithAlias:(NSString *) strError;
@end



