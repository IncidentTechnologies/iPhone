//
//  DefaultViewController.h
//  gTarCreate
//
//  Created by Idan Beck on 2/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKnob.h"
#import "UILevelSlider.h"

#import "CreateRootViewController.h"
#import "SettingsViewController.h"
#import "SynthViewController.h"
#import "GtarViewController.h"
#import "LEDViewController.h"

@interface DefaultViewController : UIViewController {
    UINavigationController *m_navigationController;
    
    CreateRootViewController *m_createRootViewController;
    SettingsViewController *m_settingsViewController;
    SynthViewController *m_synthViewController;
    GtarViewController *m_gtarViewController;
    LEDViewController *m_ledViewController;
}

@property (nonatomic, retain) IBOutlet UIView *m_navView;

@property (nonatomic, retain) IBOutlet UIButton *m_buttonSynth;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonEffects;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonLED;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonGtar;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonSettings;

@property (nonatomic, retain) IBOutlet UIButton *m_buttonTest;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonTrigger;
@property (nonatomic, retain) IBOutlet UISlider *m_sliderVolume;

@property (nonatomic, retain) IBOutlet UIKnob *m_knob;
@property (nonatomic, retain) IBOutlet UILevelSlider *m_levelSlider;

-(IBAction)onButtonTestClicked:(id)sender;
-(IBAction)onButtonTriggerClicked:(id)sender;
-(IBAction)onSliderChanged:(id)sender;
-(IBAction)onKnobChanged:(id)sender;
-(IBAction)onLevelSliderChanged:(id)sender;

-(void)setUpSamplerWithBaseName:(NSString *)strBaseName;

-(void) testFxNode;
-(void) testFilenode;
-(void)testDisconnect;

-(IBAction)onNavButtonClicked:(id)sender;


@end
