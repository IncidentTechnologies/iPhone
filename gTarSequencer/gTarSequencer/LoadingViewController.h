//
//  LoadingViewController.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/19/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "SequencerViewController.h"

@interface LoadingViewController : UIViewController
{
    UIImage * lastImage;
}

@property (strong, nonatomic) IBOutlet UIImageView * imageView;

@end

