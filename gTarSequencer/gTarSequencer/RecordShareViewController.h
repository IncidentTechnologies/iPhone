//
//  RecordShareViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 3/25/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "NSSequence.h"
#import "NSSong.h"
#import "NSSongModel.h"
#import "MainEventController.h"
#import <AVFoundation/AVFoundation.h>
#import "HorizontalAdjustor.h"
//#import "SCUI.h"

#define MAX_TRACKS 5.0
#define MIN_MEASURES 8.0
#define MEASURES_PER_SCREEN 8.0

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@protocol RecordShareDelegate <NSObject>

- (void) viewSeqSetWithAnimation:(BOOL)animate;
- (void) recordPlaybackDidEnd;
- (void) userDidLaunchEmailWithAttachment:(NSString *)filename;
- (void) userDidLaunchSMSWithAttachment:(NSString *)filename;
- (void) userDidLaunchSoundCloudAuthWithFile:(NSString *)filename;

- (void) renameFromName:(NSString *)filename toName:(NSString *)newname andType:(NSString *)type;

- (void) forceShowSessionOverlay;
- (void) forceHideSessionOverlay;

- (void) showRecordOverlay;
- (void) hideRecordOverlay;

- (NSMutableArray *)getTracks;

- (void)startSoundMaster;
- (void)stopSoundMaster;

@end

extern NSUser * g_loggedInUser;

@interface RecordShareViewController : MainEventController <UIScrollViewDelegate,AVAudioPlayerDelegate, UITextFieldDelegate,UITextViewDelegate,NSSongModelDelegate,HorizontalAdjustorDelegate>
{
    NSMutableArray * instruments;
    NSMutableArray * tracks;
    NSMutableArray * tickmarks;
    NSMutableDictionary * trackclips;
    
    int numMeasures;
    
    // Recording
    NSTimer * recordTimer;
    BOOL isWritingFile;
    
    int r_measure;
    int r_beat;
    
    float secondperbeat;
    
    NSSequence * loadedSequence;
    float loadedTempo;
    SoundMaster * loadedSoundMaster;
    
    // Editing
    NSTrack * editingTrack;
    NSClip * editingClip;
    NSClip * blinkingClip;
    UIView * editingClipView;
    UIView * editingClipLeftSlider;
    UIView * editingClipRightSlider;
    UILabel * editingPatternLetter;
    UIButton * editingPatternLetterOverlay;
    HorizontalAdjustor * horizontalAdjustor;
    float lastDiff;
    
    // Playback
    AVAudioPlayer * audioPlayer;
    NSString * sessionFilepath;
    BOOL isAudioPlaying;
    
    // Playband
    UIView * measurePlaybandView;
    NSTimer * playbandTimer;
    int playMeasure;
    int playFret;
    BOOL isPlaybandAnimating;
    
    // Sharing
    NSString * selectedShareType;
}

- (void)reloadInstruments;
- (void)loadSong:(NSSong *)song andSoundMaster:(SoundMaster *)soundMaster activeSequence:(NSSequence *)activeSequence activeSong:(NSString *)activeSong;

- (IBAction)userDidBack:(id)sender;
- (BOOL)showHideSessionOverlay;
- (void)openShareScreen;

- (void)playRecordPlayback;
- (void)stopRecordPlayback;
- (void)pauseRecordPlayback;

- (void)interruptRecording;

- (NSString *)generateNextRecordedSongName;

- (IBAction)userDidSelectShare:(id)sender;

@property (weak, nonatomic) id<RecordShareDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton * backButton;
@property (weak, nonatomic) IBOutlet UIView * progressView;
@property (weak, nonatomic) IBOutlet UIView * instrumentView;
@property (weak, nonatomic) IBOutlet UIScrollView * trackView;
@property (retain, nonatomic) UIView * progressViewIndicator;

@property (weak, nonatomic) IBOutlet UIView * noSessionOverlay;
@property (weak, nonatomic) IBOutlet UILabel * noSessionLabel;
@property (weak, nonatomic) IBOutlet UILabel * processingLabel;

@property (weak, nonatomic) IBOutlet UIButton * shareEmailButton;
@property (weak, nonatomic) IBOutlet UIButton * shareSMSButton;
@property (weak, nonatomic) IBOutlet UIButton * shareSoundcloudButton;
//@property (weak, nonatomic) IBOutlet UIButton * shareFacebookButton;

@property (retain, nonatomic) UIButton * cancelButton;

@property (retain, nonatomic) UIView * shareScreen;
@property (retain, nonatomic) UIView * shareView;

@property (nonatomic, weak) IBOutlet UITextField * songNameField;
@property (nonatomic, weak) IBOutlet UITextView * songDescriptionField;

@property (nonatomic, weak) IBOutlet UIView * playbandView;

@property (retain, nonatomic) NSSong * recordingSong;
@property (retain, nonatomic) NSSongModel * songModel;

@end
