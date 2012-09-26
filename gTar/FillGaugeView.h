//
//  FillGaugeView.h
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_LEVEL 4
@interface FillGaugeView : UIView
{
	IBOutlet UIImageView * m_level1;
	IBOutlet UIImageView * m_level2;
	IBOutlet UIImageView * m_level3;
	IBOutlet UIImageView * m_level4;
	IBOutlet UIImageView * m_level5;
	
	NSInteger m_currentLevel;
}

@property (nonatomic, retain) IBOutlet UIImageView * m_level1;
@property (nonatomic, retain) IBOutlet UIImageView * m_level2;
@property (nonatomic, retain) IBOutlet UIImageView * m_level3;
@property (nonatomic, retain) IBOutlet UIImageView * m_level4;
@property (nonatomic, retain) IBOutlet UIImageView * m_level5;

- (void)resetLevel;
- (void)increaseLevel;
- (void)setLevelToMax;
- (void)setLevelWithRollover:(NSInteger)value;
- (void)displayLevel;

@end
