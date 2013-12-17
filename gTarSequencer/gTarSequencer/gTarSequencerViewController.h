//
//  MultipleTracksViewController.h
//  gTarSequencer
//
//  Created by Ilan Gray on 7/9/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuitarView.h"
#import "Instrument.h"
#import "SoundMaker.h"
#import "ScrollButton.h"
#import "ScrollingSelector.h"
#import "SEQNote.h"
#import "TouchCatcher.h"

#define DEFAULT_TEMPO 120
#define MAX_SEQUENCES 15
#define LAST_FRET 15
#define LAST_MEASURE 3
#define SECONDS_PER_MIN 60.0

@class InstrumentCell;

@interface gTarSequencerViewController : UIViewController <UITableViewDelegate, ScrollButtonDelegate, ScrollingSelectorDelegate, GuitarViewDelegate>
{    
    BOOL isConnected;
    
    int string;
    int fret;
    
    BOOL isPlaying;
    int tempo;
    double secondsPerBeat;
    NSTimer * playTimer;
    int currentFret;
    int currentAbsoluteMeasure;
    
    
    NSMutableArray *patternQueue;
    
    GuitarView *guitarView;
    
    NSMutableArray * instruments;
    int selectedInstrumentIndex;
    
    ScrollingSelector * instrumentSelector;
    CGRect onScreenSelectorFrame;
    CGRect offLeftSelectorFrame;
    
    NSMutableArray * masterInstrumentOptions;
    NSMutableArray * remainingInstrumentOptions;
    
    NSString * instrumentDataFilePath;
    NSMutableDictionary * currentState;
}

- (void)userDidSelectMeasure:(id)sender atIndex:(int)index;
- (void)userDidSelectPattern:(id)sender atIndex:(int)index;
- (void)userDidAddMeasures:(id)sender;
- (void)userDidRemoveMeasures:(id)sender;

- (void)muteInstrument:(InstrumentCell *)sender;
- (void)unmuteInstrument:(InstrumentCell *)sender;

- (IBAction)startStop:(id)sender;
- (IBAction)playSomeNotes:(id)sender;

- (void)deleteCell:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton       *playNotesButton;
@property (weak, nonatomic) IBOutlet UITableView    *instrumentTable;
@property (weak, nonatomic) IBOutlet ScrollButton   *tempoSlider;
@property (weak, nonatomic) IBOutlet UIButton       *startStopButton;
@property (weak, nonatomic) IBOutlet UIImageView    *gTarLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView    *gTarConnectedText;


@end
