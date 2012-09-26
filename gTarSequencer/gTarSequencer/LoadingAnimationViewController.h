//
//  LoadingAnimationViewController.h
//  gTarSequencer
//
//  Created by Ilan Gray on 8/10/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gTarSequencerViewController.h"

// The LoadingAnimationVC will display the animation given by the images in the array of frames to animate. It will 
//      also load the next VC and present it once the animation has finished and the next VC is init'ed. The animation
//      is defined in terms of 4 times:
//      1) How long to hold the initial logo
//      2) The duration of the fade out of the initial logo
//      3) The duration of the animation of the S
//      4) How long to hold the S after it finishes animating
@interface LoadingAnimationViewController : UIViewController
{
    NSArray * animationFrames;
    
    UIImage * lastImage;
    
    UIViewController * nextVC;
}

@property (weak, nonatomic) IBOutlet UIImageView * imageView;
@property (weak, nonatomic) IBOutlet UIStoryboardSegue * segue;

@end
