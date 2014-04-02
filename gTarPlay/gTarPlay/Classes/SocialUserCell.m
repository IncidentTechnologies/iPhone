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

#import "UIButton+Gtar.h"

extern FileController *g_fileController;

@interface SocialUserCell()
{
    NSInteger _pictureRequestsInFlight;
    BOOL _cancelPictureRequest;
}
@end

@implementation SocialUserCell

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

- (void)dealloc {
    [_userProfile release];
    [_followInvocation release];
    [_profilePic release];
    [_userName release];
    [_followButton release];
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void) localizeViews {
    [_followButton setTitle:NSLocalizedString(@"FOLLOW", NULL) forState:UIControlStateNormal];
}

- (void)updateCell {
    UIImage *pic = [g_fileController getFileOrReturnNil:_userProfile.m_imgFileId];
    
    [self localizeViews];
    
    if ( pic )
    {
        // We cancel a picture request if there is already one pending.
        // The most request 'updateCell' has the most updated info.
        _cancelPictureRequest = YES;
        [_profilePic setImage:pic];
    }
    else
    {
        // Count how many image requests are in flight.
        // We only want the last one to be applied when they all come back.
        _cancelPictureRequest = NO;
        _pictureRequestsInFlight++;
        
        // Nil it out for now.
        [_profilePic setImage:nil];
        
        [g_fileController getFileOrDownloadAsync:_userProfile.m_imgFileId callbackObject:self callbackSelector:@selector(profilePicDownloadComplete:)];
    }

    [_userName setText:_userProfile.m_name];
    
    if ( _isUser == YES )
    {
        [_followButton setHidden:YES];
    }
    else if ( self.following == YES)
    {
        [_followButton setHidden:NO];
        UIImage *image = [UIImage imageNamed:@"SocialFollowingButton.png"];
        [_followButton setImage:image forState:UIControlStateNormal];
    }
    else
    {
        [_followButton setHidden:NO];
        UIImage *image = [UIImage imageNamed:@"SocialFollowButton.png"];
        [_followButton setImage:image forState:UIControlStateNormal];
    }
    
    [_followButton stopActivityIndicator];
    
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
        [_profilePic performSelectorOnMainThread:@selector(setImage:) withObject:pic waitUntilDone:NO];
    }
}

- (IBAction)followButtonClicked:(id)sender
{
    [_followButton startActivityIndicator];
    [_followInvocation invoke];
}


@end
