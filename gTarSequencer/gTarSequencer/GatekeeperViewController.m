//
//  GatekeeperViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 9/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "GatekeeperViewController.h"

#define GTAR_REG_WAIT 2.0

#define SIGNUP_USERNAME_INVALID @"Invalid Username"
#define SIGNUP_USERNAME_INVALID_FIRSTLETTER @"Username must begin with a letter"
#define SIGNUP_PASSWORD_INVALID @"Invalid Password"
#define SIGNUP_PASSWORD_INVALID_LENGTH @"Password must be at least 8 letters"
#define SIGNUP_EMAIL_INVALID @"Invalid Email"
#define SIGNIN_USERNAME_INVALID @"Invalid Username"
#define SIGNIN_PASSWORD_INVALID @"Invalid Password"

@interface GatekeeperViewController ()
{
    UIView * _currentTopPanel;
    NSTimer *_textFieldSliderTimer;
}
@end

@implementation GatekeeperViewController

@synthesize delegate;
@synthesize notificationView;
@synthesize notificationVerticalSpace;

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    g_ophoMaster.loginDelegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self resetScreen];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loggedoutSigninButtonClicked:nil];
}

- (void)resetScreen
{
    
    [self showTopPanel:_signinTopPanel];
    
}

#pragma mark - Panel handling

- (void)showTopPanel:(UIView *)panel
{
    [_currentTopPanel setHidden:YES];
    
    [panel setHidden:NO];
    
    _currentTopPanel = panel;
    
}

- (IBAction)loggedoutSigninButtonClicked:(id)sender
{
    [self enableButton:_loggedoutSignupButton];
    [self disableButton:_loggedoutSigninButton];
    
    [self hideNotification];
    
    [self showTopPanel:_signinTopPanel];
    
}

- (IBAction)loggedoutSignupButtonClicked:(id)sender
{
    [self enableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
    
    [self hideNotification];
    
    [self showTopPanel:_signupTopPanel];
}

- (void)enableButton:(UIButton *)button {
    [button setHidden:NO];
    [button setEnabled:YES];
}

- (void)disableButton:(UIButton *)button {
    [button setHidden:YES];
    [button setEnabled:NO];
}

#pragma mark - Tutorial Reload

- (IBAction)reloadTutorialButtonClicked:(id)sender
{
    [delegate relaunchFTUTutorial];
}

#pragma mark - Notification management

// This changes the top bar notification
- (void)displayNotification:(NSString *)notification turnRed:(BOOL)red {
    
    [_notificationLabel setText:NSLocalizedString(notification, NULL)];
    
    [UIView animateWithDuration:0.2 animations:^(void){
        
        notificationVerticalSpace.constant = 0.0;
        
        [notificationView layoutIfNeeded];
        
    }completion:^(BOOL finished){
        
        // Trigger minimize
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideNotification) userInfo:nil repeats:NO];
    }];
}

- (void)hideNotification {
    
    [UIView animateWithDuration:0.2 animations:^(void){
        
        notificationVerticalSpace.constant = -1 * notificationView.frame.size.height;;
        
        [notificationView layoutIfNeeded];
        
    }completion:^(BOOL finished){
        
    }];
    
}

#pragma mark - Actions

- (IBAction)signinButtonClicked:(id)sender
{
    if ( _signinUsernameText.text == nil || [_signinUsernameText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNIN_USERNAME_INVALID turnRed:YES];
        
        return;
    }
    
    if ( _signinPasswordText.text == nil || [_signinPasswordText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNIN_PASSWORD_INVALID turnRed:YES];
        
        return;
    }
    
    [self hideNotification];
    
    [self showTopPanel:_loadingTopPanel];
    
    [self disableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
    
    [g_ophoMaster loginWithUsername:_signinUsernameText.text password:_signinPasswordText.text];
}

- (IBAction)signupButtonClicked:(id)sender
{
    
    if ( _signupUsernameText.text == nil || [_signupUsernameText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNUP_USERNAME_INVALID turnRed:YES];
        
        return;
    }
    
    if ( _signupPasswordText.text == nil || [_signupPasswordText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNUP_PASSWORD_INVALID turnRed:YES];
        
        return;
    }
    
    //    NSCharacterSet * alphaNumChars = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet * alphaChars = [NSCharacterSet letterCharacterSet];
    
    NSString * firstChar = [_signupUsernameText.text substringToIndex:1];
    
    // The first char of the username must be a letter
    if ( [firstChar rangeOfCharacterFromSet:alphaChars].location == NSNotFound )
    {
        [self displayNotification:SIGNUP_USERNAME_INVALID_FIRSTLETTER turnRed:YES];
        
        return;
    }
    
    if ( [_signupPasswordText.text length] < 8 )
    {
        [self displayNotification:SIGNUP_PASSWORD_INVALID_LENGTH turnRed:YES];
        
        return;
    }
    
    [self hideNotification];
    
    [self showTopPanel:_loadingTopPanel];
    
    [self disableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
    
    [g_ophoMaster registerWithUsername:_signupUsernameText.text password:_signupPasswordText.text email:_signupEmailText.text];
    
}

- (void)requestCachedLogin
{
    DLog(@"Uncaching %@ %@",g_loggedInUser.m_username,g_loggedInUser.m_password);
    
    // get user and password from cache
    [g_ophoMaster loginWithUsername:g_loggedInUser.m_username password:g_loggedInUser.m_password];
}

- (void)requestLogout
{
    [g_ophoMaster logout];
}


#pragma mark - Callbacks

- (void)loggedInCallback
{
    [self hideNotification];
    
    [delegate loggedIn:YES];
}

- (void)loginFailedCallback:(NSString *)error
{
    [delegate loggedOut:NO];
    
    [self displayNotification:error turnRed:YES];
    [self showTopPanel:_signinTopPanel];
    
    [self enableButton:_loggedoutSignupButton];
}

/*
- (void)signupCallback:(CloudResponse *)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        [self hideNotification];
        
        [g_loggedInUser loadWithId:cloudResponse.m_responseUserId Name:cloudResponse.m_cloudRequest.m_username Password:cloudResponse.m_cloudRequest.m_password Email:cloudResponse.m_cloudRequest.m_email Image:cloudResponse.m_responseFileId Profile:cloudResponse.m_responseUserProfile];
        
        [g_loggedInUser cache];
        
        [delegate loggedIn:YES];
    }
    else
    {
        // There was an error
        
        [self displayNotification:cloudResponse.m_statusText turnRed:YES];
        
        [self showTopPanel:_signupTopPanel];
        
        // Renable buttons
        [self enableButton:_loggedoutSignupButton];
    }
}

 
- (void)facebookCallback:(CloudResponse *)cloudResponse
{
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        [self hideNotification];
        
        DLog(@"Facebook callback login success");
        
        [g_loggedInUser loadWithId:cloudResponse.m_responseUserId Name:cloudResponse.m_cloudRequest.m_username Password:cloudResponse.m_cloudRequest.m_password Email:cloudResponse.m_cloudRequest.m_email Image:cloudResponse.m_responseFileId Profile:cloudResponse.m_responseUserProfile];
        
        [g_loggedInUser cache];
        
        [delegate loggedIn:YES];
    }
    else
    {
        // There was an error
        
        DLog(@"Facebook callback login error");
        
        [self displayNotification:cloudResponse.m_statusText turnRed:YES];
        
        [self showTopPanel:_signupTopPanel];
        
        // Renable buttons
        [self enableButton:_loggedoutSignupButton];
    }
}
 
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    DLog(@"Login view fetched user info %@ access token %@",user.name,[[[FBSession activeSession] accessTokenData] accessToken]);
    
    //[g_cloudController requestFacebookLoginWithToken:[[[FBSession activeSession] accessTokenData] accessToken] andCallbackObj:self andCallbackSel:@selector(facebookCallback:)];
    
    [delegate loggedIn:YES];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    DLog(@"Logged in user");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    DLog(@"Logged out user");
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    [self displayNotification:FACEBOOK_INVALID turnRed:YES];
}

 */

#pragma mark - UITextFieldDelegate

- (IBAction)textFieldSelected:(id)sender
{
    
    
    // Invalidate this, if its already running
    [_textFieldSliderTimer invalidate];
    
    _textFieldSliderTimer = nil;
    
    CyclingTextField *cyclingTextField = (CyclingTextField *)sender;
    
    UIView *parent = cyclingTextField.superview.superview;
    
    // Shift the superview up enough so that the textfield is
    // centered in the remaining visble space once the keyboard displays.
    // I kinda just tweaked this value till it looked right.
    //CGFloat delta = cyclingTextField.frame.origin.y - 35;
    CGFloat delta = 0;
    if(cyclingTextField == _signupEmailText){
        delta = cyclingTextField.superview.frame.origin.y - 35;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    //    parent.transform = CGAffineTransformMakeTranslation( 0, -delta );
    parent.layer.transform = CATransform3DMakeTranslation( 0, -delta, 0 );
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _textFieldSliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(delayedTextFieldSlider:) userInfo:textField repeats:NO];
    
    return YES;
}

- (void)delayedTextFieldSlider:(NSTimer *)timer
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)[timer userInfo];
    
    [_textFieldSliderTimer invalidate];
    
    _textFieldSliderTimer = nil;
    
    UIView *parent = cyclingTextField.superview.superview;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    //    parent.transform = CGAffineTransformIdentity;
    parent.layer.transform = CATransform3DIdentity;
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)textField;
    
    if ( cyclingTextField.nextTextField != nil )
    {
        [cyclingTextField.nextTextField becomeFirstResponder];
    }
    else if ( cyclingTextField.submitButton != nil )
    {
        [cyclingTextField.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        [cyclingTextField resignFirstResponder];
    }
    
	return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
