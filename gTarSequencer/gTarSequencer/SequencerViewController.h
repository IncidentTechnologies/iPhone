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
#import "SaveLoadSelector.h"

@interface SequencerViewController : UIViewController <GuitarViewDelegate,PlayControlDelegate,InstrumentDelegate,SaveLoadSelectorDelegate> {
    
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
    
    // State
    NSMutableDictionary * currentState;
    NSString * instrumentDataFilePath;
    
    // Save/Load
    NSString * activeSequencer;
    SaveLoadSelector * saveLoadSelector;
    CGRect onScreenSaveLoadFrame;
    CGRect offLeftSaveLoadFrame;
    
}

@property (retain, nonatomic) InstrumentTableViewController * instrumentTableViewController;
@property (retain, nonatomic) PlayControlViewController * playControlViewController;

@property (retain, nonatomic) UIButton * gTarConnectedBar;


@end
