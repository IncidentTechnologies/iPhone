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
#import "SeqSetViewController.h"
#import "PlayControlViewController.h"
#import "LeftNavigatorViewController.h"
#import "OptionsViewController.h"
#import "InstrumentViewController.h"
#import "InfoViewController.h"

@interface SequencerViewController : UIViewController <GuitarViewDelegate,PlayControlDelegate,SeqSetDelegate,LeftNavigatorDelegate,OptionsDelegate,InstrumentDelegate,InfoDelegate> {
    
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
    double playVolume;
    
    NSMutableArray * patternQueue;
    
    // Subviews
    UIViewController * shareViewController;
    
    // State
    NSMutableDictionary * currentState;
    NSString * instrumentDataFilePath;
    
    // Save/Load
    NSString * activeSequencer;
    CGRect onScreenSaveLoadFrame;
    CGRect offLeftSaveLoadFrame;
    
    // Left nav
    BOOL leftNavOpen;
    CGRect onScreenNavigatorFrame;
    CGRect offLeftNavigatorFrame;
    CGRect onScreenMainFrame;
    CGRect overScreenMainFrame;
    UIView * activeMainView;
    
    UISwipeGestureRecognizer * swipeLeft;
    UISwipeGestureRecognizer * swipeRight;
}

@property (retain, nonatomic) OptionsViewController * optionsViewController;
@property (retain, nonatomic) SeqSetViewController * seqSetViewController;
@property (retain, nonatomic) InstrumentViewController * instrumentViewController;
@property (retain, nonatomic) InfoViewController * infoViewController;
@property (retain, nonatomic) PlayControlViewController * playControlViewController;
@property (retain, nonatomic) LeftNavigatorViewController * leftNavigator;

@end
