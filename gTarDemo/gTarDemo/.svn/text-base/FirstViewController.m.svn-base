//
//  FirstViewController.m
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "FirstViewController.h"

#import "GuitarEffect.h"

@implementation FirstViewController

@synthesize m_secondViewController;
@synthesize m_clearFirstSwitch;
@synthesize m_redColorControl;
@synthesize m_greenColorControl;
@synthesize m_blueColorControl;
@synthesize m_randomColorSwitch;
@synthesize m_directionControl;
@synthesize m_directionScatteringSwitch;
@synthesize m_durationLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        self.title = NSLocalizedString(@"Add", @"Add");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
        m_duration = 0.5;
        
    }
    
    return self;
    
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [m_durationLabel setText:[NSString stringWithFormat:@"%.2f",m_duration]];

}

- (void)viewDidUnload
{
    [self setM_clearFirstSwitch:nil];
    [self setM_redColorControl:nil];
    [self setM_greenColorControl:nil];
    [self setM_blueColorControl:nil];
    [self setM_randomColorSwitch:nil];
    [self setM_directionControl:nil];
    [self setM_directionScatteringSwitch:nil];
    [self setM_durationLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)addButtonClicked:(id)sender
{
    
    GuitarEffect * effect = [[GuitarEffect alloc] init];
    
    effect.m_clearFirst = m_clearFirstSwitch.isOn;
    
    effect.m_colorRed = m_redColorControl.selectedSegmentIndex;
    effect.m_colorGreen = m_greenColorControl.selectedSegmentIndex;
    effect.m_colorBlue = m_blueColorControl.selectedSegmentIndex;
    effect.m_colorRandom = m_randomColorSwitch.isOn;
    
    effect.m_direction = m_directionControl.selectedSegmentIndex;
    effect.m_directionScattering = m_directionScatteringSwitch.isOn;
    
    effect.m_duration = m_duration;
    
    [m_secondViewController addEffect:effect];
    
}

- (IBAction)plusButtonClicked:(id)sender
{
    m_duration += 0.10;
    
    [m_durationLabel setText:[NSString stringWithFormat:@"%.2f",m_duration]];
}

- (IBAction)minusButtonClicked:(id)sender
{
    m_duration -= 0.10;
    
    if ( m_duration < 0.00 )
    {
        m_duration = 0.00;
    }
    
    [m_durationLabel setText:[NSString stringWithFormat:@"%.2f",m_duration]];
}

@end
