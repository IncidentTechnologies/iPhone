//
//  ActivityFeedCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/13/13.
//
//

#import "ActivityFeedCell.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongSession.h>

extern CloudController * g_cloudController;
extern FileController * g_fileController;
extern UserController * g_userController;

@implementation ActivityFeedCell

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
    UIImage * image = [g_fileController getFileOrDownloadSync:_userSongSession.m_userSong.m_imgFileId];
    
    if ( image != nil && [image isKindOfClass:[UIImage class]] )
    {
        [_picture setImage:image];
    }
    
    // some of our user data is incomplete now, so this wouldn't happen in production
    if ( _userSongSession.m_userProfile.m_firstName == nil ||
        [_userSongSession.m_userProfile.m_firstName isEqualToString:@""] == YES )
    {
        [_name setText:@"Someone"];
    }
    else
    {
        [_name setText:_userSongSession.m_userProfile.m_firstName];
    }
    
    if ( _userSongSession.m_userSong == nil || _userSongSession.m_userSong.m_songId == 0 )
    {
        [_activity setText:@"Jamed out"];
    }
    else
    {
        [_activity setText:[NSString stringWithFormat:@"Played %@", _userSongSession.m_userSong.m_title]];
    }

//    NSString * time = [TimeFormatter stringFromNow:m_userSongSession.m_created];
//    
//    [m_timeLabel setText:time];
}

- (void)dealloc {
    [_activityView release];
    [super dealloc];
}
@end
