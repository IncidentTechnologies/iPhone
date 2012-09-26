//
//  AccountViewCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 11/2/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "AccountViewCell.h"

#import "UserSongSession.h"
#import "UserSong.h"
#import "UserProfile.h"
#import "TimeFormatter.h"

#import "CloudController.h"
#import "FileController.h"

extern CloudController * g_cloudController;
extern FileController * g_fileController;

@implementation AccountViewCell

@synthesize m_userSongSession;
@synthesize m_albumArt;
@synthesize m_userName;
@synthesize m_songTitle;
@synthesize m_playLabel;
@synthesize m_jamLabel;
@synthesize m_timeLabel;

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

- (void)dealloc
{
    
    [m_userSongSession release];
    [m_albumArt release];
    [m_userName release];
    [m_songTitle release];
    [m_playLabel release];
    [m_jamLabel release];
    [m_timeLabel release];

    [super dealloc];
    
}

- (void)updateCell
{
    
    UIImage * image = [g_fileController getFileOrDownloadSync:m_userSongSession.m_userSong.m_imgFileId];
    
    if ( image != nil && [image isKindOfClass:[UIImage class]] )
    {
        [self.m_albumArt setImage:image];
    }
    
    // some of our user data is incomplete now, so this wouldn't happen in production
    if ( m_userSongSession.m_userProfile.m_firstName == nil ||
        [m_userSongSession.m_userProfile.m_firstName isEqualToString:@""] == YES )
    {
        [self.m_userName setText:@"Someone"];
    }
    else
    {
        [self.m_userName setText:m_userSongSession.m_userProfile.m_firstName];
    }
    
    if ( m_userSongSession.m_userSong == nil || m_userSongSession.m_userSong.m_songId == 0 )
    {
        
        [self.m_songTitle setHidden:YES];
        
        [self.m_jamLabel setHidden:NO];
        [self.m_playLabel setHidden:YES];
        
    }
    else
    {
        
        [self.m_songTitle setHidden:NO];
        [self.m_songTitle setText:m_userSongSession.m_userSong.m_title];
        
        [self.m_jamLabel setHidden:YES];
        [self.m_playLabel setHidden:NO];
        
    }
    
    NSString * time = [TimeFormatter stringFromNow:m_userSongSession.m_created];
    
    [m_timeLabel setText:time];
    
}

@end