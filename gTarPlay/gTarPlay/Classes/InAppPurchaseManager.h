//
//  InAppPurchaseManager.h
//  gTarPlay
//
//  Created by Franco on 8/28/13.
//
//

#import <StoreKit/StoreKit.h>

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

// test
- (void)getProductList;

@end
