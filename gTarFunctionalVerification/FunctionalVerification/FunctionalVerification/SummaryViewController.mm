//
//  SummaryViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "SummaryViewController.h"

#import "Checklist.h"

extern Checklist g_checklist;

@interface SummaryViewController ()

@property (strong, nonatomic) NSString * testType;

@end

@implementation SummaryViewController

@synthesize testType = _testType;
@synthesize summaryView = _summaryView;
@synthesize resultLabel = _resultLabel;

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
    
//    NSMutableString * summaryString = [[NSMutableString alloc] init];
    
//    [summaryString appendFormat:@"Connect Test: %@\n", (g_checklist.connectedTest ? @"Pass" : @"FAIL!")];
//    [summaryString appendFormat:@"Red Test: %@\n", (g_checklist.redTestAll ? @"Pass" : @"FAIL!")];
//    [summaryString appendFormat:@"Green Test: %@\n", (g_checklist.greenTestAll ? @"Pass" : @"FAIL!")];
//    [summaryString appendFormat:@"Blue Test: %@\n", (g_checklist.blueTestAll ? @"Pass" : @"FAIL!")];
//    [summaryString appendFormat:@"White Test: %@\n", (g_checklist.whiteTestAll ? @"Pass" : @"FAIL!")];
//    [summaryString appendFormat:@"Fret Test: %@\n", (g_checklist.fretUpTest ? @"Pass" : @"FAIL!")];
//    [summaryString appendFormat:@"Disconnect Test: %@\n", (g_checklist.disconnectedTest ? @"Pass" : @"FAIL!")];
    
//    self.summaryView.text = summaryString;
    
    self.summaryView.text = @"";
    
    if ( [_testType isEqualToString:@"Functional"] )
    {
    
        if ( g_checklist.connectedTest &&
            g_checklist.disconnectedTest &&
            g_checklist.redTestAll &&
            g_checklist.greenTestAll &&
            g_checklist.blueTestAll &&
            g_checklist.whiteTestAll &&
            g_checklist.fretUpTest &&
            g_checklist.fretDownTest &&
            g_checklist.noteOnTest &&
            g_checklist.lineOutTest )
        {
            self.resultLabel.text = @"Pass";
        }
        else
        {
            self.resultLabel.text = @"Fail!";
        }
    }
    
    if ( [_testType isEqualToString:@"MainBoard"] )
    {
        
        if ( g_checklist.connectedTest &&
            g_checklist.disconnectedTest &&
            g_checklist.redTestAll &&
            g_checklist.greenTestAll &&
            g_checklist.blueTestAll &&
            g_checklist.whiteTestAll &&
            g_checklist.fretElectricalTest &&
            g_checklist.piezoElectricalTest &&
            g_checklist.lineOutTest &&
            g_checklist.batteryTest )
        {
            self.resultLabel.text = @"Pass";
        }
        else
        {
            self.resultLabel.text = @"Fail!";
        }
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
