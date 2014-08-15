//
//  PlayControlViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/2/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "RadialButton.h"
#import "VolumeDisplay.h"

@protocol PlayControlDelegate <NSObject>

- (void) stopAllPlaying;
- (void) startAllPlaying:(float)secondsperbeat withAmplitude:(double)volume;
- (void) changePlayVolume:(double)newVolume;
- (void) refreshVolumeSliders;

- (void) initPlayLocation;
- (void) resetPlayLocation;

- (void) playRecordPlayback;
- (void) pauseRecordPlayback;

- (void) saveContext:(NSString *)filepath force:(BOOL)forceSave;
- (void) userDidLoadSequenceOptions;

- (void) stopGestures;
- (void) startGestures;
- (void) stopDrawing;
- (void) startDrawing;

- (void) endTutorialIfOpen;

- (NSMutableArray *)getTracks;
- (void) openInstrument:(int)instIndex;

- (void) setRecordMode:(BOOL)record andAnimate:(BOOL)animate;

- (void) userDidSelectShare;

- (void) enableInstrument:(int)instIndex;
- (void) disableInstrument:(int)instIndex;

- (void) commitMasterLevelSlider:(UILevelSlider *)masterSlider;

- (void)updateTempo:(int)tempo;

@end


@interface PlayControlViewController : UIViewController <RadialButtonDelegate,VolumeDisplayDelegate>
{
    // Tempo slider
    int tempo;
    BOOL isTempoSliderOpen;
    
    // Volume slider
    double volume;
    BOOL isVolumeSliderOpen;
    
    // Play loop
    BOOL isPlaying;
    BOOL isPlaybackPlaying;
    BOOL isRecording;
    float secondsPerBeat;
    
    VolumeDisplay * volumeDisplay;
    
   
}

- (IBAction)userDidLoadOptions:(id)sender; // TODO: move to left nav
- (IBAction)startStop:(id)sender;
- (IBAction)startStopRecordPlayback:(id)sender;
- (IBAction)toggleVolumeOpen:(id)sender;
- (IBAction)recordSession:(id)sender;
- (IBAction)userDidSelectShare:(id)sender;
- (void)stopPlayRecordAndAnimate:(BOOL)animate showEndScreen:(BOOL)showEndScreen;

- (void)pauseRecordPlayback;

- (int)getTempo;
- (void)resetTempo;
- (void)setTempo:(int)newTempo;

- (double)getVolume;
- (void)resetVolume;
- (void)setVolume:(double)newVolume;

- (void)setShareMode:(BOOL)share;
- (void)setLockRecord:(BOOL)lock;

- (void)showSessionOverlay;
- (void)hideSessionOverlay;
- (void)showRecordOverlay;
- (void)hideRecordOverlay;

@property (weak, nonatomic) id<PlayControlDelegate> delegate;
@property (weak, nonatomic) IBOutlet RadialButton * tempoSlider;
@property (weak, nonatomic) IBOutlet UIButton * volumeButton;
@property (weak, nonatomic) IBOutlet UIButton * startStopButton;
@property (weak, nonatomic) IBOutlet UIButton * recordPlaybackButton;
@property (weak, nonatomic) IBOutlet UIButton * recordButton;
@property (weak, nonatomic) IBOutlet UIButton * shareButton;

@property (weak, nonatomic) IBOutlet UIView * disableShare;
@property (weak, nonatomic) IBOutlet UIView * disablePlay;
@property (weak, nonatomic) IBOutlet UIView * disableRecord;

@end
