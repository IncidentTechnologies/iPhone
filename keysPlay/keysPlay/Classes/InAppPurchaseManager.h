//
//  InAppPurchaseManager.h
//  keysPlay
//
//  Created by Franco on 8/28/13.
//
//


#import "AppCore.h"
#import <StoreKit/StoreKit.h>

#import "SongPurchaseRequest.h"

@class UserSong;

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
}

+ (InAppPurchaseManager *)sharedInstance;

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseSong;

-(void)purchaseSongWithSong:(UserSong*)song target:(id)obj cbSel:(SEL)sel;

// test
- (void)getProductList;

@end
