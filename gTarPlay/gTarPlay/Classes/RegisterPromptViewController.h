//
//  RegisterPromptViewController.h
//  gTarPlay
//
//  Created by Kate Schnippering on 5/20/14.
//
//

#import <UIKit/UIKit.h>

@interface RegisterPromptViewController : UIViewController
{
    CGRect onFrame;
    CGRect offFrame;
}

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, strong) IBOutlet UILabel *freeSongsLabel;
@property (nonatomic, strong) IBOutlet UILabel *registerLabel;

@property (nonatomic, strong) IBOutlet UIButton *laterButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;

- (IBAction)laterButtonClicked:(id)sender;
- (IBAction)registerButtonClicked:(id)sender;

@end
