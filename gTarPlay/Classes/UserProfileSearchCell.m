//
//  UserProfileSearchCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/26/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "UserProfileSearchCell.h"
#import "UserProfile.h"
#import "UserProfileSearchViewController.h"

@implementation UserProfileSearchCell

@synthesize m_view1;
@synthesize m_view2;
@synthesize m_statusLabel1;
@synthesize m_statusLabel2;
@synthesize m_nameButton1;
@synthesize m_nameButton2;
@synthesize m_portrait1;
@synthesize m_portrait2;
@synthesize m_userProfile1;
@synthesize m_userProfile2;
@synthesize m_addFriendButton1;
@synthesize m_addFriendButton2;
@synthesize m_parent;
@synthesize m_isSelf1;
@synthesize m_isSelf2;
@synthesize m_areFriends1;
@synthesize m_areFriends2;

#import "FileController.h"

#import <QuartzCore/QuartzCore.h>

extern FileController * g_fileController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
                
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
    
    [m_view1 release];
    [m_view2 release];
    [m_portrait1 release];
    [m_portrait2 release];
    [m_statusLabel1 release];
    [m_statusLabel2 release];
    [m_nameButton1 release];
    [m_nameButton2 release];
    [m_userProfile1 release];
    [m_userProfile2 release];
    [m_addFriendButton1 release];
    [m_addFriendButton2 release];
    
    [super dealloc];
    
}

+ (CGFloat)cellHeight
{
    return 50;
}

- (void)updateCell
{
    
    UIView * innerView;
    
    innerView = [m_view1.subviews objectAtIndex:0];
    innerView.layer.shadowRadius = 5.0;
    innerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    innerView.layer.shadowOffset = CGSizeMake(0, 0);
    innerView.layer.shadowOpacity = 0.9;
    
    innerView = [m_view2.subviews objectAtIndex:0];
    innerView.layer.shadowRadius = 5.0;
    innerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    innerView.layer.shadowOffset = CGSizeMake(0, 0);
    innerView.layer.shadowOpacity = 0.9;
    
    m_nameButton1.titleLabel.minimumFontSize = 5.0;
    m_nameButton2.titleLabel.minimumFontSize = 5.0;
    
    if ( m_userProfile1 != nil )
    {
        
        [m_view1 setHidden:NO];
        
        if ( m_isSelf1 == YES )
        {
            [m_addFriendButton1 setHidden:YES];
            [m_removeFriendButton1 setHidden:YES];
            
            [m_statusLabel1 setHidden:NO];
            [m_statusLabel1 setText:@"This is you"];
            
        }
        else if ( m_areFriends1 == YES )
        {
            [m_addFriendButton1 setHidden:YES];
            [m_removeFriendButton1 setHidden:NO];
            
            [m_statusLabel1 setHidden:YES];
        }
        else
        {
            [m_addFriendButton1 setHidden:NO];
            [m_removeFriendButton1 setHidden:YES];
            
            [m_statusLabel1 setHidden:YES];
        }
        
        UIImage * image = [g_fileController getFileOrDownloadSync:m_userProfile1.m_imgFileId];
        
        [m_nameButton1 setTitle:m_userProfile1.m_name forState:UIControlStateNormal];
        [m_portrait1 setImage:image];
        
    }
    else
    {
        [m_view1 setHidden:YES];
    }
    
    if ( m_userProfile2 != nil )
    {
        
        [m_view2 setHidden:NO];
        
        if ( m_isSelf2 == YES )
        {
            [m_addFriendButton2 setHidden:YES];
            [m_removeFriendButton2 setHidden:YES];
            
            [m_statusLabel2 setHidden:NO];
            [m_statusLabel2 setText:@"This is you"];
            
        }
        else if ( m_areFriends2 == YES )
        {
            [m_addFriendButton2 setHidden:YES];
            [m_removeFriendButton2 setHidden:NO];
            
            [m_statusLabel2 setHidden:YES];
        }
        else
        {
            [m_addFriendButton2 setHidden:NO];
            [m_removeFriendButton2 setHidden:YES];
            
            [m_statusLabel2 setHidden:YES];
        }
        
        UIImage * image = [g_fileController getFileOrDownloadSync:m_userProfile2.m_imgFileId];
        
        [m_nameButton2 setHidden:NO];
        [m_portrait2 setHidden:NO];
        [m_nameButton2 setTitle:m_userProfile2.m_name forState:UIControlStateNormal];
        [m_portrait2 setImage:image];
        
    }
    else
    {
        [m_view2 setHidden:YES];
    }
    
    [super updateCell];
    
}

- (IBAction)addFriend1Clicked:(id)sender
{
    [m_parent addFriend:m_userProfile1];
}

- (IBAction)addFriend2Clicked:(id)sender
{
    [m_parent addFriend:m_userProfile2];    
}

- (IBAction)removeFriend1Clicked:(id)sender
{
    [m_parent removeFriend:m_userProfile1];
}

- (IBAction)removeFriend2Clicked:(id)sender
{
    [m_parent removeFriend:m_userProfile2];    
}

- (IBAction)displayProfile1Clicked:(id)sender
{
    [m_parent displayUserProfile:m_userProfile1];
}

- (IBAction)displayProfile2Clicked:(id)sender
{
    [m_parent displayUserProfile:m_userProfile2];    
}

@end
