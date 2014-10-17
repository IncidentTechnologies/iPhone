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

#define OPHO_CALL_LOGIN @"OphoCallLogin"
#define OPHO_CALL_LOGOUT @"OphoCallLogout"
#define DEFAULT_SET_PATH @"tutorialSet"

@implementation OphoMaster

extern NSUser * g_loggedInUser;

@synthesize loginDelegate;
@synthesize tutorialDelegate;
@synthesize savingSong;
@synthesize savingSequence;

- (id)init
{
    self = [super init];
    if ( self )
    {
        ophoCloudController = [[OphoCloudController alloc] initWithServer:kServerAddress];
        pendingLoadTutorial = NO;
        
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

#pragma mark - XMP Save
// Sequences
- (void)saveSequence:(NSSequence *)sequence
{   
    if(savingSequence == nil && sequence.m_name != nil && ![sequence.m_name isEqualToString:@""]){
        
        DLog(@"Saving to name %@",sequence.m_name);
        
        savingSequence = sequence;
        
        if(savingSequence.m_id <= 0){
            [self saveToNewWithName:sequence.m_name callbackObj:self selector:@selector(saveNewSequenceCallback:)];
        }else{
            [self saveSequenceToId:sequence.m_id];
        }
        
    }
}

- (void)saveNewSequenceCallback:(CloudResponse *)cloudResponse
{
    [self saveSequenceToId:(long)cloudResponse.m_id];
}

- (void)saveSequenceToId:(long)newId
{
    savingSequence.m_id = newId;
    
    DLog(@"Sequence ID is now %li",savingSequence.m_id);
    
    NSString * sequenceData = [savingSequence saveToFile:savingSequence.m_name];
    
    [self saveToId:savingSequence.m_id withData:sequenceData];
}

// Songs
- (void)saveSong:(NSSong *)song
{
    DLog(@"Song is %@",song);
    
    if(savingSong == nil && song != nil){
        
        savingSong = song;
        
        if(savingSong.m_id <= 0){
            [self saveToNewWithName:song.m_title callbackObj:self selector:@selector(saveNewSongCallback:)];
        }else{
            [self saveSongToId:song.m_id];
        }
        
    }
}

- (void)saveNewSongCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Cloud response id is %i",cloudResponse.m_id);
    
    [self saveSongToId:(long)cloudResponse.m_id];
}

- (void)saveSongToId:(long)newId
{
    savingSong.m_id = newId;
    
    DLog(@"Song ID is now %li %@",savingSong.m_id,savingSong);
    
    NSString * songData = [savingSong saveToFile:savingSong.m_title];
    
    [self saveToId:savingSong.m_id withData:songData];
    
}

// Generic
- (void)saveToNewWithName:(NSString *)name callbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestNewXmpWithFolderId:0 andName:name andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)saveToId:(NSInteger)xmpId withData:(NSString *)data
{
    [ophoCloudController requestSaveXmpWithId:xmpId andXmpFile:nil andXmpData:data andCallbackObj:self andCallbackSel:@selector(saveCallback:)];
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

#pragma mark - XMP Delete

- (void)deleteWithId:(NSInteger)xmpId
{
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

#pragma mark - Pregenerate XMP Data

- (void)regenerateData
{
    [self loadSongList];
    [self loadSequenceList];

}

- (void)loadSongList
{
    songIdSet = [[NSMutableArray alloc] init];
    songLoadSet = [[NSMutableArray alloc] init];
    songDateSet = [[NSMutableArray alloc] init];
    
    [self getSongListForCallbackObj:self selector:@selector(requestGetXmpSongListCallback:)];
}

- (void)loadSequenceList
{
    sequenceIdSet = [[NSMutableArray alloc] init];
    sequenceLoadSet = [[NSMutableArray alloc] init];
    sequenceDateSet = [[NSMutableArray alloc] init];
    
    [self getSequenceListForCallbackObj:self selector:@selector(requestGetXmpSequenceListCallback:)];
}

- (void)requestGetXmpSongListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Song List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    [self buildSortedXmpList:xmpList withIds:songIdSet withData:songLoadSet withDates:songDateSet];
}

- (void)requestGetXmpSequenceListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Sequence List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
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
            
            DLog(@"Max date index %i",maxDateIndex);
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
    NSSequence * tutorialSequence = [[NSSequence alloc] initWithXMPFilename:DEFAULT_SET_PATH];
    
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
