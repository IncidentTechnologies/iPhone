//
//  StoreTransaction.m
//  gTarAppCore
//
//  Created by Marty Greenia on 5/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "StoreTransaction.h"


@implementation StoreTransaction

@synthesize m_productId;
@synthesize m_userSong;
@synthesize m_transactionReceipt;
@synthesize m_transactionDate;
@synthesize m_transactionIdentifier;
@synthesize m_paymentTransaction;

// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{
    
	[coder encodeObject:m_productId forKey:@"ProductId"];
	[coder encodeObject:m_userSong forKey:@"UserSong"];

    [coder encodeObject:m_transactionReceipt forKey:@"TransactionReceipt"];
    [coder encodeObject:m_transactionDate forKey:@"TransactionDate"];
    [coder encodeObject:m_transactionIdentifier forKey:@"TransactionIdentifier"];

    // m_paymentTransaction cannot be encoded to disk, it has to be restored
    // from the payment queue when the app restarts (or whenever).

}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
	
    self = [super init];
    
	if ( self )
	{
        
		self.m_productId = [coder decodeObjectForKey:@"ProductId"];
        self.m_userSong = [coder decodeObjectForKey:@"UserSong"];

        self.m_transactionReceipt = [coder decodeObjectForKey:@"TransactionReceipt"];
        self.m_transactionDate = [coder decodeObjectForKey:@"TransactionDate"];
        self.m_transactionIdentifier = [coder decodeObjectForKey:@"TransactionIdentifier"];

        // m_paymentTransaction cannot be encoded to disk, it has to be restored
        // from the payment queue when the app restarts (or whenever).

	}
	
	return self;
	
}


@end
