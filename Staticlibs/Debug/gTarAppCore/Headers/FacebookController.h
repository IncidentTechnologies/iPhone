//
//  FacebookController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 6/15/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopupViewController.h"

@class CloudResponse;

@protocol FacebookControllerDelegate <NSObject>

- (void)facebookLoginSucceeded;
- (void)facebookLoginUserDoesntExist;
- (void)facebookLoginFailed;

@end

@interface FacebookController : PopupViewController <UIWebViewDelegate>
{
    
    IBOutlet UIWebView * m_webView;
    IBOutlet UIView * m_successView;
    
    id<FacebookControllerDelegate> m_delegate;
    
    NSString * m_clientId;
    
    NSString * m_redirectUri;
    NSString * m_loginUri;
    
    NSString * m_accessToken;
    
    // After we log in we can get a bit of infor about them.
    // Basically just a convenience
    
    NSString * m_username;
    NSString * m_name;
    NSString * m_firstname;
    NSString * m_lastname;
    
    NSArray * m_friendsList;
}

@property (nonatomic, retain) IBOutlet UIWebView * m_webView;
@property (nonatomic, retain) IBOutlet UIView * m_successView;

@property (nonatomic, assign) id<FacebookControllerDelegate> m_delegate;
@property (nonatomic, retain) NSString * m_clientId;
@property (nonatomic, readonly) NSString * m_accessToken;

@property (nonatomic, readonly) NSString * m_username;
@property (nonatomic, readonly) NSString * m_name;
@property (nonatomic, readonly) NSString * m_firstname;
@property (nonatomic, readonly) NSString * m_lastname;

- (void)sharedInit;
- (void)sendLoginRequest;
- (void)logout;

- (void)loginWithFacebookToken:(NSString*)accessToken;
- (void)loginWithFacebookToken;
- (void)loginWithFacebookTokenCallback:(CloudResponse*)cloudResponse;

@end
