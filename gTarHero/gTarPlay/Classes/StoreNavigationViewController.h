//
//  StoreNavigationViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <gTarAppCore/StoreController.h>

#import "CustomNavigationViewController.h"

@class StoreFeaturedViewController;
@class StoreFeaturedGenreViewController;
@class StoreListViewController;
@class StoreTopTenViewController;
@class StoreSongDetailViewController;
@class StoreSearchViewController;
@class StorePurchaseViewController;
@class StoreRedemptionViewController;
@class StoreBuyCreditsPopupViewController;

@class StoreFeatureCollection;
@class StoreGenreCollection;
@class UserSong;

@interface StoreNavigationViewController : CustomNavigationViewController <StoreControllerDelegate>
{

    StoreController * m_storeController;
    
    // Sub controllers
    StoreFeaturedViewController * m_featuredViewController;
    StoreFeaturedGenreViewController * m_featuredGenreViewController;
    StoreListViewController * m_listViewController;
    StoreTopTenViewController * m_topTenViewController;
    StoreSongDetailViewController * m_songDetailViewController;
    StoreSearchViewController * m_searchViewController;
    StoreRedemptionViewController * m_redemptionViewController;
    StoreBuyCreditsPopupViewController * m_creditsPopupViewController;
    
    UserSong * m_shortcutUserSong;
    
}

@property (nonatomic, retain) UserSong * m_shortcutUserSong;

// change view controllers
- (void)showUserSongDetail:(UserSong*)userSong;
- (void)showSubcategory:(StoreGenreCollection*)genreCollection;
- (void)showFullList:(StoreGenreCollection*)genreCollection;
- (void)showRedemptionView;
- (void)showBuyCreditsView;

// song stuff
- (void)buyCreditsA;
- (void)buyCreditsB;
- (void)buyCreditsC;
- (void)buySong:(UserSong*)userSong;
- (void)retryPurchase;
- (void)redeemCreditCode:(NSString*)creditCode;
//- (void)cancelPurchase;

@end
