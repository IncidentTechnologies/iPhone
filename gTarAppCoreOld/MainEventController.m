//
//  MainEventController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "MainEventController.h"

#import <GuitarController.h>
#import <AudioController.h>

#define AUDIO_CONTROLLER_ATTENUATION 0.99f
#define AUDIO_CONTROLLER_ATTENUATION_INCORRECT 0.80f

@implementation MainEventController

@synthesize m_isRunning;

- (id)init
{
    
    self = [super init];
    
    if ( self )
    {
        
        // Custom initialization
        [self sharedInit];
        
    }
    
    return self;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        
        // Custom initialization
        [self sharedInit];
        
    }
    
    return self;
    
}

- (void)sharedInit
{
    
    m_isRunning = NO;
    
    //
    // Load the controllers
    //
    
    // Create guitar controller
//    m_guitarController = [[GuitarController alloc] init];
    
//    [m_guitarController turnOffAllEffects];
//    [m_guitarController turnOffAllLeds];
    
//    m_guitarController.m_delegate = self;

}

- (void)dealloc
{
    
    // Remove ourself as an observer
    [m_guitarController removeObserver:self];
    
    [m_guitarController turnOffAllLeds];
    [m_guitarController turnOffAllEffects];
    
    [m_guitarController release];
    
    [m_eventLoopTimer invalidate];
    
    m_eventLoopTimer = nil;

    [super dealloc];
    
}

- (void)observeGuitarController:(GuitarController*)guitarController
{
    
    m_guitarController = [guitarController retain];
    
    // Register ourself as an observer
    [m_guitarController addObserver:self];
        
}

- (void)ignoreGuitarController:(GuitarController*)guitarController
{
    
    [m_guitarController turnOffAllEffects];
    [m_guitarController turnOffAllLeds];
    
    // Remove ourself as an observer
    [m_guitarController removeObserver:self];
    
    [m_guitarController release];
    
    m_guitarController = nil;
    
}

#pragma mark - View lifecycle

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
    [self stopMainEventLoop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Main event loop

- (void)mainEventLoop
{
	
	
}

- (void)startMainEventLoop
{
	if ( m_eventLoopTimer != nil )
	{
		[self stopMainEventLoop];
	}
	
	m_eventLoopTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)SECONDS_PER_EVENT_LOOP target:self selector:@selector(mainEventLoop) userInfo:nil repeats:TRUE];
    
    m_isRunning = YES;
    
}

- (void)stopMainEventLoop
{
	if ( m_eventLoopTimer != nil )
	{
		[m_eventLoopTimer invalidate];
		
		m_eventLoopTimer = nil;
	}
    
    m_isRunning = NO;
    
}

#pragma GuitarControllerDelegate

- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
    
}

- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
    
}

- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str
{
//    [m_audioController PluckString:str atFret:fret];
}

- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
    
}

- (void)guitarConnected
{

}

- (void)guitarDisconnected
{
 
}

@end
