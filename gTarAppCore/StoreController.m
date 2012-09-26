//
//  StoreController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 5/16/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "StoreController.h"

#import "CloudController.h"
#import "UserSong.h"
#import "UserSongs.h"
#import "CloudResponse.h"
#import "StoreSettingsController.h"
#import "StoreTransaction.h"
#import "UserProfile.h"
#import "StoreFeatureCollection.h"

@implementation StoreController

//@synthesize m_searchString;
@synthesize m_delegate;
@synthesize m_ownedSongs;
@synthesize m_allSongs;
@synthesize m_featureCollection;
@synthesize m_credits;

- (id)initWithCloudController:(CloudController*)cloudController andDelegate:(id<StoreControllerDelegate>)delegate
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_delegate = delegate;
        
        m_cloudController = [cloudController retain];

        // create the arrays
        m_productIdentifiers = [[NSMutableArray alloc] init];
        m_productInformation = [[NSMutableDictionary alloc] init];

        [m_productIdentifiers addObject:[NSString stringWithFormat:@"TestPurchaseIP1"]];
        [m_productIdentifiers addObject:[NSString stringWithFormat:@"IncidentSong1"]];
        [m_productIdentifiers addObject:[NSString stringWithFormat:@"IncidentPoints1"]];
        [m_productIdentifiers addObject:[NSString stringWithFormat:@"IncidentPoints10"]];
        [m_productIdentifiers addObject:[NSString stringWithFormat:@"IncidentPoints11"]];
        [m_productIdentifiers addObject:[NSString stringWithFormat:@"IncidentPoints15"]];
        [m_productIdentifiers addObject:[NSString stringWithFormat:@"IncidentPoints24"]];
        
        // add ourselves as an observer to the default queue
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // get all the songs
        [self requestSongList];
        
        // get an updated list of our products
        [self requestProductInformationAllProducts];
        
        // get the owned songs
        [self requestOwnedSongList];
        
        // get the featured songs
        [self requestFeaturedSongList];
        
        // get the current users credits
//        [self requestUserCredits];

    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_productIdentifiers release];
    
    [m_cloudController release];

    [m_credits release];
    
    [m_featureCollection release];
    
    // effectively release
    m_delegate = nil;
    
    // add ourselves as an observer to the default queue
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    [super dealloc];
    
}

#pragma mark - Local information

- (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

- (BOOL)ownUserSong:(UserSong*)userSong
{

    NSNumber * key = [NSNumber numberWithInteger:userSong.m_songId];

    UserSong * ownedUserSong = [m_ownedSongs objectForKey:key];
    
    if ( ownedUserSong != nil )
    {
        return YES;
    }
    
    return NO;
    
}

#pragma mark - Request information

- (void)requestProductIdentifiers
{
    // request a list of product IDs from our server
}

- (void)requestProductInformationAllProducts
{

    [self requestProductInformation:[NSSet setWithArray:m_productIdentifiers]];
    
}

- (void)requestProductInformation:(NSSet*)productIds
{

    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];

    request.delegate = self;

    [request start];

}

#pragma mark - SK Delegate

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{

    NSLog(@"%@", error.localizedDescription);
    
    [request release];
    
}

- (void)requestDidFinish:(SKRequest *)request
{
    
    [request release];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    for ( unsigned int index = 0; index < [response.invalidProductIdentifiers count]; index++ )
    {
        NSLog(@"Invalid!:%@", [response.invalidProductIdentifiers objectAtIndex:index] );
    }

    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for ( unsigned int index = 0; index < [response.products count]; index++ )
    {
        SKProduct * product = [response.products objectAtIndex:index];
    
        [numberFormatter setLocale:product.priceLocale];
        NSString * formattedString = [numberFormatter stringFromNumber:product.price];
        
        NSLog(@"%@, %@, %@", product.localizedTitle, product.localizedDescription, formattedString);
        
    }

    [numberFormatter release];
    
}

#pragma mark - CloudController request 

- (void)requestUserCredits
{
    
    // get the user credits first
    NSNumber * credits = [m_cloudController requestUserCredits];
    
    if ( credits != nil )
    {
        m_credits = [credits retain];
        
        [m_delegate creditCountUpdated:m_credits];
    }
    
}

- (void)requestSongList
{
    
    [m_cloudController requestSongStoreListCallbackObj:self andCallbackSel:@selector(requestSongStoreListCallback:)];
    
}

//- (void)requestSongListSearch:(NSString*)search
//{
// 
//    [m_searchString release];
//    
//    m_searchString = [search retain];
//    
//    // get the full store list
//    [m_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongStoreListCallback)];
////    [m_cloudController requestSongStoreListSearch:search andCallbackObj:self andCallbackSel:@selector(requestSongStoreListCallback:)];
//    
//}

- (void)requestOwnedSongList
{

    // get the songs owned by this owner
    [m_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];

}

- (void)requestFeaturedSongList
{

    [m_cloudController requestFeaturedSongListCallbackObj:self andCallbackSel:@selector(requestFeaturedSongListCallback:)];
    
}

- (void)requestPurchaseSong:(UserSong*)userSong
{
    
    // we do this if we already have credits purchased.
    [m_cloudController requestPurchaseSong:userSong andCallbackObj:self andCallbackSel:@selector(requestPurchaseSongCallback:)];
    
}

- (void)requestVerifyReceipt:(NSData*)receipt
{
    
    // we would generally only allow this if something tragic failed:
    // we charged the user, but don't know what song to give him, so just credit the account
    [m_cloudController requestVerifyReceipt:receipt andCallbackObj:self andCallbackSel:@selector(requestVerifyReceiptCallback:)];
    
}

- (void)redeemCreditCode:(NSString*)creditCode
{
    
    [m_cloudController requestRedeemCreditCode:creditCode andCallbackObj:self andCallbackSel:@selector(requestRedeemCreditCodeCallback:)];
    
}

#pragma mark - CloudController response callbacks

- (void)requestSongListCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate userLoggedOut];
        return;
    }

    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        UserSongs * userSongs = cloudResponse.m_responseUserSongs;
        
        [m_ownedSongs release];
        
        m_ownedSongs = [[NSMutableDictionary alloc] init];
        
        // add them to the dictionary by song id key
        for ( UserSong * userSong in userSongs.m_songsArray )
        {
            
            NSNumber * key = [NSNumber numberWithInteger:userSong.m_songId];
            
            [m_ownedSongs setObject:userSong forKey:key];
            
        }
    }
    
    // don't need to inform the delegate because the owned song info is request on demand.

}

- (void)requestFeaturedSongListCallback:(CloudResponse*)cloudResponse
{
    
    // get the feature collection from the store object and use it for something.
    [m_featureCollection release];
    
    m_featureCollection = cloudResponse.m_responseStoreFeatureCollection;
    
    [m_delegate requestFeaturedSongListComplete];
    
}

- (void)requestSongStoreListCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate userLoggedOut];
        return;
    }

    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {

        UserSongs * userSongs = cloudResponse.m_responseUserSongs;
        
        // also put them in a dictionary for easy searching
        [m_allSongs release];
        
        m_allSongs = [[NSMutableDictionary alloc] init];
        
        // add them to the dictionary by song id key
        for ( UserSong * userSong in userSongs.m_songsArray )
        {
            
            NSNumber * key = [NSNumber numberWithInteger:userSong.m_songId];
            
            [m_allSongs setObject:userSong forKey:key];
            
        }
        
    }
    
    // Its ok if the delegate is nil
    [m_delegate requestSongListComplete];
    
}


- (void)requestPurchaseSongCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate userLoggedOut];
        // Let this run even if we aren't logged in so we can confirm the sale, if it happened
        //return;
    }

    // Purchasing a song by itself isn't that big of a deal.
    // If it doesn't work, we don't have to be as aggressive about recovering
    // because they can just repurchase without loosing anything.
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        NSLog(@"Purchase succeeded");
        
        UserSong * userSong = m_currentUserSong;

        NSNumber * key = [NSNumber numberWithInteger:userSong.m_songId];

        // add this song manually for now. we are about to request an official new list 
        [m_ownedSongs setObject:userSong forKey:key];

        [m_currentUserSong release];
        
        m_currentUserSong = nil;
        
        // get the revised currently owned songs
        [m_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];

        [m_delegate songPurchaseSucceeded:@"Purchase succeeded"];

        // get the new user credits
        NSNumber * credits = [m_cloudController requestUserCredits];
        
        if ( credits != nil )
        {
            m_credits = [credits retain];
            
            [m_delegate creditCountUpdated:m_credits];
        }

    }
    else
    {
        
        NSLog(@"Purchase failed: %@", cloudResponse.m_statusText);
        
        if ( [cloudResponse.m_statusText isEqualToString:@"Not logged in"] )
        {
            
            NSLog(@"Not logged in");
            
//            [m_currentUserSong release];
            
            m_failedUserSong = m_currentUserSong;
            
            m_currentUserSong = nil;

            [m_delegate songPurchaseFailed:@"Not logged in"];

        }
        else if ( [cloudResponse.m_statusText isEqualToString:@"Invalid song ID"] ||
                  [cloudResponse.m_statusText isEqualToString:@"Empty song ID"] )
        {
            
            NSLog(@"Invalid song ID");

//            [m_currentUserSong release];
            
            m_failedUserSong = m_currentUserSong;
            
            m_currentUserSong = nil;
            
            [m_delegate songPurchaseFailed:@"Invalid song ID"];
            
        }
        else
        {
            
            NSLog(@"Unknown server error");
            
//            [m_currentUserSong release];
            
            m_failedUserSong = m_currentUserSong;
            
            m_currentUserSong = nil;
            
            [m_delegate songPurchaseFailed:@"Unknown server error"];
            
        }

    }
    
}

- (void)requestVerifyReceiptCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate userLoggedOut];
        // Let this run even if we aren't logged in so we can confirm the sale
        // return;
    }

    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        NSLog(@"Verify succeeded");

        // Remove this transaction, we don't need it locally anymore
        SKPaymentTransaction * transaction = m_currentTransaction;

        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        [m_currentTransaction release];

        m_currentTransaction = nil;

        [m_delegate creditPurchaseSucceeded:@"Verify succeeded"];
        
        // If there is a song pending purchase, do it now.
        if ( m_currentUserSong != nil )
        {
            [self requestPurchaseSong:m_currentUserSong];
        }
    
    }
    else
    {

        NSLog(@"Verify failed: %@", cloudResponse.m_statusText);
        
        if ( [cloudResponse.m_statusText isEqualToString:@"Not logged in"] )
        {

            // tell user to go log in
            [m_currentTransaction release];
            
            m_currentTransaction = nil;
            
            // also release the song
//            [m_currentUserSong release];
            
            m_failedUserSong = m_currentUserSong;
            
            m_currentUserSong = nil;

            [m_delegate creditPurchaseFailed:@"Not logged in"];
            
        }
        else if ( [cloudResponse.m_statusText isEqualToString:@"Invalid receipt"] ||
                  [cloudResponse.m_statusText isEqualToString:@"Empty receipt"] )
        {
            
            NSLog(@"Invalid receipt");
            
            // If the receipt doesn't check out, they must be trying to fake it somehow.
            // Don't feel bad invalidating this purchase.
            SKPaymentTransaction * transaction = m_currentTransaction;
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            [m_currentTransaction release];
            
            m_currentTransaction = nil;
            
            // also release the song
//            [m_currentUserSong release];
            
            m_failedUserSong = m_currentUserSong;
            
            m_currentUserSong = nil;

            [m_delegate creditPurchaseFailed:@"Invalid receipt"];
            
        }
        else
        {
            
            NSLog(@"Server error");
            
            [m_currentTransaction release];
            
            m_currentTransaction = nil;

            m_failedUserSong = m_currentUserSong;
            
            m_currentUserSong = nil;

            [m_delegate creditPurchasePending:@"Server error"];

        }
        
    }

}

- (void)requestRedeemCreditCodeCallback:(CloudResponse*)cloudResponse
{
    
    
    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate userLoggedOut];
    }
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self requestUserCredits];
        
        [m_delegate redemptionSucceeded];
        
    }
    else
    {
        
        [m_delegate redemptionFailed:cloudResponse.m_statusText];
        
    }
    
}

#pragma mark - Buy

- (void)buyCredits1
{
    [self buyCredits:@"IncidentPoints1"];
}

- (void)buyCredits10
{
    [self buyCredits:@"IncidentPoints10"];
}

- (void)buyCredits11
{
    [self buyCredits:@"IncidentPoints11"];
}

- (void)buyCredits15
{
    [self buyCredits:@"IncidentPoints15"];
}

- (void)buyCredits24
{
    [self buyCredits:@"IncidentPoints24"];
}

- (void)buyCredits:(NSString*)productIdentifier
{
    
    // common case safety check.
    // make sure the server is actually up before we charge the customer.
    // we can handle it if we charge first w/out the song server, but this
    // is the better user experience 
    if ( [m_cloudController requestServerStatus] == YES && 
         [m_cloudController requestItunesServerStatus] == YES )
    {
        
        // nothing pending; add the payment to the queue.
        SKPayment * payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
    else
    {
        
        NSLog(@"The server is down");
        
        [m_delegate creditPurchaseFailed:@"The server is down"];
        
    }

    
}

// this is a void function, since any errors 
// should be sent to the delegate purchaseFailed function
- (void)buySong:(UserSong*)userSong;
{
    
//    NSString * productIdentifier = @"TestPurchaseIP1";
//    NSString * productIdentifier = @"IncidentSong1";
    
    if ( m_currentTransaction != nil )
    {
        
        NSLog(@"Credit purchase already pending");
        
        [m_delegate creditPurchaseFailed:@"Credit purchase already pending"];
        
        return;
        
    }
    
    if ( m_currentUserSong != nil )
    {

        NSLog(@"Song purchase already pending");
        
        [m_delegate creditPurchaseFailed:@"Song purchase already pending"];
        
        return;
        
    }
    
    NSNumber * credits = [m_cloudController requestUserCredits];
    
    if ( credits != nil )
    {
        [m_credits release];
        
        m_credits = [credits retain];
        
        [m_delegate creditCountUpdated:m_credits];
    }
    
    // short cut, just buy the song with current credit balance.
    // if credits == nil, it returns floatValue zero which is fine.
    // we just buy the credits first.
    if ( [credits floatValue] >= [userSong.m_cost floatValue] )
    {

        // save the new current song.
        [m_currentUserSong release];
        
        m_currentUserSong = [userSong retain];
        
        // see if the server is up
        if ( [m_cloudController requestServerStatus] == YES )
        {
            
            [self requestPurchaseSong:userSong];
            
        }
        else
        {
            
            NSLog(@"The server is down");

            [m_delegate songPurchaseFailed:@"The server is down"];
            
        }
        
    }
    else
    {
        
        // save the new current song.
        [m_currentUserSong release];
        
        m_currentUserSong = [userSong retain];
        
        // buy the credits now
        [self buyCredits1];
                
    }
    
}

- (BOOL)isPurchasePending
{
    
//    NSArray * transactions = [SKPaymentQueue defaultQueue].transactions;
//    
//    if ( [transactions count] > 0 )
//    {
//        return YES;
//    }
//    
//    UserSong * userSong = m_storeSettings.m_currentPurchaseUserSong;
//    
//    if ( userSong != nil )
//    {
//        return YES;
//    }
    
    return (m_currentUserSong != nil);

}

- (UserSong*)userSongPurchasePending
{
    
//    UserSong * userSong = m_storeSettings.m_currentPurchaseUserSong;
    
    return m_currentUserSong;
    
}

- (void)retryPurchase
{

    // Retry any pending transactions in the queue
//    NSArray * transactions = [SKPaymentQueue defaultQueue].transactions;
//
//    if ( [transactions count] > 0 )
//    {
//        
//        SKPaymentTransaction * transaction = [transactions objectAtIndex:0];
//        
//        [self verifyTransaction:transaction];
//        
//        return;
//        
//    }
//    
//    // Retry any pending song purchases
//    UserSong * userSong = m_storeSettings.m_currentPurchaseUserSong;
//
//    if ( userSong != nil )
//    {
//        
//        [self requestPurchaseSong:userSong];
//        
//        return;
//        
//    }
    
    NSArray * transactions = [SKPaymentQueue defaultQueue].transactions;
    
    if ( [transactions count] > 0 )
    {
        [self verifyPurchasedTransactions];
    }
    else if ( m_failedUserSong != nil )
    {
        
        UserSong * failedSong = m_failedUserSong;
        
        // we want to free up this song before starting the buy process.
        [m_failedUserSong release];
        
        m_failedUserSong = nil;
        
        [self buySong:failedSong];
        
    }

}

//- (void)cancelPurchase
//{
//    
//    // This only cancels the user song purchase.
//    // We cannot let the credit purchase fail, else the user looses money.
//
//    [m_currentUserSong release];
//    
//    m_currentUserSong = nil;
//    
//    [m_delegate purchaseCanceled];
//    
//}

#pragma mark - Transactions management

- (void)verifyPurchasedTransactions
{

    NSArray * pendingTransactions = [[SKPaymentQueue defaultQueue] transactions];
    
    for ( SKPaymentTransaction * transaction in pendingTransactions )
    {
        
        if ( transaction.transactionState == SKPaymentTransactionStatePurchased )
        {
            
            // take action to purchase the feature
            NSLog(@"Bought this thing. Let the server know (in bulk).");
            
            [self verifyPurchasedTransaction:transaction];

        }
    
    }
    
}

- (void)verifyPurchasedTransaction:(SKPaymentTransaction*)transaction
{
    
    // We just charged them money and theres no going back.
    if ( transaction == nil )
    {
        
        NSLog(@"Transaction cannot be nil");
        
        [m_delegate creditPurchaseFailed:@"Transaction cannot be nil"];
        
        return;
        
    }
    
    if ( m_currentTransaction != nil )
    {
        
        NSLog(@"Transaction pending; transaction already in progress.");
        
        [m_delegate creditPurchasePending:@"Transaction pending; transaction already in progress."];
        
        return;
        
    }

    [m_currentTransaction release];
    
    m_currentTransaction = [transaction retain];

    [self requestVerifyReceipt:transaction.transactionReceipt];

}

#pragma mark - Transactions helpers

- (void)handleRestoreTransaction
{
    
    NSArray * pendingTransactions = [[SKPaymentQueue defaultQueue] transactions];

    for ( SKPaymentTransaction * transaction in pendingTransactions )
    {
        NSLog(@"%@", transaction.transactionIdentifier);
    }
    
}

//- (void)verifyTransaction:(SKPaymentTransaction*)transaction
//{
//    
//    // We just charged them money and theres no going back.
//    if ( transaction == nil )
//    {
//        
//        NSLog(@"Transaction cannot be nil");
//        
//        [m_delegate purchaseFailed:@"Transaction is nil"]; // todo
//        
//        return;
//        
//    }
//    // If there is no productid/usersong waiting for us here -- not common-case but not error either.
//    // We at least must give them credit.
//    if ( m_storeSettings.m_currentPurchaseUserSong == nil )
//    {
//        NSLog(@"Warning, there is no UserSong to purchase.");
//        
//        [m_storeSettings setCurrentTransaction:transaction];
//        
//        // If there is no user song, we can just credit their account.
//        [self requestVerifyReceipt:transaction.transactionReceipt];
//        
//        return;
//        
//    }
//    
//    if ( [m_storeSettings setCurrentTransaction:transaction] == NO )
//    {
//        
//        // This basically only happens if transaction == nil,
//        // or if the file system fails to save. 
//        NSLog(@"Unable save store song state, just crediting user account.");
//        
//        // We can at least credit their account, best effort.
//        [self requestVerifyReceipt:transaction.transactionReceipt];
//        
//        return;
//        
//    }
//    
//    // At this point, the Apple TransactionId+Receipt has been associated with our UserSong and saved to disk.
//    // We can let our server what to look for (i.e. the receipt).
//    
//    //[self requestVerifyReceipt:transaction.transactionReceipt andPurchaseSong:m_storeSettings.m_currentPurchaseUserSong];
//    NSLog(@"Verifying %@", [NSString stringWithCString:(char*)[transaction.transactionReceipt bytes] encoding:NSASCIIStringEncoding] );
//
//    [self requestVerifyReceipt:transaction.transactionReceipt];
//    
//    return;
//    
//}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    NSLog(@"Update transactions");
    
    for ( SKPaymentTransaction * transaction in transactions )
    {

        switch ( transaction.transactionState )
        {

            case SKPaymentTransactionStatePurchased:
            {
                
                // take action to purchase the feature
                NSLog(@"Purchased this thing. Let the server know.");
                
                if ( m_currentTransaction != nil )
                {
                    
                    NSLog(@"Purchase already in progress");
                    
                    [m_delegate creditPurchasePending:@"Purchase already in progress"];
                    
                }
                else
                {

                    [self verifyPurchasedTransaction:transaction];

                }
                
            } break;
                
            case SKPaymentTransactionStateRestored:
            {
                
                // take action to restore the app as if it was purchased
                NSLog(@"'Rebought' this thing. Let the server know.");
                
                // Recover the transaction ID.
//                SKPaymentTransaction * originalTransaction = transaction.originalTransaction;
//                
//                if ( originalTransaction.transactionIdentifier != 
//                     m_storeSettings.m_currentTransaction.m_paymentTransaction.transactionIdentifier )
//                {
//                    // This is odd but not fatal.
//                    NSLog(@"Transaction mismatch, using the new one.");
//                }

                if ( m_currentTransaction != nil )
                {
                    
                    NSLog(@"Purchase already in progress");
                    
                    [m_delegate creditPurchasePending:@"Purchase already in progress"];
                    
                }
                else
                {

                    [self verifyPurchasedTransaction:transaction];
                    
                }

            } break;
                
            case SKPaymentTransactionStateFailed:
            {
                
                if (transaction.error.code != SKErrorPaymentCancelled)
                {

                    NSLog(@"iTunes payment failed");
                    
                    [m_delegate creditPurchaseFailed:@"iTunes payment failed"];
                    
                }
                else 
                {
                    
                    NSLog(@"User canceled purchase");
                    
                    [m_delegate creditPurchaseCanceled:@"User canceled purchase"];
                    
                }
                
                [m_currentUserSong release];
                
                m_currentUserSong = nil;

                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
            } break;
                
            case SKPaymentTransactionStatePurchasing:
            {
                
                NSLog(@"Purchasing this thing");
                
                // Unfortunately there isn't anything meaningful we can do here.
                // The transaction id/date/receipt aren't even created until after the purchase.

            } break;
                
            default:
            {
                
                // doesn't happen
                NSLog(@"Invalid transaction state: %u", (NSInteger)transaction.transactionState );
                
            } break;

        }
        
    }

}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    
    // We have our own log of transactions in the store settings object.
    // We only adjust things there based on our servers response.
    // We don't care what leaves this queue at this place.
    
    NSLog(@"Removed transactions:");
    
    for ( SKPaymentTransaction * transaction in transactions )
    {
        NSLog( @"%@", transaction.transactionIdentifier );
    }
    
    
    // clear out the queue if anything is left
    [self verifyPurchasedTransactions];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    
    NSLog(@"Transaction failed error");

    // clear out the queue if anything is left
    [self verifyPurchasedTransactions];

}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
    NSLog(@"Transaction finished");

    // clear out the queue if anything is left
    [self verifyPurchasedTransactions];

}


@end