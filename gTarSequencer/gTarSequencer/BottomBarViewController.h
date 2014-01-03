//
//  RadialViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/2/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadialButton.h"

@interface BottomBarViewController : UIViewController <RadialButtonDelegate>
{
    // tempo slider
    int tempo;
    
    // play loop
    BOOL isPlaying;
    double secondsPerBeat;
    NSTimer * playTimer;
    int currentFret;
    int currentAbsoluteMeasure;

}

- (IBAction)startStop:(id)sender;

@property (weak, nonatomic) IBOutlet RadialButton * tempoSlider;
@property (retain, nonatomic) IBOutlet UIButton * startStopButton;


@end
