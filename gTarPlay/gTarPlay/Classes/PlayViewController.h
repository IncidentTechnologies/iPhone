//
//  PlayViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/28/13.
//
//

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *volumeButton;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)volumeButtonClicked:(id)sender;

@end
