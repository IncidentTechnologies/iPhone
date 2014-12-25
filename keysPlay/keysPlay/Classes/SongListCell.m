//
//  SongListCell.m
//  keysPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import "SongListCell.h"
#import <gTarAppCore/UserController.h>
#import "UserSong.h"

extern UserController * g_userController;

@implementation SongListCell

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
    [self setUserInteractionEnabled:YES];
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    double screenWidth = [frameGenerator getFullscreenWidth];
    
    // Add Borders
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, -1.0f, screenWidth + 1.0f, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:(170.0f/255.0f) alpha:1.0f].CGColor;
    [self.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 60.0f, screenWidth + 1.0f, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:(170.0f/255.0f) alpha:1.0f].CGColor;
    [self.layer addSublayer:bottomBorder];
    
    [_activityView stopAnimating];
    
    _songTitle.alpha = 1.0f;
    _songArtist.alpha = 1.0f;
    _songSkill.alpha = 1.0f;
    _songScore.alpha = 1.0f;
    
    [_songScore setHidden:NO];
    [_songStar setHidden:NO];
    
    if ( _userSong.m_title != nil )
    {
        [_songTitle setText:_userSong.m_title];
    }
    else
    {
        [_songTitle setText:@"Unknown"];
    }
    
    if(g_userController.m_loggedInUserId == _userSong.m_authorId){
        
        // For now override the username for the logged in user
        
        [_songArtist setText:g_userController.m_loggedInUsername];
        _userSong.m_author = g_userController.m_loggedInUsername;
        
    }else if ( _userSong.m_author != nil )
    {
        [_songArtist setText:_userSong.m_author];
    }
    else
    {
        [_songArtist setText:@"Unknown"];
    }
    
    if ( _userSong.m_difficulty == 0)
    {
        _songSkill.image = [UIImage imageNamed:@"Skill_GREEN.png"];
    }
    else if ( _userSong.m_difficulty == 1)
    {
        _songSkill.image = [UIImage imageNamed:@"Skill_YELLOW.png"];
    }
    else
    {
        _songSkill.image = [UIImage imageNamed:@"Skill_RED.png"];
    }

    [_songScore setText:[NSString stringWithFormat:@"%li", _playStars]];
    
    if(_playStars == 0){
        [_songScore setAlpha:0.3];
        [_songStar setAlpha:0.3];
    }else{
        [_songScore setAlpha:1.0];
        [_songStar setAlpha:1.0];
    }
    
    self.selectedBackgroundView = _selectedBgView;
    
}

- (void)updateCellInactive
{
    [self updateCell];
    
    [self setUserInteractionEnabled:NO];
    
    [_activityView startAnimating];
    
    CGFloat gray = 0.3f;
    
    _songTitle.alpha = gray;
    _songArtist.alpha = gray;
//    _songSkill.alpha = gray;
    _songScore.alpha = gray;
    
    [_songScore setHidden:YES];
    [_songStar setHidden:YES];
    
    _songSkill.image = [UIImage imageNamed:@"Skill_GREY.png"];

}

@end
