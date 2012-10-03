//
//  ScoreController.h
//  gTar
//
//  Created by wuda on 10/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScoreController : UIViewController
{
	UIViewController * m_returnToController;
	
	NSString * m_songName;
	
	NSUInteger m_notesHit;
	NSUInteger m_notesMax;
	
	NSUInteger m_score;
	NSUInteger m_scoreMax;
	
	NSUInteger m_combo;
	
	NSString * m_nibName;
	
}

@property (nonatomic, retain) UIViewController * m_returnToController;
@property (nonatomic, retain) NSString * m_songName;
@property (nonatomic) NSUInteger m_notesHit, m_notesMax, m_score, m_scoreMax, m_combo;
@property (nonatomic, retain) NSString * m_nibName;


-(IBAction)backButtonClicked;

@end
