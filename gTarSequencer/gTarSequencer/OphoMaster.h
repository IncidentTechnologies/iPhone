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

#define OPHO_FOLDER_ROOT @"Sequence"
#define OPHO_FOLDER_SEQUENCE @"Sets"
#define OPHO_FOLDER_SAMPLE @"Samples"
#define OPHO_FOLDER_SONG @"Songs"
#define OPHO_FOLDER_INSTRUMENT @"Instruments"
#define OPHO_FOLDER_USER @"Users"

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

@protocol OphoLoadingDelegate <NSObject>

- (void)loadingBegan:(BOOL)loginLoading;
- (void)loadingEnded:(BOOL)delay endLoginLoading:(BOOL)endLoginLoading;
- (void)setLoadingPercentage:(double)percent;
- (void)instrumentListLoaded;
- (void)resetState;
- (void)createNewSet;

@end

@protocol OphoProfileDelegate <NSObject>

- (void)profileLoaded;

@end

@interface OphoMaster : NSObject
{
    OphoCloudController * ophoCloudController;
    
    NSMutableDictionary * ophoInstruments;
    NSMutableDictionary * ophoLoadingInstrumentQueue;
    NSMutableArray * loadedInstruments;
    
    NSMutableDictionary * ophoSampleCache;
    
    // Preloaded Data
    NSMutableArray * songIdSet;
    NSMutableArray * songLoadSet;
    NSMutableArray * songDateSet;
    NSMutableArray * songVersionSet;
    NSMutableArray * songIsCustomSet;
    
    NSMutableArray * sequenceIdSet;
    NSMutableArray * sequenceLoadSet;
    NSMutableArray * sequenceDateSet;
    NSMutableArray * sequenceVersionSet;
    NSMutableArray * sequenceIsCustomSet;
    
    NSMutableArray * sampleIdSet;
    NSMutableArray * sampleLoadSet;
    NSMutableArray * sampleDateSet;
    NSMutableArray * sampleVersionSet;
    NSMutableArray * sampleIsCustomSet;
    
    NSMutableArray * instrumentIdSet;
    NSMutableArray * instrumentLoadSet;
    NSMutableArray * instrumentDateSet;
    NSMutableArray * instrumentVersionSet;
    NSMutableArray * instrumentIsCustomSet;

    BOOL tutorialSkipped;
    BOOL loggedInAndLoaded;
    double samplesToLoad;
    double samplesLoaded;
    
}

@property (weak, nonatomic) id <OphoLoginDelegate> loginDelegate;
@property (weak, nonatomic) id <OphoTutorialDelegate> tutorialDelegate;
@property (weak, nonatomic) id <OphoSampleDelegate> sampleDelegate;
@property (weak, nonatomic) id <OphoLoadingDelegate> loadingDelegate;
@property (weak, nonatomic) id <OphoProfileDelegate> profileDelegate;
@property (assign, nonatomic) NSInteger rootFolderId;
@property (assign, nonatomic) NSInteger userRootFolderId;
@property (assign, nonatomic) NSInteger userSequenceFolderId;
@property (assign, nonatomic) NSInteger userSampleFolderId;
@property (assign, nonatomic) NSInteger userSongFolderId;
@property (assign, nonatomic) NSInteger userInstrumentFolderId;
@property (assign, nonatomic) NSInteger ophoSequenceFolderId;
@property (assign, nonatomic) NSInteger ophoSampleFolderId;
@property (assign, nonatomic) NSInteger ophoSongFolderId;
@property (assign, nonatomic) NSInteger ophoInstrumentFolderId;
@property (assign, nonatomic) NSInteger ophoUserFolderId;

@property (strong, nonatomic) NSSong * savingSong;
@property (strong, nonatomic) NSData * savingSongData;
@property (strong, nonatomic) NSSequence * savingSequence;
@property (strong, nonatomic) NSSample * savingSample;
@property (strong, nonatomic) NSData * savingSampleData;
@property (strong, nonatomic) NSInstrument * savingInstrument;
@property (strong, nonatomic) id savingInstrumentObject;
@property (strong, nonatomic) NSString * savingInstrumentSelector;
@property (strong, nonatomic) id loadingSampleObject;
@property (strong, nonatomic) NSString * loadingSampleSelector;

- (id)init;

// Authentication
- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)logout;
- (BOOL)loggedIn;

- (NSInteger)getUserId;
- (UIImage *)getUserProfileImage;
- (NSString *)getUsername;

// Caching
- (BOOL)cacheForSample:(long)xmpId;

// XMP
- (void)saveSequence:(NSSequence *)sequence;
- (void)saveSong:(NSSong *)song withFile:(NSData *)filedata;
- (void)saveSample:(NSSample *)sample withFile:(NSData *)filedata;
- (void)saveInstrument:(NSInstrument *)instrument;
- (void)saveNewInstrument:(NSInstrument *)instrument callbackObj:(id)object selector:(SEL)selector;

- (void)renameSongWithId:(NSInteger)xmpId toName:(NSString *)name;
- (void)renameSequenceWithId:(NSInteger)xmpId toName:(NSString *)name;

- (void)loadFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector;
- (void)loadSampleFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector;

- (void)prepareToLoadSamples:(int)numSamples;
- (void)loadSamplesForInstrument:(NSInteger)instrumentId andName:(NSString *)instrumentName andSamples:(NSArray *)samples callbackObj:(id)object selector:(SEL)selector;

- (void)deleteWithId:(NSInteger)xmpId;

// Tutorial
- (void)resetTutorial;
- (void)tutorialSkipped;
- (void)copyTutorialFile;

// Acces pregenerated data
- (NSDictionary *)getSongList;

- (NSDictionary *)getSequenceList;
- (NSString *)generateNextSequenceName;

- (NSDictionary *)getSampleList;
- (NSDictionary *)getCustomSampleList;
- (NSDictionary *)getStandardSampleList;

- (NSDictionary *)getCustomInstrumentList;
- (NSDictionary *)getInstrumentList;

@end
