//
//  SequencerViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "GuitarView.h"
#import "SoundMaker.h"
#import "RadialButton.h"
#import "ScrollingSelector.h"
#import "SEQNote.h"
#import "InstrumentTableViewController.h"
#import "PlayControlViewController.h"

@interface SequencerViewController : UIViewController <GuitarViewDelegate,PlayControlDelegate,InstrumentDelegate> {
    
    // gTar connection
    BOOL isConnected;
    GuitarView *guitarView;
    int string;
    int fret;
    
    // Play loop
    NSTimer * playTimer;
    int currentFret;
    int currentAbsoluteMeasure;
    BOOL isPlaying;

    NSMutableArray * patternQueue;
    
    // Subviews
    InstrumentTableViewController * instrumentTableViewController;
    PlayControlViewController * playControlViewController;
    
    IBOutlet UIImageView * gTarLogoImageView;
    
    // State
    NSMutableDictionary * currentState;
    NSString * instrumentDataFilePath;
}

@property (retain, nonatomic) InstrumentTableViewController * instrumentTableViewController;
@property (retain, nonatomic) PlayControlViewController * playControlViewController;

@property (retain, nonatomic) IBOutlet UIImageView * gTarLogoImageView;
@property (retain, nonatomic) IBOutlet UILabel * gTarConnectedText;


@end
