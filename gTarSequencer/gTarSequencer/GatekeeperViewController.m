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
#define FACEBOOK_INVALID @"Facebook failed to login"

#define FACEBOOK_PERMISSIONS [NSArray arrayWithObjects: @"public_profile", @"email", nil]

@interface GatekeeperViewController ()
{
    UIView * _currentTopPanel;
    NSTimer *_textFieldSliderTimer;
    
    BOOL _waitingForFacebook;
}

@end

@implementation GatekeeperViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self showTopPanel:_signinTopPanel];
    
    _loginView.readPermissions = FACEBOOK_PERMISSIONS;
}

#pragma mark - Panel handling

- (void)showTopPanel:(UIView *)panel
{
    [_currentTopPanel setHidden:YES];
        
    //[panel setFrame:CGRectMake(0, 0, _topPanel.frame.size.width, _topPanel.frame.size.height )];
    
    //[_topPanel addSubview:panel];
    
    [panel setHidden:NO];
    
    _currentTopPanel = panel;
    
}

- (IBAction)loggedoutSigninButtonClicked:(id)sender
{
    [self enableButton:_loggedoutSignupButton];
    [self disableButton:_loggedoutSigninButton];
    
    //[self hideNotification];
    
    [self showTopPanel:_signinTopPanel];
    
}

- (IBAction)loggedoutSignupButtonClicked:(id)sender
{
    [self enableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
    
    //[self hideNotification];
    
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

#pragma mark - Notification management

// This changes the top bar notification
- (void)displayNotification:(NSString *)notification turnRed:(BOOL)red {
    
    [_notificationLabel setText:NSLocalizedString(notification, NULL)];
    [_notificationView setHidden:NO];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        [_notificationView setFrame:CGRectMake(0, 0, _notificationView.frame.size.width, _notificationView.frame.size.height)];
    }completion:^(BOOL finished){
        // Trigger minimize
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(minimizeNotification) userInfo:nil repeats:NO];
    }];
}

- (void)hideNotification {
    
    CGRect notifyOffFrame = CGRectMake(0,-1*_notificationView.frame.size.height,_notificationView.frame.size.width,_notificationView.frame.size.height);
    
    [_notificationView setFrame:notifyOffFrame];
    
    [_notificationView setHidden:YES];
    
}


- (void)minimizeNotification {
    
    [UIView animateWithDuration:0.5 animations:^(void){
        [_notificationView setFrame:CGRectMake(0, -1*_notificationView.frame.size.height, _notificationView.frame.size.width, _notificationView.frame.size.height)];
    }completion:^(BOOL finished){
        [_notificationView setHidden:YES];
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
    
    [g_cloudController requestLoginUsername:_signinUsernameText.text andPassword:_signinPasswordText.text andCallbackObj:self andCallbackSel:@selector(signinCallback:)];

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
    
    [g_cloudController requestRegisterUsername:_signupUsernameText.text andPassword:_signupPasswordText.text andEmail:_signupEmailText.text andCallbackObj:self andCallbackSel:@selector(signupCallback:)];
    
}

#pragma mark - Callbacks

- (void)signinCallback:(CloudResponse *)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        [self hideNotification];
        
        [delegate loggedIn];
       // [self loggedinScreen];
        
    }else{
        
        // There was an error
        
        if ( (_loggedInFacebookToken != nil ||
              _loggedInUsername != nil) )
        {
            // We didn't log in, but we have before, so we won't lock them out yet..
            
        }else{
            [delegate loggedOut];
            //[self loggedoutScreen];
            
            [self displayNotification:cloudResponse.m_statusText turnRed:YES];
            [self showTopPanel:_signinTopPanel];
            //[self swapRightPanel:_signinRightPanel];
            
            [self enableButton:_loggedoutSignupButton];
        }
    }
}

- (void)signupCallback:(CloudResponse *)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        [delegate loggedIn];
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


- (void)facebookSigninCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        //[self logLoginEvent];
        
        //[g_userController sendPendingUploads];
        
        [self hideNotification];
        
        [delegate loggedIn];
        
    }
    else
    {
        // There was an error
        [self displayNotification:cloudResponse.m_statusText turnRed:YES];
        
        [delegate loggedOut];
        [self showTopPanel:_signinTopPanel];
        
        // Renable buttons
        [self enableButton:_loggedoutSignupButton];
    }
}



#pragma mark - FacebookDelegate
/*

- (void)fbDidNotLogin:(BOOL)cancelled
{
    _waitingForFacebook = NO;
    
    [self showTopPanel:_signinTopPanel];
    
    [self displayNotification:FACEBOOK_INVALID turnRed:YES];
}

- (void)fbDidLogout
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // Clear cached data
    [settings removeObjectForKey:@"FBAccessTokenKey"];
    [settings removeObjectForKey:@"FBExpirationDateKey"];
    
    [settings synchronize];
    
    [delegate loggedOut];
}

- (void)fbSessionInvalidated
{
    [delegate loggedOut];
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
    
}

*/

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"Login view fetched user info");
    
    _loggedInUsername = user.username;
    
    [delegate loggedIn];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"Logged in user");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"Logged out user");
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    [self displayNotification:FACEBOOK_INVALID turnRed:YES];
}


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
