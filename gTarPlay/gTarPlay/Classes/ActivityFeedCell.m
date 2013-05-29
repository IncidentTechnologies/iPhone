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

@interface ActivityFeedCell ()
{
    NSInteger _pictureRequestsInFlight;
    BOOL _cancelPictureRequest;
}
@end

@implementation ActivityFeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        // Initialization code
        _pictureRequestsInFlight = 0;
        _cancelPictureRequest = NO;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)likeButtonClicked:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [button setSelected:!button.isSelected];
}

- (void)updateCell
{
    UIImage *pic = [g_fileController getFileOrReturnNil:_userSongSession.m_userProfile.m_imgFileId];
    
    if ( pic != nil && [pic isKindOfClass:[UIImage class]])
    {
        // We cancel a picture request if there is already one pending.
        // The most request 'updateCell' has the most updated info.
        _cancelPictureRequest = YES;
        [_picture setImage:pic];
    }
    else
    {
        // Count how many image requests are in flight.
        // We only want the last one to be applied when they all come back.
        _cancelPictureRequest = NO;
        _pictureRequestsInFlight++;
        
        // Nil it out for now.
        [_picture setImage:nil];
        
        [g_fileController getFileOrDownloadAsync:_userSongSession.m_userProfile.m_imgFileId callbackObject:self callbackSelector:@selector(profilePicDownloadComplete:)];
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

- (void)dealloc
{
    [_userSongSession release];
    [_activityView release];
    [_likeButton release];
    [super dealloc];
}

- (void)profilePicDownloadComplete:(UIImage *)pic
{
    _pictureRequestsInFlight--;
    
    // Display picture only if:
    // -Its not null
    // -It hasn't been canceled
    // -It is the last of a series of requests.
    if ( pic != nil && [pic isKindOfClass:[UIImage class]] &&  _cancelPictureRequest == NO && _pictureRequestsInFlight == 0 )
    {
        [_picture performSelectorOnMainThread:@selector(setImage:) withObject:pic waitUntilDone:NO];
    }
}

@end
