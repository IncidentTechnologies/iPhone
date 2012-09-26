//
//  ThirdViewController.m
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "ThirdViewController.h"

#import "GuitarEffectSequence.h"
#import "GuitarEffectSerialized.h"
#import "GuitarController.h"

extern GuitarController * g_guitarController;

@implementation ThirdViewController

@synthesize m_splashScreen;
@synthesize m_blackScreen;
@synthesize m_whiteScreen;
@synthesize m_blackWhiteSwitch;
@synthesize m_rotationControl;
@synthesize m_preLabel;
@synthesize m_postLabel;
@synthesize m_connectionLabel;
@synthesize m_effectsSequence;
@synthesize m_effectsSequenceSerialized;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        
        self.title = NSLocalizedString(@"Start", @"Start");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
                        
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
    
    m_preDelay = 5;
    m_postDelay = 5;
    
    [m_preLabel setText:[NSString stringWithFormat:@"%u",m_preDelay]];
    [m_postLabel setText:[NSString stringWithFormat:@"%u",m_postDelay]];
    
}

- (void)viewDidUnload
{
    [self setM_blackWhiteSwitch:nil];
    [self setM_preLabel:nil];
    [self setM_postLabel:nil];
    [self setM_connectionLabel:nil];
    [self setM_rotationControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    g_guitarController.m_delegate = (id<GuitarControllerDelegate>)self;
    
    if ( g_guitarController.m_connected == YES )
    {
        [m_connectionLabel setText:@"Connected"];
        [m_connectionLabel setTextColor:[UIColor greenColor]];
    }
    else
    {
        [m_connectionLabel setText:@"Disconnected"];
        [m_connectionLabel setTextColor:[UIColor redColor]];
    }

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

- (IBAction)prePlusClicked:(id)sender
{
    m_preDelay++;
    [m_preLabel setText:[NSString stringWithFormat:@"%u",m_preDelay]];
}

- (IBAction)preMinusClicked:(id)sender
{
    m_preDelay--;
    [m_preLabel setText:[NSString stringWithFormat:@"%u",m_preDelay]];
}

- (IBAction)postPlusClicked:(id)sender
{
    m_postDelay++;
    [m_postLabel setText:[NSString stringWithFormat:@"%u",m_postDelay]];
}

- (IBAction)postMinusClicked:(id)sender
{
    m_postDelay--;
    [m_postLabel setText:[NSString stringWithFormat:@"%u",m_postDelay]];
}

- (IBAction)startButtonClicked:(id)sender
{
    
    [self fadeInBlack];
    
    
    if ( m_blackWhiteSwitch.isOn == YES )
    {
        if ( m_rotationControl.selectedSegmentIndex == 0 ||
             m_rotationControl.selectedSegmentIndex == 2 )
        {
            m_splashScreen.image = [UIImage imageNamed:@"gTarApp_Icon640X960_W.png"];
        }
        else
        {
            m_splashScreen.image = [UIImage imageNamed:@"gTarApp_Icon640X960_W_portrait.png"];
        }
    }
    else
    {
        m_splashScreen.image = [UIImage imageNamed:@"gTarApp_Icon640X960_B.png"];
    }
    
    if ( m_rotationControl.selectedSegmentIndex == 0 )
    {
        m_splashScreen.transform = CGAffineTransformIdentity;
    }
    if ( m_rotationControl.selectedSegmentIndex == 1 )
    {
        
        if ( m_blackWhiteSwitch.isOn == NO )
        {
            CGAffineTransform trans = CGAffineTransformMakeRotation(-3.14/2.0);
            trans = CGAffineTransformScale( trans, 0.8, 0.8);
            m_splashScreen.transform = trans;
        }
        else
        {
            m_splashScreen.transform = CGAffineTransformIdentity;
        }

    }
    if ( m_rotationControl.selectedSegmentIndex == 2 )
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(-3.14);
        
        m_splashScreen.transform = trans;
    }
    if ( m_rotationControl.selectedSegmentIndex == 3 )
    {

        if ( m_blackWhiteSwitch.isOn == NO )
        {
            CGAffineTransform trans = CGAffineTransformMakeRotation(3.14/2.0);
            trans = CGAffineTransformScale( trans, 0.8, 0.8);
            m_splashScreen.transform = trans;
        }
        else
        {
            CGAffineTransform trans = CGAffineTransformMakeRotation(3.14);
            m_splashScreen.transform = trans;
        }

    }
    
    GuitarEffectSequence * seq = [[GuitarEffectSequence alloc] init];
    
    [seq serializeEffectArray:m_effectsSequence];
    
    m_effectsSequenceSerialized = [NSMutableArray arrayWithArray:seq.m_effectSequenceSerialized];
    
    [g_guitarController turnOffAllLeds];
    
}

- (void)fadeInBlack
{
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.6f];
    
    m_blackScreen.alpha = 1.0f;
    
	[UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:m_preDelay target:self selector:@selector(fadeInSplash) userInfo:nil repeats:NO];

}

- (void)fadeOutBlack
{
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.6f];
    
    m_blackScreen.alpha = 0.0f;
    
	[UIView commitAnimations];
    
    [g_guitarController turnOffAllLeds];

}

- (void)fadeInSplash
{
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.6f];
    
    m_splashScreen.alpha = 1.0f;
    
	[UIView commitAnimations];
    
//    [self startEffectsSequence];
    [self startEffectsSequenceLoop];
    
}

- (void)fadeOutSplash
{
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.6f];
    
    m_splashScreen.alpha = 0.0f;
    
	[UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(fadeOutBlack) userInfo:nil repeats:NO];

}

- (void)startEffectsSequence
{
    
    if ( [m_effectsSequenceSerialized count] == 0 )
    {
        return;
    }
    
    GuitarEffectSerialized * effect = [m_effectsSequenceSerialized objectAtIndex:0];
    
//    NSLog(@"Delay: %f Str: %u Fret %u", 
//          effect.m_effectTime,
//          effect.m_string,
//          effect.m_fret);
    
    if ( effect == nil )
    {
        return;
    }
    
    [m_effectsSequenceSerialized removeObjectAtIndex:0];
    
    [self sendEffectToGuitar:effect];
    
    // queue up the next
    if ( [m_effectsSequenceSerialized count] > 0 )
    {
        [NSTimer scheduledTimerWithTimeInterval:effect.m_effectTime target:self selector:@selector(startEffectsSequence) userInfo:nil repeats:NO];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:m_postDelay target:self selector:@selector(fadeOutSplash) userInfo:nil repeats:NO];
    }
    
}

// not used right now
- (void)startEffectsSequenceLoop
{
    
    for ( GuitarEffectSerialized * effect in m_effectsSequenceSerialized )
    {
        [self sendEffectToGuitar:effect];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:m_postDelay target:self selector:@selector(fadeOutSplash) userInfo:nil repeats:NO];

}

- (void)sendEffectToGuitar:(GuitarEffectSerialized*)effect
{
    
    if ( effect.m_effectType == GuitarEffectTypeClear )
    {
        [g_guitarController turnOffAllLeds];
    }
    else if ( effect.m_effectType == GuitarEffectTypeLedOn )
    {
        
        [g_guitarController turnOnLedAtString:effect.m_string
                                      andFret:effect.m_fret
                                      withRed:effect.m_red
                                     andGreen:effect.m_green
                                      andBlue:effect.m_blue];
        
    }
    
}

#pragma mark - GuitarControllerDelegate

- (void)guitarFretDown:(GuitarFret)fret atString:(GuitarString)str
{
    
}

- (void)guitarFretUp:(GuitarFret)fret atString:(GuitarString)str
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
    [m_connectionLabel setText:@"Connected"];
    [m_connectionLabel setTextColor:[UIColor greenColor]];
}

- (void)guitarDisconnected
{
    [m_connectionLabel setText:@"Disconnected"];
    [m_connectionLabel setTextColor:[UIColor redColor]];
}

@end
