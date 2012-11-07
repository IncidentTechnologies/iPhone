//
//  SelectUserSongCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomUserSongCell.h"

@class SelectListViewController;

@interface SelectUserSongCell : CustomUserSongCell
{
    
    IBOutlet UILabel * m_scoreLabel;
    IBOutlet UILabel * m_difficultyLabel;
    IBOutlet UIButton * m_infoButton;
    
    SelectListViewController * m_parent;
    
}

@property (nonatomic, retain) IBOutlet UILabel * m_scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_difficultyLabel;
@property (nonatomic, retain) IBOutlet UIButton * m_infoButton;
@property (nonatomic, assign) SelectListViewController * m_parent;

//- (IBAction)infoButtonClicked:(id)sender;

@end
