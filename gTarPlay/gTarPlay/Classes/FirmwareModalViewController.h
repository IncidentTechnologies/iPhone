//
//  FirmwareModalViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 5/15/13.
//
//

#import "SlidingModalViewController.h"

@interface FirmwareModalViewController : SlidingModalViewController

@property (retain, nonatomic) IBOutlet UILabel *currentFirmwareLabel;
@property (retain, nonatomic) IBOutlet UILabel *availableFirmwareLabel;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIButton *updateButton;

@property (retain, nonatomic) NSString *currentFirmwareVersion;
@property (retain, nonatomic) NSString *availableFirmwareVersion;

@property (retain, nonatomic) NSInvocation *updateInvocation;
@property (assign, nonatomic) unsigned char updateProgress;

- (IBAction)updateButtonClicked:(id)sender;

@end
