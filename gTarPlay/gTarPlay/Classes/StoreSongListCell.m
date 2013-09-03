//
//  StoreSongListCell.m
//  gTarPlay
//
//  Created by Idan Beck on 8/31/13.
//
//

#import "StoreSongListCell.h"
#import <gTarAppCore/UserSong.h>
#import "InAppPurchaseManager.h"

@interface StoreSongListCell () {
    BUY_BUTTON_STATE m_buyButtonState;
}
@end


@implementation StoreSongListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        m_buyButtonState = BUY_BUTTON_PRICE;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onBuyButtonTouchUpInside:(id)sender {
    switch(m_buyButtonState)
    {
        case BUY_BUTTON_PRICE: {
            m_buyButtonState = BUY_BUTTON_CONFIRM;
            [_buyButtonView updateBuyButtonState:m_buyButtonState];
        } break;
            
        case BUY_BUTTON_CONFIRM: {
            m_buyButtonState = BUY_BUTTON_PROCESSING;
            [_buyButtonView updateBuyButtonState:m_buyButtonState];
            
            // Try to buy the song
            InAppPurchaseManager *iapManager = [InAppPurchaseManager sharedInstance];
            [iapManager purchaseSongWithSong:_userSong target:self cbSel:@selector(IAPSongPurchaseCallback)];
        } break;
            
        case BUY_BUTTON_PROCESSING: {
            // This should not actually register an action
        } break;
            
        case BUY_BUTTON_PURCHASED: {
            // This should send the user to play the song (bring up the modal dialog?)
        } break;
            
        case BUY_BUTTON_INVALID:
        default: {
            // Err
        } break;
    }
}

-(void)IAPSongPurchaseCallback
{
    NSLog(@"testing selector callback loop");
}

- (void)updateCell
{
    [self setUserInteractionEnabled:YES];
 
    _labelSongArtist.alpha = 1.0f;
    _labelSongTitle.alpha = 1.0f;
    _songSkill.alpha = 1.0f;
    
    if(_userSong.m_title != NULL)
        [_labelSongTitle setText:_userSong.m_title];
    else
        [_labelSongTitle setText:@"Unkown"];
    
    if(_userSong.m_author != NULL)
        [_labelSongArtist setText:_userSong.m_author];
    else
        [_labelSongArtist setText:@"Unkown"];
    
    if ( _userSong.m_difficulty == 0)
        _songSkill.image = [UIImage imageNamed:@"Skill_GREEN.png"];
    else if ( _userSong.m_difficulty == 1)
        _songSkill.image = [UIImage imageNamed:@"Skill_YELLOW.png"];
    else
        _songSkill.image = [UIImage imageNamed:@"Skill_RED.png"];
}

@end
