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
#import "TutorialViewController.h"
#import "RecordShareViewController.h"

@interface SequencerViewController : UIViewController <GuitarViewDelegate,PlayControlDelegate,SeqSetDelegate,LeftNavigatorDelegate,OptionsDelegate,InstrumentDelegate,InfoDelegate,TutorialDelegate,RecordShareDelegate> {
    
    // tutorial
    BOOL isTutorialOpen;
    
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
    BOOL isRecording;
    double playVolume;
    
    NSMutableArray * patternQueue;
    
    // State
    NSMutableDictionary * currentState;
    NSString * instrumentDataFilePath;
    
    // Save/Load
    NSString * activeSequencer;
    
    // Left nav
    BOOL leftNavOpen;
    CGRect onScreenNavigatorFrame;
    CGRect offLeftNavigatorFrame;
    CGRect onScreenMainFrame;
    CGRect overScreenMainFrame;
    UIView * activeMainView;
    
    UISwipeGestureRecognizer * swipeLeft;
    UISwipeGestureRecognizer * swipeRight;
    
    // Screen
    BOOL isScreenLarge;
    CGRect setNameOnScreenFrame;
    CGRect setNameOffScreenFrame;
    
    NSTimer * saveContextTimer;
}

@property (nonatomic) BOOL isFirstLaunch;
@property (retain, nonatomic) OptionsViewController * optionsViewController;
@property (retain, nonatomic) SeqSetViewController * seqSetViewController;
@property (retain, nonatomic) InstrumentViewController * instrumentViewController;
@property (retain, nonatomic) InfoViewController * infoViewController;
@property (retain, nonatomic) PlayControlViewController * playControlViewController;
@property (retain, nonatomic) TutorialViewController * tutorialViewController;
@property (retain, nonatomic) LeftNavigatorViewController * leftNavigator;
@property (retain, nonatomic) RecordShareViewController * recordShareController;

@property (retain, nonatomic) UIButton * setName;

// FTU Tutorial
//@property (weak, nonatomic) IBOutlet UIButton * yesButton;
//@property (weak, nonatomic) IBOutlet UIButton * noButton;

@end
