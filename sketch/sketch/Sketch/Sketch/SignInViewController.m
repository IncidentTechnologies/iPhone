//
//  SignInViewController.m
//  Sketch
//
//  Created by Franco on 7/31/13.
//
//

#import "SignInViewController.h"
#import "ViewController.h"
#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>

#define USERNAME_INVALID @"Invalid Username"
#define PASSWORD_INVALID @"Invalid Password"
#define SIGNIN_FAILED @"Invalid Username or Password"
#define SIGNUP_USERNAME_INVALID_FIRSTLETTER @"Username must begin with a letter"
#define SIGNUP_PASSWORD_INVALID_LENGTH @"Password must be at least 8 letters"
#define SIGNUP_EMAIL_INVALID @"Invalid Email"
#define FACEBOOK_INVALID @"Facebook failed to login"
#define FACEBOOK_CLIENT_ID @"285410511522607"
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
@property (weak, nonatomic) IBOutlet UITextField *singInPassword;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UITextField *signUpUsername;
@property (weak, nonatomic) IBOutlet UITextField *signUpPassword;
@property (weak, nonatomic) IBOutlet UITextField *signUpEmail;

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
    // Init the cloud controller
    //        g_cloudController = [[CloudController alloc] initWithServer:@"http://184.169.154.56/v1.0.6"];
    //        g_cloudController = [[CloudController alloc] initWithServer:@"http://50.18.250.24/m1"];
    _cloudController = [[CloudController alloc] initWithServer:@"http://184.169.154.56/v1.5"];
    
    _userController = [[UserController alloc] initWithCloudController:_cloudController];
    
    _facebookController = [[Facebook alloc] initWithAppId:FACEBOOK_CLIENT_ID andDelegate:self];
    
    // See if there are any cached credentials
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    if ( [settings objectForKey:@"FBAccessTokenKey"] && [settings objectForKey:@"FBExpirationDateKey"] )
    {
        _facebookController.accessToken = [settings objectForKey:@"FBAccessTokenKey"];
        _facebookController.expirationDate = [settings objectForKey:@"FBExpirationDateKey"];
    }
    
    _notificationView.hidden = YES;
    _spinner.hidden = YES;
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
    
    if ( _singInPassword.text == nil || [_singInPassword.text isEqualToString:@""] == YES )
    {
        [self displayNotification:PASSWORD_INVALID turnRed:YES];
        
        return;
    }

    [_userController requestLoginUser:_signInUsername.text
                           andPassword:_singInPassword.text
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
    [_notificationLabel setText:notification];
    [_notificationView setHidden:NO];
    
    if ( red )
    {
        _notificationView.backgroundColor = [UIColor redColor];
    }
    else
    {
        _notificationView.backgroundColor = [UIColor colorWithRed:2.0/256.0 green:160.0/256.0 blue:220.0/256.0 alpha:1.0];
    }
}

- (void)hideNotification
{
    [_notificationLabel.superview setHidden:YES];
    
    _notificationView.backgroundColor = [UIColor colorWithRed:2.0/256.0 green:160.0/256.0 blue:220.0/256.0 alpha:1.0];
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
