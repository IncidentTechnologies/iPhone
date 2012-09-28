//
//  FirmwareViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirmwareViewController.h"

#import "GuitarController.h"
#import "Checklist.h"

extern GuitarController * g_guitarController;
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
    
    g_guitarController.m_delegate = self;
    
    NSLog(@"Requesting FW version");
    
    [g_guitarController SendRequestFirmwareVersion];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    g_guitarController.m_delegate = nil;
    
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - GuitarControllerDelegate

- (void)ReceivedFWVersion:(int)MajorVersion andMinorVersion:(int)MinorVersion
{
    NSLog(@"Received FW Version %u %u", MajorVersion, MinorVersion);
    
    NSString * str = [[NSString alloc] initWithFormat:@"%u.%u", MajorVersion, MinorVersion];
    
    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:str waitUntilDone:NO];
    
}

- (void)updateLabel:(NSString*)version
{
    self.firmwareLabel.text = version;
}

- (void)guitarFretDown:(GuitarFret)fret atString:(GuitarString)str{ }
- (void)guitarFretUp:(GuitarFret)fret atString:(GuitarString)str{ }
- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str{ }
- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str{ }
- (void)guitarConnected{ }
- (void)guitarDisconnected{ }

- (void)RxFWUpdateACK:(unsigned char)status{ }
- (void)RxBatteryStatus:(BOOL)charging{ }
- (void)RxBatteryCharge:(unsigned char)percentage{ }

- (void)SocketRxBytes:(NSString *)pstrRx{ }
- (void)SocketConnected{ }
- (void)SocketConnectionError{ }
- (void)SocketDisconnected{ }

@end
