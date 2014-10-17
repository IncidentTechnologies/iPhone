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

@class NSSong;
@class NSSequence;

@protocol OphoLoginDelegate <NSObject>

- (void)loggedInCallback;
- (void)loginFailedCallback:(NSString *)error;

@end

@protocol OphoTutorialDelegate <NSObject>

- (void)tutorialReady:(NSInteger)xmpId;

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
    
    BOOL pendingLoadTutorial;
    
}

@property (weak, nonatomic) id <OphoLoginDelegate> loginDelegate;
@property (weak, nonatomic) id <OphoTutorialDelegate> tutorialDelegate;
@property (strong, nonatomic) NSSong * savingSong;
@property (strong, nonatomic) NSSequence * savingSequence;


- (id)init;

// Authentication
- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)logout;
- (BOOL)loggedIn;

// XMP
- (void)saveSequence:(NSSequence *)sequence;
- (void)saveSong:(NSSong *)song;

- (void)renameSongWithId:(NSInteger)xmpId toName:(NSString *)name;
- (void)renameSequenceWithId:(NSInteger)xmpId toName:(NSString *)name;

- (void)loadFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector;

- (void)deleteWithId:(NSInteger)xmpId;

// Tutorial
- (void)loadTutorialSequenceWhenReady;
- (void)copyTutorialFile;


// Acces pregenerated data
- (NSDictionary *)getSongList;
- (NSDictionary *)getSequenceList;

@end
