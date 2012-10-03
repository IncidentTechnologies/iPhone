//
//  AccountViewCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 11/2/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserSongSession;

@interface AccountViewCell : UITableViewCell
{
    
    UserSongSession * m_userSongSession;
    
    IBOutlet UIImageView * m_albumArt;
    IBOutlet UILabel * m_userName;
    IBOutlet UILabel * m_songTitle;
    IBOutlet UILabel * m_playLabel;
    IBOutlet UILabel * m_jamLabel;
    IBOutlet UILabel * m_timeLabel;
    
}

@property (nonatomic, retain) UserSongSession * m_userSongSession;

@property (nonatomic, retain) IBOutlet UIImageView * m_albumArt;
@property (nonatomic, retain) IBOutlet UILabel * m_userName;
@property (nonatomic, retain) IBOutlet UILabel * m_songTitle;
@property (nonatomic, retain) IBOutlet UILabel * m_playLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_jamLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_timeLabel;

- (void)updateCell;

@end
