//
//  PlayScoreController.m
//  gTar
//
//  Created by wuda on 11/5/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "PlayScoreController.h"


@implementation PlayScoreController

@synthesize m_replayController;
@synthesize m_songNameLabel, m_scoreLabel, m_notesLabel, m_comboLabel;
@synthesize m_gstar1, m_gstar2, m_gstar3, m_gstar4, m_gstar5;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)updateScores
{
	
	[m_songNameLabel setText:m_songName];
	[m_scoreLabel setText:[NSString stringWithFormat:@"%u!", m_score]];
	CGFloat percentHit = (CGFloat)m_notesHit * 100.0 / (CGFloat)m_notesMax;
	[m_notesLabel setText:[NSString stringWithFormat:@"%3.0f%% hit!", percentHit]];
	[m_comboLabel setText:[NSString stringWithFormat:@"%u note streak!", m_combo]];
	
	// set the stars based on how high the score is.
	// the 'on' stars are hiding behind the 'off' stars
	CGFloat percentScore = (CGFloat)m_score / (CGFloat)m_scoreMax;
	
	if ( percentScore > 0.20 )
	{
		[m_gstar1 setHidden:YES];
	}
	if ( percentScore > 0.40 )
	{
		[m_gstar2 setHidden:YES];
	}
	if ( percentScore > 0.60 )
	{
		[m_gstar3 setHidden:YES];
	}
	if ( percentScore > 0.80 )
	{
		[m_gstar4 setHidden:YES];
	}
	if ( percentScore > 0.90 )
	{
		[m_gstar5 setHidden:YES];
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Button click handling

//-(IBAction)backButtonClicked
//{
//	[self.navigationController popToViewController:m_returnToController animated:YES];
//}

-(IBAction)replayButtonClicked
{
	[self.navigationController popToViewController:m_replayController animated:YES];	
}
@end
