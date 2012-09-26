//
//  UserProfileFriendCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/22/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "UserProfileFriendCell.h"
#import "UserProfile.h"
#import "UserProfileViewController.h"

@implementation UserProfileFriendCell

@synthesize m_profileImageView;
@synthesize m_nameLabel;
@synthesize m_addFriendButton;
@synthesize m_removeFriendButton;
@synthesize m_userProfile;
@synthesize m_parent;
@synthesize m_areFriends;
@synthesize m_isSelf;

#import "FileController.h"

extern FileController * g_fileController;

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
    
    [m_profileImageView release];
    [m_nameLabel release];
    [m_addFriendButton release];
    [m_removeFriendButton release];    
    [m_userProfile release];
    
    [super dealloc];
    
}

+ (CGFloat)cellHeight
{
    // default
    return 44;
}

- (void)updateCell
{
    
    UIImage * image = [g_fileController getFileOrDownloadSync:m_userProfile.m_imgFileId];
    
    [m_profileImageView setImage:image];
    
    [m_nameLabel setText:m_userProfile.m_name];
    
    if ( m_isSelf == YES )
    {
        [m_addFriendButton setHidden:YES];
        [m_removeFriendButton setHidden:YES];
    }
    else if ( m_areFriends == YES )
    {
        [m_addFriendButton setHidden:YES];
        [m_removeFriendButton setHidden:NO];        
    }
    else
    {
        [m_addFriendButton setHidden:NO];
        [m_removeFriendButton setHidden:YES];
    }
    
    [super updateCell];
    
}

- (IBAction)addUserButtonClicked:(id)sender
{
    [m_parent addUserFollows:m_userProfile];
}

- (IBAction)removeUserButtonClicked:(id)sender
{
    [m_parent removeUserFollows:m_userProfile];
}

@end
