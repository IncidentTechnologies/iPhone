//
//  OphoMaster.h
//  Sequence
//
//  Created by Kate Schnippering on 10/15/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "OphoCloudController.h"

#define OPHO_LIST_IDS @"ids"
#define OPHO_LIST_NAMES @"names"
#define OPHO_LIST_DATES @"dates"

@protocol OphoLoginDelegate <NSObject>

- (void)loggedInCallback;
- (void)loginFailedCallback:(NSString *)error;

@end

@interface OphoMaster : NSObject
{
    OphoCloudController * ophoCloudController;
    
    NSMutableDictionary * ophoQueueDict;
    
    // Preloaded Data
    NSMutableArray * songIdSet;
    NSMutableArray * songLoadSet;
    NSMutableArray * songDateSet;
    NSMutableArray * sequenceIdSet;
    NSMutableArray * sequenceLoadSet;
    NSMutableArray * sequenceDateSet;
}

@property (weak, nonatomic) id <OphoLoginDelegate> loginDelegate;

- (id)init;

// Authentication
- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)logout;
- (BOOL)loggedIn;

// XMP
- (void)getSongListForCallbackObj:(id)callbackObj selector:(SEL)selector;
- (void)getSequenceListForCallbackObj:(id)callbackObj selector:(SEL)selector;

- (void)saveToNewWithName:(NSString *)name callbackObj:(id)callbackObj selector:(SEL)selector;
- (void)saveToId:(NSInteger)xmpId withData:(NSString *)data callbackObj:(id)callbackObj selector:(SEL)selector;
- (void)loadFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector;

- (void)deleteWithId:(NSInteger)xmpId;

// Acces pregenerated data
- (NSDictionary *)getSongList;
- (NSDictionary *)getSequenceList;

@end
