//
//  StoreSettings.h
//  gTarAppCore
//
//  Created by Marty Greenia on 5/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "SettingsController.h"

@class SettingsController;
@class StoreTransaction;
@class UserSong;

@interface StoreSettingsController : SettingsController
{
    
    NSString * m_currentPurchaseProductId;
    UserSong * m_currentPurchaseUserSong;
    StoreTransaction * m_currentTransaction;
    
    UserSong * m_previousPurchaseUserSong;
    
    BOOL m_isDirty;
    
    BOOL m_songBuyInitiated;
    BOOL m_creditBuyInitiated;
    BOOL m_creditBuyCompleted;
    BOOL m_songBuyCompleted;

}

@property (nonatomic, readonly) NSString * m_currentPurchaseProductId;
@property (nonatomic, readonly) UserSong * m_currentPurchaseUserSong;
@property (nonatomic, readonly) StoreTransaction * m_currentTransaction;

@property (nonatomic, readonly) UserSong * m_previousPurchaseUserSong;

@property (nonatomic, readonly) BOOL m_isDirty;

- (BOOL)setCurrentPurchaseProductId:(NSString*)productId andUserSong:(UserSong*)userSong;
- (void)clearCurrentPurchase;
- (BOOL)setCurrentTransaction:(SKPaymentTransaction*)transaction;

- (void)restoreIncompletePurchase;

- (BOOL)initiateSongBuy;
- (BOOL)completeSongBuy;
- (BOOL)initiateCreditBuy;
- (BOOL)completeCreditBuy;

@end
