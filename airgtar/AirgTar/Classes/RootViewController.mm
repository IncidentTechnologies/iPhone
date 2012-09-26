//
//  RootViewController.m
//  AirgTar
//
//  Created by idanbeck on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#include <time.h>


@implementation RootViewController

@synthesize buttonChordView, buttonPlaySongView, buttonSettingsView, buttonConnectPick, buttonConnectAsPick;

@synthesize chordViewController, noteViewController;
@synthesize m_pgTarState;

@synthesize m_pAccel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

BOOL g_fLastProximityState = FALSE;
long int g_LastClockTicks = 0;

#define MAX_PLUCK_TIME 0.25f
#define MAX_PLUCK_DELAY 0.15f
#define KILL_ATTEN 0.9f
#define PLAY_ATTEN 0.985f

-(void) PreventPxomityScreenLock
{
	// We're going to try to flip the proximity sensing on/off 
	// which will likely stop it from locking the string but it might also
	// register a proximity changed event in the process (experimental)
	
	
	UIDevice *device = [UIDevice currentDevice];
	;
	
	if(g_fLastProximityState == TRUE) 
	{
		if(device.proximityMonitoringEnabled == TRUE)
	    {
			device.proximityMonitoringEnabled = FALSE;
			NSLog(@"Prevent screen lock! - OFF");
		}
		else 
		{			
			device.proximityMonitoringEnabled = TRUE;
			NSLog(@"Prevent screen lock! -- ON");
		}
	}
		
	
	// check it if worked
	/*
	if(device.proximityMonitoringEnabled)
	{
		NSLog(@"Proximity monitoring enabled!");
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(ProximityChanged:) 
													 name:@"UIDeviceProximityStateDidChangeNotification" 
												   object:device];
	}
	else 
		NSLog(@"Proximity monitoring not supported on current device!");
	 */
	
	
}

-(void) ProximityChanged:(NSNotification *)notify
{
	UIDevice *device = [notify object];

	
	if(m_pgTarState != NULL && g_fLastProximityState == TRUE && (BOOL)device.proximityState == FALSE)
	{
		// Invalidate the timer
		[timerProx invalidate];
		timerProx = NULL;
		
		//[m_pgTarState TestPluckString:0 fret:0];
		double PluckTime = (float)(clock() - g_LastClockTicks) / (float)(CLOCKS_PER_SEC);
		float pluckDelay = 0.010;
		if(PluckTime > MAX_PLUCK_TIME)
			pluckDelay = MAX_PLUCK_DELAY;
		else 
			pluckDelay =  (PluckTime / MAX_PLUCK_TIME) * MAX_PLUCK_DELAY;

		
		NSLog(@"Pluck with delay: %f from %f", pluckDelay, PluckTime);
		[m_pgTarState.m_ac SetAttentuation:PLAY_ATTEN];
		[m_pgTarState PlayChordState:pluckDelay];
	}
	else if((BOOL)device.proximityState == TRUE)
	{
		g_LastClockTicks = clock();
		
		// Also mute the strings by attenuating
		[m_pgTarState.m_ac SetAttentuation:KILL_ATTEN];
		
		/*
		// Set up screen lock prevention
		timerProx = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self 
												   selector:@selector(PreventPxomityScreenLock) 
												   userInfo:nil repeats:YES];
		 */
	}
	
	g_fLastProximityState = (BOOL)device.proximityState;
}

///*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	UIDevice *device = [UIDevice currentDevice];
	device.proximityMonitoringEnabled = TRUE;
	
	// check it if worked
	if(device.proximityMonitoringEnabled)
	{
		NSLog(@"Proximity monitoring enabled!");
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(ProximityChanged:) 
													 name:@"UIDeviceProximityStateDidChangeNotification" 
												   object:device];
	}
	else 
		NSLog(@"Proximity monitoring not supported on current device!");
	
	// Turn off the idle timer
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	m_pgTarState = [[gTarState alloc] init];
	
	// Flip the view
	//[self.view setTransform:CGAffineTransformMakeRotation(180.0f)];
	
	// Set up the accelerometer 
	self.m_pAccel = [UIAccelerometer sharedAccelerometer];
	self.m_pAccel.updateInterval = 0.1f;
	self.m_pAccel.delegate = self;
	
	// Must be oriented properly
	CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(180.0f));
	[self.view setTransform:trans];
	
	[super viewDidLoad];
}
//*/

#define ACCEL_DELTA_THRES 0.275f

double g_lastX;

BOOL m_fLastState = false;

// delegate function for the accelerometer
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	// We only send a pick event if the connection is established and the current device is the pick
	
	if( abs(acceleration.x - g_lastX) > ACCEL_DELTA_THRES)// ||
	    //abs(acceleration.y) - g_lastY > ACCEL_DELTA_THRES ||
		//abs(acceleration.z) - g_lastZ > ACCEL_DELTA_THRES)
	{
		NSLog(@"LastX:%f new X:%f", g_lastX, acceleration.x);
		
		if(m_fLastState == false)
			m_fLastState = true;
		else 
		{
			if(m_pgTarState.m_fPickConnected == TRUE && m_pgTarState.m_fPick == TRUE)
				[m_pgTarState SendPluck];
			
			m_fLastState = false;			
		}
	}
	else 
	{
		m_fLastState = false;
	}
	
	g_lastX = acceleration.x;
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction) switchPageToChordView:(id)sender
{
	if(self.chordViewController == NULL)
	{		
		self.chordViewController = [[ChordViewController alloc] initWithNibName:@"ChordViewController" bundle:[NSBundle mainBundle]];
		self.chordViewController.m_ViewHeight = self.view.frame.size.height;
		//self.chordViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		self.chordViewController.m_pgTarState = m_pgTarState;
	}
	
	[self.navigationController pushViewController:self.chordViewController animated:TRUE];
}

-(IBAction) switchPageToNoteView:(id)sender
{
	if(self.noteViewController == NULL)
	{
		self.noteViewController = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:[NSBundle mainBundle]];
		self.noteViewController.m_ViewHeight = self.view.frame.size.height;
		self.noteViewController.m_pgTarState = m_pgTarState;
	}
	
	[self.navigationController pushViewController:self.noteViewController animated:TRUE];
}

-(IBAction) connectPick:(id)sender
{
	return [m_pgTarState ConnectPickiOS:sender];
}

-(IBAction) connectAsPick:(id)sender
{
	return [m_pgTarState ConnectAsPickiOS:sender];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[buttonPlaySongView dealloc];
	[buttonChordView dealloc];
	[buttonSettingsView dealloc];
	
    [super dealloc];
}


@end
