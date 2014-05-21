//
//  StoreSongListCell.m
//  gTarPlay
//
//  Created by Idan Beck on 8/31/13.
//
//

#import "StoreSongListCell.h"
#import "UserSong.h"
#import "InAppPurchaseManager.h"
#import "CloudResponse.h"

#import "SongSelectionViewController.h"

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
            
        case BUY_BUTTON_FREE:
        case BUY_BUTTON_CONFIRM: {
            m_buyButtonState = BUY_BUTTON_PROCESSING;
            [_buyButtonView updateBuyButtonState:m_buyButtonState];
            
            // Try to buy the song
            InAppPurchaseManager *iapManager = [InAppPurchaseManager sharedInstance];
            [iapManager purchaseSongWithSong:_userSong target:self cbSel:@selector(IAPSongPurchaseCallbackWithContext:)];
        } break;
            
        case BUY_BUTTON_PROCESSING: {
            // This should not actually register an action
        } break;
            
        case BUY_BUTTON_PURCHASED: {
            // Start play mode with appropriate song
            [_parentStoreViewController openSongListToSong:_userSong];
        } break;
            
        case BUY_BUTTON_INVALID:
        default: {
            // Err
        } break;
    }
}

-(void)resetButtonState
{
    if([_userSong.m_cost floatValue] == 0)
        m_buyButtonState = BUY_BUTTON_FREE;
    else
        m_buyButtonState = BUY_BUTTON_PRICE;
    
    [_buyButtonView updateBuyButtonState:m_buyButtonState];
}

-(void)IAPSongPurchaseCallbackWithContext:(id)pContext
{
    NSLog(@"IAPSongPurchaseCallbackWithContext");
    
    if(pContext == NULL)
    {
        NSLog(@"Song purchase failed");
        [self resetButtonState];
        return;
    }
    
    CloudResponse *cloudResponse = (CloudResponse*)(pContext);
    switch(cloudResponse.m_status)
    {
        case CloudResponseStatusItunesServerError: {
            NSLog(@"Song purchase failed");
            [self resetButtonState];
            
            // Show failure message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Song Purchase Failed", NULL)
                                                            message:NSLocalizedString(@"No products available, no payments have been processed", NULL)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        } break;
        
        case CloudResponseStatusFailure: {
            NSLog(@"Song purchase failed");
            
            [self resetButtonState];
            
            // Show failure message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Song Purchase Failed", NULL)
                                                            message:NSLocalizedString(@"Song Purchase Failed, your account has been credited and the song purchase will be attempted until success", NULL)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        } break;
            
        case CloudResponseStatusSuccess: {
            NSLog(@"Song purchase succeeded");
            m_buyButtonState = BUY_BUTTON_PURCHASED;
            [_buyButtonView updateBuyButtonState:m_buyButtonState];
            
            // Show failure message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Song Purchase Succeeded", NULL)
                                                            message:NSLocalizedString(@"Song Purchase Succeeded!", NULL)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        } break;
            
        default: {
            NSLog(@"Song purchase fail state: %d", cloudResponse.m_status);
            [self resetButtonState];
            
            // Show failure message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Song Purchase Failed", NULL)
                                                            message:NSLocalizedString(@"Song Purchase Failed, your account has been credited and the song purchase will be attempted until success", NULL)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        } break;
    }
}

- (void)updateCell
{
    [self setUserInteractionEnabled:YES];
    
    // Add Borders
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, -1.0f, [[UIScreen mainScreen] bounds].size.height + 1.0f, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:(212.0f/255.0f) alpha:1.0f].CGColor;
    [self.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 60.0f, [[UIScreen mainScreen] bounds].size.height + 1.0f, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:(212.0f/255.0f) alpha:1.0f].CGColor;
    [self.layer addSublayer:bottomBorder];
    
    CALayer *borderTitleArtist = [CALayer layer];
    borderTitleArtist.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - 132.0f, 0.0f, 1.0f, 60.0f);
    borderTitleArtist.backgroundColor = [UIColor colorWithWhite:(212.0f/255.0f) alpha:1.0f].CGColor;
    [self.layer addSublayer:borderTitleArtist];
    
    CALayer *borderSkill = [CALayer layer];
    borderSkill.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - 66.0f, 0.0f, 1.0f, 60.0f);
    borderSkill.backgroundColor = [UIColor colorWithWhite:(212.0f/255.0f) alpha:1.0f].CGColor;
    [self.layer addSublayer:borderSkill];
    
    
    // Don't let user buy the song if it's already owned or leased by them
    if(_userSong.m_userLeased || _userSong.m_userOwned)
        m_buyButtonState = BUY_BUTTON_PURCHASED;
    else if([_userSong.m_cost floatValue] == 0)
        m_buyButtonState = BUY_BUTTON_FREE;
    else
        m_buyButtonState = BUY_BUTTON_PRICE;
    
    [_buyButtonView updateBuyButtonState:m_buyButtonState];
    
    _labelSongArtist.alpha = 1.0f;
    _labelSongTitle.alpha = 1.0f;
    _songSkill.alpha = 1.0f;
    
    if(_userSong.m_title != NULL)
        [_labelSongTitle setText:_userSong.m_title];
    else
        [_labelSongTitle setText:@"Unknown"];
    
    if(_userSong.m_author != NULL)
        [_labelSongArtist setText:_userSong.m_author];
    else
        [_labelSongArtist setText:@"Unknown"];
    
    if ( _userSong.m_difficulty == 0)
        _songSkill.image = [UIImage imageNamed:@"Skill_GREEN.png"];
    else if ( _userSong.m_difficulty == 1)
        _songSkill.image = [UIImage imageNamed:@"Skill_YELLOW.png"];
    else
        _songSkill.image = [UIImage imageNamed:@"Skill_RED.png"];
}

@end
