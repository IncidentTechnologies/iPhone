
//
//  InAppPurchaseManager.m
//  gTarPlay
//
//  Created by Franco on 8/28/13.
//
//

#import "InAppPurchaseManager.h"


#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/UserSong.h>

#define kInAppPurchaseSongProductId @"gtarsong"

@interface InAppPurchaseManager () {
    NSArray* _productList;
}
@end

@implementation InAppPurchaseManager {
    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet *_productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

+ (InAppPurchaseManager *)sharedInstance
{
    static InAppPurchaseManager *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
        {
            sharedSingleton = [[InAppPurchaseManager alloc] init];
        }
        
        return sharedSingleton;
    }
}

#pragma -
#pragma Test Functions
- (void)getProductList
{
    NSLog(@"Testing!");
    
    _productIdentifiers = [NSSet setWithObjects:kInAppPurchaseSongProductId, nil];

    // Check previously purchased product ids (from NSUserDefaults)
    _purchasedProductIdentifiers = [NSSet set];
    for(NSString *productIdentifier in _productIdentifiers)
    {
        BOOL fProductPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
        if(fProductPurchased)
        {
            [_purchasedProductIdentifiers addObject:productIdentifier];
            NSLog(@"Previously purchased %@", productIdentifier);
        }
        else
        {
            NSLog(@"Not purchased %@", productIdentifier);
        }
    }
    
    // Request list of products from iTunes
    _completionHandler = ^(BOOL success, NSArray *products) {
        // Will handle the completion of the fetch from itunes
        
        return;
    };
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma -
#pragma Public methods

// call this method once on startup
- (void)loadStore
{
    // Restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // Get the product description (defined in early sections)
    [self requestProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
    
}

//
// kick off the upgrade transaction
//
- (void)purchaseSong
{
    if ([_productList count] == 0)
    {
        NSLog(@"Cannot make InApp purchase, no products available");
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:_productList[0]];
    //SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseSongProductId];

    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) requestProductData
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                 [NSSet setWithObject: kInAppPurchaseSongProductId]];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Got product list from itunes");
    _productsRequest = NULL;                    // clear outstanding request
    
    NSArray *skProducts = response.products;
    for(SKProduct *skProduct in skProducts)
    {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = NULL;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products from itunes");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseSongProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}


//
// successful purchase
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseSongProductId])
    {
        // TODO: move this out of the InAppPurchase manager
        
        // Hardcode a temporary UserSong to purchase
        UserSong* userSong = [[UserSong alloc] init];
        userSong.m_songId = 140;
        
        [[CloudController sharedSingleton] requestPurchaseSong:userSong andCallbackObj:self andCallbackSel:@selector(requestPurchaseSongCallback:)];
    }
}

// TODO: move this out of the InAppPurchase manager
- (void)requestPurchaseSongCallback:(CloudResponse*)cloudResponse
{
    // Purchasing a song by itself isn't that big of a deal.
    // If it doesn't work, we don't have to be as aggressive about recovering
    // because they can just repurchase without loosing anything.
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        NSLog(@"Purchase succeeded");
    }
    else
    {
        NSLog(@"Purchase failed: %@", cloudResponse.m_statusText);
    }
    
}

@end
