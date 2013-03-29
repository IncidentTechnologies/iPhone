//
//  SelectSongOptionsPopupViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 11/8/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <gTarAppCore/PopupViewController.h>

@class CustomSegmentedControl;
@class SelectNavigationViewController;
@class UserSong;

@interface SelectSongOptionsPopupViewController : PopupViewController
{
 
    id m_navigationController;
    UserSong * m_userSong;
    
    IBOutlet UIView * m_muffleView;
    IBOutlet UIView * m_tempoView;
    
    IBOutlet CustomSegmentedControl * m_difficultyControl;
    IBOutlet CustomSegmentedControl * m_muffleControl;
    IBOutlet UISlider * m_tempoSlider;
    IBOutlet UILabel * m_tempoSliderValue;
    
    IBOutlet UILabel * m_titleLabel;
    IBOutlet UILabel * m_artistLabel;
    IBOutlet UILabel * m_difficultyDescriptionLabel;
    IBOutlet UIButton * m_previewButton;
}

@property (nonatomic, retain) id m_navigationController;
@property (nonatomic, retain) UserSong * m_userSong;
@property (nonatomic, retain) IBOutlet UIView * m_muffleView;
@property (nonatomic, retain) IBOutlet UIView * m_tempoView;

@property (nonatomic, retain) IBOutlet CustomSegmentedControl * m_difficultyControl;
@property (nonatomic, retain) IBOutlet CustomSegmentedControl * m_muffleControl;
@property (nonatomic, retain) IBOutlet UISlider * m_tempoSlider;
@property (nonatomic, retain) IBOutlet UILabel * m_tempoSliderValue;

@property (nonatomic, retain) IBOutlet UILabel * m_titleLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_artistLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_difficultyDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIButton * m_previewButton;

- (IBAction)difficultyValueChanged:(id)sender;
- (IBAction)muffleValueChanged:(id)sender;
- (IBAction)tempoValueChanged:(id)sender;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)previewButtonClicked:(id)sender;

- (void)toggleDifficultyParamters;

@end
