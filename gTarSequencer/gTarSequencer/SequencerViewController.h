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
#import "GatekeeperViewController.h"
#import "CloudController.h"
#import "SCUI.h"
#import "NSSong.h"

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

extern CloudController * g_cloudController;
extern NSUser * g_loggedInUser;

@interface SequencerViewController : UIViewController <GuitarViewDelegate,PlayControlDelegate,SeqSetDelegate,LeftNavigatorDelegate,OptionsDelegate,InstrumentDelegate,InfoDelegate,TutorialDelegate,RecordShareDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,GatekeeperDelegate> {
    
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
    double playVolume;
    
    NSMutableArray * patternQueue;
    
    // Record
    BOOL isRecording;
    NSMutableArray * tempMeasures;
    int startPatterns[5];
    BOOL forceRecord;
    NSSong * recordingSong;
    int r_beat;
    
    // Save/Load
    NSString * activeSong;
    NSString * activeSequencer;
    NSString * sequencerToSave;
    
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
    FrameGenerator * frameGenerator;
    CGRect setNameOnScreenFrame;
    CGRect setNameOffScreenFrame;
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
@property (retain, nonatomic) GatekeeperViewController * gatekeeperViewController;

@property (retain, nonatomic) UIButton * setName;

@property (retain, nonatomic) NSSong * loadedSong;

// FTU Tutorial
//@property (weak, nonatomic) IBOutlet UIButton * yesButton;
//@property (weak, nonatomic) IBOutlet UIButton * noButton;

@end
