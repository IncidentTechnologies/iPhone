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
@synthesize m_buildVersionLabel;

@synthesize m_firmwareFileId;

@synthesize m_firmwareCurrentMajorVersion;
@synthesize m_firmwareCurrentMinorVersion;
@synthesize m_firmwareAvailableMajorVersion;
@synthesize m_firmwareAvailableMinorVersion;

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
    
    NSString * compileDate = [NSString stringWithUTF8String:__DATE__];
    NSString * compileTime = [NSString stringWithUTF8String:__TIME__];
    NSString * compileVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString * dateTimeString = [NSString stringWithFormat:@"%@ %@", compileDate, compileTime];
    
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [formatter setDateFormat:@"MMM d yyyy HH:mm:ss"];
    
    NSDate * date = [formatter dateFromString:dateTimeString];
    
    [formatter setDateFormat:@"YYYMMddHHmmss"];
    
    [m_buildVersionLabel setText:[NSString stringWithFormat:@"App Build: %@-%@", compileVersion, [formatter stringFromDate:date]]];

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
    self.m_buildVersionLabel = nil;
    
}

- (void)dealloc
{
    
    [m_leftButton release];
    [m_rightButton release];
    [m_statusLabel release];
    [m_currentFirmwareLabel release];
    [m_availableFirmwareLabel release];
    [m_buildVersionLabel release];
    
    [m_currentActivity release];
    [m_availableActivity release];
    
    [super dealloc];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Attachments

- (void)forceUpdate:(UIView*)view
{
    
    [self attachToSuperview:view];
    
    [self compareVersions];
    
    [m_statusLabel setText:@"Please update to continue."];
    [m_statusLabel setHidden:NO];
    
    [m_currentFirmwareLabel setText:[NSString stringWithFormat:@"Current Version: %d.%d", m_firmwareCurrentMajorVersion, m_firmwareCurrentMinorVersion]];
    [m_availableFirmwareLabel setText:[NSString stringWithFormat:@"Available Version: %d.%d", m_firmwareAvailableMajorVersion, m_firmwareAvailableMinorVersion]];

}

- (void)softUpdate:(UIView*)view
{
    
    [self attachToSuperview:view];
    
    [self checkCurrentFirmwareVersion];
    [self checkAvailableFirmwareVersion];
    
}

- (void)attachToSuperview:(UIView*)view
{
    
    [super attachToSuperview:view];
    
    m_updating = NO;
    
    [g_gtarController addObserver:self];
    
    [m_statusLabel setHidden:YES];
    
    [m_leftButton setSelected:NO];
    [m_leftButton setEnabled:YES];

    [m_rightButton setSelected:NO];
    [m_rightButton setEnabled:NO];
    
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
        //[self cancelFirmware];
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
        NSLog(@"Update already in progress");
    }
    else
    {
        [self updateFirmware];
    }

}

#pragma mark - Firmware

//- (void)cancelFirmware
//{
//    
//    [g_gtarController sendFirmwareUpdateCancelation];
//    
//}

- (void)updateFirmware
{
    
    // output some messages
    NSString * msg = [[NSString alloc] initWithFormat:@"Firmware updating"];
    
    NSLog(@"%@", msg);
    
    [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     msg, @"Status",
                                     [NSNumber numberWithInteger:m_firmwareFileId], @"FileId",
                                     nil]];
    
    [msg release];
    
    g_gtarController.m_delegate = self;
    
    NSData * firmware = [g_fileController getFileOrDownloadSync:m_firmwareFileId];
    
    if ( firmware == nil )
    {
        
        NSString * msg = [[NSString alloc] initWithFormat:@"Firmware is nil"];
        
        NSLog(@"%@", msg);
        
        [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         msg, @"Status",
                                         [NSNumber numberWithInteger:m_firmwareFileId], @"FileId",
                                         nil]];
        
        [m_statusLabel setText:msg];
        [m_statusLabel setHidden:NO];
        
        [msg release];
        
        return;
    }
    
    if ( [g_gtarController sendFirmwareUpdate:firmware] == YES )
    {
        NSLog(@"Starting update");
        
        m_updating = YES;
        
        [m_statusLabel setText:@"Progress: 0%"];
        [m_statusLabel setHidden:NO];
        
        [m_leftButton setEnabled:NO];
        [m_rightButton setEnabled:NO];
    }
    else
    {
        
        NSString * msg = [[NSString alloc] initWithFormat:@"Update failed to start"];
        
        NSLog(@"%@", msg);
        
        [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         msg, @"Status",
                                         [NSNumber numberWithInteger:m_firmwareFileId], @"FileId",
                                         nil]];
        
        [m_statusLabel setText:msg];
        [m_statusLabel setHidden:NO];
        
        [msg release];

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
        
        [m_leftButton setEnabled:YES];
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
        
        [m_leftButton setEnabled:YES];
        
    }
    
}

- (void)compareVersions
{
    
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
    
    // See if the new version is newer
    if ( m_firmwareAvailableMajorVersion > m_firmwareCurrentMajorVersion )
    {
        [m_leftButton setEnabled:NO];
        [m_rightButton setEnabled:YES];
    }
    
    // See if the new version is newer    
    if ( (m_firmwareAvailableMajorVersion == m_firmwareCurrentMajorVersion) &&
         (m_firmwareAvailableMinorVersion > m_firmwareCurrentMinorVersion) )
    {
        [m_leftButton setEnabled:NO];
        [m_rightButton setEnabled:YES];
    }
    
    // See if we are done
    if ( (m_firmwareAvailableMajorVersion == m_firmwareCurrentMajorVersion) &&
         (m_firmwareAvailableMinorVersion == m_firmwareCurrentMinorVersion) )
    {
        [m_rightButton setEnabled:NO];
        [m_leftButton setEnabled:YES];
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
    NSString * msg = @"Firmware update succeeded";

    NSLog(@"%@", msg);
    
    [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     msg, @"Status",
                                     [NSNumber numberWithInteger:m_firmwareFileId], @"FileId",
                                     nil]];
    
    m_updating = NO;
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusSucceededMain) withObject:nil waitUntilDone:YES];
    
}

- (void)receivedFirmwareUpdateStatusSucceededMain
{
    
    [m_statusLabel setText:@"Update Succeeded"];
    
    [self checkCurrentFirmwareVersion];
    
}

- (void)receivedFirmwareUpdateStatusFailed
{
    
    NSString * msg = @"Firmware update failed";
    
    NSLog(@"%@", msg);
    
    [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     msg, @"Status",
                                     [NSNumber numberWithInteger:m_firmwareFileId], @"FileId",
                                     nil]];

    m_updating = NO;
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusFailedMain) withObject:nil waitUntilDone:YES];
        
}

- (void)receivedFirmwareUpdateStatusFailedMain
{
    
    [m_statusLabel setText:@"Update Failed -- Restart the gTar"];
    
//    [m_leftButton setSelected:NO];
//    [m_leftButton setEnabled:YES];
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
