//
//  CATBackEndManager.m
//  CATLove
//
//  Created by astraea on 8/10/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "CATBackEndManager.h"
#import "TWebApi.h"
#import "SBJson4.h"
#import "CATConstant.h"
#import "CATAppDelegate.h"

@implementation JigRect
@synthesize rect;
@end

@implementation CATBackEndManager

@synthesize delegate = delegate_;
@synthesize m_isLoggedin;

- (id)init
{
    self = [super init];
    m_isLoggedin = NO;
	return self;
}

- (void) login:(NSString *) strFacebookID strMailAddress:(NSString *) strMailAddress strPassword:(NSString *)strPassword
{
    NSString *url = [NSString stringWithFormat: @"%@?action=login&user_id=%@&password=%@&email=%@", [[CATAppDelegate get].userManager getDomainName], strMailAddress, strPassword, strMailAddress];

	TWebApi *registerWebAPI = [[TWebApi alloc] initWithFullApiName:url andAlias:@"login"];
	[registerWebAPI runApiSuccessCallback:@selector(webApiSuccessWithAlias:andData:) FailCallback:@selector(webApiFailWithAlias:andError:) inDelegate:self];
}

- (NSString *) uploadPicture:(UIImage*)image strName:(NSString *) strName
{
    NSString* url = [[CATAppDelegate get].userManager getDomainName];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n", strName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSLog(@"Returned Data from img server:%@", [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]);
    SBJson4Parser *parser = [SBJson4Parser parserWithBlock:^(id item, BOOL *stop) {
        NSObject *itemObject = item;
        
        if ([item isKindOfClass:[NSDictionary class]]) {
            m_dictParseData = (NSDictionary*)itemObject;
        }
    }
                                            allowMultiRoot:NO
                                           unwrapRootArray:NO
                                              errorHandler:^(NSError *error) {
                                                  NSLog(@"%@", error);
                                              }];
    [parser parse:returnData];
    imageData = nil;
    
    return (NSString *)[m_dictParseData objectForKey:@"image_path"];
}

- (void) webApiSuccessWithAlias:(NSString *)alias andData:(NSData *)data 
{
    char *cache = calloc(1, [data length]);
    memcpy(cache, [data bytes], [data length]);
    NSString *rawData = [NSString stringWithCString:cache encoding:NSASCIIStringEncoding];
    free (cache);
    NSLog(@"WEBAPI: %@ -> RAWDATA:%@", alias, rawData);
}

- (void) webApiFailWithAlias:(NSString *)alias andError:(NSError *)err 
{
    NSString *strError = [NSString stringWithFormat:@"%@", [err.userInfo objectForKey:@"error"]];
    NSLog(@"There are connection problems:%@", strError);
    [delegate_ webApiFailWithAlias:strError];
}
@end
