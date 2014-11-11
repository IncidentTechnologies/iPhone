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
#import "HorizontalAdjustor.h"
#import "RecordEditor.h"
//#import "SCUI.h"

#define MAX_TRACKS 5.0
#define MIN_MEASURES 7.0
#define MAX_MEASURES 1000
#define MEASURES_PER_SCREEN 8.0
#define MEASURE_BEATS 4.0
#define EDITING_OFFSET 65.0

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@protocol RecordShareDelegate <NSObject>

- (void) refreshSong:(NSSong *)song;
- (void) viewSeqSetWithAnimation:(BOOL)animate;
- (void) recordPlaybackDidEnd;
- (void) userDidLaunchEmailWithAttachment:(NSString *)filename xmpId:(NSInteger)xmpId;
- (void) userDidLaunchSMSWithAttachment:(NSString *)filename xmpId:(NSInteger)xmpId;
- (void) userDidLaunchSoundCloudAuthWithFile:(NSString *)filename xmpId:(NSInteger)xmpId;

- (void) renameForXmpId:(NSInteger)xmpId FromName:(NSString *)filename toName:(NSString *)newname andType:(NSString *)type;

- (void) forceShowSessionOverlay;
- (void) forceHideSessionOverlay;

- (void) showRecordOverlay;
- (void) hideRecordOverlay;

- (NSMutableArray *)getTracks;

- (void)startSoundMaster;
- (void)stopSoundMaster;

@end

extern OphoMaster * g_ophoMaster;
extern NSUser * g_loggedInUser;

@interface RecordShareViewController : MainEventController <UIScrollViewDelegate, UITextFieldDelegate,UITextViewDelegate,NSSongModelDelegate,RecordEditorDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray * instruments;
    NSMutableArray * tracks;
    NSMutableArray * tickmarks;
    
    int numMeasures;
    
    // Recording
    NSTimer * recordTimer;
    BOOL isWritingFile;
    
    int r_measure;
    int r_beat;
    
    float secondperbeat;
    
    NSSequence * loadedSequence;
    float loadedTempo;
    double secondsPerBeat;
    SoundMaster * loadedSoundMaster;
    
    // Editing
    RecordEditor * recordEditor;
    NSMutableArray * gridOverlayLines;
    BOOL isEditingOffset;
    float measureWidth;
    float trackViewVerticalOffset;
    
    // Playback
    NSTimer * playTimer;
    NSString * sessionFilepath;
    BOOL isAudioPlaying;
    
    // Playband
    UIView * measurePlaybandView;
    NSTimer * playbandTimer;
    int playMeasure;
    int playFret;
    BOOL isPlaybandAnimating;
    
    UIPanGestureRecognizer * panProgressView;
    float panProgressViewFirstX;
    
    // Sharing
    NSString * selectedShareType;
    
}

- (void)reloadInstruments;
- (void)clearLoadedSong;
- (void)loadSong:(NSSong *)song andSoundMaster:(SoundMaster *)soundMaster activeSequence:(NSSequence *)activeSequence;

- (IBAction)userDidBack:(id)sender;
- (BOOL)showHideSessionOverlay;
- (void)openShareScreen;

- (void)playRecordPlayback;
- (void)stopRecordPlayback;
- (void)pauseRecordPlayback;

//- (void)interruptRecording;

- (NSString *)generateNextRecordedSongName;

- (IBAction)userDidSelectShare:(id)sender;

@property (weak, nonatomic) id<RecordShareDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton * backButton;
@property (weak, nonatomic) IBOutlet UIView * progressView;
@property (weak, nonatomic) IBOutlet UIView * instrumentView;
@property (weak, nonatomic) IBOutlet UIView * editingView;
@property (weak, nonatomic) IBOutlet UIScrollView * trackView;
@property (retain, nonatomic) UIView * progressViewIndicator;

@property (weak, nonatomic) IBOutlet UIView * noSessionOverlay;
@property (weak, nonatomic) IBOutlet UILabel * noSessionLabel;

@property (weak, nonatomic) IBOutlet UIButton * shareEmailButton;
@property (weak, nonatomic) IBOutlet UIButton * shareSMSButton;
@property (weak, nonatomic) IBOutlet UIButton * shareSoundcloudButton;
//@property (weak, nonatomic) IBOutlet UIButton * shareFacebookButton;

@property (retain, nonatomic) UIButton * cancelButton;

@property (retain, nonatomic) UIView * shareScreen;
@property (retain, nonatomic) UIView * shareView;
@property (retain, nonatomic) IBOutlet UIView * processingScreen;

@property (nonatomic, weak) IBOutlet UITextField * songNameField;
@property (nonatomic, weak) IBOutlet UITextView * songDescriptionField;

@property (nonatomic, weak) IBOutlet UIView * playbandView;

@property (retain, nonatomic) NSSong * recordingSong;
@property (retain, nonatomic) NSSongModel * songModel;

// Editing panel
@property (retain, nonatomic) IBOutlet UIButton * addMeasureButton;
@property (retain, nonatomic) IBOutlet UIButton * duplicateMeasureButton;
@property (retain, nonatomic) IBOutlet UIButton * pasteMeasureButton;
@property (retain, nonatomic) IBOutlet UIButton * editMeasureButton;
@property (retain, nonatomic) IBOutlet UIButton * saveTrackButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint * addMeasureWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * duplicateMeasureWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * pasteMeasureWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * editMeasureWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * saveTrackWidth;

- (IBAction)userDidAddMeasure:(id)sender;
- (IBAction)userDidCopyMeasure:(id)sender;
- (IBAction)userDidPasteMeasure:(id)sender;
- (IBAction)userDidEditMeasure:(id)sender;
- (IBAction)userDidSaveTrack:(id)sender;

@end
