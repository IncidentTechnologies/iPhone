//
//  TitleNavigationController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <UIKit/UIKit.h>

@interface TitleNavigationController : UIViewController

// Main
@property (retain, nonatomic) IBOutlet UIView *rightPanel;
@property (retain, nonatomic) IBOutlet UIView *leftPanel;

// Signup
@property (retain, nonatomic) IBOutlet UIView *signinLeftPanel;
@property (retain, nonatomic) IBOutlet UIView *signupRightPanel;
@property (retain, nonatomic) IBOutlet UIView *signinRightPanel;
@property (retain, nonatomic) IBOutlet UIButton *signupSelectButton;
@property (retain, nonatomic) IBOutlet UIButton *signinSelectButton;

- (IBAction)signinSelectButtonClicked:(id)sender;
- (IBAction)signupSelectButtonClicked:(id)sender;
- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)facebookButtonClicked:(id)sender;


@end
