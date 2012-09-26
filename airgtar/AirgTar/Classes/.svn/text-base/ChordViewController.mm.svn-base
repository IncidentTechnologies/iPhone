//
//  ChordViewController.m
//  AirgTar
//
//  Created by idanbeck on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChordViewController.h"


@implementation ChordViewController

@synthesize m_ViewHeight;
@synthesize m_pgTarState;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


static char g_keys[] =
{
	'C', 'D', 'E', 'F', 'G', 'A', 'B'
};

static int keys_n = sizeof(g_keys) / sizeof(g_keys[0]);

static char *g_mods[] =
{
	"b5", "#5", "6", "7", "9"
};

static CHORD_STATES g_mod_states[] = 
{
	CHORD_FLAT5, CHORD_SHARP5, CHORD_6, CHORD_7, CHORD_9
};

static int g_mods_n = sizeof(g_mods) / sizeof(g_mods[0]);

-(IBAction)KeyButtonDown:(id)sender
{
	UIButton *tempButton = (UIButton *)sender;
	
	///*
	for(int i = 0; i < keys_n; i++)
	{
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
		[m_ppbuttonKeys[i] setBackgroundImage:image forState:UIControlStateNormal];
		
		if (m_ppbuttonKeys[i] == tempButton && m_pgTarState != nil) 
		{
			m_pgTarState.m_RootKey = i + 1;
		}
	}
	//*/
	
	UIImage *image = [UIImage imageNamed:@"airgTarButtonOn.png"];			
	[tempButton setBackgroundImage:image forState:UIControlStateNormal];
}


-(IBAction)FlatButtonDown:(id)sender
{
	UIButton *tempButton = (UIButton *)sender;
	
	if(m_pgTarState.m_fFlat)
	{
		m_pgTarState.m_fFlat = false;
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
	}
	else 
	{
		m_pgTarState.m_fFlat = true;
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOn.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
	}

	UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
	[m_pbuttonSharp setBackgroundImage:image forState:UIControlStateNormal];
	m_pgTarState.m_fSharp = false;

}


-(IBAction)SharpButtonDown:(id)sender
{
	UIButton *tempButton = (UIButton *)sender;
	
	if(m_pgTarState.m_fSharp)
	{
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
		m_pgTarState.m_fSharp = false;
	}
	else 
	{
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOn.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
		m_pgTarState.m_fSharp = true;
	}

	UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
	[m_pbuttonFlat setBackgroundImage:image forState:UIControlStateNormal];
	m_pgTarState.m_fFlat = false;
}


-(IBAction)MinorButtonDown:(id)sender
{
	UIButton *tempButton = (UIButton *)sender;
	
	if([m_pgTarState CheckState:CHORD_MINOR])
	{
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
		
		[m_pgTarState DisableState:CHORD_MINOR];
	}
	else 
	{
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOn.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
		[m_pgTarState EnableState:CHORD_MINOR];
	}

	UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
	[m_pbuttonMajor setBackgroundImage:image forState:UIControlStateNormal];
}


-(IBAction)MajorButtonDown:(id)sender
{
	UIButton *tempButton = (UIButton *)sender;
	if([m_pgTarState CheckState:CHORD_MAJOR])
	{
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
		
		[m_pgTarState DisableState:CHORD_MAJOR];
	}
	else 
	{
		UIImage *image = [UIImage imageNamed:@"airgTarButtonOn.png"];			
		[tempButton setBackgroundImage:image forState:UIControlStateNormal];
		
		[m_pgTarState EnableState:CHORD_MAJOR];
	}

	UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
	[m_pbuttonMinor setBackgroundImage:image forState:UIControlStateNormal];	

}


-(IBAction)ModifierButtonDown:(id)sender
{
	UIButton *tempButton = (UIButton *)sender;

	///*
	for(int i = 0; i < g_mods_n; i++)
	{	
		if (m_ppbuttonModifiers[i] == tempButton && m_pgTarState != nil) 
		{
			if([m_pgTarState CheckState:g_mod_states[i]])
			{
				[m_pgTarState DisableState:g_mod_states[i]];
				
				UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
				[m_ppbuttonModifiers[i] setBackgroundImage:image forState:UIControlStateNormal];				
			}
			else 
			{
				[m_pgTarState EnableState:g_mod_states[i]];
				
				UIImage *image = [UIImage imageNamed:@"airgTarButtonOn.png"];			
				[m_ppbuttonModifiers[i] setBackgroundImage:image forState:UIControlStateNormal];
				
				// Certain modifiers cannot be on at the same time
				if(g_mod_states[i] == CHORD_7)
				{
					for(int j = 0; j < g_mods_n; j++)
						if(g_mod_states[j] == CHORD_6 && m_ppbuttonModifiers[j] != NULL)
						{
							UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
							[m_ppbuttonModifiers[j] setBackgroundImage:image forState:UIControlStateNormal];
						}
				}
				else if(g_mod_states[i] == CHORD_6)
				{
					for(int j = 0; j < g_mods_n; j++)
						if(g_mod_states[j] == CHORD_7 && m_ppbuttonModifiers[j] != NULL)
						{
							UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
							[m_ppbuttonModifiers[j] setBackgroundImage:image forState:UIControlStateNormal];
						}
				}
				else if(g_mod_states[i] == CHORD_FLAT5)
				{
					for(int j = 0; j < g_mods_n; j++)
						if(g_mod_states[j] == CHORD_SHARP5 && m_ppbuttonModifiers[j] != NULL)
						{
							UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
							[m_ppbuttonModifiers[j] setBackgroundImage:image forState:UIControlStateNormal];
						}
				}
				else if(g_mod_states[i] == CHORD_SHARP5)
				{
					for(int j = 0; j < g_mods_n; j++)
						if(g_mod_states[j] == CHORD_FLAT5 && m_ppbuttonModifiers[j] != NULL)
						{
							UIImage *image = [UIImage imageNamed:@"airgTarButtonOff.png"];			
							[m_ppbuttonModifiers[j] setBackgroundImage:image forState:UIControlStateNormal];
						}
				}
			}
		}
	}
	//*/
}

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, m_ViewHeight);
	
	// Assign Key Buttons
	m_ppbuttonKeys = new UIButton*[keys_n];
	m_ppbuttonKeys[0] = m_pbuttonC;
	m_ppbuttonKeys[1] = m_pbuttonD;
	m_ppbuttonKeys[2] = m_pbuttonE;
	m_ppbuttonKeys[3] = m_pbuttonF;
	m_ppbuttonKeys[4] = m_pbuttonG;
	m_ppbuttonKeys[5] = m_pbuttonA;
	m_ppbuttonKeys[6] = m_pbuttonB;
	
	// Rotate the buttons	
	// First row
	m_pbuttonC.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-15.0f));
	m_pbuttonD.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-45.0f));
	m_pbuttonE.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-70.0f));
	m_pbuttonF.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-80.0f));
	
	// Second Row
	m_pbuttonG.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-15.0f));
	m_pbuttonA.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-55.0f));
	m_pbuttonB.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-82.0f));
	
	// Mod Buttons	
	m_ppbuttonModifiers = new UIButton*[g_mods_n];
	m_ppbuttonModifiers[0] = NULL;
	m_ppbuttonModifiers[1] = NULL;
	m_ppbuttonModifiers[2] = m_pbutton6;
	m_ppbuttonModifiers[3] = m_pbutton7;
	m_ppbuttonModifiers[4] = m_pbutton9;
	
	CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(180.0f));
	[self.view setTransform:trans];
	
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
