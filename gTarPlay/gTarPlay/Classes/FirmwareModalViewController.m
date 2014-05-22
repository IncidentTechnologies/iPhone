//
//  FirmwareModalViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 5/15/13.
//
//

#import "FirmwareModalViewController.h"
#import "UIView+Gtar.h"

@interface FirmwareModalViewController ()

@end

@implementation FirmwareModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
    [_updateButton addShadowWithRadius:2.0 andOpacity:0.9];
    
    [_currentFirmwareLabel setText:_currentFirmwareVersion];
    [_availableFirmwareLabel setText:_availableFirmwareVersion];
}


- (void)localizeViews
{
    _firmwareUpdateLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Firmware Update", NULL)];
    
    _currentVersionLabel.text = [NSLocalizedString(@"Current Version", NULL) stringByAppendingString:@":"];
    _availableVersionLabel.text = [NSLocalizedString(@"Available Version", NULL) stringByAppendingString:@":"];
    _progressLabel.text = [NSLocalizedString(@"Progress", NULL) stringByAppendingString:@":"];
    
    [_updateButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"UPDATE", NULL)] forState:UIControlStateNormal];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.updateInvocation = nil;
    self.updateProgress = 0;
    
    [_progressLabel setHidden:YES];
    [_activityIndicator setHidden:NO];
    [_updateButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Setting this invocation will enable the 'Update' button
- (void)setUpdateInvocation:(NSInvocation *)updateInvocation
{
    
    _updateInvocation = updateInvocation;
    
    [self performSelectorOnMainThread:@selector(setUpdateInvocationMain) withObject:nil waitUntilDone:YES];
}

- (void)setUpdateInvocationMain
{
    // Once we have an invocation, we are good to go.
    [_activityIndicator setHidden:YES];
    [_updateButton setEnabled:YES];
}

- (void)setUpdateProgress:(unsigned char)updateProgress
{
    _updateProgress = updateProgress;
    
    [_progressLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"Progress: %u%%", updateProgress] waitUntilDone:YES];
}

- (void)setCurrentFirmwareVersion:(NSString *)currentFirmwareVersion
{
    
    _currentFirmwareVersion = currentFirmwareVersion;
    
    [_currentFirmwareLabel setText:_currentFirmwareVersion];
}

- (void)setAvailableFirmwareVersion:(NSString *)availableFirmwareVersion
{
    
    _availableFirmwareVersion = availableFirmwareVersion;
    
    [_availableFirmwareLabel setText:_availableFirmwareVersion];
}

- (IBAction)updateButtonClicked:(id)sender
{
    [_updateButton setEnabled:NO];
    [_progressLabel setHidden:NO];
    [_updateInvocation invoke];
}

@end
