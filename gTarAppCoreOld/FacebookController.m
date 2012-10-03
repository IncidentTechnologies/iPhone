//
//  FacebookController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 6/15/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "FacebookController.h"
#import "RoundedRectangleView.h"
#import "XmlDictionary.h"

#import "CloudController.h"
#import "CloudResponse.h"
#import "UserProfile.h"

#define FACEBOOK_REDIRECT_URI @"http://www.facebook.com/connect/login_success.html"
#define FACEBOOK_CLIENT_ID @"116111488470898"

extern CloudController * g_cloudController;

@implementation FacebookController

@synthesize m_webView;
@synthesize m_successView;

@synthesize m_delegate;
@synthesize m_clientId;
@synthesize m_accessToken;

@synthesize m_username;
@synthesize m_name;
@synthesize m_firstname;
@synthesize m_lastname;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        [self sharedInit];
    }
    
    return self;
}

- (void)sharedInit
{
    
    m_clientId = FACEBOOK_CLIENT_ID;
    
    m_redirectUri = FACEBOOK_REDIRECT_URI;
    
    // maybe try this old one too
    // http://m.facebook.com/connect/uiserver.php?app_id=116111488470898&method=permissions.request&display=wap&next=http%3A%2F%2Flocalhost%3A8888%2FEtarOnline%2Fetaronline%2F&response_type=code&fbconnect=1
    m_loginUri = [[NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&type=user_agent&display=touch&scope=offline_access,email", m_clientId, m_redirectUri] retain];
    
}

- (void)dealloc
{
    
    [m_webView release];
    [m_successView release];
    [m_accessToken release];
    [m_loginUri release];

    [super dealloc];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
    self.view.layer.borderWidth = 0.0;
    self.view.layer.cornerRadius = 7.0;
    
    // for the webview to have rounded corners
    self.m_successView.layer.cornerRadius = 7.0;
    self.m_successView.clipsToBounds = YES;
    
    // this sadly doesn't seem to work
    self.m_webView.layer.cornerRadius = 7.0;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.m_webView = nil;
    self.m_successView = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

    [self sendLoginRequest];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma WebView delegate

- (void)sendLoginRequest
{
    
    // create the request
    NSURL * url = [NSURL URLWithString:m_loginUri];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    // set outself as delegate so we can parse the results
    m_webView.delegate = self;
    
    // load the page.
    [m_webView loadRequest:request];
    
}

- (void)detachFinalize
{

    [super detachFinalize];
    
    [m_webView setHidden:NO];
    
}

- (void)logout
{
    
    NSHTTPCookieStorage * sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //NSArray * cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:@"facebook.com"]];
    
    NSArray * cookies = [sharedHTTPCookieStorage cookies];
    
    for ( NSInteger index = 0; index < [cookies count]; index++ )
    {
        
        NSHTTPCookie * cookie = [cookies objectAtIndex:index];
        
        NSLog( @"%@ %@ %@ %@ %@", cookie.name, cookie.domain, cookie.path, cookie.expiresDate, cookie.value );
                
        [sharedHTTPCookieStorage deleteCookie:cookie];
        
    }

    [g_cloudController requestLogoutCallbackObj:self andCallbackSel:@selector(logoutCallback:)];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	
    //
    // This function gets called everytime a page loads.
    // We want the token from: http://www.facebook.com/connect/login_success.html#access_token=..........
    //
	
	// Get the url
    NSURL * url = ((webView.request).URL);
	NSString * urlString = [url absoluteString];
	
    //
    // Hide the window as soon as it succeeded
    //
    
    // Cut off the token
    NSArray * urlTokens = [urlString componentsSeparatedByString:@"#"];
    
    NSString * urlToken = [urlTokens objectAtIndex:0];
    
    // also sign of success. popdown once we receive this, so the user doesn't see it.
    if ( [urlToken isEqualToString:FACEBOOK_REDIRECT_URI] )
    {
        
        [m_webView setHidden:YES];
        
        [self detachFromSuperView];
        
    }
    

    //
	// Get the access token
    //
	NSRange accessTokenRange = [urlString rangeOfString:@"access_token="];
	
	// If we find it, parse it out
	if (accessTokenRange.length > 0)
    {

		NSInteger startIndex = accessTokenRange.location + accessTokenRange.length;
        
		NSString * accessTokenWithTrailing = [urlString substringFromIndex:startIndex];
        
        NSArray * accessTokens = [accessTokenWithTrailing componentsSeparatedByString:@"&"];
        
        NSString * accessToken = [accessTokens objectAtIndex:0];
		
		NSLog(@"Access Token:  %@", accessToken);
        
        [m_accessToken release];
        
        m_accessToken = [accessToken retain];
        
        [self loginWithFacebookToken];
        
//        [m_delegate facebookLoginSucceeded];
        
//        [self detachFromSuperView];
        
	}

}

#pragma -
#pragma Misc helpers

- (void)loginWithFacebookToken:(NSString*)accessToken
{

    [m_accessToken release];
    
    m_accessToken = [accessToken retain];
    
    [g_cloudController requestFacebookLoginWithToken:accessToken
                                      andCallbackObj:self 
                                      andCallbackSel:@selector(loginWithFacebookTokenCallback:) ];

}

- (void)loginWithFacebookToken
{

    [self loginWithFacebookToken:m_accessToken];
    
}

- (void)loginWithFacebookTokenCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        // get the users name
        [m_username release];
        [m_name release];
        [m_firstname release];
        [m_lastname release];
        
        m_username = [g_cloudController.m_username retain];
        m_name = [cloudResponse.m_responseUserProfile.m_name retain];
        m_firstname = [cloudResponse.m_responseUserProfile.m_firstName retain];
        m_lastname = [cloudResponse.m_responseUserProfile.m_lastName retain];
        
        [m_delegate facebookLoginSucceeded];

    }
    else
    {
        
        if ( [cloudResponse.m_statusText isEqualToString:@"UserError"] )
        {
            [m_delegate facebookLoginUserDoesntExist];
        }
        else
        {
            [m_delegate facebookLoginFailed];        
        }
        
    }
}

- (void)logoutCallback:(CloudResponse*)cloudResponse
{
    
}

#pragma -
#pragma Button clicked handlers

- (IBAction)closeButtonClicked:(id)sender
{
    
    [m_delegate facebookLoginFailed];
    
    [super closeButtonClicked:sender];
    
}

@end
