//
//  AudioJunk1ViewController.m
//  AudioJunk1
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AudioJunk1ViewController.h"
#import "AudioJunk1AppDelegate.h"

@implementation AudioJunk1ViewController

@synthesize audioController, segWaveform, attenLabel, mainScroll, attenSlider;


@synthesize m_MidiMonitorView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

int CoreMidiCallback(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext)
{
    NSLog(@"Got data!");
    
    return 0;
}

- (id) initWithTabBar
{
    if([self init])
    {
        // Tab Title
        self.title = @"Synth";
        //self.tabBarItem.image = [UIImage imageNamed:@"name_gray.png"];
        
        // set the long name shown in the navigation bar at the top
        self.navigationController.title = @"Synth";     
        
        m_pCoreMidiObject = new CoreMidiObject(CoreMidiCallback, audioController);
        m_pCoreMidiObject->init();
    }
    
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (IBAction) changeSegControl:(id)sender
{
	[audioController SetWaveform:self.segWaveform.selectedSegmentIndex];
}

- (IBAction) changeAttenSlider:(id)sender
{	
	[audioController SetAttentuation:(float)attenSlider.value];
	attenLabel.text = [[NSString alloc] initWithFormat:@"Filter Tap: %f", (float)attenSlider.value];
}

- (IBAction) changeCutoffSlider:(id)sender
{
    [audioController SetBWCutoff:(double)cutoffSlider.value];
    cutoffLabel.text = [[NSString alloc] initWithFormat:@"BW Cutoff: %f", (double)cutoffSlider.value];
}

- (IBAction) changeKsCutoffSlider:(id)sender
{
    [audioController SetKSBWCutoff:(double)ksCutoffSlider.value];
    ksCutoffLabel.text = [[NSString alloc] initWithFormat:@"KS BW Cutoff: %f", (double)ksCutoffSlider.value];
}

- (IBAction) changeKsOrderSlider:(id)sender
{
    int newOrder = (int)(ksOrderSlider.value + 0.5f);   
    newOrder = newOrder + (newOrder % 2);
    
    [audioController SetKSBWOrder:newOrder];
    ksOrderLabel.text = [[NSString alloc] initWithFormat:@"KS Order: %d", newOrder];
}

- (IBAction) pluckButtonClick:(id)sender
{
	UIButton *b = (UIButton*)sender;
	NSString *name = b.currentTitle;
	NSArray *arr = [name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"fs"]];
	
	if([arr count] != 3) return;
	
	int string_n = [[arr objectAtIndex:1] intValue];
	int fret_n = [[arr objectAtIndex:2] intValue];
	
    // Turn off the note for the synths
    [audioController NoteOff];
    
    [audioController PluckStringFret:string_n atFret:fret_n];
	m_psp->SendLEDMsg(string_n, fret_n, "off");
	
	return;
}

- (IBAction) pluckButtonClickDown:(id)sender
{
	UIButton *b = (UIButton*)sender;
	NSString *name = b.currentTitle;
	NSArray *arr = [name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"fs"]];
	
	if([arr count] != 3) return;
	
	int string_n = [[arr objectAtIndex:1] intValue];
	int fret_n = [[arr objectAtIndex:2] intValue];
	
	m_psp->SendLEDMsg(string_n, fret_n, "on");    
    [audioController NoteOnStringFret:string_n atFret:fret_n];
	
	return;
}

// This should be called in a thread proc
- (void) checkRxSerialInput
{
	unsigned char *pBuffer;
	int bytes_n = m_psp->ReadSerialPort(pBuffer);
	
	if(bytes_n > 0)
	{
		for(int i = 0; i < bytes_n; i++)
		{
			switch(pBuffer[i])
			{
				case 0x80:
				{
					// Make sure that the message is large enough
					if((i + 3) >= bytes_n) 
						return;
					
					// this is note off, the next two indicate midi-note and velocity
					// then one more byte of encoded string/fret position
					unsigned char midinote = pBuffer[i + 1];
					unsigned char vel = pBuffer[i + 2];  
					unsigned char strfret = pBuffer[i + 3];					
					
					i += 3;
				} break;
					
				case 0x90:
				{
					// Make sure that the message is large enough
					if((i + 3) >= bytes_n) 
						return;
					
					// Note ON, first byte indicates midi note, second byte velocity
					// then last byte is string/fret position
					unsigned char midinote = pBuffer[i + 1];
					unsigned char vel = pBuffer[i + 2];  
					unsigned char strfret = pBuffer[i + 3];
					
					unsigned char str = (strfret >> 5);
					unsigned char fret = (strfret & 0x1F);
					
					// Lets just send the pluck info for this, the other messages are unneeded for now
					[audioController PluckStringFret:(int)str atFret:(int)fret];
					
					i += 3;
				} break;
					
				case 0xB0:
				{
					if((i + 2) >= bytes_n) 
						return;
					
					// This is a fret down / up message
					// First byte is whether its up or down, second byte is encoded string/fret position
					unsigned char updown = pBuffer[i + 1];
					unsigned char strfret = pBuffer[i + 2];  
					
					i += 2;
				} break;
			}
		}
	}
	
	return;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	int StringWidth = mainScroll.frame.size.width / g_NumStrings;
	int FretHeight = StringWidth;
    //m_MidiMonitorView = NULL;
	
	// Set up scroll view
	mainScroll.contentSize = CGSizeMake(g_NumStrings * StringWidth, g_NumFrets * FretHeight);
	mainScroll.maximumZoomScale = 1.0f;
	mainScroll.minimumZoomScale = 1.0f;
	mainScroll.clipsToBounds = TRUE;
	mainScroll.delegate = self;
	
	// Set up the buttons
	pppPluckButtons = new FretButton**[g_NumStrings];
	
	for(int i = 0; i < g_NumStrings; i++)
	{
		pppPluckButtons[i] = new FretButton*[g_NumFrets];
		for(int j = 0; j < g_NumFrets; j++)
		{
			pppPluckButtons[i][j] = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			
			NSString *tempString = [[NSString alloc] initWithFormat:@"s%df%d", i, j];
			
			[pppPluckButtons[i][j] setTitle:tempString forState:UIControlStateNormal];
			pppPluckButtons[i][j].frame = CGRectMake(StringWidth * i, FretHeight * j,StringWidth, FretHeight);
			[pppPluckButtons[i][j] addTarget:self action:@selector(pluckButtonClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
			[pppPluckButtons[i][j] addTarget:self action:@selector(pluckButtonClickDown:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
			[mainScroll addSubview:pppPluckButtons[i][j]];
			
			[tempString release];
		}
	}
	
	[audioController SetAttentuation:(float)attenSlider.value];
	attenLabel.text = [[NSString alloc] initWithFormat:@"Filter Tap: %f", (float)attenSlider.value];
    
    [audioController SetBWCutoff:(double)cutoffSlider.value];
    cutoffLabel.text = [[NSString alloc] initWithFormat:@"BW Cutoff: %f", (double)cutoffSlider.value];
    
    // Ks Cuttoff
    [audioController SetKSBWCutoff:(double)ksCutoffSlider.value];
    ksCutoffLabel.text = [[NSString alloc] initWithFormat:@"KS BW Cutoff: %f", (double)ksCutoffSlider.value];
    
    // Ks Order
    int newOrder = (int)(ksOrderSlider.value + 0.5f);   
    newOrder = newOrder + (newOrder % 2);
    [audioController SetKSBWOrder:newOrder];
    ksOrderLabel.text = [[NSString alloc] initWithFormat:@"KS Order: %d", newOrder];
	
	[audioController initializeAUGraph:(int)segWaveform.selectedSegmentIndex];
	[audioController startAUGraph];
	
	// Initialize the serial port
	m_psp = new SerialPort();
	
	// Set up the rxTimer
	serialRxTimer = [NSTimer scheduledTimerWithTimeInterval:0.002 target:self selector:@selector(checkRxSerialInput) userInfo:nil repeats:YES];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[segWaveform release];
	
	[mainScroll release];
	
	[audioController stopAUGraph];
	[audioController release];
	
    [super dealloc];
}

@end
