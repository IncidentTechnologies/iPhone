//
//  SequencerViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuitarView.h"

#import "RadialButton.h"
#import "ScrollingSelector.h"

#import "InstrumentTableViewController.h"

@interface SequencerViewController : UIViewController <GuitarViewDelegate, RadialButtonDelegate> {

    // gtar connection
    BOOL isConnected;
    GuitarView *guitarView;
    int string;
    int fret;

    // play loop
    BOOL isPlaying;
    int tempo;
    double secondsPerBeat;
    NSTimer * playTimer;
    int currentFret;
    int currentAbsoluteMeasure;
    
    InstrumentTableViewController * instrumentTableViewController;
    
    IBOutlet UIImageView * gTarLogoImageView;
    
}

- (IBAction)startStop:(id)sender;

@property (retain, nonatomic) IBOutlet InstrumentTableViewController * instrumentTableViewController;

@property (retain, nonatomic) IBOutlet UIButton * startStopButton;
@property (retain, nonatomic) IBOutlet UIImageView * gTarLogoImageView;
@property (retain, nonatomic) IBOutlet UILabel * gTarConnectedText;
@property (weak, nonatomic) IBOutlet RadialButton * tempoSlider;


@end
