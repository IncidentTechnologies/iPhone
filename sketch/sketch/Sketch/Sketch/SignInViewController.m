//
//  SignInViewController.m
//  Sketch
//
//  Created by Franco on 7/31/13.
//
//

#import "SignInViewController.h"

#import "AppDelegate.h"
#import "ViewController.h"
#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>

#define DEFAULT_NOTIFICATION @"SKETCHPAD"
#define USERNAME_INVALID @"Invalid Username"
#define PASSWORD_INVALID @"Invalid Password"
#define SIGNIN_FAILED @"Invalid Username or Password"
#define SIGNUP_USERNAME_INVALID_FIRSTLETTER @"Username must begin with a letter"
#define SIGNUP_PASSWORD_INVALID_LENGTH @"Password must be at least 8 letters"
#define SIGNUP_EMAIL_INVALID @"Invalid Email"
#define FACEBOOK_INVALID @"Facebook failed to login"
#define FACEBOOK_CLIENT_ID @"461827050581550"
#define FACEBOOK_PERMISSIONS [NSArray arrayWithObjects:@"email", nil]

@interface SignInViewController ()
{
    ViewController* _mainViewController;
    
    CloudController* _cloudController;
    UserController* _userController;
    
    Facebook* _facebookController;
    
    BOOL _waitingForFacebook;
}
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet UITextField *signInUsername;
@property (weak, nonatomic) IBOutlet UITextField *signInPassword;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UITextField *signUpUsername;
@property (weak, nonatomic) IBOutlet UITextField *signUpPassword;
@property (weak, nonatomic) IBOutlet UITextField *signUpEmail;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation SignInViewController

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
    
    _userController = [UserController sharedSingleton];
                       
    _facebookController = [[Facebook alloc] initWithAppId:FACEBOOK_CLIENT_ID andDelegate:self];
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.facebook = _facebookController;
    
    // See if there are any cached credentials
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    if ( [settings objectForKey:@"FBAccessTokenKey"] && [settings objectForKey:@"FBExpirationDateKey"] )
    {
        _facebookController.accessToken = [settings objectForKey:@"FBAccessTokenKey"];
        _facebookController.expirationDate = [settings objectForKey:@"FBExpirationDateKey"];
    }
    
    [_createAccountButton setTitle:@"Don't have an account? Sign Up" forState:UIControlStateNormal];
    [_createAccountButton setTitle:@"Already have an account? Sign In" forState:UIControlStateSelected];
    
    _signUpView.hidden = YES;
    _spinner.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self hideNotification];
    _signInUsername.text = @"";
    _signInPassword.text = @"";
    
    if ( _cloudController.m_loggedIn == NO &&
        (_userController.m_loggedInFacebookToken != nil ||
         _userController.m_loggedInUsername != nil) )
    {
        // If we are not logged in, but we have cached creds, login.
        [_userController requestLoginUserCachedCallbackObj:self andCallbackSel:@selector(signinCallback:)];
        
        // Assume for now that we are actually logged in for now. The callback can revert this if needed
        [self displayMainView];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)attemptSignIn:(id)sender
{
    [self hideNotification];
    
    if ( _signInUsername.text == nil || [_signInUsername.text isEqualToString:@""] == YES )
    {
        [self displayNotification:USERNAME_INVALID turnRed:YES];
        
        return;
    }
    
    if ( _signInPassword.text == nil || [_signInPassword.text isEqualToString:@""] == YES )
    {
        [self displayNotification:PASSWORD_INVALID turnRed:YES];
        
        return;
    }

    [_userController requestLoginUser:_signInUsername.text
                           andPassword:_signInPassword.text
                        andCallbackObj:self
                        andCallbackSel:@selector(signinCallback:)];
    
    _spinner.hidden = NO;
    [_spinner startAnimating];
}

- (void)signinCallback:(UserResponse *)userResponse
{
    [_spinner stopAnimating];
    _spinner.hidden = YES;
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self displayMainView];
    }
    else
    {
        // There was an error
        NSString* message = userResponse.m_statusText;
        if ([message isEqualToString:@"Unauthorized"])
        {
            message = SIGNIN_FAILED;
        }
        
        [self displayNotification:message turnRed:YES];
        
        if ( (_userController.m_loggedInFacebookToken != nil ||
              _userController.m_loggedInUsername != nil) )
        {
            // We didn't log in, but we have before, so we won't lock them out yet..
            
        }
        else
        {
            
        }
    }
}

- (IBAction)attempSingUp:(id)sender
{
    [self hideNotification];
    
    if ( _signUpUsername.text == nil || [_signUpUsername.text isEqualToString:@""] == YES )
    {
        [self displayNotification:USERNAME_INVALID turnRed:YES];
        
        return;
    }
    
    if ( _signUpPassword.text == nil || [_signUpPassword.text isEqualToString:@""] == YES )
    {
        [self displayNotification:PASSWORD_INVALID turnRed:YES];
        
        return;
    }
    
    //    NSCharacterSet * alphaNumChars = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet * alphaChars = [NSCharacterSet letterCharacterSet];
    
    NSString * firstChar = [_signUpUsername.text substringToIndex:1];
    
    // The first char of the username must be a letter
    if ( [firstChar rangeOfCharacterFromSet:alphaChars].location == NSNotFound )
    {
        [self displayNotification:SIGNUP_USERNAME_INVALID_FIRSTLETTER turnRed:YES];
        
        return;
    }
    
    if ( [_signUpPassword.text length] < 8 )
    {
        [self displayNotification:SIGNUP_PASSWORD_INVALID_LENGTH turnRed:YES];
        
        return;
    }
    
    // Email is optional. Leaving the email field empty is ok, but if present validate it.
    if ( !(_signUpEmail.text == nil || [_signUpEmail.text isEqualToString:@""]) )
    {
        // user has attempted to type something in, check if valid email
        if (![self NSStringIsValidEmail:_signUpEmail.text])
        {
            [self displayNotification:SIGNUP_EMAIL_INVALID turnRed:YES];
            return;
        }
    }
    
    [_userController requestSignupUser:_signUpUsername.text
                            andPassword:_signUpPassword.text
                               andEmail:_signUpEmail.text
                         andCallbackObj:self
                         andCallbackSel:@selector(signupCallback:)];
    
    _spinner.hidden = NO;
    [_spinner startAnimating];
}

- (void)signupCallback:(UserResponse *)userResponse
{
    [_spinner stopAnimating];
    _spinner.hidden = YES;
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self displayMainView];
    }
    else
    {
        // There was an error
        [self displayNotification:userResponse.m_statusText turnRed:YES];
    }
}

- (IBAction)facebookLogin:(id)sender
{
    if ( _waitingForFacebook == YES )
    {
        return;
    }
    
    _waitingForFacebook = YES;
    
    [_facebookController authorize:FACEBOOK_PERMISSIONS];
}

- (void)facebookSigninCallback:(UserResponse*)userResponse
{
    [_spinner stopAnimating];
    _spinner.hidden = YES;
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self hideNotification];
        
        [self displayMainView];
    }
    else
    {
        // There was an error
        [self displayNotification:userResponse.m_statusText turnRed:YES];        
    }
}


- (IBAction)toggleSignUpView:(UIButton*)button
{
    button.selected = !button.selected;
    if (button.selected)
    {
        _signUpView.hidden = NO;
        _signInView.hidden = YES;
        
        _signUpUsername.text = @"";
        _signUpPassword.text = @"";
        _signUpEmail.text = @"";
    }
    else
    {
        _signUpView.hidden = YES;
        _signInView.hidden = NO;
        
        _signInUsername.text = @"";
        _signInPassword.text = @"";
    }
    
    [self displayNotification:DEFAULT_NOTIFICATION turnRed:NO];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder)
    {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    }
    else
    {
        // Not found, so remove keyboard and hit submit button
        [textField resignFirstResponder];
        
        // Check which field is being filed out.
        // Currently textField at end of signIn has tag of 1
        if (textField.tag == 2)
        {
            [self attemptSignIn:self];
        }
        else if (textField.tag == 6)
        {
            [self attempSingUp:self];
        }
    
    }
    
    return NO;
}

#pragma mark - FBSessionDelegate

- (void)fbDidLogin
{
    _waitingForFacebook = NO;
    
    // We save the access token to the user settings
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setObject:[_facebookController accessToken] forKey:@"FBAccessTokenKey"];
    [settings setObject:[_facebookController expirationDate] forKey:@"FBExpirationDateKey"];
    
    [settings synchronize];
    
    [self hideNotification];
    
    // Log into our server
    [_userController requestLoginUserFacebookToken:_facebookController.accessToken
                                     andCallbackObj:self
                                     andCallbackSel:@selector(facebookSigninCallback:)];
    
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    _waitingForFacebook = NO;
    
    [self displayNotification:FACEBOOK_INVALID turnRed:YES];
}

- (void)fbDidLogout
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // Clear cached data
    [settings removeObjectForKey:@"FBAccessTokenKey"];
    [settings removeObjectForKey:@"FBExpirationDateKey"];
    
    [settings synchronize];
}

- (void)fbSessionInvalidated
{

}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
    
}

#pragma mark - helpers

- (void)displayNotification:(NSString *)notification turnRed:(BOOL)red
{
    [_notificationLabel setHidden:NO];
    [_notificationLabel setText:notification];
    
    if ( red )
    {
        _notificationLabel.font = [UIFont boldSystemFontOfSize:18];
        _notificationView.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:46.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    else
    {
        _notificationLabel.font = [UIFont systemFontOfSize:21];
        _notificationView.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:59.0/255.0 blue:66.0/255.0 alpha:1.0];
    }
}

- (void)hideNotification
{
    // "hide notification" should mean display the default notification
    [self displayNotification:DEFAULT_NOTIFICATION turnRed:NO];
}

- (void)displayMainView
{
    _mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainScreenViewControllerID"];
    [self.navigationController pushViewController:_mainViewController animated:YES];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}


@end
