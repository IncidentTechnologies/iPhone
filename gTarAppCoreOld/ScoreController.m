//
//  ScoreController.m
//  gTar
//
//  Created by wuda on 10/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "ScoreController.h"


@implementation ScoreController

@synthesize m_returnToController;
@synthesize m_songName;
@synthesize m_notesHit, m_notesMax, m_score, m_scoreMax, m_combo;
@synthesize m_nibName;

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

/*
// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Teardown

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void)dealloc {
    [super dealloc];
}

- (IBAction)backButtonClicked
{
	
	[self.navigationController popToViewController:m_returnToController animated:YES];
	
}


@end
