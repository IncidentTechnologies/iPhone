//
//  FirmwareModalViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 5/15/13.
//
//

#import "SlidingModalViewController.h"

@interface FirmwareModalViewController : SlidingModalViewController

@property (strong, nonatomic) IBOutlet UILabel *firmwareUpdateLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel *availableVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentFirmwareLabel;
@property (strong, nonatomic) IBOutlet UILabel *availableFirmwareLabel;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;

@property (strong, nonatomic) NSString *currentFirmwareVersion;
@property (strong, nonatomic) NSString *availableFirmwareVersion;

@property (strong, nonatomic) NSInvocation *updateInvocation;
@property (assign, nonatomic) unsigned char updateProgress;

- (IBAction)updateButtonClicked:(id)sender;
- (void)delayLoadingComplete;

@end
