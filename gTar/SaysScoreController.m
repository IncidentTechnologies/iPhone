//
//  SaysScoreController.m
//  gTar
//
//  Created by wuda on 12/14/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "SaysScoreController.h"


@implementation SaysScoreController

@synthesize m_replayController, m_maxSequence, m_status, m_notesLabel, m_statusLabel;

-(void)viewDidLoad
{
    [super viewDidLoad];
	
	[m_statusLabel setText:m_status];
	[m_notesLabel setText:[NSString stringWithFormat:@"%d notes hit!", m_maxSequence]];

}

-(IBAction)replayButtonClicked
{
	[self.navigationController popToViewController:m_replayController animated:YES];
}

-(void)updateScores
{
	[m_statusLabel setText:m_status];
	[m_notesLabel setText:[NSString stringWithFormat:@"%d notes hit!", m_maxSequence]];
}

@end
