//
//  SlidingModalViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/14/13.
//
//

#import <UIKit/UIKit.h>
#import "FrameGenerator.h"

@interface SlidingModalViewController : UIViewController
{
    CGRect onFrame;
    CGRect offFrame;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *blackButtonOrig;

- (IBAction)closeButtonClicked:(id)sender;

@end
