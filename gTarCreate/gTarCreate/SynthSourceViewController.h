//
//  SynthSourceViewController.h
//  gTarCreate
//
//  Created by Idan Beck on 5/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UILevelSlider.h>
#import <UIKnob.h>

typedef enum {
    SYNTH_OFF,
    SYNTH_SINE,
    SYNTH_SAW,
    SYNTH_SQUARE,
    SYNTH_TRIANGLE,
    SYNTH_COUNT
} SYNTH_TYPE;

@interface SynthSourceViewController : UIViewController {
    int m_synthType;
}

// Synth Type
@property (nonatomic, retain) IBOutlet UILabel *m_labelSynthType;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonTypeLeft;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonTypeRight;

// Controls
@property (nonatomic, retain) IBOutlet UIKnob *m_knobOctave;
@property (nonatomic, retain) IBOutlet UIKnob *m_knobTune;
@property (nonatomic, retain) IBOutlet UIKnob *m_knobPhase;

@property (nonatomic, retain) IBOutlet UILevelSlider *m_levelSliderVolume;


- (IBAction) OnTypeClick:(id)sender;

@end
