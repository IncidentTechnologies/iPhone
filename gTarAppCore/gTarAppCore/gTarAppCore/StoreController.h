//
//  StoreController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 5/16/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class CloudController;
@class UserSong;
@class UserSongs;
@class UserProfile;
@class CloudResponse;
@class StoreSettingsController;
@class StoreFeatureCollection;

@protocol StoreControllerDelegate

// i don't use a lot of these anymore, need to remove the old stuff
- (void)creditCountUpdated:(NSNumber*)creditCount;
- (void)requestSongListComplete;
- (void)requestFeaturedSongListComplete;
//- (void)purchaseFailed:(NSString*)reason;
//- (void)purchaseSucceed;
//- (void)purchasePending:(NSString*)reason;
//- (void)purchaseCanceled;
- (void)userLoggedOut;

- (void)redemptionSucceeded;
- (void)redemptionFailed:(NSString*)reason;

- (void)creditPurchaseResumed:(UserSong*)userSong;
- (void)creditPurchaseFailed:(NSString*)reason;
- (void)creditPurchaseCanceled:(NSString*)reason;
- (void)creditPurchasePending:(NSString*)reason;
- (void)creditPurchaseSucceeded:(NSString*)reason;

- (void)songPurchaseResumed:(UserSong*)userSong;
- (void)songPurchaseFailed:(NSString*)reason;
- (void)songPurchaseCanceled:(NSString*)reason;
- (void)songPurchasePending:(NSString*)reason;
- (void)songPurchaseSucceeded:(NSString*)reason;


@end

//
// This was the original store controller that bought things via credits using consumable IAPs.
// The 'ContentController' is replacing this for the non-consumable types.

@interface StoreController : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    
    id<StoreControllerDelegate> __weak m_delegate;
    
    CloudController * m_cloudController;
    
//    StoreSettingsController * m_storeSettings;
    
    NSMutableArray * m_productIdentifiers;
    NSMutableDictionary * m_productInformation;
    
    UserSongs * m_featuredSongsList;
    
//    NSString * m_searchString;

    // Keyed off of the song id
    NSMutableDictionary * m_ownedSongs;
    NSMutableDictionary * m_allSongs;
    
    StoreFeatureCollection * __weak m_featureCollection;
    
    NSNumber * m_credits;
    
    // state
    BOOL m_initiatedCreditBuy;
    BOOL m_initiatedSongBuy;
    
    SKPaymentTransaction * m_currentTransaction;
    UserSong * m_currentUserSong;
    UserSong * m_failedUserSong;
    
}

//@property (nonatomic, readonly) NSString * m_searchString;
@property (nonatomic, weak) id<StoreControllerDelegate> m_delegate;
@property (nonatomic, readonly) NSDictionary * m_ownedSongs;
@property (nonatomic, readonly) NSDictionary * m_allSongs;
@property (weak, nonatomic, readonly) StoreFeatureCollection * m_featureCollection;
@property (nonatomic, readonly) NSNumber * m_credits;

//- (id)initWithCloudController:(CloudController*)cloudController;
//- (void)tearDownController;

- (BOOL)canMakePayments;
- (BOOL)ownUserSong:(UserSong*)userSong;

- (void)requestProductIdentifiers;
- (void)requestProductInformationAllProducts;
- (void)requestProductInformation:(NSSet*)productIds;

- (void)requestUserCredits;
- (void)requestSongList;
//- (void)requestSongListSearch:(NSString*)search;
- (void)requestOwnedSongList;
- (void)requestFeaturedSongList;

- (void)requestPurchaseSong:(UserSong*)userSong;
- (void)requestVerifyReceipt:(NSData*)receipt;
//- (void)requestVerifyReceipt:(NSData*)receipt andPurchaseSong:(UserSong*)userSong;

- (void)requestSongListCallback:(CloudResponse*)cloudResponse;
- (void)requestSongStoreListCallback:(CloudResponse*)cloudResponse;
- (void)requestFeaturedSongListCallback:(CloudResponse*)cloudResponse;
- (void)requestVerifyReceiptCallback:(CloudResponse*)cloudResponse;
- (void)requestPurchaseSongCallback:(CloudResponse*)cloudResponse;
//- (void)requestVerifyAndPurchaseCallback:(CloudResponse*)cloudResponse;
- (void)requestRedeemCreditCodeCallback:(CloudResponse*)cloudResponse;

- (void)buyCredits1;
- (void)buyCredits10;
- (void)buyCredits11;
- (void)buyCredits15;
- (void)buyCredits24;
- (void)buyCredits:(NSString*)productIdentifier;
- (void)buySong:(UserSong*)userSong;
- (BOOL)isPurchasePending;
- (UserSong*)userSongPurchasePending;
- (void)retryPurchase;
//- (void)cancelPurchase;

- (void)handleRestoreTransaction;
//- (void)verifyTransaction:(SKPaymentTransaction*)transaction;

- (void)verifyPurchasedTransactions;
- (void)verifyPurchasedTransaction:(SKPaymentTransaction*)transaction;

- (void)redeemCreditCode:(NSString*)creditCode;

@end
