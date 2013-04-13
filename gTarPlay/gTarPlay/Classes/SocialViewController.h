//
//  SocialViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/12/13.
//
//

#import <UIKit/UIKit.h>

@class SelectorControl;
@class PullToUpdateTableView;

@interface SocialViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *topBar;
@property (retain, nonatomic) IBOutlet SelectorControl *feedSelector;
@property (retain, nonatomic) IBOutlet PullToUpdateTableView *feedTable;

@property (retain, nonatomic) IBOutlet UIImageView *picImageView;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)accountButtonClicked:(id)sender;
- (IBAction)changePicButtonClicked:(id)sender;
- (IBAction)feedSelectorChanged:(id)sender;

@end
