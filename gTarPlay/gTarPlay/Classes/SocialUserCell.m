//
//  SocialUserCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/29/13.
//
//

#import "SocialUserCell.h"

#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/FileController.h>

extern FileController *g_fileController;

@implementation SocialUserCell

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
    [_profilePic release];
    [_userName release];
    [_followButton release];
    [super dealloc];
}

- (void)updateCell
{
    UIImage * image = [g_fileController getFileOrDownloadSync:_userProfile.m_imgFileId];
    
    if ( image != nil )
    {
        [_profilePic setImage:image];
    }

    [_userName setText:_userProfile.m_name];
}

- (IBAction)followButtonClicked:(id)sender
{
    
}

@end
