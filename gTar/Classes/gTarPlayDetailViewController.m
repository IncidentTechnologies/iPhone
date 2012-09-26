//
//  gTarPlayDetailViewController.m
//  gTar
//
//  Created by wuda on 1/11/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//
#import "gTarPlayDetailViewController.h"

//#import "PlayController.h"
#import "PlayControllerNew.h"
#import "PlayScoreController.h"
#import "gTarPlayViewController.h"
#import "gTarPlayTabsViewController.h"
#import "gTarPlayModalViewController.h"


@implementation gTarPlayDetailViewController

@synthesize m_xmpBlob;
@synthesize m_userSong;

@synthesize m_title, m_author, m_description, m_icon, m_achievements;
@synthesize m_blackView, m_ampView;

extern EAGLViewDisplayMode g_eaglDisplayMode;

#define AMP_HEIGHT (90.0)
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
#if 1
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//[self animateModal:NO];
	// insert the subviews
	// the black one perfectly overlays the base view
	//m_blackView.frame = self.view.frame;
	// the amp is offset down
	//m_ampView.frame = CGRectMake(0, self.view.frame.size.height - AMP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height);
	
	NSInteger height = self.view.frame.size.height - AMP_HEIGHT;

	m_ampView.transform = 
	CGAffineTransformMakeTranslation( 0, height );
	
	[self.view addSubview:m_blackView];
	[self.view addSubview:m_ampView];
	
	//UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake (100, 100, 100, 100)];
	//[self.view addSubview:textView];
	
	m_popupVisible = NO;
	
	//NSInteger height = self.view.frame.size.height;	
	//m_modalView.transform = CGAffineTransformMakeTranslation( 0, +height );

}

- (void)viewWillAppear:(BOOL)animated
{

	[m_title setText:m_userSong.m_title];
	m_title.adjustsFontSizeToFitWidth = YES;
	
	[m_author setText:[NSString stringWithFormat:@"by %@", m_userSong.m_author]];
	m_author.adjustsFontSizeToFitWidth = YES;
	
	[m_description setText:m_userSong.m_description];
	m_description.adjustsFontSizeToFitWidth = YES;

}
#endif

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (IBAction)backButtonClicked:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)playButtonClicked:(id)sender
{
	[self animateModal:YES];
}

- (IBAction)cancelButtonClicked:(id)sender
{
	[self animateModal:NO];
}

- (IBAction)easyButtonClicked:(id)sender
{
	m_difficulty = @"Easy";
	[self playWithXmpBlob:m_xmpBlob];
	[self animateModal:NO];
}
- (IBAction)mediumButtonClicked:(id)sender
{
	m_difficulty = @"Medium";
	[self playWithXmpBlob:m_xmpBlob];
	[self animateModal:NO];
}
- (IBAction)hardButtonClicked:(id)sender
{
	m_difficulty = @"Hard";
	[self playWithXmpBlob:m_xmpBlob];
	[self animateModal:NO];
}
- (IBAction)realButtonClicked:(id)sender
{
	m_difficulty = @"Real";
	[self playWithXmpBlob:m_xmpBlob];
	[self animateModal:NO];
}

- (void)animateModal:(BOOL)popup
{
	
	NSInteger height = self.view.frame.size.height - AMP_HEIGHT;
	
	// slide the popup off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];

	if ( m_popupVisible == NO)
	{
		m_ampView.transform = 
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height - (self.view.frame.size.height - m_modalView.frame.size.height)/2 );
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height + (m_modalView.frame.size.height/2) );
		CGAffineTransformMakeTranslation( 0, 0 );
	
		m_blackView.alpha = 0.8;
	}
	else 
	{
		m_ampView.transform = 
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height - (self.view.frame.size.height - m_modalView.frame.size.height)/2 );
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height + (m_modalView.frame.size.height/2) );
		CGAffineTransformMakeTranslation( 0, height );
		
		m_blackView.alpha = 0.0;
	}
	
	m_popupVisible = !m_popupVisible;
	
	[UIView commitAnimations];

}	

- (void)playWithXmpBlob:(NSString*)xmpBlob
{
	
	if ( xmpBlob == nil )
	{
		return;
	}
	
	PlayControllerNew * playController = [[PlayControllerNew alloc] initWithNibName:@"PlayController" bundle:nil];
	
	playController.m_songName = m_userSong.m_title;
	
	playController.m_xmpBlob = xmpBlob;
	g_eaglDisplayMode = DisplayModeES;

	/*
	if ( m_debugger != nil )
	{
		playController.m_debugger = m_debugger;
	}
	if ( m_clone != nil )
	{
		playController.m_clone = m_clone;
	}
	*/
	if ( m_difficulty == @"Easy" )
	{
		playController.m_tempo = TempoNone;
		playController.m_accuracy = NewAccuracyStringOnly;
		playController.m_penalty = NO;
	}
	else if ( m_difficulty == @"Medium" )
	{
		playController.m_tempo = TempoNone; 
		playController.m_accuracy = NewAccuracyExactNote;	
		playController.m_penalty = NO;
	}
	else if ( m_difficulty == @"Hard" )
	{
		playController.m_tempo = TempoAutoAdjust; 
		playController.m_accuracy = NewAccuracyExactNote;	
		playController.m_penalty = YES;
	}
	else 
	{
		playController.m_tempo = TempoReal;
		playController.m_accuracy = NewAccuracyExactNote;
		playController.m_penalty = YES;
	}
	
	playController.m_returnToController = self;
	
#if 0
	// Score controller
	PlayScoreController * playSc = [[PlayScoreController alloc] init];
	//	playSc.m_nibName = @"PlayScoreController";
	playSc.m_returnToController = self;
	
	playController.m_scoreController = playSc;
	
	[playController changeDisplayMode:PlayControllerModePlay];
#endif
	// Navigate
	[self.navigationController pushViewController:playController animated:YES];
	
	// All done, release.
	[playController release];
	
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
    [super dealloc];
}


@end
