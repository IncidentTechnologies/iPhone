//
//  RecordShareViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 3/25/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "Instrument.h"
#import <AVFoundation/AVFoundation.h>

#define MAX_INSTRUMENTS 5
#define MIN_MEASURES 8
#define MEASURES_PER_SCREEN 8.0

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@protocol RecordShareDelegate <NSObject>

- (void) viewSeqSetWithAnimation:(BOOL)animate;
- (void) recordPlaybackDidEnd;

- (NSMutableArray *)getInstruments;

@end

@interface RecordShareViewController : UIViewController <UIScrollViewDelegate,AVAudioPlayerDelegate>
{
    NSMutableArray * loadedPattern;
    NSMutableArray * instruments;
    NSMutableArray * tracks;
    NSMutableArray * tickmarks;
    
    int numMeasures;
    
    NSString * prevPattern[MAX_INSTRUMENTS];
    NSString * prevInterruptPattern[MAX_INSTRUMENTS];
    double prevTranspose[MAX_INSTRUMENTS];
    
    // Recording
    NSTimer * recordTimer;
    
    int r_measure;
    int r_beat;
    
    float secondperbeat;
    
    // Playback
    AVAudioPlayer * audioPlayer;
    NSString * sessionFilepath;
    BOOL isAudioPlaying;
}

- (void)reloadInstruments;
- (void)loadPattern:(NSMutableArray *)patternData withTempo:(int)tempo andSoundMaster:(SoundMaster *)m_soundMaster;
- (IBAction)userDidBack:(id)sender;
- (BOOL)showHideSessionOverlay;
- (void)openShareScreen;

- (void)playRecordPlayback;
- (void)stopRecordPlayback;
- (void)pauseRecordPlayback;

@property (weak, nonatomic) id<RecordShareDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton * backButton;
@property (weak, nonatomic) IBOutlet UIView * progressView;
@property (weak, nonatomic) IBOutlet UIView * instrumentView;
@property (weak, nonatomic) IBOutlet UIScrollView * trackView;
@property (retain, nonatomic) UIView * progressViewIndicator;
@property (weak, nonatomic) IBOutlet UIView * noSessionOverlay;

@property (weak, nonatomic) IBOutlet UIButton * shareEmailButton;
@property (weak, nonatomic) IBOutlet UIButton * shareSMSButton;
@property (weak, nonatomic) IBOutlet UIButton * shareSoundcloudButton;
@property (weak, nonatomic) IBOutlet UIButton * shareFacebookButton;

@property (weak, nonatomic) IBOutlet UIButton * shareEmailSelector;
@property (weak, nonatomic) IBOutlet UIButton * shareSMSSelector;
@property (weak, nonatomic) IBOutlet UIButton * shareSoundcloudSelector;
@property (weak, nonatomic) IBOutlet UIButton * shareFacebookSelector;
@end
