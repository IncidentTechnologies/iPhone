//
//  ContentController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 2/23/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import "ContentController.h"
#import "CloudController.h"
#import "CloudRequest.h"
#import "CloudResponse.h"
#import "UserSong.h"
#import "UserSongs.h"

@implementation ContentController

@synthesize m_ownedUserSongs;
@synthesize m_allUserSongs;

- (id)initWithCloudController:(CloudController*)cloudController
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_cloudController = cloudController;
        
        // Create a little place to store our content stuff
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * contentPath = [documentsDirectory stringByAppendingPathComponent:@"Content"];
        
        m_contentFilePath = contentPath;
        
        if ( [[NSFileManager defaultManager] fileExistsAtPath:m_contentFilePath] == NO )
        {
            
            NSError * error = nil;
            
            // Create the content folder
            [[NSFileManager defaultManager] createDirectoryAtPath:m_contentFilePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            if ( error != nil )
            {
                NSLog(@"Error: '%@' creating Content path: '%@'", [error localizedDescription], m_contentFilePath);
                
                
                return nil;
            }
            
        }
        
        // Try to load the owned PIDs from settings
        [self loadOwnedProductIds];
        
        // If it fails, we probably have never run before
        if ( m_ownedProductIds == nil )
        {
            [self updateOwnedProductIds];
        }
        
        // Try to load all the user songs
        [self loadAllUserSongs];
        
        if ( m_allUserSongs == nil )
        {
            [self updateAllUserSongs];
        }
        else
        {
            [self mapPidsToAllUserSongs];
        }
        
        // Update all available PIDs
        [self updateAllProductIdentifiers];
        
        // add ourselves as an observer to the default queue
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    
    return self;
    
}


#pragma mark - External helpers

- (BOOL)isSongOwned:(UserSong*)userSong
{
    
    return [m_ownedUserSongs containsObject:userSong];
    
}

#pragma mark - Local management

// Get all of the SKProduct objects for the provided PID list
- (void)updateAllProducts
{
    
    // Resolved all the product IDs into product objects
    
    m_allProductIdsToProducts = [[NSMutableDictionary alloc] init];
    
    // Request all the products
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:m_allProductIds]];
    
    request.delegate = self;
    
    [request start];
    
}

// Get all the PIDs that this user owns
- (void)updateOwnedProductIds
{
    
    
    m_ownedProductIds = [[NSMutableArray alloc] init];
    
    // Begin the process of restoring transactions
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

- (void)createOwnedUserSongsList
{
    
    if ( [m_allProductIdsToUserSongs count] == 0 || [m_ownedProductIds count] == 0 )
    {
        // We don't have all the data we need yet
        return;
    }
    
    
    m_ownedUserSongs = [[NSMutableArray alloc] init];
    
    // Using the owned PID array, create an owned song array
    for ( NSString * productId in m_ownedProductIds )
    {
        
        UserSong * userSong = [m_allProductIdsToUserSongs objectForKey:productId];
        
        [m_ownedUserSongs addObject:userSong];
        
    }
    

}

- (void)mapPidsToAllUserSongs
{
    
    if ( [m_allUserSongs count] == 0 )
    {
        // We don't have all the data we need yet.
        return;
    }
    
    
    m_allProductIdsToUserSongs = [[NSMutableDictionary alloc] init];
    
    // Map all of these songs pid->usersong
    for ( UserSong * userSong in m_allUserSongs )
    {
        
        NSString * key = userSong.m_productId;
        
        if ( key != nil )
        {
            [m_allProductIdsToUserSongs setObject:userSong forKey:key];
        }
        
    }
    
    [self createOwnedUserSongsList]; 

}

- (void)saveOwnedProductIds
{
    
    NSString * path = [m_contentFilePath stringByAppendingPathComponent:@"OwnedProductIds"];
    
    [NSKeyedArchiver archiveRootObject:m_ownedProductIds toFile:path];
    
}

- (void)loadOwnedProductIds
{
    
    NSString * path = [m_contentFilePath stringByAppendingPathComponent:@"OwnedProductIds"];
    
    // nil is ok
    m_ownedProductIds = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
}

- (void)saveAllUserSongs
{
    
    NSString * path = [m_contentFilePath stringByAppendingPathComponent:@"AllUserSongs"];
    
    [NSKeyedArchiver archiveRootObject:m_allUserSongs toFile:path];
    
}

- (void)loadAllUserSongs
{
    
    NSString * path = [m_contentFilePath stringByAppendingPathComponent:@"AllUserSongs"];
    
    // nil is ok
    m_allUserSongs = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
}

#pragma mark - Cloud requests

// Get all the user songs
- (void)updateAllUserSongs
{
    
    // Pull down a list of UserSongs that include PIDs
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetAllSongsList
                                                   andCallbackObject:self
                                                 andCallbackSelector:@selector(updateAllUserSongsCallback:)];
    
    [m_cloudController cloudSendRequest:cloudRequest];
    
}

- (void)updateAllUserSongsCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        
        m_allUserSongs = cloudResponse.m_responseUserSongs.m_songsArray;
        
        [self createOwnedUserSongsList]; 
        
        [self saveAllUserSongs];
        
        [self mapPidsToAllUserSongs];
        
    }
    
}

// Get all the PIDs
- (void)updateAllProductIdentifiers
{
    
    // Pull down a list of valid PIDs from our server and stick them in m_allProductIds
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetAllSongPids
                                                   andCallbackObject:self
                                                 andCallbackSelector:@selector(updateProductIdentifiersCallback:)];
    
    [m_cloudController cloudSendRequest:cloudRequest];
    
}

- (void)updateProductIdentifiersCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        
        m_allProductIds = cloudResponse.m_responseProductIds;
        
    }
    
    [self updateAllProducts];
    
}

#pragma mark - Buying content

- (void)buyProductId:(NSString*)productId
{
    
    SKProduct * product = [m_allProductIdsToProducts objectForKey:productId];
    
//    SKPayment * payment = [SKPayment paymentWithProductIdentifier:productId];
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

#pragma mark - SKProducts Delegate

// Map all the PIDs to SKProduct objects
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    for ( NSString * productId in response.invalidProductIdentifiers )
    {
        NSLog( @"Invalid PID: %@", productId );
    }
    
    // Format the price in local currency
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for ( SKProduct * product in response.products )
    {
        
        [numberFormatter setLocale:product.priceLocale];
        
        NSString * formattedString = [numberFormatter stringFromNumber:product.price];
        
        NSLog( @"PID: '%@', Title: '%@', Desc: '%@', Price: '%@'", 
              product.productIdentifier, product.localizedTitle, product.localizedDescription, formattedString );
        
        [m_allProductIdsToProducts setObject:product forKey:product.productIdentifier];
        
    }
    
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    
    NSLog(@"SKProduct request failed: %@", error.localizedDescription);
    
    
}

- (void)requestDidFinish:(SKRequest *)request
{
    
    
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    for ( SKPaymentTransaction * transaction in transactions )
    {
        
        switch ( transaction.transactionState )
        {
                
            case SKPaymentTransactionStatePurchased:
            {
                
                NSLog( @"Purchased transaction: %@ PID: %@", transaction.transactionIdentifier, transaction.payment.productIdentifier );
                
                [m_ownedProductIds addObject:transaction.payment.productIdentifier];
                                
            } break;
                
            case SKPaymentTransactionStateRestored:
            {
                
                NSLog( @"Restoring transaction: %@ PID: %@", transaction.transactionIdentifier, transaction.payment.productIdentifier );
                
                [m_ownedProductIds addObject:transaction.payment.productIdentifier];
                
            } break;
                
            case SKPaymentTransactionStateFailed:
            {
                
                if ( transaction.error.code != SKErrorPaymentCancelled )
                {
                    
                    NSLog( @"Failed transaction: %@ PID: %@", transaction.transactionIdentifier, transaction.payment.productIdentifier );
                    
                }
                else 
                {
                    
                    NSLog( @"Cancelled transaction: %@ PID: %@", transaction.transactionIdentifier, transaction.payment.productIdentifier );
                    
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
            } break;
                
            case SKPaymentTransactionStatePurchasing:
            {
                
                NSLog( @"Purchasing transaction: %@ PID: %@", transaction.transactionIdentifier, transaction.payment.productIdentifier );
                
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
    
    for ( SKPaymentTransaction * transaction in transactions )
    {
        NSLog( @"Removed transaction: %@ PID: %@", transaction.transactionIdentifier, transaction.payment.productIdentifier );
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    
    NSLog( @"Restore failed: %@", [error localizedDescription] );
    
    // Failure isn't good, not much we can do
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
    NSLog(@"Restore finished");
    
    // After restoring all the transactions, we can save the PID array
    [self saveOwnedProductIds];
    
}


@end
