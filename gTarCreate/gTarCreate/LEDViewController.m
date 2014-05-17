//
//  LEDViewController.m
//  gTarCreate
//
//  Created by Idan Beck on 5/14/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "LEDViewController.h"
extern GtarController *g_gtarController;

@interface LEDViewController () {
    
}

@end

@implementation LEDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    oldR = 0;
    oldG = 0;
    oldB = 0;
    
    [self UpdateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) UpdateView {
    float red = ((float)(oldR)/3.0f);
    float green = ((float)(oldG)/3.0f);
    float blue = ((float)(oldB)/3.0f);
    
    [_m_labelFretFollow setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0f]];
    if(oldR > 1 || oldG > 1 || oldB > 1)
        [_m_labelFretFollow setTextColor:[UIColor blackColor]];
    else
        [_m_labelFretFollow setTextColor:[UIColor whiteColor]];
}

- (IBAction)OnSegmentChanged:(id)sender {
    //UISegmentedControl *seg = (UISegmentedControl *)sender;
    
    unsigned char r = [_m_segmentedRed selectedSegmentIndex];
    unsigned char g = [_m_segmentedGreen selectedSegmentIndex];
    unsigned char b = [_m_segmentedBlue selectedSegmentIndex];
    
    NSLog(@"Setting fret follow to r:%d g:%d b:%d", r, g, b);
    
    GtarLedColor gcolor = {r, g, b};
    if([g_gtarController turnOnEffect:GtarControllerEffectFretFollow withColor:gcolor] != GtarControllerStatusOk) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                        message:@"Failed to set Fret Follow"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [_m_segmentedRed setSelectedSegmentIndex:oldR];
        [_m_segmentedRed setSelectedSegmentIndex:oldG];
        [_m_segmentedRed setSelectedSegmentIndex:oldB];
    }
    else {
        oldR = r;
        oldG = g;
        oldB = b;
    }
    
    [self UpdateView];
}

@end
