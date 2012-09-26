//
//  ConnectionViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConnectionViewController.h"

//#import <GtarController/GtarController.h>

#import "Checklist.h"

//extern GtarController * g_gtarController;
extern GuitarController * g_guitarController;

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
    
//    [g_gtarController addObserver:self];
    [g_guitarController addObserver:self];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [g_guitarController removeObserver:self];

    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
//    if ( [segue.identifier isEqualToString:@"failSegue"] == YES )
//    {
//        
//    }
}

#pragma mark - GtarControllerObserver

- (void)gtarConnected
{
    
    NSLog(@"Connecting...");
    
    [g_guitarController turnOffAllEffects];
    [g_guitarController turnOffAllLeds];
    
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:g_guitarController selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:g_guitarController selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:3.0 target:g_guitarController selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:4.0 target:g_guitarController selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:5.0 target:g_guitarController selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:6.0 target:g_guitarController selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:7.0 target:g_guitarController selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
    
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

#pragma mark -- GuitarController

- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarConnected
{
    NSLog(@"Connecting...");
    
    if ( [_testType isEqualToString:@"Connect"] == YES )
    {
        
        g_checklist.connectedTest = YES;
        
        // Move onto the next stage
        [self performSegueWithIdentifier:@"passSegue" sender:self];
    }
}
- (void)guitarDisconnected
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
