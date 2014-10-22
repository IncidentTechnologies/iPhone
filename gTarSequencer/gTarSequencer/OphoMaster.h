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
@class NSSample;
@class NSInstrument;

@protocol OphoLoginDelegate <NSObject>

- (void)loggedInCallback;
- (void)loginFailedCallback:(NSString *)error;

@end

@protocol OphoTutorialDelegate <NSObject>

- (void)tutorialReady:(NSInteger)xmpId;

@end

@protocol OphoSampleDelegate <NSObject>

- (void)customSampleSavedWithId:(NSInteger)xmpId andName:(NSString *)xmpName;

@end

@interface OphoMaster : NSObject
{
    OphoCloudController * ophoCloudController;
    
    NSMutableDictionary * ophoInstruments;
    NSMutableDictionary * ophoLoadingInstrumentQueue;
    
    // Preloaded Data
    NSMutableArray * songIdSet;
    NSMutableArray * songLoadSet;
    NSMutableArray * songDateSet;
    NSMutableArray * sequenceIdSet;
    NSMutableArray * sequenceLoadSet;
    NSMutableArray * sequenceDateSet;
    NSMutableArray * sampleIdSet;
    NSMutableArray * sampleLoadSet;
    NSMutableArray * sampleDateSet;
    NSMutableArray * instrumentIdSet;
    NSMutableArray * instrumentLoadSet;
    NSMutableArray * instrumentDateSet;

    BOOL pendingLoadTutorial;
    
}

@property (weak, nonatomic) id <OphoLoginDelegate> loginDelegate;
@property (weak, nonatomic) id <OphoTutorialDelegate> tutorialDelegate;
@property (weak, nonatomic) id <OphoSampleDelegate> sampleDelegate;
@property (strong, nonatomic) NSSong * savingSong;
@property (strong, nonatomic) NSSequence * savingSequence;
@property (strong, nonatomic) NSSample * savingSample;
@property (strong, nonatomic) NSData * savingSampleData;
@property (strong, nonatomic) NSInstrument * savingInstrument;

- (id)init;

// Authentication
- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)logout;
- (BOOL)loggedIn;

// XMP
- (void)saveSequence:(NSSequence *)sequence;
- (void)saveSong:(NSSong *)song;
- (void)saveSample:(NSSample *)sample withFile:(NSData *)data;
- (void)saveInstrument:(NSInstrument *)instrument;

- (void)renameSongWithId:(NSInteger)xmpId toName:(NSString *)name;
- (void)renameSequenceWithId:(NSInteger)xmpId toName:(NSString *)name;

- (void)loadFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector;

- (void)loadSamplesForInstrument:(NSInteger)instrumentId andName:(NSString *)instrumentName andSamples:(NSArray *)samples callbackObj:(id)object selector:(SEL)selector;

- (void)deleteWithId:(NSInteger)xmpId;

// Tutorial
- (void)loadTutorialSequenceWhenReady;
- (void)copyTutorialFile;

// Acces pregenerated data
- (NSDictionary *)getSongList;
- (NSDictionary *)getSequenceList;
- (NSDictionary *)getSampleList;
- (NSDictionary *)getInstrumentList;

@end
