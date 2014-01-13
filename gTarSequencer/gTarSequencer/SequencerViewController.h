//
//  SequencerViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuitarView.h"
#import "SoundMaker.h"
#import "RadialButton.h"
#import "ScrollingSelector.h"
#import "SEQNote.h"
#import "InstrumentTableViewController.h"
#import "PlayControlViewController.h"

@interface SequencerViewController : UIViewController <GuitarViewDelegate,PlayControlDelegate,InstrumentDelegate> {

    // gtar connection
    BOOL isConnected;
    GuitarView *guitarView;
    int string;
    int fret;
    
    IBOutlet UIImageView * gTarLogoImageView;
    
    // play loop
    NSTimer * playTimer;
    int currentFret;
    int currentAbsoluteMeasure;
    BOOL isPlaying;
    
    // instruments
    float secondsPerBeat;
    NSMutableArray * instruments;
    
    int selectedInstrumentIndex;
    NSMutableArray * patternQueue;
    
    // Subviews
    InstrumentTableViewController * instrumentTableViewController;
    PlayControlViewController * playControlViewController;
}

@property (retain, nonatomic) InstrumentTableViewController * instrumentTableViewController;
@property (retain, nonatomic) PlayControlViewController * playControlViewController;

@property (retain, nonatomic) IBOutlet UIImageView * gTarLogoImageView;
@property (retain, nonatomic) IBOutlet UILabel * gTarConnectedText;


@end
