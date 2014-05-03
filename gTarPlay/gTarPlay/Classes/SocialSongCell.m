//
//  SocialSongCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 5/7/13.
//
//

#import "SocialSongCell.h"

#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/TimeFormatter.h>

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
    
    [_titleLabel setText:_userSongSession.m_userSong.m_title];
    [_artistLabel setText:_userSongSession.m_userSong.m_author];
    [_timeLabel setText:time];
}

@end
