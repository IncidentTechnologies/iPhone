//
//  LedViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "LedAllViewController.h"

#import "Checklist.h"

extern GtarController * g_gtarController;

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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [g_gtarController turnOffAllLeds];

    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [g_gtarController turnOffAllEffects];
    
    // init tests
    if ( [_testType isEqualToString:@"Red"] == YES )
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0)
                                    withColor:GtarLedColorMake(3, 0, 0)];
    }
    if ( [_testType isEqualToString:@"Green"] == YES )
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0)
                                    withColor:GtarLedColorMake(0, 3, 0)];
    }
    if ( [_testType isEqualToString:@"Blue"] == YES )
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0)
                                    withColor:GtarLedColorMake(0, 0, 3)];
    }
    if ( [_testType isEqualToString:@"White"] == YES )
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0)
                                    withColor:GtarLedColorMake(3, 3, 3)];
    }
    
    // initially set to fail
    if ( [_testType isEqualToString:@"Red"] == YES )
    {
        g_checklist.redTestAll = NO;
    }
    if ( [_testType isEqualToString:@"Green"] == YES )
    {
        g_checklist.greenTestAll = NO;
    }
    if ( [_testType isEqualToString:@"Blue"] == YES )
    {
        g_checklist.blueTestAll = NO;
    }
    if ( [_testType isEqualToString:@"White"] == YES )
    {
        g_checklist.whiteTestAll = NO;
    }
    
    [super viewDidAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
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
