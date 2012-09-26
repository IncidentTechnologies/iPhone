//
//  gTarPlayDetailViewController.h
//  gTar
//
//  Created by wuda on 1/11/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSong.h"


@interface gTarPlayDetailViewController : UIViewController
{

	NSString * m_xmpBlob;
	NSString * m_difficulty;

	UserSong * m_userSong;
	
	BOOL m_popupVisible;
	
	IBOutlet UILabel * m_title;
	IBOutlet UILabel * m_author;
	IBOutlet UILabel * m_description;
	IBOutlet UIImageView * m_icon;
	IBOutlet UITextView * m_achievements;
	
	IBOutlet UIView * m_blackView;
	IBOutlet UIView * m_ampView;
	
}

@property (nonatomic, retain) NSString * m_xmpBlob;
@property (nonatomic, retain) UserSong * m_userSong;

@property (nonatomic, retain) UILabel * m_title;
@property (nonatomic, retain) UILabel * m_author;
@property (nonatomic, retain) UILabel * m_description;
@property (nonatomic, retain) UIImageView * m_icon;
@property (nonatomic, retain) UITextView * m_achievements;

@property (nonatomic, retain) UIView * m_blackView;
@property (nonatomic, retain) UIView * m_ampView;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

- (IBAction)easyButtonClicked:(id)sender;
- (IBAction)mediumButtonClicked:(id)sender;
- (IBAction)hardButtonClicked:(id)sender;
- (IBAction)realButtonClicked:(id)sender;


- (void)animateModal:(BOOL)popup;

@end
