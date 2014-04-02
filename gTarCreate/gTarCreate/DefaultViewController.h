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

@interface DefaultViewController : UIViewController {
    
}

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

@end
