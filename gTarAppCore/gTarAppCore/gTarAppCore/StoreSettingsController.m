//
//  StoreSettings.m
//  gTarAppCore
//
//  Created by Marty Greenia on 5/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "StoreSettingsController.h"
#import "StoreTransaction.h"

@implementation StoreSettingsController

@synthesize m_currentPurchaseProductId;
@synthesize m_currentPurchaseUserSong;
@synthesize m_currentTransaction;
@synthesize m_previousPurchaseUserSong;
@synthesize m_isDirty;


// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{

    [coder encodeObject:m_currentPurchaseProductId forKey:@"ProductId"];
    [coder encodeObject:m_currentPurchaseUserSong forKey:@"UserSong"];
    [coder encodeObject:m_currentTransaction forKey:@"Transaction"];
    
    [coder encodeObject:m_previousPurchaseUserSong forKey:@"PreviousUserSong"];
    
	[super encodeWithCoder:coder];
  	
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
	
    self = [super initWithCoder:coder];
    
	if ( self )
	{
		
        m_currentPurchaseProductId = [coder decodeObjectForKey:@"ProductId"];
        m_currentPurchaseUserSong = [coder decodeObjectForKey:@"UserSong"];
        m_currentTransaction = [coder decodeObjectForKey:@"Transaction"];
        
        m_previousPurchaseUserSong = [coder decodeObjectForKey:@"PreviousUserSong"];
        
	}
	
	return self;
	
}

- (BOOL)setCurrentPurchaseProductId:(NSString*)productId andUserSong:(UserSong*)userSong
{
    
    if ( m_currentPurchaseProductId != nil || m_currentPurchaseUserSong != nil )
    {
        NSLog(@"Purchase in progress");
        return NO;
    }
    
    if ( productId == nil || userSong == nil )
    {
        NSLog(@"No purchase data provided");
        return NO;
    }
    
    //m_currentPurchaseProductId = [productId retain];
    //m_currentPurchaseUserSong = [userSong retain];
    m_currentPurchaseProductId = productId;
    m_currentPurchaseUserSong = userSong;
  
    return [self saveArchive];;

}

- (void)clearCurrentPurchase
{
    
    /*[m_currentPurchaseProductId release];
    [m_currentPurchaseUserSong release];
    [m_currentTransaction release];
*/
    m_currentPurchaseProductId = nil;
    m_currentPurchaseUserSong = nil;
    m_currentTransaction = nil;
    
    [self saveArchive];

}

- (BOOL)setCurrentTransaction:(SKPaymentTransaction*)transaction
{
    
    if ( transaction == nil )
    {
        return NO;
    }
    
    if ( transaction.transactionDate == nil ||
         transaction.transactionReceipt == nil ||
         transaction.transactionIdentifier == nil )
    {
        return NO;
    }
    
    StoreTransaction * storeTransaction = [[StoreTransaction alloc] init];
    
    // these two are redundant but thats ok.
    storeTransaction.m_productId = m_currentPurchaseProductId;
    storeTransaction.m_userSong = m_currentPurchaseUserSong;
    
    storeTransaction.m_transactionDate = transaction.transactionDate;
    storeTransaction.m_transactionReceipt = transaction.transactionReceipt;
    storeTransaction.m_transactionIdentifier = transaction.transactionIdentifier;
    storeTransaction.m_paymentTransaction = transaction;
    
    m_currentTransaction = storeTransaction;
    
    return [self saveArchive];
}

- (void)restoreIncompletePurchase
{
    // if there is a still a current purchase, it is left over
    // from a previous run. we now consider it to be a 'previous'
    // purchase for used in recovery only.
    // if for some reason there is already a previous purchase, it is 
    // ok to blow it away.
    
    m_previousPurchaseUserSong = m_currentPurchaseUserSong;
    
    m_currentPurchaseUserSong = nil;
    m_currentTransaction = nil;
    
    // we don't need the transaction id, because the storekit will
    // provde us with a new one when it gets around to it.
    
}

- (BOOL)initiateSongBuy
{
    
    if ( m_songBuyInitiated == YES && m_songBuyCompleted == NO)
    {
        NSLog(@"Cannot initiate song purchase, song purchase in progress.");
        return NO;
    }
    
//    if ( m_songBuyCompleted == YES )
//    {
//        NSLog(@"Cannot initiate song purchase, song purchase already complete.");
//        return NO;
//    }

    m_songBuyInitiated = YES;
    m_songBuyCompleted = NO;
    
    return [self saveArchive];
    
}

- (BOOL)completeSongBuy
{
    
    if ( m_songBuyInitiated == NO )
    {
        NSLog(@"Cannot complete song purchase, no song purchase in progress.");
        return NO;
    }

    if ( m_songBuyCompleted == YES )
    {
        NSLog(@"Cannot complete song purchase, song purchase already complete");
        return NO;
    }

    m_songBuyInitiated = YES;
    m_songBuyCompleted = YES;
    
    return [self saveArchive];

}

- (BOOL)initiateCreditBuy
{
    
    if ( m_creditBuyInitiated == YES && m_creditBuyCompleted == NO )
    {
        NSLog(@"Cannot initiate credit purchase, credit purchase in progress.");
        return NO;
    }
    
//    if ( m_creditBuyInitiated == YES && m_creditBuyCompleted == NO )
//    {
//        NSLog(@"Cannot initiate song purchase, song purchase in progress.");
//        return NO;
//    }

    m_creditBuyInitiated = YES;
    m_creditBuyCompleted = NO;
    
    return [self saveArchive];
    
}

- (BOOL)completeCreditBuy
{
    
    if ( m_songBuyInitiated == NO )
    {
        NSLog(@"Cannot complete song purchase, now song purchase in progress.");
        return NO;
    }
    
    if ( m_songBuyCompleted == YES )
    {
        NSLog(@"Cannot complete song purchase, song purchase already complete");
        return NO;
    }
    
    m_songBuyInitiated = YES;
    m_songBuyCompleted = YES;
    
    return [self saveArchive];
    
}

- (BOOL)saveArchive
{

    BOOL result = [super saveArchive];

    m_isDirty = !result;

    return result;
    
}

@end
