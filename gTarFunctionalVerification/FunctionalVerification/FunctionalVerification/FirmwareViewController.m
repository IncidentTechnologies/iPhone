//
//  FirmwareViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/14/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "FirmwareViewController.h"

#import "Checklist.h"

extern GtarController * g_gtarController;

extern Checklist g_checklist;

@interface FirmwareViewController ()

@end

@implementation FirmwareViewController

@synthesize firmwareLabel = _firmwareLabel;

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
	// Do any additional setup after loading the view.
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    
    g_gtarController.m_delegate = self;
    
    NSLog(@"Requesting FW version");
    
    [g_gtarController sendRequestFirmwareVersion];

    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    g_gtarController.m_delegate = nil;
    
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - GtarControllerDelegate

- (void)receivedFirmwareMajorVersion:(int)majorVersion andMinorVersion:(int)minorVersion
{
    
    NSLog(@"Received FW Version %u %u", majorVersion, minorVersion);
    
    NSString * str = [[NSString alloc] initWithFormat:@"%u.%u", majorVersion, minorVersion];
    
    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:str waitUntilDone:NO];
    
}

- (void)updateLabel:(NSString*)version
{
    self.firmwareLabel.text = version;
}

@end
