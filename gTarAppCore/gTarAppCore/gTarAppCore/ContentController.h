//
//  ContentController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 2/23/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class CloudController;
@class CloudResponse;
@class UserSong;

@interface ContentController : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    
    NSString * m_contentFilePath;
    
    CloudController * m_cloudController;
    
    NSArray * m_allProductIds;
    NSArray * m_allUserSongs;
    
    NSMutableArray * m_ownedProductIds;
    NSMutableArray * m_ownedUserSongs;
    
    NSMutableDictionary * m_allProductIdsToProducts;
    NSMutableDictionary * m_allProductIdsToUserSongs;
    
}

@property (nonatomic, readonly) NSArray * m_ownedUserSongs;
@property (nonatomic, readonly) NSArray * m_allUserSongs;

- (id)initWithCloudController:(CloudController*)cloudController;

- (BOOL)isSongOwned:(UserSong*)userSong;

- (void)updateAllProducts;
- (void)updateOwnedProductIds;
- (void)createOwnedUserSongsList;
- (void)mapPidsToAllUserSongs;
- (void)saveOwnedProductIds;
- (void)loadOwnedProductIds;
- (void)saveAllUserSongs;
- (void)loadAllUserSongs;
- (void)updateAllUserSongs;
//- (void)updateUserSongsCallback:(CloudResponse*)cloudResponse;
- (void)updateAllProductIdentifiers;
- (void)updateProductIdentifiersCallback:(CloudResponse*)cloudResponse;
- (void)buyProductId:(NSString*)productId;


@end
