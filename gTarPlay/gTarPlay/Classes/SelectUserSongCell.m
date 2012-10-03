//
//  SelectUserSongCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SelectUserSongCell.h"

#import "SelectListViewController.h"

#import <gTarAppCore/StarRatingView.h>

#import <gTarAppCore/UserSong.h>

@implementation SelectUserSongCell

@synthesize m_scoreLabel;
@synthesize m_difficultyLabel;
@synthesize m_infoButton;
@synthesize m_parent;

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
    [m_scoreLabel release];
    [m_difficultyLabel release];
    [m_infoButton release];
    
    [super dealloc];
}

#pragma mark - Cell specific stuff

+ (CGFloat)cellHeight
{
    // default
    return 40.0f;
}

- (void)updateCell
{
    
    [super updateCell];
    
    NSNumberFormatter * numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString * numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:m_userSong.m_playScore]];
    
    [m_scoreLabel setText:numberAsString];
//    [m_scoreLabel setText:[NSString stringWithFormat:@"%u", m_userSong.m_playScore]];
    
    [m_starRatingView updateStarRating:m_userSong.m_playStars];
    
    switch ( m_userSong.m_difficulty )
    {
        default:
        case 0:
        case 1:
        {
            [m_difficultyLabel setText:@"Beginner"];
        } break;
            
        case 2:
        {
            [m_difficultyLabel setText:@"Intermediate"];
        } break;

        case 3:
        {
            [m_difficultyLabel setText:@"Expert"];
        } break;
    }

}

#pragma mark - Button clicked handlers

- (IBAction)infoButtonClicked:(id)sender
{
    
    [m_parent showSongDetails:m_userSong];
    
}

@end
