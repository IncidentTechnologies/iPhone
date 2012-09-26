//
//  SelectSongDetailViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/22/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"

@class UserSong;
@class StarRatingView;

@interface SelectSongDetailViewController : CustomViewController
{
    
    IBOutlet UIImageView * m_albumArtView;
    IBOutlet UILabel * m_songAuthor;
    IBOutlet UILabel * m_songTitle;
    IBOutlet UILabel * m_songGenre;
    IBOutlet UILabel * m_songScore;
    IBOutlet UITextView * m_songDesc;
    IBOutlet StarRatingView * m_starRatingView;
    IBOutlet UIButton * m_backButton;
    
    UserSong * m_userSong;
    
    NSString * m_songXmpBlob;

}

@property (nonatomic, retain) IBOutlet UIImageView * m_albumArtView;
@property (nonatomic, retain) IBOutlet UILabel * m_songAuthor;
@property (nonatomic, retain) IBOutlet UILabel * m_songTitle;
@property (nonatomic, retain) IBOutlet UILabel * m_songGenre;
@property (nonatomic, retain) IBOutlet UILabel * m_songScore;
@property (nonatomic, retain) IBOutlet UITextView * m_songDesc;
@property (nonatomic, retain) IBOutlet StarRatingView * m_starRatingView;
@property (nonatomic, retain) IBOutlet UIButton * m_backButton;

@property (nonatomic, retain) UserSong * m_userSong;
@property (nonatomic, retain) NSString * m_songXmpBlob;

- (IBAction)playButtonClicked:(id)sender;

@end
