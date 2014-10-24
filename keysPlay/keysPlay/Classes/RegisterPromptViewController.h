//
//  RegisterPromptViewController.h
//  keysPlay
//
//  Created by Kate Schnippering on 5/20/14.
//
//

#import <UIKit/UIKit.h>
#import "FrameGenerator.h"

@protocol RegisterPromptDelegate <NSObject>

- (void)registerDevice;

@end

@interface RegisterPromptViewController : UIViewController
{
    CGRect onFrame;
    CGRect offFrame;
    
    FrameGenerator * frameGenerator;
}

@property (weak, nonatomic) id <RegisterPromptDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, strong) IBOutlet UILabel *freeSongsLabel;
@property (nonatomic, strong) IBOutlet UILabel *registerLabel;

@property (nonatomic, strong) IBOutlet UIButton *laterButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;

- (IBAction)laterButtonClicked:(id)sender;
- (IBAction)registerButtonClicked:(id)sender;

@end
