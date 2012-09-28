//
//  BatteryViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BatteryViewController.h"

#import "GuitarController.h"
#import "Checklist.h"

extern GuitarController * g_guitarController;
extern Checklist g_checklist;

@interface BatteryViewController ()

@end

@implementation BatteryViewController

@synthesize percentageLabel = _percentageLabel;
@synthesize chargingLabel = _chargingLabel;

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

- (IBAction)testBatteryClicked:(id)sender
{
    NSLog(@"Requesting Battery status");
    
    [g_guitarController SendRequestBatteryStatus];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [segue.identifier isEqualToString:@"passSegue"] == YES )
    {
        g_checklist.batteryTest = YES;
    }
    else
    {
        g_checklist.batteryTest = NO;
    }
}

#pragma mark - GuitarControllerDelegate

- (void)ReceivedFWVersion:(int)MajorVersion andMinorVersion:(int)MinorVersion{ }

- (void)updateLabel:(NSString*)version{ }

- (void)guitarFretDown:(GuitarFret)fret atString:(GuitarString)str{ }
- (void)guitarFretUp:(GuitarFret)fret atString:(GuitarString)str{ }
- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str{ }
- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str{ }
- (void)guitarConnected{ }
- (void)guitarDisconnected{ }

- (void)RxFWUpdateACK:(unsigned char)status{ }

- (void)RxBatteryStatus:(BOOL)charging
{
    
    NSLog(@"Battert status received");
    
    if ( charging == YES )
    {
        _chargingLabel.text = @"Battery Status: Charging!";
    }
    else
    {
        _chargingLabel.text = @"Battery Status: Not Charging";
    }
}

- (void)RxBatteryCharge:(unsigned char)percentage
{
    NSLog(@"Battert percentage received");
    _percentageLabel.text = [[NSString alloc] initWithFormat:@"Battery Percentage: %u%", percentage];
}

- (void)SocketRxBytes:(NSString *)pstrRx{ }
- (void)SocketConnected{ }
- (void)SocketConnectionError{ }
- (void)SocketDisconnected{ }

@end
