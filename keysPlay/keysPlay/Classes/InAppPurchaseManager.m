
//
//  InAppPurchaseManager.m
//  keysPlay
//
//  Created by Franco on 8/28/13.
//
//

//#import <StoreKit/StoreKit.h>

#import "InAppPurchaseManager.h"

#import "CloudController.h"
#import "CloudResponse.h"
#import "CloudRequest.h"
#import "UserSong.h"

#define kInAppPurchaseSongProductId @"gtarsong"


@interface InAppPurchaseManager () {

}
@end

@implementation InAppPurchaseManager
{
    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet *_productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    NSArray* m_productList;
    
    NSMutableArray *m_pendingSongPurchases;     // For itunes purchases
    NSMutableArray *m_purchasedSongs;           // itunes purchase processed, hasn't reflected server side yet
}

+ (InAppPurchaseManager *)sharedInstance
{
    static InAppPurchaseManager *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[InAppPurchaseManager alloc] init];
        }
        
        return sharedSingleton;
    }
}

#pragma -
#pragma Test Functions

- (void)getProductList
{
    _productIdentifiers = [NSSet setWithObjects:kInAppPurchaseSongProductId, nil];

    // Check previously purchased product ids (from NSUserDefaults)
    _purchasedProductIdentifiers = [NSMutableSet set];
    
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
    // Get the product description (defined in early sections)
    [self getProductList];
    
    // Restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // Check for incomplete transactions
    NSArray *transactions = [[SKPaymentQueue defaultQueue] transactions];
    for(SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"left over transaction %@ with state: %d", transaction.transactionIdentifier, transaction.transactionState);
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    
    // TODO: Load from disk in case there are any pending purchases
    // that were not completed
    m_pendingSongPurchases = [[NSMutableArray alloc] init];
    m_purchasedSongs = [[NSMutableArray alloc] init];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Got product list from itunes");
    _productsRequest = NULL;                    // clear outstanding request
    
    m_productList = [response.products copy];
    for(SKProduct *skProduct in m_productList)
        NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    
    _completionHandler(YES, m_productList);
    _completionHandler = NULL;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products from itunes: %@", [error description]);
    _productsRequest = nil;
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

// call this before making a purchase
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

// kick off the upgrade transaction
- (void)purchaseSong
{
    if ([m_productList count] == 0)
    {
        NSLog(@"Cannot make InApp purchase, no products available");
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:m_productList[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)purchaseSongWithSong:(UserSong*)song target:(id)obj cbSel:(SEL)sel
{
    if ([m_productList count] == 0) {
        NSLog(@"Cannot make In-App purchase, no products available");
        CloudResponse *cloudResponse = [[CloudResponse alloc] init];
        cloudResponse.m_status = CloudResponseStatusItunesServerError;
        [obj performSelector:sel withObject:cloudResponse];
        return;
    }
    
    SongPurchaseRequest *pSongRequest = [[SongPurchaseRequest alloc] initWithSong:song andTarget:obj andSelector:sel];
    NSLog(@"Created song request with song id: %d", [[pSongRequest m_pSong] m_songId]);
    
    // If song is free
    if([song.m_cost floatValue] == 0) {
        return [self purchaseFreeSongOnServer:pSongRequest];
    }
    
    for(SKProduct *skProduct in m_productList)
    {
        if([skProduct.productIdentifier isEqualToString:kInAppPurchaseSongProductId])
        {
            [m_pendingSongPurchases addObject:pSongRequest];
            SKPayment *skPayment = [SKPayment paymentWithProduct:skProduct];
            
            @try {
                [[SKPaymentQueue defaultQueue] addPayment:skPayment];
            }
            @catch(NSException* ex) {
                NSLog(@"Payment bug captured %@ %@", ex.name, ex.reason);
            }
            
            return;
        }
    }
    
    // Didn't find gtarsong in product list
    NSLog(@"Couldn't find %@ in products list", kInAppPurchaseSongProductId);
    [obj performSelector:sel withObject:NULL];
    return;
}

#pragma -
#pragma Purchase helpers

// Saves a record of the transaction by storing the receipt to disk
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseSongProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// Verify transaction
// Will send receipt up the server, server will credit the user account
// Otherwise purchase song will fail with insufficient credits
-(void) verifyTransaction:(SKPaymentTransaction *)transaction
{
    NSData *pReceipt = transaction.transactionReceipt;
    CloudController *pCloudController = [CloudController sharedSingleton];
    [pCloudController requestVerifyReceipt:pReceipt andCallbackObj:self andCallbackSel:@selector(requestVerifyReceiptCallback:)];
    
    // It's ok to finish the transaction here
    // If server can't verify the transaciton we still shouldn't hold on to it
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)requestVerifyReceiptCallback:(CloudResponse*)cloudResponse
{
    if ( cloudResponse.m_loggedIn == NO )
        NSLog(@"Warn: User not logged in");
    
    if (cloudResponse.m_status == CloudResponseStatusSuccess ) {
        NSLog(@"IAP Verify receipt succeeded");
        
        // Purchase a song
        [self purchasePendingSongOnServer];
    }
    else
    {
        NSLog(@"Verify failed: %@", cloudResponse.m_statusText);
        
        // Song purchase failed, remove pending purchase and let the cell know
        SongPurchaseRequest *pSongPurchaseRequest = [m_pendingSongPurchases objectAtIndex:([m_pendingSongPurchases count] - 1)];
        [pSongPurchaseRequest.m_obj performSelector:pSongPurchaseRequest.m_sel withObject:cloudResponse];
        [m_pendingSongPurchases removeLastObject];
    }
    
}

// Removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // Send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

// Called when the transaction was successful or restored
// Song purchase is in the pendingSongPurchase queue 
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    // Save transaction to disk
    [self recordTransaction:transaction];
    
    // Shoot transaction up to server, this secures the credits
    // On success this will send a pending song purchase up to the server as well
    if([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseSongProductId])
        [self verifyTransaction:transaction];
    else {
        NSLog(@"Warning: transaction for unsupported product %@", transaction.payment.productIdentifier);
    }
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    // TODO: If a user hits multiple songs to purchase at once, this might not do it in the right order
    SongPurchaseRequest *pSongPurchaseRequest = [m_pendingSongPurchases objectAtIndex:([m_pendingSongPurchases count] - 1)];
    [pSongPurchaseRequest.m_obj performSelector:pSongPurchaseRequest.m_sel withObject:NULL];
    [m_pendingSongPurchases  removeObject:pSongPurchaseRequest];
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // error!
        NSLog(@"Error: Transaction failed with error code desc: %@ reason: %@", [transaction.error localizedDescription], [transaction.error localizedFailureReason]);
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else {
        // This is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
            {
                [self completeTransaction:transaction];
            } break;
                
            case SKPaymentTransactionStateFailed: {
                [self failedTransaction:transaction];
            } break;
                
            default: break;
        }
    }
}

// Will attempt to purchase a pending song on the server
// if it fails, it will save the song in the purchasedSongs queue
-(void)purchasePendingSongOnServer
{
    if(m_purchasedSongs == NULL) {
        NSLog(@"Error: Purchased Songs is null");
        return;
    }
    
    if(m_pendingSongPurchases == NULL) {
        NSLog(@"Error: pending song purchases is NULL");
        return;
    }
    
    if([m_pendingSongPurchases count] == 0) {
        NSLog(@"Error: No pending song purchases");
        return;
    }
    
    SongPurchaseRequest *pSongPurchaseRequest = [m_pendingSongPurchases objectAtIndex:([m_pendingSongPurchases count] - 1)];
    UserSong *pSong = [pSongPurchaseRequest m_pSong];
    
    [m_purchasedSongs addObject:pSongPurchaseRequest];
    [m_pendingSongPurchases removeLastObject];
    [[CloudController sharedSingleton] requestPurchaseSong:pSong andCallbackObj:self andCallbackSel:@selector(requestPurchaseSongCallback:)];
}

- (void)purchaseFreeSongOnServer:(SongPurchaseRequest*)songRequest
{
    [m_purchasedSongs addObject:songRequest];
    UserSong *pSong = [songRequest m_pSong];
    [[CloudController sharedSingleton] requestPurchaseSong:pSong andCallbackObj:self andCallbackSel:@selector(requestPurchaseSongCallback:)];
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
        
        for(SongPurchaseRequest *pSongPurchaseRequest in m_purchasedSongs) {
            if(pSongPurchaseRequest.m_pSong == cloudResponse.m_cloudRequest.m_userSong) {
                
                [pSongPurchaseRequest.m_obj performSelector:pSongPurchaseRequest.m_sel withObject:cloudResponse];
                [m_purchasedSongs removeObject:pSongPurchaseRequest];
                return;
            }
        }
    }
    else
    {
        NSLog(@"Purchase failed: %@", cloudResponse.m_statusText);
        
        for(SongPurchaseRequest *pSongPurchaseRequest in m_purchasedSongs) {
            if(pSongPurchaseRequest.m_pSong == cloudResponse.m_cloudRequest.m_userSong) {
                
                [pSongPurchaseRequest.m_obj performSelector:pSongPurchaseRequest.m_sel withObject:cloudResponse];
                return;
            }
        }
    }
    
}

@end
