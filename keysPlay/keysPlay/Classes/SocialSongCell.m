//
//  SocialSongCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 5/7/13.
//
//

#import "SocialSongCell.h"

#import "UserSongSession.h"
#import "UserSong.h"
#import "UserProfile.h"
#import "TimeFormatter.h"

@implementation SocialSongCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self )
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)updateCell
{
    NSString * time = [TimeFormatter stringFromNow:_userSongSession.m_created];
    
    if([_userSongSession.m_userSong.m_title length] == 0 || _userSongSession.m_userSong.m_title == nil){
        [_titleLabel setText:@"Jam session"];
    }else{
        [_titleLabel setText:_userSongSession.m_userSong.m_title];
    }
    
    if([_userSongSession.m_userSong.m_author length] == 0 || _userSongSession.m_userSong.m_author == nil){
        [_artistLabel setText:_userSongSession.m_userProfile.m_firstName];
    }else{
        [_artistLabel setText:_userSongSession.m_userSong.m_author];
    }
    
    [_timeLabel setText:time];
}

@end
