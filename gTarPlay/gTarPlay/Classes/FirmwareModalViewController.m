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
    // Do any additional setup after loading the view from its nib.
    [_updateButton addShadow];
    
    [_currentFirmwareLabel setText:_currentFirmwareVersion];
    [_availableFirmwareLabel setText:_availableFirmwareVersion];
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

- (void)dealloc
{
    [_currentFirmwareLabel release];
    [_availableFirmwareLabel release];
    [_currentFirmwareVersion release];
    [_availableFirmwareVersion release];
    [_activityIndicator release];
    [_progressLabel release];
    [_updateButton release];
    [super dealloc];
}

// Setting this invocation will enable the 'Update' button
- (void)setUpdateInvocation:(NSInvocation *)updateInvocation
{
    [_updateInvocation release];
    
    _updateInvocation = [updateInvocation retain];
    
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
    [_currentFirmwareVersion release];
    
    _currentFirmwareVersion = [currentFirmwareVersion retain];
    
    [_currentFirmwareLabel setText:_currentFirmwareVersion];
}

- (void)setAvailableFirmwareVersion:(NSString *)availableFirmwareVersion
{
    [_availableFirmwareVersion release];
    
    _availableFirmwareVersion = [availableFirmwareVersion retain];
    
    [_availableFirmwareLabel setText:_availableFirmwareVersion];
}

- (IBAction)updateButtonClicked:(id)sender
{
    [_updateButton setEnabled:NO];
    [_progressLabel setHidden:NO];
    [_updateInvocation invoke];
}

@end
