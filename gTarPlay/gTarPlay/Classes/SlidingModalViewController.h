//
//  SlidingModalViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/14/13.
//
//

#import <UIKit/UIKit.h>

@interface SlidingModalViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *blackButtonOrig;

- (IBAction)closeButtonClicked:(id)sender;

@end
