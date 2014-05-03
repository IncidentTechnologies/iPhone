//
//  VolumeViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/3/13.
//
//

#import <UIKit/UIKit.h>
#import "SlidingViewController.h"

@interface VolumeViewController : SlidingViewController

@property (strong, nonatomic) IBOutlet UIView *sliderView;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UIView *volumeView;
@property (strong, nonatomic) IBOutlet UIImageView *volumeTrackView;
@property (strong, nonatomic) IBOutlet UIView * innerView;

@property (readonly, nonatomic) BOOL displayed;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isInverse:(BOOL)invert;

- (IBAction)volumeValueChanged:(id)sender;

@end
