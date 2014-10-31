//
//  OphoMaster.m
//  Sequence
//
//  Created by Kate Schnippering on 10/15/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "OphoMaster.h"
#import "NSSong.h"
#import "NSSequence.h"
#import "NSSample.h"

#define OPHO_CALL_LOGIN @"OphoCallLogin"
#define OPHO_CALL_LOGOUT @"OphoCallLogout"

@implementation OphoMaster

extern NSUser * g_loggedInUser;

@synthesize loginDelegate;
@synthesize tutorialDelegate;
@synthesize sampleDelegate;
@synthesize loadingDelegate;
@synthesize savingSong;
@synthesize savingSequence;
@synthesize savingSample;
@synthesize savingSampleData;
@synthesize savingInstrument;

- (id)init
{
    self = [super init];
    if ( self )
    {
        ophoCloudController = [[OphoCloudController alloc] initWithServer:kServerAddress];
        pendingLoadTutorial = NO;
        
        ophoInstruments = [[NSMutableDictionary alloc] init];
        ophoLoadingInstrumentQueue = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}


#pragma mark - Authentication

- (void)registerWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    [ophoCloudController requestRegisterUsername:username andPassword:password andEmail:email andCallbackObj:self andCallbackSel:@selector(loginCallback:)];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    [ophoCloudController requestLoginUsername:username andPassword:password andCallbackObj:self andCallbackSel:@selector(loginCallback:)];
}

- (void)loginCallback:(CloudResponse *)cloudResponse
{
    if(cloudResponse.m_status == CloudResponseStatusSuccess){
        
        [g_loggedInUser loadWithId:cloudResponse.m_responseUserId Name:cloudResponse.m_cloudRequest.m_username Password:cloudResponse.m_cloudRequest.m_password Email:cloudResponse.m_cloudRequest.m_email Image:cloudResponse.m_responseFileId Profile:cloudResponse.m_responseUserProfile];
        
        [g_loggedInUser cache];
        
        [loginDelegate loggedInCallback];
        
        [self regenerateData];
        
    }else{
        
        [loginDelegate loginFailedCallback:cloudResponse.m_statusText];
        
    }
}

- (void)logout
{
    if([self loggedIn]){
        [ophoCloudController requestLogoutCallbackObj:self andCallbackSel:@selector(logoutCallback:)];
    }
}

- (void)logoutCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Opho Callback | Logged Out");
}

- (BOOL)loggedIn
{
    return ophoCloudController.m_loggedIn;
}

#pragma mark - XMP Lists

- (void)getSongListForCallbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestGetXmpListWithType:OphoXmpTypeSong andUserId:g_loggedInUser.m_userId andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)getSequenceListForCallbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestGetXmpListWithType:OphoXmpTypeAppDefined andUserId:g_loggedInUser.m_userId andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)getSampleListForCallbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestGetXmpListWithType:OphoXmpTypeXMPSample andUserId:g_loggedInUser.m_userId andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)getInstrumentListForCallbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestGetXmpListWithType:OphoXmpTypeXMPInstrument andUserId:g_loggedInUser.m_userId andCallbackObj:callbackObj andCallbackSel:selector];
}

#pragma mark - XMP Save
// Sequences
- (void)saveSequence:(NSSequence *)sequence
{   
    if(savingSequence == nil && sequence.m_name != nil && ![sequence.m_name isEqualToString:@""]){
        
        DLog(@"Saving to name %@",sequence.m_name);
        
        savingSequence = sequence;
        [savingSequence giveUserOwnership]; // May be an edited preset
        
        if(savingSequence.m_id <= 0){
            [self saveToNewWithName:sequence.m_xmpName callbackObj:self selector:@selector(saveNewSequenceCallback:)];
        }else{
            [self saveSequenceToId:sequence.m_id withName:sequence.m_xmpName];
        }
        
    }
}

- (void)saveNewSequenceCallback:(CloudResponse *)cloudResponse
{
    [self saveSequenceToId:(long)cloudResponse.m_id withName:cloudResponse.m_xmpName];
}

- (void)saveSequenceToId:(long)newId withName:(NSString *)name
{
    savingSequence.m_id = newId;
    [savingSequence renameToName:name];
    
    DLog(@"Sequence ID is now %li",savingSequence.m_id);
    
    NSString * sequenceData = [savingSequence saveToFile:savingSequence.m_name];
    
    [self saveToId:savingSequence.m_id withData:sequenceData withName:savingSequence.m_name];
}

// Songs
- (void)saveSong:(NSSong *)song
{
    DLog(@"Song is %@",song);
    
    if(savingSong == nil && song != nil){
        
        savingSong = song;
        
        if(savingSong.m_id <= 0){
            [self saveToNewWithName:song.m_xmpName callbackObj:self selector:@selector(saveNewSongCallback:)];
        }else{
            [self saveSongToId:song.m_id withName:song.m_xmpName];
        }
    }
}

- (void)saveNewSongCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Cloud response id is %i",cloudResponse.m_id);
    
    [self saveSongToId:(long)cloudResponse.m_id withName:cloudResponse.m_xmpName];
}

- (void)saveSongToId:(long)newId withName:(NSString *)name
{
    savingSong.m_id = newId;
    [savingSong renameToName:name andDescription:savingSong.m_description];
    
    DLog(@"Song ID is now %li %@",savingSong.m_id,savingSong);
    
    NSString * songData = [savingSong saveToFile:savingSong.m_xmpName];
    
    [self saveToId:savingSong.m_id withData:songData withName:savingSong.m_xmpName];
    
}

// Samples

- (void)saveSample:(NSSample *)sample withFile:(NSData *)data
{
    // Samples can't currently be renamed, so it's OK to track m_name instead of m_xmpName
    
    DLog(@"Sample is %@",sample);
    
    if(savingSample == nil && sample != nil){
        
        savingSample = sample;
        savingSampleData = data;
        
        if(savingSample.m_xmpFileId <= 0){
            [self saveToNewWithName:sample.m_name callbackObj:self selector:@selector(saveNewSampleCallback:)];
        }else{
            [self saveSampleToId:sample.m_xmpFileId withName:sample.m_name];
        }
    }
}

-(void)saveNewSampleCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Cloud respones id is %i",cloudResponse.m_id);
    
    [self saveSampleToId:(long)cloudResponse.m_id withName:cloudResponse.m_xmpName];
    
    [sampleDelegate customSampleSavedWithId:cloudResponse.m_id andName:cloudResponse.m_xmpName];
}

-(void)saveSampleToId:(long)newId withName:(NSString *)name
{
    savingSample.m_name = name;
    savingSample.m_xmpFileId = newId;
    
    DLog(@"Sample ID is now %li %@",savingSample.m_xmpFileId,savingSample);
    
    [self saveToId:savingSample.m_xmpFileId withFile:savingSampleData withName:savingSample.m_name];
}

// Instruments

- (void)saveInstrument:(NSInstrument *)instrument
{
    DLog(@"Instrument is %@",instrument);
    
    if(savingInstrument == nil && instrument != nil){
        
        savingInstrument = instrument;
        
        if(savingInstrument.m_id <= 0){
            [self saveToNewWithName:instrument.m_name callbackObj:self selector:@selector(saveNewInstrumentCallback:)];
        }else{
            [self saveInstrumentToId:savingInstrument.m_id withName:savingInstrument.m_name];
        }
    }
}

-(void)saveNewInstrumentCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Cloud respones id is %i",cloudResponse.m_id);
    
    [self saveInstrumentToId:(long)cloudResponse.m_id withName:cloudResponse.m_xmpName];
}

-(void)saveInstrumentToId:(long)newId withName:(NSString *)name
{
    savingInstrument.m_name = name;
    savingInstrument.m_id = newId;
    
    DLog(@"Instrument ID is now %li",savingInstrument.m_id);
    
    NSString * instrumentData = [savingInstrument saveToFile:savingInstrument.m_name];
    
    [self saveToId:savingInstrument.m_id withData:instrumentData withName:savingInstrument.m_name];
}


// Generic
- (void)saveToNewWithName:(NSString *)name callbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestNewXmpWithFolderId:0 andName:name andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)saveToId:(NSInteger)xmpId withFile:(NSData *)data withName:(NSString *)name
{
    [ophoCloudController requestSaveXmpWithId:xmpId andXmpFile:data andXmpData:nil andName:name andCallbackObj:self andCallbackSel:@selector(saveCallback:)];
}

- (void)saveToId:(NSInteger)xmpId withData:(NSString *)data withName:(NSString *)name
{
    [ophoCloudController requestSaveXmpWithId:xmpId andXmpFile:nil andXmpData:data andName:name andCallbackObj:self andCallbackSel:@selector(saveCallback:)];
}

- (void)saveCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Opho Callback | Save XMP");
    
    // delete temporary data
    // TODO: beware race conditions
    if(savingSong != nil){
        [savingSong deleteFile];
        savingSong = nil;
        [self loadSongList];
    }
    
    if(savingSequence != nil){
        [savingSequence deleteFile];
        savingSequence = nil;
        [self loadSequenceList];
    }
    
    if(savingSample != nil){
        savingSample = nil;
        savingSampleData = nil;
        [self loadSampleList];
    }
    
    if(savingInstrument != nil){
        [savingInstrument deleteFile];
        savingInstrument = nil;
        [self loadInstrumentList];
    }
    
}

#pragma mark - XMP Rename

- (void)renameSongWithId:(NSInteger)xmpId toName:(NSString *)name
{
    [ophoCloudController requestSetXmpNameWithId:xmpId andName:name andCallbackObj:self andCallbackSel:@selector(renameSongCallback:)];
    
}

- (void)renameSequenceWithId:(NSInteger)xmpId toName:(NSString *)name
{
    [ophoCloudController requestSetXmpNameWithId:xmpId andName:name andCallbackObj:self andCallbackSel:@selector(renameSequenceCallback:)];
}

- (void)renameSongCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Calling song rename callback");
    
    [self loadSongList];
    
}

- (void)renameSequenceCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Calling sequence rename callback");
    
    [self loadSequenceList];
    
}

#pragma mark - XMP Load

- (void)loadFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestGetXmpWithId:xmpId isXmpOnly:false andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)loadSamplesForInstrument:(NSInteger)instrumentId andName:(NSString *)instrumentName andSamples:(NSArray *)samples callbackObj:(id)object selector:(SEL)selector
{
    // Check for an entry
    if([ophoInstruments objectForKey:instrumentName] != nil){
        DLog(@"Instrument already loaded");
        
        [object performSelector:selector withObject:[ophoInstruments objectForKey:[NSNumber numberWithInt:instrumentId]] afterDelay:0.0];
        
        return;
    }
    
    [loadingDelegate loadingBegan];
    
    DLog(@"Load samples from instrument %i, %@",instrumentId,samples);
    
    // Create an entry
    NSMutableArray * instrumentStrings = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"", nil];
    [ophoInstruments setObject:instrumentStrings forKey:[NSNumber numberWithInt:instrumentId]];
    
    [ophoLoadingInstrumentQueue setObject:[NSArray arrayWithObjects:samples,object,NSStringFromSelector(selector), nil] forKey:[NSNumber numberWithInt:instrumentId]];
    
    // Then load al the samples asynchronously
    for(NSSample * sample in samples){
        int xmpId = (sample.m_xmpFileId == 0) ? DEFAULT_STRING_ID : sample.m_xmpFileId;
        sample.m_xmpFileId = DEFAULT_STRING_ID;
        [self loadFromId:xmpId callbackObj:self selector:@selector(addSampleXmpToOphoInstrument:)];
    }
}

- (void)addSampleXmpToOphoInstrument:(CloudResponse *)cloudResponse
{
    NSInteger xmpId = cloudResponse.m_id;
    
    XmlDom * xmp = cloudResponse.m_xmpDom;
    XmlDom * sampleXmp = [xmp getChildWithName:@"sample"];
    
    NSString * datastring = [sampleXmp getText];
    
    DLog(@"Opho Instruments is %@ | %@",ophoInstruments,ophoLoadingInstrumentQueue);
    
    NSMutableArray * keysToRemove = [[NSMutableArray alloc] init];
    
    if([[ophoLoadingInstrumentQueue allKeys] count] == 0){
        // work already done
        return;
    }
    
    for(id instId in ophoLoadingInstrumentQueue){
        
        NSArray * samples = [[ophoLoadingInstrumentQueue objectForKey:instId] objectAtIndex:0];
        id object = [[ophoLoadingInstrumentQueue objectForKey:instId] objectAtIndex:1];
        SEL selector = NSSelectorFromString([[ophoLoadingInstrumentQueue objectForKey:instId] objectAtIndex:2]) ;
        
        for(NSSample * sample in samples){
            
            DLog(@"Attempting samples, %li == %li",(long)xmpId,sample.m_xmpFileId);
            
            if((long)xmpId == sample.m_xmpFileId){
                
                // Stash the sound data
                [[ophoInstruments objectForKey:instId] setObject:datastring atIndexedSubscript:[sample.m_value intValue]];
            }
        }
        
        // If done, empty queue and call delegate
        BOOL isComplete = true;
        for(int i = 0 ; i < STRINGS_ON_GTAR; i++){
            if([[[ophoInstruments objectForKey:instId] objectAtIndex:i] isEqualToString:@""]){
                isComplete = false;
            }
        }
        
        if(isComplete){
            
            [object performSelector:selector withObject:[ophoInstruments objectForKey:instId] afterDelay:0.0];
            [keysToRemove addObject:instId];
        }
    }
    
    [ophoLoadingInstrumentQueue removeObjectsForKeys:keysToRemove];
    
    if([[ophoLoadingInstrumentQueue allKeys] count] == 0){
        [loadingDelegate loadingEnded];
    }
    
}

#pragma mark - XMP Delete

- (void)deleteWithId:(NSInteger)xmpId
{
    DLog(@"Delete with ID %i",xmpId);
    
    [ophoCloudController requestDeleteXmpWithId:xmpId andCallbackObj:self andCallbackSel:@selector(deleteCallback:)];
}

- (void)deleteCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Opho Callback | Delete XMP");
    
    [self regenerateData];
}

#pragma mark - Access Pregenerated XMP Data

- (NSDictionary *)getSongList
{
    NSDictionary * songList = [NSDictionary dictionaryWithObjectsAndKeys:songIdSet,OPHO_LIST_IDS,songLoadSet,OPHO_LIST_NAMES,songDateSet,OPHO_LIST_DATES, nil];
    
    return songList;
}

- (NSDictionary *)getSequenceList
{
    NSDictionary * sequenceList = [NSDictionary dictionaryWithObjectsAndKeys:sequenceIdSet,OPHO_LIST_IDS,sequenceLoadSet,OPHO_LIST_NAMES,sequenceDateSet,OPHO_LIST_DATES, nil];

    return sequenceList;
}

- (NSDictionary *)getSampleList
{
    NSDictionary * sampleList = [NSDictionary dictionaryWithObjectsAndKeys:sampleIdSet,OPHO_LIST_IDS,sampleLoadSet,OPHO_LIST_NAMES,sampleDateSet,OPHO_LIST_DATES, nil];
    
    return sampleList;
}

- (NSDictionary *)getInstrumentList
{
    NSDictionary * instrumentList = [NSDictionary dictionaryWithObjectsAndKeys:instrumentIdSet,OPHO_LIST_IDS,instrumentLoadSet,OPHO_LIST_NAMES,instrumentDateSet,OPHO_LIST_DATES, nil];
    
    return instrumentList;
}

#pragma mark - Pregenerate XMP Data

- (void)regenerateData
{
    [self loadSongList];
    [self loadSequenceList];
    [self loadSampleList];
    [self loadInstrumentList];
    
}

- (void)loadSongList
{
    if(songIdSet == nil){
        songIdSet = [[NSMutableArray alloc] init];
        songLoadSet = [[NSMutableArray alloc] init];
        songDateSet = [[NSMutableArray alloc] init];
    }
        
    [self getSongListForCallbackObj:self selector:@selector(requestGetXmpSongListCallback:)];
}

- (void)loadSequenceList
{
    if(sequenceIdSet == nil){
        sequenceIdSet = [[NSMutableArray alloc] init];
        sequenceLoadSet = [[NSMutableArray alloc] init];
        sequenceDateSet = [[NSMutableArray alloc] init];
    }
    
    [self getSequenceListForCallbackObj:self selector:@selector(requestGetXmpSequenceListCallback:)];
}

- (void)loadSampleList
{
    if(sampleIdSet == nil){
        sampleIdSet = [[NSMutableArray alloc] init];
        sampleLoadSet = [[NSMutableArray alloc] init];
        sampleDateSet = [[NSMutableArray alloc] init];
    }
    
    [self getSampleListForCallbackObj:self selector:@selector(requestGetXmpSampleListCallback:)];
}

- (void)loadInstrumentList
{
    if(instrumentIdSet == nil){
        instrumentIdSet = [[NSMutableArray alloc] init];
        instrumentLoadSet = [[NSMutableArray alloc] init];
        instrumentDateSet = [[NSMutableArray alloc] init];
    }
        
    [self getInstrumentListForCallbackObj:self selector:@selector(requestGetXmpInstrumentListCallback:)];
}

- (void)requestGetXmpSongListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Song List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    [songIdSet removeAllObjects];
    [songLoadSet removeAllObjects];
    [songDateSet removeAllObjects];
    
    [self buildSortedXmpList:xmpList withIds:songIdSet withData:songLoadSet withDates:songDateSet];
}

- (void)requestGetXmpInstrumentListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Instrument List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    [instrumentIdSet removeAllObjects];
    [instrumentLoadSet removeAllObjects];
    [instrumentDateSet removeAllObjects];
    
    [self buildSortedXmpList:xmpList withIds:instrumentIdSet withData:instrumentLoadSet withDates:instrumentDateSet];
    
    [loadingDelegate instrumentListLoaded];
}

- (void)requestGetXmpSequenceListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Sequence List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    [sequenceIdSet removeAllObjects];
    [sequenceLoadSet removeAllObjects];
    [sequenceDateSet removeAllObjects];
    
    [self buildSortedXmpList:xmpList withIds:sequenceIdSet withData:sequenceLoadSet withDates:sequenceDateSet];
    
    // Check that TUTORIAL has been copied over
    BOOL convertTutorialSet = [[NSUserDefaults standardUserDefaults] boolForKey:@"ConvertTutorialSet"];
    
    if(![self defaultSetExists] && !convertTutorialSet){
        [self copyTutorialFile];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"ConvertTutorialSet"];
    }
    
    if(pendingLoadTutorial){
        [self launchPendingTutorial];
    }
    
}

- (void)requestGetXmpSampleListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Sample List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    [sampleIdSet removeAllObjects];
    [sampleLoadSet removeAllObjects];
    [sampleDateSet removeAllObjects];
    
    [self buildSortedXmpList:xmpList withIds:sampleIdSet withData:sampleLoadSet withDates:sampleDateSet];
}

- (BOOL)defaultSetExists
{
    for(NSString * setName in sequenceLoadSet){
        if([setName isEqualToString:DEFAULT_SET_NAME]){
            return TRUE;
        }
    }
    
    return FALSE;
}

- (void)buildSortedXmpList:(NSArray *)xmpList withIds:(NSMutableArray *)fileIdSet withData:(NSMutableArray *)fileLoadSet withDates:(NSMutableArray *)fileDateSet;
{
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for(XmlDom * xmp in xmpList){
        NSInteger xmpid = [[xmp getTextFromChildWithName:@"xmp_id"] intValue];
        NSString * name = [xmp getTextFromChildWithName:@"xmp_name"];
        NSDate * date = [df dateFromString:[xmp getTextFromChildWithName:@"xmp_create_date"]];
        
        DLog(@"Date is %@",date);
        
        if(xmpid > 0){
            [fileIdSet addObject:[NSNumber numberWithInt:xmpid]];
        }
        
        if(name != nil){
            [fileLoadSet addObject:name];
        }
        
        if(date != nil){
            [fileDateSet addObject:date];
        }
    }
    
    DLog(@"FileIdSet %@ FileLoadSet %@ FileDateSet %@",fileIdSet, fileLoadSet,fileDateSet);
    
    // Sort by date order
    if([fileLoadSet count] > 0){
        [self sortFilesByDates:fileDateSet withIds:fileIdSet withData:fileLoadSet];
    }
    
}

// TODO: this can probably be done nicer with comparators
- (void)sortFilesByDates:(NSMutableArray *)fileDateSet withIds:(NSMutableArray *)fileIdSet withData:(NSMutableArray *)fileLoadSet
{
    
    NSString * newFileLoadSet[[fileDateSet count]];
    NSDate * newFileDateSet[[fileDateSet count]];
    NSNumber * newFileIdSet[[fileDateSet count]];
    
    NSDate * maxDate;
    int maxDateIndex;
    
    @synchronized(self){
        for(int i = 0; i < [fileDateSet count]; i++){
            
            maxDateIndex = i;
            maxDate = fileDateSet[i];
            //fileDateSet[j] > maxDate
            for(int j = 0; j < [fileDateSet count]; j++){
                if([(NSDate *)fileDateSet[j] compare:maxDate] == NSOrderedDescending){
                    maxDateIndex = j;
                    maxDate = fileDateSet[j];
                }
            }
            
            newFileDateSet[i] = fileDateSet[maxDateIndex];
            newFileLoadSet[i] = fileLoadSet[maxDateIndex];
            newFileIdSet[i] = fileIdSet[maxDateIndex];
            
            fileDateSet[maxDateIndex] = [NSDate distantPast];
        }
    }
    
    for(int i = 0; i < [fileDateSet count]; i++){
        [fileLoadSet setObject:newFileLoadSet[i] atIndexedSubscript:i];
        [fileDateSet setObject:newFileDateSet[i] atIndexedSubscript:i];
        [fileIdSet setObject:newFileIdSet[i] atIndexedSubscript:i];
    }
}

#pragma mark - Default Tutorial File

- (void)loadTutorialSequenceWhenReady
{
    pendingLoadTutorial = YES;
}

- (void)copyTutorialFile
{
    NSSequence * tutorialSequence = [[NSSequence alloc] initWithXMPFilename:DEFAULT_SET_PATH fromBundle:YES];
    
    [self saveSequence:tutorialSequence];
}

- (void)launchPendingTutorial
{
    pendingLoadTutorial = NO;
    
    NSInteger xmpId;
    
    for(int i = 0; i < [sequenceLoadSet count]; i++){
        if([sequenceLoadSet[i] isEqualToString:DEFAULT_SET_NAME]){
            xmpId = [sequenceIdSet[i] intValue];
        }
    }
    
    [tutorialDelegate tutorialReady:xmpId];
}


@end
