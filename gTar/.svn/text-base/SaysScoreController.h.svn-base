//
//  SaysScoreController.h
//  gTar
//
//  Created by wuda on 12/14/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreController.h"

@interface SaysScoreController : ScoreController
{

	UIViewController * m_replayController;
	
	NSInteger m_maxSequence;
	NSString * m_status;
	
	IBOutlet UILabel * m_notesLabel;
	IBOutlet UILabel * m_statusLabel;

}

@property (nonatomic, retain) UIViewController * m_replayController;
@property (nonatomic, assign) NSInteger m_maxSequence;
@property (nonatomic, retain) NSString * m_status;
@property (nonatomic, retain) IBOutlet UILabel * m_notesLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;

-(IBAction)replayButtonClicked;
-(void)updateScores;

@end
