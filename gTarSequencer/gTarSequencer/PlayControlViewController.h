//
//  PlayControlViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/2/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadialButton.h"

@protocol PlayControlDelegate <NSObject>

- (void) stopAllPlaying;
- (void) startAllPlaying:(float)secondsperbeat;
- (void) saveContext;
- (void) initPlayLocation;
- (void) notePlayedAtString:(int)str andFret:(int)fr;

@end


@interface PlayControlViewController : UIViewController <RadialButtonDelegate>
{
    // tempo slider
    int tempo;
    
    // play loop
    BOOL isPlaying;
    float secondsPerBeat;
   
}

- (IBAction)playSomeNotes:(id)sender;
- (IBAction)startStop:(id)sender;
- (void)stopAll;

@property (weak, nonatomic) id<PlayControlDelegate> delegate;
@property (weak, nonatomic) IBOutlet RadialButton * tempoSlider;
@property (retain, nonatomic) IBOutlet UIButton * startStopButton;
@property (retain, nonatomic) IBOutlet UIButton * playNotesButton;


@end
