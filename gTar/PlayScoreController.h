//
//  PlayScoreController.h
//  gTar
//
//  Created by wuda on 11/5/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreController.h"

@interface PlayScoreController : ScoreController
{
	UIViewController * m_replayController;

	IBOutlet UILabel * m_songNameLabel;
	IBOutlet UILabel * m_scoreLabel;
	IBOutlet UILabel * m_notesLabel;
	IBOutlet UILabel * m_comboLabel;
	
	IBOutlet UIImageView * m_gstar1;
	IBOutlet UIImageView * m_gstar2;
	IBOutlet UIImageView * m_gstar3;
	IBOutlet UIImageView * m_gstar4;
	IBOutlet UIImageView * m_gstar5;
	
}

@property (nonatomic, retain) UIViewController * m_replayController;
@property (nonatomic, retain) IBOutlet UILabel * m_songNameLabel, * m_scoreLabel, * m_notesLabel, * m_comboLabel;
@property (nonatomic, retain) IBOutlet UIImageView * m_gstar1, * m_gstar2, * m_gstar3, * m_gstar4, * m_gstar5;

-(IBAction)backButtonClicked;
-(IBAction)replayButtonClicked;
-(void)updateScores;

@end
