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
@synthesize profileDelegate;

@synthesize rootFolderId;
@synthesize userRootFolderId;
@synthesize userSequenceFolderId;
@synthesize userSampleFolderId;
@synthesize userSongFolderId;
@synthesize userInstrumentFolderId;
@synthesize ophoSequenceFolderId;
@synthesize ophoSampleFolderId;
@synthesize ophoSongFolderId;
@synthesize ophoInstrumentFolderId;
@synthesize ophoUserFolderId;

@synthesize savingSong;
@synthesize savingSongData;
@synthesize savingSequence;
@synthesize savingSample;
@synthesize savingSampleData;
@synthesize savingInstrument;
@synthesize savingInstrumentObject;
@synthesize savingInstrumentSelector;
@synthesize loadingSampleObject;
@synthesize loadingSampleSelector;

- (id)init
{
    self = [super init];
    if ( self )
    {
        ophoCloudController = [[OphoCloudController alloc] initWithServer:ophoServerAddress];
        //pendingLoadTutorial = NO;
        
        ophoInstruments = [[NSMutableDictionary alloc] init];
        ophoLoadingInstrumentQueue = [[NSMutableDictionary alloc] init];
        
        [self loadSampleCache];
        
        savingInstrumentObject = nil;
        
        loggedInAndLoaded = false;
        
        [self resetTutorial];
        
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
        
        DLog(@"Logged in with USER ID %li",cloudResponse.m_responseUserId);
        
        [g_loggedInUser loadWithId:cloudResponse.m_responseUserId Name:cloudResponse.m_cloudRequest.m_username Password:cloudResponse.m_cloudRequest.m_password Email:cloudResponse.m_cloudRequest.m_email Image:cloudResponse.m_responseFileId Profile:cloudResponse.m_responseUserProfile];
        
        [g_loggedInUser cache];
        
        [self loadRootFolderId];
        
        if(!tutorialSkipped){
            [loadingDelegate loadingBegan:YES];
        }
        
    }else{
        
        [loginDelegate loginFailedCallback:cloudResponse.m_statusText];
        
    }
}

- (void)loggedInAndLoaded
{
    if(!loggedInAndLoaded && !tutorialSkipped){
        loggedInAndLoaded = true;
        [loadingDelegate loadingBegan:NO];
    }else{
        [loadingDelegate loadingEnded:NO endLoginLoading:YES];
    }
    
    [loginDelegate loggedInCallback];
    
    [self requestUserProfileImage];
    
    [self regenerateData];
    
    //[self buildDefaultInstrumentsToSaveToOpho];
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
    
    // Clear all the data
    
    [ophoInstruments removeAllObjects];
    [ophoLoadingInstrumentQueue removeAllObjects];
    [songIdSet removeAllObjects];
    [songLoadSet removeAllObjects];
    [songDateSet removeAllObjects];
    [songVersionSet removeAllObjects];
    [songIsCustomSet removeAllObjects];
    [sequenceIdSet removeAllObjects];
    [sequenceLoadSet removeAllObjects];
    [sequenceDateSet removeAllObjects];
    [sequenceVersionSet removeAllObjects];
    [sequenceIsCustomSet removeAllObjects];
    [sampleIdSet removeAllObjects];
    [sampleLoadSet removeAllObjects];
    [sampleDateSet removeAllObjects];
    [sampleVersionSet removeAllObjects];
    [sampleIsCustomSet removeAllObjects];
    [instrumentIdSet removeAllObjects];
    [instrumentLoadSet removeAllObjects];
    [instrumentDateSet removeAllObjects];
    [instrumentVersionSet removeAllObjects];
    [instrumentIsCustomSet removeAllObjects];
    
    // Refresh instrument options
    [loadingDelegate resetState];
    
    // Clear set
    [loadingDelegate createNewSet];
    
    [self resetTutorial];
 
}

- (BOOL)loggedIn
{
    return ophoCloudController.m_loggedIn;
}

- (void)requestUserProfileImage
{
    [ophoCloudController requestUserProfileImage:g_loggedInUser.m_userId andCallbackObj:self andCallbackSel:@selector(requestUserProfileImageCallback:)];
}

- (void)requestUserProfileImageCallback:(CloudResponse *)cloudResponse
{
    g_loggedInUser.m_image = [[UIImage alloc] initWithData:cloudResponse.m_receivedData];
    
    [profileDelegate profileLoaded];
}

- (NSInteger)getUserId
{
    return g_loggedInUser.m_userId;
}

- (UIImage *)getUserProfileImage
{
    return g_loggedInUser.m_image;
}

- (NSString *)getUsername
{
    return g_loggedInUser.m_username;
}

#pragma mark - User Folder

- (void)loadRootFolderId
{
    [ophoCloudController requestGetXmpFolderPublicContentList:1 andXmpType:0 andExcludeType:0 andCallbackObj:self andCallbackSel:@selector(loadRootFolderIdCallback:)];
}

- (void)loadRootChildFolders
{
    [ophoCloudController requestGetXmpFolderPublicContentList:rootFolderId andXmpType:0 andExcludeType:0 andCallbackObj:self andCallbackSel:@selector(loadRootChildFoldersCalback:)];
}

- (void)loadUserFolderId
{
    [ophoCloudController requestGetXmpFolderPublicContentList:ophoUserFolderId andXmpType:0 andExcludeType:0 andCallbackObj:self andCallbackSel:@selector(loadUserFolderIdCallback:)];
}

- (void)loadUserChildFolders
{
    [ophoCloudController requestGetXmpFolderContentList:userRootFolderId andXmpType:0 andExcludeType:0 andUserId:g_loggedInUser.m_userId andCallbackObj:self andCallbackSel:@selector(loadUserChildFoldersCallback:)];
}

- (void)createRootFolderForUser
{
    [ophoCloudController requestNewXmpFolderWithName:OPHO_FOLDER_ROOT andParentFolderId:ophoUserFolderId andXmpType:0 andCallbackObj:self andCallbackSel:@selector(newRootFolderForUser:)];
}

- (void)createChildFolder:(NSString *)name xmpType:(int)xmpType
{
    [ophoCloudController requestNewXmpFolderWithName:name andParentFolderId:userRootFolderId andXmpType:xmpType andCallbackObj:self andCallbackSel:@selector(newChildFolderForUser:)];
}

- (void)loadRootFolderIdCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Root Folder ID Callback: %@", cloudResponse);
    
    rootFolderId = 0;
    
    NSArray * folderList = cloudResponse.m_folderList;
    
    for(XmlDom * folder in folderList){
        NSInteger folderid = [[folder getTextFromChildWithName:@"xmp_folder_id"] intValue];
        NSInteger userid = [[folder getTextFromChildWithName:@"user_id"] intValue];
        NSString * foldername = [folder getTextFromChildWithName:@"xmp_folder_name"];
        
        if(userid == 1 && [foldername isEqualToString:OPHO_FOLDER_ROOT]){
            rootFolderId = folderid;
            [self loadRootChildFolders];
        }
    }
    
    DLog(@"root folder id is %i",rootFolderId);

}

- (void)loadRootChildFoldersCalback:(CloudResponse *)cloudResponse
{
    DLog(@"Root Child Folders Callback: %@",cloudResponse);
    
    NSArray * folderList = cloudResponse.m_folderList;
    
    for(XmlDom * folder in folderList){
        NSInteger folderid = [[folder getTextFromChildWithName:@"xmp_folder_id"] intValue];
        NSInteger userid = [[folder getTextFromChildWithName:@"user_id"] intValue];
        NSString * foldername = [folder getTextFromChildWithName:@"xmp_folder_name"];
        
        if(userid == 1 && [foldername isEqualToString:OPHO_FOLDER_USER]){
            ophoUserFolderId = folderid;
            [self loadUserFolderId];
        }else if([foldername isEqualToString:OPHO_FOLDER_SEQUENCE]){
            ophoSequenceFolderId = folderid;
        }else if([foldername isEqualToString:OPHO_FOLDER_SAMPLE]){
            ophoSampleFolderId = folderid;
        }else if([foldername isEqualToString:OPHO_FOLDER_SONG]){
            ophoSongFolderId = folderid;
        }else if([foldername isEqualToString:OPHO_FOLDER_INSTRUMENT]){
            ophoInstrumentFolderId = folderid;
        }
    }
    
    DLog(@"opho folder ids user=%li sequence=%li sample=%li song=%li instrument=%li",ophoUserFolderId,ophoSequenceFolderId,ophoSampleFolderId,ophoSongFolderId,ophoInstrumentFolderId);
    
}


- (void)loadUserFolderIdCallback:(CloudResponse *)cloudResponse
{
    DLog(@"User Folder ID Callback: %@",cloudResponse);
    
    userRootFolderId = 0;
    
    NSArray * folderList = cloudResponse.m_folderList;
    
    for(XmlDom * folder in folderList){
        NSInteger folderid = [[folder getTextFromChildWithName:@"xmp_folder_id"] intValue];
        NSInteger userid = [[folder getTextFromChildWithName:@"user_id"] intValue];
        NSString * foldername = [folder getTextFromChildWithName:@"xmp_folder_name"];
        
        if(userid == [self getUserId] && [foldername isEqualToString:OPHO_FOLDER_ROOT]){
            userRootFolderId = folderid;
            [self loadUserChildFolders];
        }
    }
    
    DLog(@"user root folder id is %i",userRootFolderId);
    
    if(userRootFolderId == 0){
        [self createRootFolderForUser];
    }
}

- (void)loadUserChildFoldersCallback:(CloudResponse *)cloudResponse
{
    DLog(@"User Child Folders ID Callback: %@",cloudResponse);
    
    userSequenceFolderId = 0;
    userSampleFolderId = 0;
    userSongFolderId = 0;
    userInstrumentFolderId = 0;
    
    NSInteger activeUserId = [self getUserId];
    
    NSArray * folderList = cloudResponse.m_folderList;
    
    for(XmlDom * folder in folderList){
        NSInteger folderid = [[folder getTextFromChildWithName:@"xmp_folder_id"] intValue];
        NSInteger userid = [[folder getTextFromChildWithName:@"user_id"] intValue];
        NSString * foldername = [folder getTextFromChildWithName:@"xmp_folder_name"];
        
        if(activeUserId == userid && [foldername isEqualToString:OPHO_FOLDER_SEQUENCE]){
            userSequenceFolderId = folderid;
        }else if(activeUserId == userid && [foldername isEqualToString:OPHO_FOLDER_SAMPLE]){
            userSampleFolderId = folderid;
        }else if(activeUserId == userid && [foldername isEqualToString:OPHO_FOLDER_SONG]){
            userSongFolderId = folderid;
        }else if(activeUserId == userid && [foldername isEqualToString:OPHO_FOLDER_INSTRUMENT]){
            userInstrumentFolderId = folderid;
        }
    }
    
    DLog(@"child ids are sequence=%li sample=%li song=%li instrument=%li",userSequenceFolderId,userSampleFolderId,userSongFolderId,userInstrumentFolderId);
    
    if(userSequenceFolderId == 0){
        [self createChildFolder:OPHO_FOLDER_SEQUENCE xmpType:OphoXmpTypeAppDefined];
    }
    
    if(userSampleFolderId == 0){
        [self createChildFolder:OPHO_FOLDER_SAMPLE xmpType:OphoXmpTypeXMPSample];
    }
    
    if(userSongFolderId == 0){
        [self createChildFolder:OPHO_FOLDER_SONG xmpType:OphoXmpTypeSong];
    }
    
    if(userInstrumentFolderId == 0){
        [self createChildFolder:OPHO_FOLDER_INSTRUMENT xmpType:OphoXmpTypeXMPInstrument];
    }
    
    if(userSequenceFolderId > 0 && userSampleFolderId > 0 && userSongFolderId > 0 && userInstrumentFolderId > 0){
        [self loggedInAndLoaded];
    }
    
}

- (void)newRootFolderForUser:(CloudResponse *)cloudResponse;
{
    userRootFolderId = cloudResponse.m_folderId;
    
    DLog(@"user root folder id is %i",userRootFolderId);
    
    [self loadUserChildFolders];
    
}

- (void)newChildFolderForUser:(CloudResponse *)cloudResponse
{
    if(cloudResponse.m_xmpType == OphoXmpTypeAppDefined){
        userSequenceFolderId = cloudResponse.m_folderId;
        DLog(@"user child id is sequence=%li",userSequenceFolderId);
    }else if(cloudResponse.m_xmpType == OphoXmpTypeXMPSample){
        userSampleFolderId = cloudResponse.m_folderId;
        DLog(@"user child id is sample=%li",userSampleFolderId);
    }else if(cloudResponse.m_xmpType == OphoXmpTypeSong){
        userSongFolderId = cloudResponse.m_folderId;
        DLog(@"user child id is song=%li",userSongFolderId);
    }else if(cloudResponse.m_xmpType == OphoXmpTypeXMPInstrument){
        userInstrumentFolderId = cloudResponse.m_folderId;
        DLog(@"user child id is instrument=%li",userInstrumentFolderId);
    }else{
        DLog(@"Created new child folder with type %i",cloudResponse.m_xmpType);
    }
    
    if(userSequenceFolderId > 0 && userSampleFolderId > 0 && userSongFolderId > 0 && userInstrumentFolderId > 0){
        [self loggedInAndLoaded];
    }
    
}

#pragma mark - XMP Lists

- (void)getSongListForCallbackObj:(id)callbackObj selector:(SEL)selector isCustom:(BOOL)isCustom
{
    NSInteger folderId = (isCustom) ? userSongFolderId : ophoSongFolderId;
    
    NSInteger userId = (isCustom) ? g_loggedInUser.m_userId : 1;
    
    [ophoCloudController requestGetXmpFolderContentList:folderId andXmpType:OphoXmpTypeSong andExcludeType:0 andUserId:userId andCallbackObj:callbackObj andCallbackSel:selector];
    
}

- (void)getSequenceListForCallbackObj:(id)callbackObj selector:(SEL)selector isCustom:(BOOL)isCustom
{
    NSInteger folderId = (isCustom) ? userSequenceFolderId : ophoSequenceFolderId;
    
    NSInteger userId = (isCustom) ? g_loggedInUser.m_userId : 1;
    
    [ophoCloudController requestGetXmpFolderContentList:folderId andXmpType:OphoXmpTypeAppDefined andExcludeType:0 andUserId:userId andCallbackObj:callbackObj andCallbackSel:selector];
    
}

- (void)getSampleListForCallbackObj:(id)callbackObj selector:(SEL)selector isCustom:(BOOL)isCustom
{
    NSInteger folderId = (isCustom) ? userSampleFolderId : ophoSampleFolderId;
    
    NSInteger userId = (isCustom) ? g_loggedInUser.m_userId : 1;
    
    [ophoCloudController requestGetXmpFolderContentList:folderId andXmpType:OphoXmpTypeXMPSample andExcludeType:0 andUserId:userId andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)getInstrumentListForCallbackObj:(id)callbackObj selector:(SEL)selector isCustom:(BOOL)isCustom
{
    NSInteger folderId = (isCustom) ? userInstrumentFolderId : ophoInstrumentFolderId;
    
    NSInteger userId = (isCustom) ? g_loggedInUser.m_userId : 1;
    
    [ophoCloudController requestGetXmpFolderContentList:folderId andXmpType:OphoXmpTypeXMPInstrument andExcludeType:0 andUserId:userId andCallbackObj:callbackObj andCallbackSel:selector];
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
            [self saveToNewWithName:sequence.m_xmpName folderId:userSequenceFolderId callbackObj:self selector:@selector(saveNewSequenceCallback:)];
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
    
    // Only save samples for the default set
    BOOL saveWithSamples = NO;
    //BOOL saveWithSamples = ([name isEqualToString:DEFAULT_SET_NAME]) ? YES : NO;
    
    NSString * sequenceData = [savingSequence saveToFile:savingSequence.m_name saveWithSamples:saveWithSamples];
    
    [self saveToId:savingSequence.m_id withFile:nil withData:sequenceData withName:savingSequence.m_name];
}

// Songs
- (void)saveSong:(NSSong *)song withFile:(NSData *)filedata
{
    DLog(@"Song is %@",song);
    
    if(savingSong == nil && song != nil){
        
        savingSong = song;
        savingSongData = filedata;
        
        if(savingSong.m_id <= 0){
            [self saveToNewWithName:song.m_xmpName folderId:userSongFolderId callbackObj:self selector:@selector(saveNewSongCallback:)];
        }else{
            [self saveSongToId:song.m_id withFile:filedata withName:song.m_xmpName];
        }
    }
}

- (void)saveNewSongCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Cloud response id is %i",cloudResponse.m_id);
    
    [self saveSongToId:(long)cloudResponse.m_id withFile:savingSongData withName:cloudResponse.m_xmpName];
}

- (void)saveSongToId:(long)newId withFile:(NSData *)filedata withName:(NSString *)name
{
    savingSong.m_id = newId;
    [savingSong renameToName:name andDescription:savingSong.m_description];
    
    DLog(@"Song ID is now %li %@",savingSong.m_id,savingSong);
    
    NSString * songdatastring = [savingSong saveToFile:savingSong.m_xmpName];
    
    [self saveToId:savingSong.m_id withFile:nil withData:songdatastring withName:savingSong.m_xmpName];
    
    if(savingSongData != nil){
        [self saveSongRender:savingSong.m_id withFile:savingSongData];
    }
}

- (void)saveSongRender:(long)xmpId withFile:(NSData *)filedata
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ophoCloudController requestSetXmpRenderWithId:xmpId andName:[savingSong.m_xmpName stringByAppendingString:@".wav"] andRenderBlob:filedata andCallbackObj:self andCallbackSel:@selector(saveSongRenderCallback:)];
    });
}

- (void)saveSongRenderCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Save Song Render Callback");
    
}

// Samples

- (void)saveSample:(NSSample *)sample withFile:(NSData *)filedata
{
    // Samples can't currently be renamed, so it's OK to track m_name instead of m_xmpName
    
    DLog(@"Sample is %@",sample);
    
    if(savingSample == nil && sample != nil){
        
        savingSample = sample;
        savingSampleData = filedata;
        
        if(savingSample.m_xmpFileId <= 0){
            [self saveToNewWithName:sample.m_name folderId:userSampleFolderId callbackObj:self selector:@selector(saveNewSampleCallback:)];
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
    
    [self saveToId:savingSample.m_xmpFileId withFile:savingSampleData withData:nil withName:savingSample.m_name];
    
}

- (void)saveOphoSample:(NSTimer *)timer
{
    NSString * sampleName = [timer userInfo];
    
    DLog(@"Save opho sample with name %@",sampleName);
    
    NSString * newPath = [[NSBundle mainBundle] pathForResource:sampleName ofType:@"wav"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:newPath];
    NSSample * xmpSample = [[NSSample alloc] initWithName:[sampleName stringByAppendingString:@".wav"] custom:NO value:@"0" externalId:@"" xmpFileId:0];
    [g_ophoMaster saveSample:xmpSample withFile:data];
    
}
// Instruments
/*
- (void)buildDefaultInstrumentsToSaveToOpho
{
 
     [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(saveOphoSample:) userInfo:@"WubWub_Kick" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(saveOphoSample:) userInfo:@"WubWub_Clap" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(saveOphoSample:) userInfo:@"WubWub_Arp" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:18.0 target:self selector:@selector(saveOphoSample:) userInfo:@"WubWub_Airhorn" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:24.0 target:self selector:@selector(saveOphoSample:) userInfo:@"WubWub_BassSynth" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(saveOphoSample:) userInfo:@"WubWub_Womp" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:36.0 target:self selector:@selector(saveOphoSample:) userInfo:@"Sounds_I'mBacon" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:42.0 target:self selector:@selector(saveOphoSample:) userInfo:@"Sounds_I'm" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:48.0 target:self selector:@selector(saveOphoSample:) userInfo:@"Sounds_Ba-" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:54.0 target:self selector:@selector(saveOphoSample:) userInfo:@"Sounds_-con" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(saveOphoSample:) userInfo:@"Sounds_Bacon" repeats:NO];
     
     [NSTimer scheduledTimerWithTimeInterval:66.0 target:self selector:@selector(saveOphoSample:) userInfo:@"Sounds_ReverseI'mBacon" repeats:NO];
 
    
    // TODO: change to open permission
    
    NSInstrument * juno = [[NSInstrument alloc] initWithName:@"JUNO" id:4 iconName:nil isCustom:NO];
    [juno.m_sampler addSample:[[NSSample alloc] initWithName:@"Juno_C" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:43]];
    [juno.m_sampler addSample:[[NSSample alloc] initWithName:@"Juno_D" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:41]];
    [juno.m_sampler addSample:[[NSSample alloc] initWithName:@"Juno_E" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:39]];
    [juno.m_sampler addSample:[[NSSample alloc] initWithName:@"Juno_G" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:36]];
    [juno.m_sampler addSample:[[NSSample alloc] initWithName:@"Juno_A" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:34]];
    [juno.m_sampler addSample:[[NSSample alloc] initWithName:@"Juno_B" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:32]];
    
    //[self saveInstrument:juno];
    
    NSInstrument * guitar = [[NSInstrument alloc] initWithName:@"GUITAR" id:6 iconName:nil isCustom:NO];
    [guitar.m_sampler addSample:[[NSSample alloc] initWithName:@"Guitar_C" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:91]];
    [guitar.m_sampler addSample:[[NSSample alloc] initWithName:@"Guitar_D" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:89]];
    [guitar.m_sampler addSample:[[NSSample alloc] initWithName:@"Guitar_E" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:87]];
    [guitar.m_sampler addSample:[[NSSample alloc] initWithName:@"Guitar_G" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:78]];
    [guitar.m_sampler addSample:[[NSSample alloc] initWithName:@"Guitar_A" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:76]];
    [guitar.m_sampler addSample:[[NSSample alloc] initWithName:@"Guitar_B" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:74]];
    
    //[self saveInstrument:guitar];
    
    NSInstrument * piano = [[NSInstrument alloc] initWithName:@"PIANO" id:7 iconName:nil isCustom:NO];
    [piano.m_sampler addSample:[[NSSample alloc] initWithName:@"Piano_C" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:112]];
    [piano.m_sampler addSample:[[NSSample alloc] initWithName:@"Piano_D" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:110]];
    [piano.m_sampler addSample:[[NSSample alloc] initWithName:@"Piano_E" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:108]];
    [piano.m_sampler addSample:[[NSSample alloc] initWithName:@"Piano_G" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:105]];
    [piano.m_sampler addSample:[[NSSample alloc] initWithName:@"Piano_A" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:103]];
    [piano.m_sampler addSample:[[NSSample alloc] initWithName:@"Piano_B" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:101]];
    
    //[self saveInstrument:piano];
    
    NSInstrument * violin = [[NSInstrument alloc] initWithName:@"VIOLIN" id:8 iconName:nil isCustom:NO];
    [violin.m_sampler addSample:[[NSSample alloc] initWithName:@"Violin_C" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:124]];
    [violin.m_sampler addSample:[[NSSample alloc] initWithName:@"Violin_D" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:122]];
    [violin.m_sampler addSample:[[NSSample alloc] initWithName:@"Violin_E" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:120]];
    [violin.m_sampler addSample:[[NSSample alloc] initWithName:@"Violin_G" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:117]];
    [violin.m_sampler addSample:[[NSSample alloc] initWithName:@"Violin_A" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:115]];
    [violin.m_sampler addSample:[[NSSample alloc] initWithName:@"Violin_B" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:113]];
    
    //[self saveInstrument:violin];
    
    NSInstrument * vibraphone = [[NSInstrument alloc] initWithName:@"VIBRAPHONE" id:9 iconName:nil isCustom:NO];
    [vibraphone.m_sampler addSample:[[NSSample alloc] initWithName:@"Vibraphone_C" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:136]];
    [vibraphone.m_sampler addSample:[[NSSample alloc] initWithName:@"Vibraphone_D" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:134]];
    [vibraphone.m_sampler addSample:[[NSSample alloc] initWithName:@"Vibraphone_E" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:132]];
    [vibraphone.m_sampler addSample:[[NSSample alloc] initWithName:@"Vibraphone_G" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:129]];
    [vibraphone.m_sampler addSample:[[NSSample alloc] initWithName:@"Vibraphone_A" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:127]];
    [vibraphone.m_sampler addSample:[[NSSample alloc] initWithName:@"Vibraphone_B" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:125]];
    
    //[self saveInstrument:vibraphone];
    
    NSInstrument * chiptune = [[NSInstrument alloc] initWithName:@"CHIPTUNE" id:10 iconName:nil isCustom:NO];
    [chiptune.m_sampler addSample:[[NSSample alloc] initWithName:@"Chiptune_Kick" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:245]];
    [chiptune.m_sampler addSample:[[NSSample alloc] initWithName:@"Chiptune_Snare" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:246]];
    [chiptune.m_sampler addSample:[[NSSample alloc] initWithName:@"Chiptune_Siren" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:247]];
    [chiptune.m_sampler addSample:[[NSSample alloc] initWithName:@"Chiptune_Beep" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:248]];
    [chiptune.m_sampler addSample:[[NSSample alloc] initWithName:@"Chiptune_Triangle" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:249]];
    [chiptune.m_sampler addSample:[[NSSample alloc] initWithName:@"Chiptune_Lazer" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:250]];
    
    //[self saveInstrument:chiptune];
    
    NSInstrument * pluck = [[NSInstrument alloc] initWithName:@"PLUCK" id:11 iconName:nil isCustom:NO];
    [pluck.m_sampler addSample:[[NSSample alloc] initWithName:@"Pluck_C" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:148]];
    [pluck.m_sampler addSample:[[NSSample alloc] initWithName:@"Pluck_D" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:146]];
    [pluck.m_sampler addSample:[[NSSample alloc] initWithName:@"Pluck_E" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:144]];
    [pluck.m_sampler addSample:[[NSSample alloc] initWithName:@"Pluck_G" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:141]];
    [pluck.m_sampler addSample:[[NSSample alloc] initWithName:@"Pluck_A" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:139]];
    [pluck.m_sampler addSample:[[NSSample alloc] initWithName:@"Pluck_B" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:137]];
    
    //[self saveInstrument:pluck];
    
    NSInstrument * doublebass = [[NSInstrument alloc] initWithName:@"DOUBLE BASS" id:12 iconName:nil isCustom:NO];
    [doublebass.m_sampler addSample:[[NSSample alloc] initWithName:@"DoubleBass_C" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:160]];
    [doublebass.m_sampler addSample:[[NSSample alloc] initWithName:@"DoubleBass_D" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:158]];
    [doublebass.m_sampler addSample:[[NSSample alloc] initWithName:@"DoubleBass_E" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:156]];
    [doublebass.m_sampler addSample:[[NSSample alloc] initWithName:@"DoubleBass_G" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:153]];
    [doublebass.m_sampler addSample:[[NSSample alloc] initWithName:@"DoubleBass_A" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:151]];
    [doublebass.m_sampler addSample:[[NSSample alloc] initWithName:@"DoubleBass_B" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:149]];
    
    //[self saveInstrument:doublebass];
    
    NSInstrument * eight = [[NSInstrument alloc] initWithName:@"808" id:13 iconName:nil isCustom:NO];
    [eight.m_sampler addSample:[[NSSample alloc] initWithName:@"808_Kick" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:239]];
    [eight.m_sampler addSample:[[NSSample alloc] initWithName:@"808_Snare" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:240]];
    [eight.m_sampler addSample:[[NSSample alloc] initWithName:@"808_ClosedHat" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:241]];
    [eight.m_sampler addSample:[[NSSample alloc] initWithName:@"808_OpenHat" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:242]];
    [eight.m_sampler addSample:[[NSSample alloc] initWithName:@"808_Tom" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:243]];
    [eight.m_sampler addSample:[[NSSample alloc] initWithName:@"808_Clap" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:244]];
    
    //[self saveInstrument:eight];
    
    NSInstrument * house = [[NSInstrument alloc] initWithName:@"HOUSE" id:14 iconName:nil isCustom:NO];
    [house.m_sampler addSample:[[NSSample alloc] initWithName:@"House_Kick" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:257]];
    [house.m_sampler addSample:[[NSSample alloc] initWithName:@"House_Clap" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:258]];
    [house.m_sampler addSample:[[NSSample alloc] initWithName:@"House_ClosedHat" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:259]];
    [house.m_sampler addSample:[[NSSample alloc] initWithName:@"House_OpenHat" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:260]];
    [house.m_sampler addSample:[[NSSample alloc] initWithName:@"House_Snare" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:261]];
    [house.m_sampler addSample:[[NSSample alloc] initWithName:@"House_WoodBlock" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:262]];
    
    //[self saveInstrument:house];
    
    NSInstrument * rock = [[NSInstrument alloc] initWithName:@"ROCK" id:15 iconName:nil isCustom:NO];
    [rock.m_sampler addSample:[[NSSample alloc] initWithName:@"Rock_Kick" custom:NO value:@"0" externalId:@"sample_0" xmpFileId:233]];
    [rock.m_sampler addSample:[[NSSample alloc] initWithName:@"Rock_Snare" custom:NO value:@"1" externalId:@"sample_1" xmpFileId:234]];
    [rock.m_sampler addSample:[[NSSample alloc] initWithName:@"Rock_ClosedHat" custom:NO value:@"2" externalId:@"sample_2" xmpFileId:235]];
    [rock.m_sampler addSample:[[NSSample alloc] initWithName:@"Rock_OpenHat" custom:NO value:@"3" externalId:@"sample_3" xmpFileId:236]];
    [rock.m_sampler addSample:[[NSSample alloc] initWithName:@"Rock_Tom" custom:NO value:@"4" externalId:@"sample_4" xmpFileId:237]];
    [rock.m_sampler addSample:[[NSSample alloc] initWithName:@"Rock_Crash" custom:NO value:@"5" externalId:@"sample_5" xmpFileId:238]];
    
    //[self saveInstrument:rock];
    
}
 */

- (void)saveInstrument:(NSInstrument *)instrument
{
    DLog(@"Instrument is %@",instrument);
    
    if(savingInstrument == nil && instrument != nil){
        
        savingInstrument = instrument;
        
        if(savingInstrument.m_id <= 0){
            [self saveToNewWithName:instrument.m_name folderId:userInstrumentFolderId callbackObj:self selector:@selector(saveNewInstrumentCallback:)];
        }else{
            [self saveInstrumentToId:savingInstrument.m_id withName:savingInstrument.m_name];
        }
    }
}

- (void)saveNewInstrument:(NSInstrument *)instrument callbackObj:(id)object selector:(SEL)selector
{
    if(savingInstrument == nil && instrument != nil){
        
        savingInstrumentObject = object;
        savingInstrumentSelector = NSStringFromSelector(selector);
        
        [self saveInstrument:instrument];
    }
}

-(void)saveNewInstrumentCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Cloud respones id is %li",cloudResponse.m_id);
    
    [self saveInstrumentToId:(long)cloudResponse.m_id withName:cloudResponse.m_xmpName];
    
    if(savingInstrumentObject != nil){
        
        NSArray * savedInstArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithLong:cloudResponse.m_id],cloudResponse.m_xmpName, nil];
        
        [savingInstrumentObject performSelector:NSSelectorFromString(savingInstrumentSelector) withObject:savedInstArray];
        
        savingInstrumentObject = nil;
    }
}

-(void)saveInstrumentToId:(long)newId withName:(NSString *)name
{
    savingInstrument.m_name = name;
    savingInstrument.m_id = newId;
    
    DLog(@"Instrument ID is now %li",savingInstrument.m_id);
    
    NSString * instrumentData = [savingInstrument saveToFile:savingInstrument.m_name saveWithSamples:YES];
    
    [self saveToId:savingInstrument.m_id withFile:nil withData:instrumentData withName:savingInstrument.m_name];
}


// Generic
- (void)saveToNewWithName:(NSString *)name folderId:(NSInteger)folderId callbackObj:(id)callbackObj selector:(SEL)selector
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ophoCloudController requestNewXmpWithFolderId:folderId andName:name andCallbackObj:callbackObj andCallbackSel:selector];
    });
}

- (void)saveToId:(NSInteger)xmpId withFile:(NSData *)filedata withData:(NSString *)datastring withName:(NSString *)name
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ophoCloudController requestSaveXmpWithId:xmpId andXmpFileData:filedata andXmpDataString:datastring andName:name andCallbackObj:self andCallbackSel:@selector(saveCallback:)];
    });
}

- (void)saveCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Opho Callback | Save XMP");
    
    // delete temporary data
    // TODO: beware race conditions
    if(savingSong != nil){
        [savingSong deleteFile];
        savingSong = nil;
        savingSongData = nil;
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ophoCloudController requestSetXmpNameWithId:xmpId andName:name andCallbackObj:self andCallbackSel:@selector(renameSongCallback:)];
    });
    
}

- (void)renameSequenceWithId:(NSInteger)xmpId toName:(NSString *)name
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ophoCloudController requestSetXmpNameWithId:xmpId andName:name andCallbackObj:self andCallbackSel:@selector(renameSequenceCallback:)];
    });
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

// Load anything by ID
- (void)loadFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestGetXmpWithId:xmpId isXmpOnly:false andCallbackObj:callbackObj andCallbackSel:selector];
}

// Load an individual sample by ID, from cache if available
- (void)loadSampleFromId:(NSInteger)xmpId callbackObj:(id)callbackObj selector:(SEL)selector
{
    NSString * cachedSample = [self getSampleFromCache:xmpId];
    
    loadingSampleObject = callbackObj;
    loadingSampleSelector = NSStringFromSelector(selector);
    
    if(cachedSample == nil){
        // TODO: check loadingSampleObject is nil
        DLog(@"Loading sample from ID %li",xmpId);
        [self loadFromId:xmpId callbackObj:self selector:@selector(loadSampleCallback:)];
    }else{
        DLog(@"Loading sample from cache %li",xmpId);
        [callbackObj performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:cachedSample,@"Data",[NSNumber numberWithInt:xmpId],@"Id", nil]];
    }
}

// Callback to save to cache and call pending callback
- (void)loadSampleCallback:(CloudResponse *)cloudResponse
{
    NSInteger xmpId = cloudResponse.m_id;
    
    XmlDom * xmp = cloudResponse.m_xmpDom;
    XmlDom * sampleXmp = [xmp getChildWithName:@"sample"];
    
    NSString * datastring = [sampleXmp getText];
    
    if(loadingSampleObject != nil){
        [loadingSampleObject performSelector:NSSelectorFromString(loadingSampleSelector) withObject:[NSDictionary dictionaryWithObjectsAndKeys:datastring,@"Data",[NSNumber numberWithInt:xmpId],@"Id", nil]];
     
        loadingSampleObject = nil;
    }
    
    if([self getSampleFromCache:xmpId] == nil){
        long index = [sampleIdSet indexOfObject:[NSNumber numberWithLong:xmpId]];
        int version = [[sampleVersionSet objectAtIndex:index] intValue];
        
        [self cacheSample:datastring forSampleId:xmpId withVersion:version];
    }
}

- (void)prepareToLoadSamples:(int)numSamples
{
    samplesToLoad = numSamples;
    samplesLoaded = 0;
    
    DLog(@"Prepare to load %f samples, %f samples loaded",samplesToLoad,samplesLoaded);
}

- (void)loadSamplesForInstrument:(NSInteger)instrumentId andName:(NSString *)instrumentName andSamples:(NSArray *)samples callbackObj:(id)object selector:(SEL)selector
{
    // Check for an entry
    if([ophoInstruments objectForKey:instrumentName] != nil){
        DLog(@"Instrument already loaded");
        
        [object performSelector:selector withObject:[ophoInstruments objectForKey:[NSNumber numberWithLong:instrumentId]] afterDelay:0.0];
        
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingDelegate loadingBegan:NO];
    });
    
    DLog(@"Load samples from instrument %li, %@",instrumentId,samples);
    
    // Create an entry
    NSMutableArray * instrumentStrings = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"", nil];
    [ophoInstruments setObject:instrumentStrings forKey:[NSNumber numberWithLong:instrumentId]];
    
    [ophoLoadingInstrumentQueue setObject:[NSArray arrayWithObjects:samples,object,NSStringFromSelector(selector), nil] forKey:[NSNumber numberWithLong:instrumentId]];
    
    // Then load al the samples asynchronously
    for(NSSample * sample in samples){
        long xmpId = (sample.m_xmpFileId == 0) ? DEFAULT_SAMPLE_ID : sample.m_xmpFileId;
        sample.m_xmpFileId = xmpId;
        
        NSString * cachedSample = [self getSampleFromCache:sample.m_xmpFileId];
        
        if(cachedSample != nil){
            DLog(@"Loading sample from cache %li",sample.m_xmpFileId);
            [self addData:cachedSample forLoadingInstrumentSample:sample.m_xmpFileId];
        }else if(sample.m_sampleData != nil && [sample.m_sampleData length] > 0){
            DLog(@"Loading sample from sampleData for ID %li",sample.m_xmpFileId);
            [self addData:sample.m_sampleData forLoadingInstrumentSample:sample.m_xmpFileId];
            
            // Also cache it
            [self cacheSample:sample.m_sampleData forSampleId:sample.m_xmpFileId withVersion:1];
        }else{
            DLog(@"Loading sample from ID %li",sample.m_xmpFileId);
            [self loadFromId:sample.m_xmpFileId callbackObj:self selector:@selector(addSampleXmpToOphoInstrument:)];
        }
    }
}


- (void)addSampleXmpToOphoInstrument:(CloudResponse *)cloudResponse
{
    NSInteger xmpId = cloudResponse.m_id;
    
    DLog(@"attempting to add sample %i to opho instrument",xmpId);
    
    if(xmpId > 0){
        
        XmlDom * xmp = cloudResponse.m_xmpDom;
        XmlDom * sampleXmp = [xmp getChildWithName:@"sample"];
        
        NSString * datastring = [sampleXmp getText];
        
        [self addData:datastring forLoadingInstrumentSample:xmpId];
        
        if([self getSampleFromCache:xmpId] == nil && xmpId >= 0){
            long index = [sampleIdSet indexOfObject:[NSNumber numberWithLong:xmpId]];
            int version = [[sampleVersionSet objectAtIndex:index] intValue];
            
            [self cacheSample:datastring forSampleId:xmpId withVersion:version];
        }
        
    }else{
        
        NSInteger expectedXmpId = cloudResponse.m_cloudRequest.m_xmpId;
        
        [self alertSampleMissing];
        
        [self addData:MISSING_SAMPLE_DATA forLoadingInstrumentSample:expectedXmpId];
        
    }
}

- (void)alertSampleMissing
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sample Missing" message:[NSString stringWithFormat:@"One of your samples has been removed and may not play."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

- (void)addData:(NSString *)datastring forLoadingInstrumentSample:(long)xmpId
{
    //DLog(@"Opho Instruments is %@ | %@",ophoInstruments,ophoLoadingInstrumentQueue);
    
    NSLog(@"Opho loading instruments queue count is %li, d:%@",[[ophoLoadingInstrumentQueue allKeys] count],ophoLoadingInstrumentQueue);
    
    if([[ophoLoadingInstrumentQueue allKeys] count] == 0 && samplesLoaded >= samplesToLoad){
        // work already done
    
        DLog(@"Return early");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingDelegate loadingEnded:NO endLoginLoading:NO];
        });
        
        return;
    }
    
    if(datastring == nil || [datastring length] == 0){
        DLog(@"Trying to build an empty sample");
        return;
    }
    
    @synchronized(ophoLoadingInstrumentQueue){
        
        NSArray * keys = [ophoLoadingInstrumentQueue allKeys];
        
        for(id instId in keys){
            
            // Ensure if it's already complete it's skipped
            BOOL isComplete = true;
            for(int i = 0 ; i < STRINGS_ON_GTAR; i++){
                if([[[ophoInstruments objectForKey:instId] objectAtIndex:i] isEqualToString:@""]){
                    
                    isComplete = false;
                }
            }
            
            if(isComplete){
                // Count all loaded
                [ophoLoadingInstrumentQueue removeObjectForKey:instId];
                continue;
            }
            
            NSArray * samples = [[ophoLoadingInstrumentQueue objectForKey:instId] objectAtIndex:0];
            id object = [[ophoLoadingInstrumentQueue objectForKey:instId] objectAtIndex:1];
            SEL selector = NSSelectorFromString([[ophoLoadingInstrumentQueue objectForKey:instId] objectAtIndex:2]) ;
            
            for(NSSample * sample in samples){
                
                if((long)xmpId == sample.m_xmpFileId){
                    samplesLoaded++;
                    [[ophoInstruments objectForKey:instId] setObject:datastring atIndexedSubscript:[sample.m_value intValue]];
                }
            }
            
            // If done, empty queue and call delegate
            isComplete = true;
            double completeCount = 0;
            for(int i = 0 ; i < STRINGS_ON_GTAR; i++){
                if([[[ophoInstruments objectForKey:instId] objectAtIndex:i] isEqualToString:@""]){
                    isComplete = false;
                }else{
                    completeCount++;
                }
            }
            
            if(isComplete){
                [object performSelector:selector withObject:[ophoInstruments objectForKey:instId]];
                [ophoLoadingInstrumentQueue removeObjectForKey:instId];
            }
        }
        
        // Display % loaded
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingDelegate setLoadingPercentage:samplesLoaded/samplesToLoad];
        });
        
        if([[ophoLoadingInstrumentQueue allKeys] count] == 0 && samplesLoaded >= samplesToLoad){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingDelegate loadingEnded:NO endLoginLoading:NO];
            });
            
        }
    }
    
}

#pragma mark - XMP Delete

- (void)deleteWithId:(NSInteger)xmpId
{
    DLog(@"Delete with ID %i",xmpId);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [ophoCloudController requestDeleteXmpWithId:xmpId andCallbackObj:self andCallbackSel:@selector(deleteCallback:)];
    });
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

- (NSDictionary *)getStandardSampleList
{
    NSMutableArray * standardSampIdSet = [[NSMutableArray alloc] init];
    NSMutableArray * standardSampLoadSet = [[NSMutableArray alloc] init];
    NSMutableArray * standardSampDateSet = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [sampleIdSet count]; i++){
        if(![[sampleIsCustomSet objectAtIndex:i] boolValue]){
            [standardSampIdSet addObject:[sampleIdSet objectAtIndex:i]];
            [standardSampLoadSet addObject:[sampleLoadSet objectAtIndex:i]];
            [standardSampDateSet addObject:[sampleDateSet objectAtIndex:i]];
        }
    }
    
    NSDictionary * standardSampleList = [NSDictionary dictionaryWithObjectsAndKeys:standardSampIdSet,OPHO_LIST_IDS,standardSampLoadSet,OPHO_LIST_NAMES,standardSampDateSet,OPHO_LIST_DATES, nil];
    
    return standardSampleList;
}

- (NSDictionary *)getCustomSampleList
{
    NSMutableArray * customSampIdSet = [[NSMutableArray alloc] init];
    NSMutableArray * customSampLoadSet = [[NSMutableArray alloc] init];
    NSMutableArray * customSampDateSet = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [sampleIdSet count]; i++){
        if([[sampleIsCustomSet objectAtIndex:i] boolValue]){
            [customSampIdSet addObject:[sampleIdSet objectAtIndex:i]];
            [customSampLoadSet addObject:[sampleLoadSet objectAtIndex:i]];
            [customSampDateSet addObject:[sampleDateSet objectAtIndex:i]];
        }
    }
    
    NSDictionary * customSampleList = [NSDictionary dictionaryWithObjectsAndKeys:customSampIdSet,OPHO_LIST_IDS,customSampLoadSet,OPHO_LIST_NAMES,customSampDateSet,OPHO_LIST_DATES, nil];
    
    return customSampleList;
}

- (NSDictionary *)getInstrumentList
{
    NSMutableArray * instIdSet = [[NSMutableArray alloc] init];
    NSMutableArray * instLoadSet = [[NSMutableArray alloc] init];
    NSMutableArray * instDateSet = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [instrumentIdSet count]; i++){
        if(![[instrumentIsCustomSet objectAtIndex:i] boolValue]){
            [instIdSet addObject:[instrumentIdSet objectAtIndex:i]];
            [instLoadSet addObject:[instrumentLoadSet objectAtIndex:i]];
            [instDateSet addObject:[instrumentDateSet objectAtIndex:i]];
        }
    }
    
    NSDictionary * instrumentList = [NSDictionary dictionaryWithObjectsAndKeys:instIdSet,OPHO_LIST_IDS,instLoadSet,OPHO_LIST_NAMES,instDateSet,OPHO_LIST_DATES, nil];
    
    return instrumentList;
}

- (NSDictionary *)getCustomInstrumentList
{
    NSMutableArray * customInstIdSet = [[NSMutableArray alloc] init];
    NSMutableArray * customInstLoadSet = [[NSMutableArray alloc] init];
    NSMutableArray * customInstDateSet = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [instrumentIdSet count]; i++){
        if([[instrumentIsCustomSet objectAtIndex:i] boolValue]){
            [customInstIdSet addObject:[instrumentIdSet objectAtIndex:i]];
            [customInstLoadSet addObject:[instrumentLoadSet objectAtIndex:i]];
            [customInstDateSet addObject:[instrumentDateSet objectAtIndex:i]];
        }
    }
    
    NSDictionary * customInstrumentList = [NSDictionary dictionaryWithObjectsAndKeys:customInstIdSet,OPHO_LIST_IDS,customInstLoadSet,OPHO_LIST_NAMES,customInstDateSet,OPHO_LIST_DATES, nil];
    
    return customInstrumentList;
}

#pragma mark - Caching Samples
- (void)loadSampleCache
{
    ophoSampleCache = [[NSMutableDictionary alloc] init];
    
    // Unarchive cache from disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString * sampleCachePath = [[paths objectAtIndex:0]
                                  stringByAppendingPathComponent:@"sampleCache"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:sampleCachePath]){
        DLog(@"No sample cache found at %@",sampleCachePath);
        return;
    }
    
    // Load all cached samples to a dictionary
    NSData * cacheData = [NSData dataWithContentsOfFile:sampleCachePath options:0 error:nil];
    
    ophoSampleCache = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
    
    
    //[[NSDictionary dictionaryWithContentsOfFile:sampleCachePath] mutableCopy];
    
}

- (void)cacheSample:(NSString *)sample forSampleId:(long)xmpId withVersion:(int)version
{
    DLog(@"Cache sample %li with version %i",xmpId,version);
    
    NSDictionary * cacheEntry = [[NSDictionary alloc] initWithObjectsAndKeys:sample,@"Data",[NSNumber numberWithInt:version],@"Version", nil];
    
    [ophoSampleCache setObject:cacheEntry forKey:[NSNumber numberWithLong:xmpId]];
    
    [self saveCacheToFile];
    
}

- (BOOL)cacheForSample:(long)xmpId
{
    return ([self getSampleFromCache:xmpId] != nil);
}

- (NSString *)getSampleFromCache:(long)xmpId
{
    NSDictionary * cacheEntry = [ophoSampleCache objectForKey:[NSNumber numberWithLong:xmpId]];
    
    if(cacheEntry == nil){
        return nil;
    }
    
    return [cacheEntry objectForKey:@"Data"];
}

- (void)saveCacheToFile
{
    // Backup cache to disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString * sampleCachePath = [[paths objectAtIndex:0]
                                  stringByAppendingPathComponent:@"sampleCache"];
    
    NSData * convertedData = [NSKeyedArchiver archivedDataWithRootObject:ophoSampleCache];
    
    BOOL success = [convertedData writeToFile:sampleCachePath atomically:YES];
    
    //BOOL success = [ophoSampleCache writeToFile:sampleCachePath atomically:YES];
    
    if(success){
        DLog(@"Saved cache to file");
    }else{
        DLog(@"Failed to save cache to file");
    }
}

- (void)refreshCacheFromSampleList
{
    // Remove any IDs in cache not in sampleIdSet
    DLog(@"Refresh cache from sample list");
    
    @synchronized(ophoSampleCache){
        NSMutableArray * keysToRemove = [[NSMutableArray alloc] init];
    
        for(id key in ophoSampleCache){
            if(![sampleIdSet containsObject:key]){
                // Remove if absent
                [keysToRemove addObject:key];
            }else{
                // Check versions match
                long index = [sampleIdSet indexOfObject:key];
                long newVersion = [[sampleVersionSet objectAtIndex:index] longValue];
                long oldVersion = [[[ophoSampleCache objectForKey:key] objectForKey:@"Version"] longValue];
                
                if(newVersion != oldVersion){
                    [keysToRemove addObject:key];
                }
            }
        }
   
    
        for(id key in keysToRemove){
            [self removeSampleFromCache:[key longValue]];
        }
    }
    
}

- (void)removeSampleFromCache:(long)xmpId
{
    [ophoSampleCache removeObjectForKey:[NSNumber numberWithLong:xmpId]];
    
    [self saveCacheToFile];
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
        songVersionSet = [[NSMutableArray alloc] init];
        songIsCustomSet = [[NSMutableArray alloc] init];
    }else{
        
        [songIdSet removeAllObjects];
        [songLoadSet removeAllObjects];
        [songDateSet removeAllObjects];
        [songVersionSet removeAllObjects];
        [songIsCustomSet removeAllObjects];
        
    }
        
    [self getSongListForCallbackObj:self selector:@selector(requestGetXmpSongListCallback:) isCustom:YES];
    
    [self getSongListForCallbackObj:self selector:@selector(requestGetXmpSongListCallback:) isCustom:NO];
}

- (void)loadSequenceList
{
    if(sequenceIdSet == nil){
        sequenceIdSet = [[NSMutableArray alloc] init];
        sequenceLoadSet = [[NSMutableArray alloc] init];
        sequenceDateSet = [[NSMutableArray alloc] init];
        sequenceVersionSet = [[NSMutableArray alloc] init];
        sequenceIsCustomSet = [[NSMutableArray alloc] init];
    }else{
        
        [sequenceIdSet removeAllObjects];
        [sequenceLoadSet removeAllObjects];
        [sequenceDateSet removeAllObjects];
        [sequenceVersionSet removeAllObjects];
        [sequenceIsCustomSet removeAllObjects];
        
    }
    
    [self getSequenceListForCallbackObj:self selector:@selector(requestGetXmpSequenceListCallback:) isCustom:YES];
    
    [self getSequenceListForCallbackObj:self selector:@selector(requestGetXmpSequenceListCallback:) isCustom:NO];
}

- (void)loadSampleList
{

    if(sampleIdSet == nil){
        
        sampleIdSet = [[NSMutableArray alloc] init];
        sampleLoadSet = [[NSMutableArray alloc] init];
        sampleDateSet = [[NSMutableArray alloc] init];
        sampleVersionSet = [[NSMutableArray alloc] init];
        sampleIsCustomSet = [[NSMutableArray alloc] init];
    
    }
    
    [sampleIdSet removeAllObjects];
    [sampleLoadSet removeAllObjects];
    [sampleDateSet removeAllObjects];
    [sampleVersionSet removeAllObjects];
    [sampleIsCustomSet removeAllObjects];

    // Merge samples for user and system
    [self getSampleListForCallbackObj:self selector:@selector(requestGetXmpSampleListCallback:) isCustom:YES];
    [self getSampleListForCallbackObj:self selector:@selector(requestGetXmpSampleListCallback:) isCustom:NO];

}

- (void)loadInstrumentList
{
    if(instrumentIdSet == nil){
        instrumentIdSet = [[NSMutableArray alloc] init];
        instrumentLoadSet = [[NSMutableArray alloc] init];
        instrumentDateSet = [[NSMutableArray alloc] init];
        instrumentVersionSet = [[NSMutableArray alloc] init];
        instrumentIsCustomSet = [[NSMutableArray alloc] init];
    }else{
        
        [instrumentIdSet removeAllObjects];
        [instrumentLoadSet removeAllObjects];
        [instrumentDateSet removeAllObjects];
        [instrumentVersionSet removeAllObjects];
        [instrumentIsCustomSet removeAllObjects];
        
    }
        
    [self getInstrumentListForCallbackObj:self selector:@selector(requestGetXmpInstrumentListCallback:) isCustom:NO];
    
    [self getInstrumentListForCallbackObj:self selector:@selector(requestGetXmpInstrumentListCallback:) isCustom:YES];
}

- (void)requestGetXmpSongListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Song List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    [self buildSortedXmpList:xmpList withIds:songIdSet withData:songLoadSet withDates:songDateSet withVersion:songVersionSet withCustom:songIsCustomSet];
    
    //if([songIdSet count] > 0){
    //    [profileDelegate profileLoaded];
    //}
}

- (void)requestGetXmpInstrumentListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Instrument List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    BOOL firstCallback = ([instrumentIdSet count] == 0);
    
    [self buildSortedXmpList:xmpList withIds:instrumentIdSet withData:instrumentLoadSet withDates:instrumentDateSet withVersion:instrumentVersionSet withCustom:instrumentIsCustomSet];
    
    //DLog(@"Instrument Is Custom Set %@, ID Set %@, %i",instrumentIsCustomSet,instrumentIdSet,g_loggedInUser.m_userId);
    
    if(!firstCallback){
        [loadingDelegate instrumentListLoaded];
        [profileDelegate profileLoaded];
    }
}

- (void)requestGetXmpSequenceListCallback:(CloudResponse *)cloudResponse
{
    DLog(@"Request Get Xmp Sequence List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    [self buildSortedXmpList:xmpList withIds:sequenceIdSet withData:sequenceLoadSet withDates:sequenceDateSet withVersion:sequenceVersionSet withCustom:sequenceIsCustomSet];
    
    // Check that TUTORIAL has been copied over
    BOOL convertTutorialSet = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"ConvertTutorialSet_%li",[self getUserId]]];
    
    if(![self defaultSetExists] && !convertTutorialSet){
        [self copyTutorialFile];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"ConvertTutorialSet_%li",[self getUserId]]];
    }
    
    if([sequenceIdSet count] > 0){
        [profileDelegate profileLoaded];
    }
    
}

- (void)requestGetXmpSampleListCallback:(CloudResponse *)cloudResponse
{
    // This will get called twice when samples return for user and default assets
    
    DLog(@"Request Get Xmp Sample List Callback");
    
    NSArray * xmpList = cloudResponse.m_xmpList;
    
    BOOL firstCallback = ([sampleIdSet count] == 0);
    
    //if(firstCallback){
        [self buildSortedXmpList:xmpList withIds:sampleIdSet withData:sampleLoadSet withDates:sampleDateSet withVersion:sampleVersionSet withCustom:sampleIsCustomSet];
    //}
        
    if(!firstCallback){
        [self refreshCacheFromSampleList];
        [profileDelegate profileLoaded];
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

- (void)buildSortedXmpList:(NSArray *)xmpList withIds:(NSMutableArray *)fileIdSet withData:(NSMutableArray *)fileLoadSet withDates:(NSMutableArray *)fileDateSet withVersion:(NSMutableArray *)fileVersionSet withCustom:(NSMutableArray *)fileCustomSet;
{
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for(XmlDom * xmp in xmpList){
        NSInteger xmpid = [[xmp getTextFromChildWithName:@"xmp_id"] intValue];
        NSInteger version = [[xmp getTextFromChildWithName:@"xmp_current_version_number"] intValue];
        NSString * name = [xmp getTextFromChildWithName:@"xmp_name"];
        NSDate * date = [df dateFromString:[xmp getTextFromChildWithName:@"xmp_create_date"]];
        NSNumber * custom = [NSNumber numberWithBool:([[xmp getTextFromChildWithName:@"user_id"] intValue] == g_loggedInUser.m_userId)];
        
        //DLog(@"Date is %@",date);
        
        // Ensure no duplicates
        if([fileIdSet containsObject:[NSNumber numberWithLong:xmpid]]){
            continue;
        }
        
        if(xmpid > 0){
            [fileIdSet addObject:[NSNumber numberWithLong:xmpid]];
        }
        
        if(name != nil){
            [fileLoadSet addObject:name];
        }
        
        if(date != nil){
            [fileDateSet addObject:date];
        }
        
        if(version >= 0){
            [fileVersionSet addObject:[NSNumber numberWithLong:version]];
        }
        
        if(custom != nil){
            [fileCustomSet addObject:custom];
        }
    }
    
    //DLog(@"FileIdSet %@ FileLoadSet %@ FileDateSet %@",fileIdSet, fileLoadSet,fileDateSet);
    
    // Sort by date order
    if([fileLoadSet count] > 0){
        [self sortFilesByDates:fileDateSet withIds:fileIdSet withData:fileLoadSet withVersions:fileVersionSet withCustom:fileCustomSet];
    }
    
}

// TODO: this can probably be done nicer with comparators
- (void)sortFilesByDates:(NSMutableArray *)fileDateSet withIds:(NSMutableArray *)fileIdSet withData:(NSMutableArray *)fileLoadSet withVersions:(NSMutableArray *)fileVersionSet withCustom:(NSMutableArray *)fileCustomSet;
{
    
    NSString * newFileLoadSet[[fileDateSet count]];
    NSDate * newFileDateSet[[fileDateSet count]];
    NSNumber * newFileIdSet[[fileDateSet count]];
    NSNumber * newFileVersionSet[[fileDateSet count]];
    NSNumber * newFileCustomSet[[fileDateSet count]];
    
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
            newFileVersionSet[i] = fileVersionSet[maxDateIndex];
            newFileCustomSet[i] = fileCustomSet[maxDateIndex];
            
            fileDateSet[maxDateIndex] = [NSDate distantPast];
        }
    }
    
    for(int i = 0; i < [fileDateSet count]; i++){
        [fileLoadSet setObject:newFileLoadSet[i] atIndexedSubscript:i];
        [fileDateSet setObject:newFileDateSet[i] atIndexedSubscript:i];
        [fileIdSet setObject:newFileIdSet[i] atIndexedSubscript:i];
        [fileVersionSet setObject:newFileVersionSet[i] atIndexedSubscript:i];
        [fileCustomSet setObject:newFileCustomSet[i] atIndexedSubscript:i];
    }
}

#pragma mark - Name Generating


- (NSString *)generateNextSequenceName
{
    int customCount = 0;
    
    for(int i = 0; i < [sequenceLoadSet count]; i++){
        NSString * filename = sequenceLoadSet[i];
        if(!([filename rangeOfString:@"Set"].location == NSNotFound)){
            
            NSString * customSuffix = [filename stringByReplacingCharactersInRange:[filename rangeOfString:@"Set"] withString:@""];
            int numFromSuffix = [customSuffix intValue];
            
            customCount = MAX(customCount,numFromSuffix);
        }
    }
    
    customCount++;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setMinimumIntegerDigits:3];
    
    NSNumber * number = [NSNumber numberWithInt:customCount];
    
    NSString * numberString = [numberFormatter stringFromNumber:number];
    
    return [@"Set" stringByAppendingString:numberString];
    
}

#pragma mark - Default Tutorial File

- (void)resetTutorial
{
    tutorialSkipped = false;
}

- (void)tutorialSkipped
{
    tutorialSkipped = true;
}

- (void)copyTutorialFile
{
    DLog(@"Copy tutorial file | sequenceLoadSet is %@",sequenceLoadSet);
    
    NSSequence * tutorialSequence = [[NSSequence alloc] initWithXMLFilename:DEFAULT_SET_PATH fromBundle:YES];
    
    [self saveSequence:tutorialSequence];
}


@end
