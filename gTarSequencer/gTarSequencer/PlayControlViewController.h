//
//  PlayControlViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/2/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "RadialButton.h"
#import "VolumeButton.h"

@protocol PlayControlDelegate <NSObject>

- (void) stopAllPlaying;
- (void) startAllPlaying:(float)secondsperbeat withAmplitude:(double)volume;

- (void) initPlayLocation;

- (void) saveContext:(NSString *)filepath;
- (void) userDidLoadSequenceOptions;

@end


@interface PlayControlViewController : UIViewController <RadialButtonDelegate,VolumeButtonDelegate>
{
    // Tempo slider
    int tempo;
    
    // Volume slider
    double volume;
    
    // Play loop
    BOOL isPlaying;
    float secondsPerBeat;
   
}

- (IBAction)userDidLoadOptions:(id)sender; // TODO: move to left nav
- (IBAction)startStop:(id)sender;
- (void)stopAll;

- (int)getTempo;
- (void)resetTempo;
- (void)setTempo:(int)newTempo;

- (double)getVolume;
- (void)resetVolume;
- (void)setVolume:(double)newVolume;

@property (weak, nonatomic) id<PlayControlDelegate> delegate;
@property (weak, nonatomic) IBOutlet RadialButton * tempoSlider;
@property (weak, nonatomic) IBOutlet VolumeButton * volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton * startStopButton;

@end
