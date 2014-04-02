//
//  FPMenuViewController.h
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import <AudioController/AudioController.h>

@interface FPMenuViewController : UIViewController {
    
}

@property (nonatomic, retain) IBOutlet UIButton *exitButton;
@property (nonatomic, retain) IBOutlet UILabel *toneLabel;
@property (nonatomic, retain) IBOutlet UILabel *outputLabel;
@property (nonatomic, retain) IBOutlet UILabel *speakerLabel;
@property (nonatomic, retain) IBOutlet UILabel *auxLabel;
@property (nonatomic, retain) IBOutlet UILabel *slidingLabel;
@property (nonatomic, retain) IBOutlet UILabel *offLabel;
@property (nonatomic, retain) IBOutlet UILabel *onLabel;
@property (nonatomic, retain) IBOutlet UILabel *exitToMainLabel;

- (void)localizeViews;

@end
