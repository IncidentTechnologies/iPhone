//
//  MenuViewController.m
//  Sketch
//
//  Created by Franco on 8/3/13.
//
//

#import "MenuViewController.h"

#import "AppDelegate.h"
#import <gTarAppCore/Facebook.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserEntry.h>
#import <gTarAppCore/UserProfile.h>

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *signedInLabel;

@end

@implementation MenuViewController

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
	
    UserEntry *loggedInEntry = [[UserController sharedSingleton] getUserEntry:0];
    
    // Create attributed text where the user name is bold
    const CGFloat fontSize = 15;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    // Create the attributes
    NSDictionary *boldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           boldFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *regAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              regularFont, NSFontAttributeName, nil];
    
    // Calculate atrributed text range
    NSString* introText = @"Signed in as";
    NSString* username = loggedInEntry.m_userProfile.m_name;
    NSString* wholeText = [NSString stringWithFormat:@"%@ %@", introText, username];
    const NSRange range = NSMakeRange([introText length], [username length]);
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:wholeText
                                           attributes:regAttrs];
    [attributedText setAttributes:boldAttrs range:range];
    
    [_signedInLabel setAttributedText:attributedText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
    [[UserController sharedSingleton] requestLogoutUserCallbackObj:nil andCallbackSel:nil];
    
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.facebook logout];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
