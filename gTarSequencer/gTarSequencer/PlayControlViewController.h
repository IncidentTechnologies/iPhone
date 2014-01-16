//
//  PlayControlViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/2/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "RadialButton.h"

@protocol PlayControlDelegate <NSObject>

- (void) stopAllPlaying;
- (void) startAllPlaying:(float)secondsperbeat;

- (void) initPlayLocation;

- (void) saveContext;

@end


@interface PlayControlViewController : UIViewController <RadialButtonDelegate>
{
    // Tempo slider
    int tempo;
    
    // Play loop
    BOOL isPlaying;
    float secondsPerBeat;
   
}

- (IBAction)startStop:(id)sender;
- (void)stopAll;
- (int)getTempo;
- (void)resetTempo;
- (void)setTempo:(int)newTempo;

@property (weak, nonatomic) id<PlayControlDelegate> delegate;
@property (weak, nonatomic) IBOutlet RadialButton * tempoSlider;
@property (retain, nonatomic) IBOutlet UIButton * startStopButton;


@end
