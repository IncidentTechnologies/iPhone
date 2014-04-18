//
//  FPMenuViewController.h
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import <UIKit/UIKit.h>

@protocol FPMenuDelegate

- (void)audioRouteChanged:(BOOL)routeIsSpeaker;
- (void)setToneToBWCutoff:(double)tone;

@end

@interface FPMenuViewController : UIViewController {
    
    BOOL audioSwitchOn;
    
}

@property (nonatomic, assign) id <FPMenuDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *exitButton;
@property (nonatomic, retain) IBOutlet UILabel *quitLabel;
@property (nonatomic, retain) IBOutlet UILabel *toneLabel;
@property (nonatomic, retain) IBOutlet UILabel *outputLabel;
@property (nonatomic, retain) IBOutlet UILabel *speakerLabel;
@property (nonatomic, retain) IBOutlet UILabel *auxLabel;
@property (nonatomic, retain) IBOutlet UILabel *slidingLabel;
@property (nonatomic, retain) IBOutlet UILabel *offLabel;
@property (nonatomic, retain) IBOutlet UILabel *onLabel;
@property (nonatomic, retain) IBOutlet UILabel *exitToMainLabel;
@property (retain, nonatomic) IBOutlet UISlider *toneSlider;
@property (retain, nonatomic) IBOutlet UISwitch *audioRouteSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *slideSwitch;
//@property (retain, nonatomic) IBOutlet UITextField *testText;

- (void)localizeViews;
- (void)setAudioSwitchToDefault;
- (void)setAudioSwitchToSpeaker;
- (void)moveToneSliderToTone:(double)tone;

@end
