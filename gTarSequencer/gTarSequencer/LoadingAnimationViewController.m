//
//  LoadingAnimationViewController.m
//  gTarSequencer
//
//  Created by Ilan Gray on 8/10/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "LoadingAnimationViewController.h"

#define TIME_TO_HOLD_LOGO 1.225
#define LOGO_FADE_OUT_DURATION 0.75

#define S_ANIMATION_DURATION 1.5
#define TIME_TO_HOLD_S 1.5 

@implementation LoadingAnimationViewController

@synthesize imageView;
@synthesize segue;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        animationFrames = [NSArray arrayWithObjects:[UIImage imageNamed:@"Sequence1"],
                  [UIImage imageNamed:@"Sequence2"],
                  [UIImage imageNamed:@"Sequence3"],
                  [UIImage imageNamed:@"Sequence4"],
                  [UIImage imageNamed:@"Sequence5"],
                  [UIImage imageNamed:@"Sequence6"],
                  [UIImage imageNamed:@"Sequence7"],
                  [UIImage imageNamed:@"Sequence8"],
                  [UIImage imageNamed:@"Sequence9"],
                  [UIImage imageNamed:@"Sequence10"],
                  [UIImage imageNamed:@"Sequence11"],
                  nil];
        
        lastImage = [UIImage imageNamed:@"Sequence11"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)viewDidLoad
{
    imageView.animationImages = animationFrames;
    
    imageView.animationDuration = S_ANIMATION_DURATION;
    
    imageView.animationRepeatCount = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    double currentTime = 0;
    
    [self performSelectorInBackground:@selector(initNextViewController) withObject:nil];
    
    [self performSelector:@selector(fadeOutLogo) withObject:nil afterDelay:TIME_TO_HOLD_LOGO];
    currentTime += TIME_TO_HOLD_LOGO;
    
    [self performSelector:@selector(startAnimation) withObject:nil afterDelay:currentTime + LOGO_FADE_OUT_DURATION];
    currentTime += LOGO_FADE_OUT_DURATION;
    
    [self performSelector:@selector(segueToNextViewController) withObject:nil afterDelay:currentTime + S_ANIMATION_DURATION + TIME_TO_HOLD_S];
    NSLog(@"Total time: %f", currentTime + S_ANIMATION_DURATION + TIME_TO_HOLD_S);
}

- (void)fadeOutLogo
{
    [UIView animateWithDuration:LOGO_FADE_OUT_DURATION
                          delay:0.0 
                        options:UIViewAnimationCurveLinear 
                     animations:^{imageView.alpha = 0.0;} 
                     completion:nil];
}

- (void)startAnimation
{
    imageView.alpha = 1.0;
    imageView.image = lastImage;
    
    [imageView startAnimating];
}

- (void)initNextViewController
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    nextVC = [storyboard instantiateViewControllerWithIdentifier:@"gTarSequencerVC"];
    
    nextVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (void)segueToNextViewController
{
    if ( nextVC != nil )
    {
        [self presentModalViewController:nextVC animated:YES];
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(segueToNextViewController) userInfo:nil repeats:NO];
        NSLog(@"Sequencer VC NIL, giving it another 0.25 seconds.");
    }
}


@end
