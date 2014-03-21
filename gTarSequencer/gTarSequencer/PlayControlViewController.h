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

- (void) saveContext:(NSString *)filepath;
- (void) userDidLoadSequenceOptions;

- (void) stopGestures;
- (void) startGestures;
- (void) stopDrawing;
- (void) startDrawing;

- (void) endTutorialIfOpen;

- (NSMutableArray *)getInstruments;

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
    float secondsPerBeat;
    
    VolumeDisplay * volumeDisplay;
   
}

- (IBAction)userDidLoadOptions:(id)sender; // TODO: move to left nav
- (IBAction)startStop:(id)sender;
- (IBAction)toggleVolumeOpen:(id)sender;
- (void)stopAll;

- (int)getTempo;
- (void)resetTempo;
- (void)setTempo:(int)newTempo;

- (double)getVolume;
- (void)resetVolume;
- (void)setVolume:(double)newVolume;

@property (weak, nonatomic) id<PlayControlDelegate> delegate;
@property (weak, nonatomic) IBOutlet RadialButton * tempoSlider;
@property (weak, nonatomic) IBOutlet UIButton * volumeButton;
@property (weak, nonatomic) IBOutlet UIButton * startStopButton;

@end
