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
- (void)backButtonClicked;

@end

@interface FPMenuViewController : UIViewController {
    
    BOOL audioSwitchOn;
    
}

@property (nonatomic, weak) id <FPMenuDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton *exitButton;
@property (nonatomic, strong) IBOutlet UILabel *quitLabel;
@property (nonatomic, strong) IBOutlet UILabel *outputLabel;
@property (nonatomic, strong) IBOutlet UILabel *speakerLabel;
@property (nonatomic, strong) IBOutlet UILabel *auxLabel;
@property (nonatomic, strong) IBOutlet UILabel *slidingLabel;
@property (nonatomic, strong) IBOutlet UILabel *offLabel;
@property (nonatomic, strong) IBOutlet UILabel *onLabel;
@property (nonatomic, strong) IBOutlet UILabel *exitToMainLabel;
@property (strong, nonatomic) IBOutlet UISwitch *audioRouteSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *slideSwitch;
//@property (retain, nonatomic) IBOutlet UITextField *testText;

// Tone
//@property (nonatomic, strong) IBOutlet UILabel *toneLabel;
//@property (strong, nonatomic) IBOutlet UISlider *toneSlider;
//@selector(setTone:)

- (void)localizeViews;
- (void)setAudioSwitchToDefault;
- (void)setAudioSwitchToSpeaker;
- (void)moveToneSliderToTone:(double)tone;

@end
