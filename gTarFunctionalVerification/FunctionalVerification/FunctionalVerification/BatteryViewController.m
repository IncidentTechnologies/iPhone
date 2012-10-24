//
//  BatteryViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/23/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "BatteryViewController.h"

#import "Checklist.h"

extern GtarController * g_gtarController;

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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    
    g_gtarController.m_delegate = self;
    
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

- (IBAction)testBatteryClicked:(id)sender
{
    NSLog(@"Requesting Battery status");
    
    [g_gtarController sendRequestBatteryStatus];
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

#pragma mark - GtarControllerDelegate

- (void)receivedBatteryStatus:(BOOL)charging
{
    
    NSLog(@"Battery status received");
    
    if ( charging == YES )
    {
        [_chargingLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Battery Status: Charging!" waitUntilDone:YES];
    }
    else
    {
        [_chargingLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Battery Status: Not Charging" waitUntilDone:YES];
    }
}

- (void)receivedBatteryCharge:(unsigned char)percentage
{
    NSLog(@"Battery percentage received");
    
    NSString * msg = [[NSString alloc] initWithFormat:@"Battery Percentage: %u%", percentage];
    
    [_percentageLabel performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:YES];
    
}

@end
