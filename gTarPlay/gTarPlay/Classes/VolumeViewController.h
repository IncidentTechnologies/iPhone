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

@property (retain, nonatomic) IBOutlet UIView *sliderView;
@property (retain, nonatomic) IBOutlet UISlider *volumeSlider;
@property (retain, nonatomic) IBOutlet UIView *volumeView;
@property (retain, nonatomic) IBOutlet UIImageView *volumeTrackView;
@property (retain, nonatomic) IBOutlet UIView * innerView;

@property (readonly, nonatomic) BOOL displayed;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isInverse:(BOOL)invert;

- (IBAction)volumeValueChanged:(id)sender;

@end
