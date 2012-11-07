//
//  TitleFirmwareViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 10/24/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "TitleFirmwareViewController.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/TelemetryController.h>

extern GtarController * g_gtarController;
extern CloudController * g_cloudController;
extern FileController * g_fileController;
extern TelemetryController * g_telemetryController;

@implementation TitleFirmwareViewController

@synthesize m_leftButton;
@synthesize m_rightButton;
@synthesize m_statusLabel;
@synthesize m_currentFirmwareLabel;
@synthesize m_availableFirmwareLabel;

@synthesize m_currentActivity;
@synthesize m_availableActivity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        
        m_updating = NO;
        
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_leftButton = nil;
    self.m_rightButton = nil;
    self.m_statusLabel = nil;
    self.m_currentFirmwareLabel = nil;
    self.m_availableFirmwareLabel = nil;
    
    self.m_currentActivity = nil;
    self.m_availableActivity = nil;
    
}

- (void)dealloc
{
    
    [m_leftButton release];
    [m_rightButton release];
    [m_statusLabel release];
    [m_currentFirmwareLabel release];
    [m_availableFirmwareLabel release];
    
    [m_currentActivity release];
    [m_availableActivity release];
    
    [super dealloc];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Attachments

- (void)attachToSuperview:(UIView*)view
{
    
    [super attachToSuperview:view];
    
    m_updating = NO;
    
    [g_gtarController addObserver:self];
    
    [m_statusLabel setHidden:YES];
    
    [m_leftButton setSelected:NO];
    [m_rightButton setSelected:NO];
    [m_rightButton setEnabled:NO];
    
    [self checkCurrentFirmwareVersion];
    [self checkAvailableFirmwareVersion];
    
}

- (void)detachFromSuperview
{
    
    [g_gtarController removeObserver:self];
    
    [super detachFromSuperview];
    
}

#pragma mark - Buttons

- (IBAction)leftButtonClicked:(id)sender
{
    
    if ( m_updating )
    {
        [self cancelFirmware];
    }
    else
    {
        [self detachFromSuperview];
    }
    
}

- (IBAction)rightButtonClicked:(id)sender
{
    
    if ( m_updating )
    {
        // do nothing, this button is actually disabled
    }
    else
    {
        
        [m_statusLabel setText:@"Progress: 0%"];
        [m_statusLabel setHidden:NO];
        
        [self updateFirmware];
        
    }

}

#pragma mark - Firmware

- (void)cancelFirmware
{
    
    [g_gtarController sendFirmwareUpdateCancelation];
    
}

- (void)updateFirmware
{
    
    g_gtarController.m_delegate = self;
    
    NSData * firmware = [g_fileController getFileOrDownloadSync:m_firmwareFileId];
    
    // output some messages
    NSLog(@"Updating with firmware file id: %u length: %u", m_firmwareFileId, [firmware length]);
    
    NSString * msg = [[NSString alloc] initWithFormat:@"Updating with firmware file id: %u length: %u", m_firmwareFileId, [firmware length]];
    
    [g_telemetryController logMessage:msg withType:TelemetryControllerMessageTypeError];
    
    [msg release];
    
    if ( [firmware length] > 0 )
    {
        if ( [g_gtarController sendFirmwareUpdate:firmware] == YES )
        {
            m_updating = YES;
            
            [m_leftButton setSelected:YES];
            [m_rightButton setEnabled:NO];   
        }
    }
    
}

- (void)checkCurrentFirmwareVersion
{
    
    NSLog(@"Checking gtar firmware version");
    
    [m_currentActivity startAnimating];
    [m_currentFirmwareLabel setText:@"Current Version:"];
    
    g_gtarController.m_delegate = self;
    
    if ( [g_gtarController sendRequestFirmwareVersion] == NO )
    {
        [m_currentFirmwareLabel setText:@"Current Version: Failed to update"];
        
        m_firmwareCurrentMajorVersion = 0;
        m_firmwareCurrentMinorVersion = 0;
        
        [m_currentActivity stopAnimating];
    }
    
}

- (void)checkAvailableFirmwareVersion
{
    // Query the server
    [m_availableActivity startAnimating];
    [m_availableFirmwareLabel setText:@"Available Version:"];
    
    [g_cloudController requestCurrentFirmwareVersionCallbackObj:self andCallbackSel:@selector(receivedAvailableFirmwareVersion:)];
    
}

- (void)receivedAvailableFirmwareVersion:(CloudResponse*)cloudResponse
{
    
    [m_availableActivity stopAnimating];
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [m_availableFirmwareLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"Available Version: %d.%d", 
                                                                                                cloudResponse.m_responseFirmwareMajorVersion, cloudResponse.m_responseFirmwareMinorVersion] waitUntilDone:NO];
        
        // Get the new binary
        [g_fileController precacheFile:cloudResponse.m_responseFileId];
        
        m_firmwareFileId = cloudResponse.m_responseFileId;
        
        m_firmwareAvailableMajorVersion = cloudResponse.m_responseFirmwareMajorVersion;
        m_firmwareAvailableMinorVersion = cloudResponse.m_responseFirmwareMinorVersion;
        
        [self compareVersions];
        
    }
    else
    {
        
        [m_availableFirmwareLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Available Version: Failed to update" waitUntilDone:NO];
        
        m_firmwareFileId = 0;
        
        m_firmwareAvailableMajorVersion = 0;
        m_firmwareAvailableMinorVersion = 0;
        
    }
    
}

- (void)compareVersions
{
    
    [m_rightButton setEnabled:YES];
    
    if ( (m_firmwareCurrentMajorVersion == 0) && (m_firmwareCurrentMinorVersion == 0) )
    {
        // Not available yet
        return;
    }
    
    if ( (m_firmwareAvailableMajorVersion == 0) && (m_firmwareAvailableMinorVersion == 0) )
    {
        // Not available yet
        return;
    }
    
    if ( m_firmwareAvailableMajorVersion > m_firmwareCurrentMajorVersion )
    {
        [m_rightButton setEnabled:YES];
    }
    
    
    if ( (m_firmwareAvailableMajorVersion == m_firmwareCurrentMajorVersion) &&
        (m_firmwareAvailableMinorVersion > m_firmwareCurrentMinorVersion) )
    {
        [m_rightButton setEnabled:YES];
    }
    
}

#pragma mark - GtarControllerObserver

- (void)gtarDisconnected
{
    [self detachFromSuperview];
}

#pragma mark - GtarControllerDelegate

- (void)receivedFirmwareMajorVersion:(int)majorVersion andMinorVersion:(int)minorVersion
{
    NSLog(@"Receiving firmware version");
    
    NSString * msg = [[NSString alloc] initWithFormat:@"Current Version: %d.%d", majorVersion, minorVersion];
    
    [m_currentFirmwareLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:YES];
    
    [msg release];
    
    [m_currentActivity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    
    m_firmwareCurrentMajorVersion = majorVersion;
    m_firmwareCurrentMinorVersion = minorVersion;
    
    [self compareVersions];
    
}

- (void)receivedFirmwareUpdateStatusSucceeded
{
    NSLog(@"Firmware update succeeded");
    
    [g_telemetryController logMessage:@"Firmware update succeeded" withType:TelemetryControllerMessageTypeInfo];
    
    m_updating = NO;
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusSucceededMain) withObject:nil waitUntilDone:YES];
    
}

- (void)receivedFirmwareUpdateStatusSucceededMain
{
    
    [m_statusLabel setText:@"Update Succeeded"];
    
    [m_leftButton setSelected:NO];
    [m_rightButton setSelected:YES];
//    [m_rightButton setEnabled:YES];    
}

- (void)receivedFirmwareUpdateStatusFailed
{
    
    NSLog(@"Firmware update failed");
    
    [g_telemetryController logMessage:@"Firmware update failed" withType:TelemetryControllerMessageTypeError];
    
    m_updating = NO;
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusFailedMain) withObject:nil waitUntilDone:YES];
        
}

- (void)receivedFirmwareUpdateStatusFailedMain
{
    
    [m_statusLabel setText:@"Update Failed"];
    
    [m_leftButton setSelected:NO];
    [m_rightButton setSelected:NO];
    
}

- (void)receivedFirmwareUpdateProgress:(unsigned char)percentage
{
    
    NSLog(@"Progress: %u", percentage);
    
    NSString * msg = [[NSString alloc] initWithFormat:@"Progress: %u%%", percentage];
    
    [m_statusLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:YES];
    
    [msg release];
    
}

@end
