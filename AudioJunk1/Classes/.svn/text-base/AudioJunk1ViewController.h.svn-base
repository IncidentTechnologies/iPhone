//
//  AudioJunk1ViewController.h
//  AudioJunk1
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"
#import "FretButton.h"
#import "SerialPort.h"

#import "CoreMidiObject.h"

const int g_NumStrings = 6;
const int g_NumFrets = 12;

@interface AudioJunk1ViewController : UIViewController <UIApplicationDelegate, UIScrollViewDelegate>
{
	IBOutlet UISegmentedControl *segWaveform;
	
	// KS Stuff
	IBOutlet UIButton ***pppPluckButtons;
	IBOutlet UISlider *attenSlider;
	IBOutlet UILabel *attenLabel;
    
    IBOutlet UILabel *cutoffLabel;
    IBOutlet UISlider *cutoffSlider;
    
    IBOutlet UILabel *ksCutoffLabel;
    IBOutlet UISlider *ksCutoffSlider;
    
    IBOutlet UILabel *ksOrderLabel;
    IBOutlet UISlider *ksOrderSlider;
	
	// The grid
	IBOutlet UIScrollView *mainScroll;
	
	// Serial stuff
	SerialPort *m_psp;
	
	NSTimer *serialRxTimer;
    
@public
    AudioController *audioController;    
    CoreMidiObject *m_pCoreMidiObject;
}

@property (nonatomic, retain) MidiMonitorView *m_MidiMonitorView;

@property (nonatomic, retain) UIScrollView *mainScroll;

@property (nonatomic, readonly) AudioController *audioController;
@property (nonatomic, retain) UISegmentedControl *segWaveform;
//@property (nonatomic, retain) UIButton *pluckButton;
@property (nonatomic, retain) UISlider *attenSlider;
@property (nonatomic, retain) UILabel *attenLabel;

@property (nonatomic, retain) UILabel *cutoffLabel;
@property (nonatomic, retain) UISlider *cutoffSlider;

@property (nonatomic, retain) UILabel *ksCutoffLabel;
@property (nonatomic, retain) UISlider *ksCutoffSlider;

@property (nonatomic, retain) UILabel *ksOrderLabel;
@property (nonatomic, retain) UISlider *ksOrderSlider;

- (IBAction) changeSegControl:(id)sender;

- (IBAction) pluckButtonClick:(id)sender;
//- (IBAction) pluckButtonClickDown:(id)sender;

- (IBAction) changeAttenSlider:(id)sender;

- (IBAction) changeCutoffSlider:(id)sender;

- (IBAction) changeKsCutoffSlider:(id)sender;
- (IBAction) changeKsOrderSlider:(id)sender;

- (void) checkRxSerialInput;

- (id) initWithTabBar;

// C style
int CoreMidiCallback(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext);

@end

