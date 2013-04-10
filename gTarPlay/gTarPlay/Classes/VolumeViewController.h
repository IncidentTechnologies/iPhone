//
//  VolumeViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/3/13.
//
//

#import <UIKit/UIKit.h>

@interface VolumeViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *sliderView;

@property (retain, nonatomic) IBOutlet UISlider *volumeSlider;
@property (retain, nonatomic) IBOutlet UIView *volumeView;
@property (retain, nonatomic) IBOutlet UIImageView *volumeTrackView;

@property (readonly, nonatomic) BOOL displayed;

- (IBAction)volumeValueChanged:(id)sender;

- (void)attachToSuperview:(UIView *)view;
- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect;
- (void)toggleVolumeView;
- (void)setFrame:(CGRect)frame;
- (void)enableAppleSlider;
- (void)enableManualSlider;

@end
