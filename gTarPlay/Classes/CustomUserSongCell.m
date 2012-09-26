//
//  CustomUserSongCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "CustomUserSongCell.h"

#import "UserSong.h"
#import "StarRatingView.h"

#import "FileController.h"

extern FileController * g_fileController;

@implementation CustomUserSongCell

@synthesize m_albumArtView;
@synthesize m_songAuthor;
@synthesize m_songTitle;
@synthesize m_songGenre;
@synthesize m_starRatingView;
@synthesize m_userSong;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        // Initialization code
        m_initialized = NO;
        
        [m_starRatingView setHidden:YES];
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
    [m_albumArtView release];
    [m_songAuthor release];
    [m_songTitle release];
    [m_songGenre release];
    [m_starRatingView release];
    [m_userSong release];

    [super dealloc];
}

#pragma mark - Custom cell methods

- (void)updateCell
{
    
    if ( m_userSong != nil )
    {
        [m_songTitle setText:m_userSong.m_title];
        [m_songAuthor setText:m_userSong.m_author];
        [m_songGenre setText:m_userSong.m_genre];
        
        CGFloat rating = [m_userSong.m_rating floatValue];
        
        //        UIColor * fill = [UIColor colorWithRed:0.2 green:0.5 blue:0.7 alpha:1.0];
        //        UIColor * fill = [UIColor colorWithRed:4.0/256.0 green:66.0/256.0 blue:115.0/256.0 alpha:1.0];
        
        UIColor * fill = [UIColor colorWithRed:7.0/256.0 green:124.0/256.0 blue:216.0/256.0 alpha:1.0];
        
        [m_starRatingView setStrokeColor:[[UIColor blackColor] CGColor] andFillColor:[fill CGColor]];
        [m_starRatingView updateStarRating:rating];
        
        //        m_starRatingView.bounds.size = CGSizeMake( m_starRatingView.frame.size.width / 2,
        //                                                   m_starRatingView.frame.size.height );
        //        m_starRatingView.clipsToBounds = YES;
        
        UIImage * image = [g_fileController getFileOrDownloadSync:m_userSong.m_imgFileId];
        
        if ( image != nil )
        {
            [m_albumArtView setImage:image];
        }
        
    }
    
    [super updateCell];
    
}

@end
