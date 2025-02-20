//
//  StoreTransaction.h
//  gTarAppCore
//
//  Created by Marty Greenia on 5/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class UserSong;

@interface StoreTransaction : NSObject <NSCoding>
{
    
    NSString * m_productId;
    UserSong * m_userSong;

    NSData * m_transactionReceipt;
    NSDate * m_transactionDate;
    NSString * m_transactionIdentifier;
    
    SKPaymentTransaction * m_paymentTransaction;

}

@property (nonatomic, retain) NSString * m_productId;
@property (nonatomic, retain) UserSong * m_userSong;

@property (nonatomic, retain) NSData * m_transactionReceipt;
@property (nonatomic, retain) NSDate * m_transactionDate;
@property (nonatomic, retain) NSString * m_transactionIdentifier;

@property (nonatomic, retain) SKPaymentTransaction * m_paymentTransaction;

@end
