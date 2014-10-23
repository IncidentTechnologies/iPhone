//
//  ConnectionViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "ConnectionViewController.h"

#import "Checklist.h"

//extern GtarController * g_gtarController;
extern GtarController * g_gtarController;

extern Checklist g_checklist;

@interface ConnectionViewController ()

@property (strong, nonatomic) NSString * testType;

@end

@implementation ConnectionViewController

@synthesize testType = _testType;

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
    
#ifdef TARGET_IPHONE_SIMULATOR
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:g_gtarController selector:@selector(debugSpoofConnected) userInfo:nil repeats:NO];
#endif
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void)viewDidAppear:(BOOL)animated
{
    
    // init tests
    if ( [_testType isEqualToString:@"Connect"] == YES )
    {
        g_checklist.connectedTest = NO;
    }
    if ( [_testType isEqualToString:@"Disconnect"] == YES )
    {
        g_checklist.disconnectedTest = NO;
    }
    
    [g_gtarController addObserver:self];
    
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [g_gtarController removeObserver:self];

    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - GtarControllerObserver

- (void)gtarConnected
{
    
    NSLog(@"Connecting...");
    
    [g_gtarController turnOffAllEffects];
    [g_gtarController turnOffAllLeds];
    [g_gtarController sendDisableDebug];
    
    if ( [_testType isEqualToString:@"Connect"] == YES )
    {
        
        g_checklist.connectedTest = YES;
        
        // Move onto the next stage
        [self performSegueWithIdentifier:@"passSegue" sender:self];
    }
    
}

- (void)gtarDisconnected
{

    NSLog(@"Disconnecting...");
    
    if ( [_testType isEqualToString:@"Disconnect"] == YES )
    {
        
        g_checklist.disconnectedTest = YES;
        
        // Move onto the next stage
        [self performSegueWithIdentifier:@"passSegue" sender:self];
    }
    
}

@end
