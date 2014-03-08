//
//  ViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/19/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "LoadingViewController.h"

#define WAIT_TO_ANIMATE 0.75
#define ANIMATION_DURATION 1.5
#define HOLD_ANIMATION 1.5

@implementation LoadingViewController

@synthesize imageView;

// Initialize the view
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

// Initialize and trigger the animation
- (void)viewDidAppear:(BOOL)animated
{

    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    [self initAnimation:x y:y];

}

// Animation initialization
- (void)initAnimation:(float)screenX y:(float)screenY
{
    
    // Define imageView window
    imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = CGRectMake(0,0,screenX,screenY);
    [imageView setBackgroundColor:[UIColor whiteColor]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    // Prepare animation
    imageView.animationImages = [[NSArray alloc] initWithObjects:
                                      [UIImage imageNamed:@"Sequence1"],
                                      [UIImage imageNamed:@"Sequence2"],
                                      [UIImage imageNamed:@"Sequence3"],
                                      [UIImage imageNamed:@"Sequence4"],
                                      [UIImage imageNamed:@"Sequence5"],
                                      [UIImage imageNamed:@"Sequence6"],
                                      [UIImage imageNamed:@"Sequence7"],
                                      [UIImage imageNamed:@"Sequence8"],
                                      [UIImage imageNamed:@"Sequence9"],
                                      [UIImage imageNamed:@"Sequence10"],
                                      [UIImage imageNamed:@"Sequence11"],nil];
    
    lastImage = [UIImage imageNamed:@"Sequence11"];
    
    imageView.animationDuration = ANIMATION_DURATION;
    
    imageView.animationRepeatCount = 1;
    
    double totalWait = WAIT_TO_ANIMATE;
    
    [self performSelector:@selector(startAnimation) withObject:nil afterDelay: totalWait];
    totalWait += ANIMATION_DURATION + HOLD_ANIMATION;
    
    [self performSelector:@selector(initSequence) withObject:nil afterDelay: totalWait];
    
    NSLog(@"Animation time: %f", WAIT_TO_ANIMATE + ANIMATION_DURATION + HOLD_ANIMATION);
    
}

- (void)startAnimation
{
    imageView.alpha = 1.0;
    
    imageView.image = lastImage;
    
    [imageView startAnimating];
}

- (void)initSequence
{
    
    // Check for first launch
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        NSLog(@"Nth time launch");
        
        [self transitionToSequencerController:FALSE];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"First time launch");
        
        [self transitionToSequencerController:TRUE];
    }
}

- (void)transitionToSequencerController:(BOOL)firstLaunch
{
    SequencerViewController *sequencerViewController = [[SequencerViewController alloc] initWithNibName:@"SequencerViewController" bundle:nil];
    
    [self.navigationController pushViewController:sequencerViewController animated:YES];
    [sequencerViewController setIsFirstLaunch:firstLaunch];
    
}

@end
