//
//  TitleFirmwareViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 10/24/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "FullScreenDialogViewController.h"

#import <GtarController/GtarControllerInternal.h>

@class CloudResponse;

@interface TitleFirmwareViewController : FullScreenDialogViewController <GtarControllerDelegate>
{
    
    IBOutlet UIButton * m_leftButton;
    IBOutlet UIButton * m_rightButton;
    IBOutlet UILabel * m_statusLabel;
    IBOutlet UILabel * m_currentFirmwareLabel;
    IBOutlet UILabel * m_availableFirmwareLabel;
    
    IBOutlet UIActivityIndicatorView * m_currentActivity;
    IBOutlet UIActivityIndicatorView * m_availableActivity;
    
    BOOL m_updating;
    
    // Firmware reflashing
    NSInteger m_firmwareFileId;
    
    NSInteger m_firmwareCurrentMajorVersion;
    NSInteger m_firmwareCurrentMinorVersion;
    NSInteger m_firmwareAvailableMajorVersion;
    NSInteger m_firmwareAvailableMinorVersion;
    
}

@property (nonatomic, retain) IBOutlet UIButton * m_leftButton;
@property (nonatomic, retain) IBOutlet UIButton * m_rightButton;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_currentFirmwareLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_availableFirmwareLabel;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_currentActivity;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_availableActivity;


- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonClicked:(id)sender;

- (void)cancelFirmware;
- (void)updateFirmware;
- (void)checkCurrentFirmwareVersion;
- (void)checkAvailableFirmwareVersion;
- (void)receivedAvailableFirmwareVersion:(CloudResponse*)cloudResponse;
- (void)compareVersions;
- (void)receivedFirmwareUpdateStatusSucceededMain;
- (void)receivedFirmwareUpdateStatusFailedMain;

@end
