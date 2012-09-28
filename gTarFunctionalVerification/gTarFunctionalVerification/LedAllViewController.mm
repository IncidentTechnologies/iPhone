//
//  LedViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LedAllViewController.h"

#import <GtarController/GtarController.h>

#import "Checklist.h"

//extern GtarController * g_gtarController;
extern GuitarController * g_guitarController;

extern Checklist g_checklist;


@interface LedAllViewController ()

@property (strong, nonatomic) NSString * testType;

@end

@implementation LedAllViewController

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
    // Do any additional setup after loading the view from its nib.
    
//    [g_gtarController addObserver:self];
//    
//    if ( [_testType isEqualToString:@"Red"] == YES )
//    {
//        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0) withColor:GtarLedColorMake(GtarMaxLedIntensity, 0, 0)];
//    }
//    if ( [_testType isEqualToString:@"Green"] == YES )
//    {
//        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0) withColor:GtarLedColorMake(0, GtarMaxLedIntensity, 0)];
//    }
//    if ( [_testType isEqualToString:@"Blue"] == YES )
//    {
//        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0) withColor:GtarLedColorMake(0, 0, GtarMaxLedIntensity)];
//    }
//    if ( [_testType isEqualToString:@"White"] == YES )
//    {
//        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0) withColor:GtarLedColorMake(GtarMaxLedIntensity, GtarMaxLedIntensity, GtarMaxLedIntensity)];
//    }
//    
    
    [g_guitarController addObserver:self];
    
    [g_guitarController turnOffAllEffects];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [g_guitarController turnOffAllLeds];
    [g_guitarController removeObserver:self];

    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if ( [_testType isEqualToString:@"Red"] == YES )
    {
        [g_guitarController turnOnLedAtString:0 andFret:0 withRed:3 andGreen:0 andBlue:0];
    }
    if ( [_testType isEqualToString:@"Green"] == YES )
    {
        [g_guitarController turnOnLedAtString:0 andFret:0 withRed:0 andGreen:3 andBlue:0];
    }
    if ( [_testType isEqualToString:@"Blue"] == YES )
    {
        [g_guitarController turnOnLedAtString:0 andFret:0 withRed:0 andGreen:0 andBlue:3];
    }
    if ( [_testType isEqualToString:@"White"] == YES )
    {
        [g_guitarController turnOnLedAtString:0 andFret:0 withRed:3 andGreen:3 andBlue:3];
    }

    [super viewDidAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    [g_gtarController turnOffAllLeds];
//    [g_gtarController removeObserver:self];
    
    if ([[segue identifier] isEqualToString:@"passSegue"])
    {
        if ( [_testType isEqualToString:@"Red"] == YES )
        {
            g_checklist.redTestAll = YES;
        }
        if ( [_testType isEqualToString:@"Green"] == YES )
        {
            g_checklist.greenTestAll = YES;
        }
        if ( [_testType isEqualToString:@"Blue"] == YES )
        {
            g_checklist.blueTestAll = YES;
        }
        if ( [_testType isEqualToString:@"White"] == YES )
        {
            g_checklist.whiteTestAll = YES;
        }
    }
}

@end
