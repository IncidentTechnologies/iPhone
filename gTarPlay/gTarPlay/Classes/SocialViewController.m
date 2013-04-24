//
//  SocialViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/12/13.
//
//

#import "SocialViewController.h"

#import "SelectorControl.h"
#import "Facebook.h"
#import "UIView+Gtar.h"

#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/UserEntry.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserResponse.h>

extern UserController *g_userController;
extern Facebook *g_facebook;

@interface SocialViewController ()

@end

@implementation SocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_topBar addShadow];
    
    NSAttributedString *attributedString1 = [self createAttributedStringWithInteger:200 andText:@"SESSIONS"];
    NSAttributedString *attributedString2 = [self createAttributedStringWithInteger:100 andText:@"FOLLOWERS"];
    NSAttributedString *attributedString3 = [self createAttributedStringWithInteger:999 andText:@"FOLLOWING"];
    
    [_feedSelector setTitles:[NSArray arrayWithObjects:attributedString1,attributedString2,attributedString3,nil]];
//    [_feedSelector setFontSize:15];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_topBar release];
    [_feedSelector release];
    [_feedTable release];
    [_picImageView release];
    [_userNameLabel release];
    [super dealloc];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)accountButtonClicked:(id)sender
{
    [g_userController requestLogoutUserCallbackObj:nil andCallbackSel:nil];
    
    [g_facebook logout];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changePicButtonClicked:(id)sender
{
}

- (IBAction)feedSelectorChanged:(id)sender
{
}

#pragma mark - Helpers

- (NSAttributedString *)createAttributedStringWithInteger:(NSInteger)num andText:(NSString *)text
{
    NSString *numString = [NSString stringWithFormat:@"%d",num];
    NSString *string = [NSString stringWithFormat:@"%@\n%@",numString,text];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    UIFont *fontSmall = [UIFont systemFontOfSize:11.0];
    UIFont *fontBig = [UIFont systemFontOfSize:17.0];
    
    [attributedString addAttribute:NSFontAttributeName value:fontBig range:NSMakeRange(0,[numString length])];
    [attributedString addAttribute:NSFontAttributeName value:fontSmall range:NSMakeRange([numString length]+1,[text length])];
    
    return [attributedString autorelease];
}

@end