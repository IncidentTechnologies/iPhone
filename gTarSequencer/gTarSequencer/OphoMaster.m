//
//  OphoMaster.m
//  Sequence
//
//  Created by Kate Schnippering on 10/15/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "OphoMaster.h"

#define OPHO_CALL_LOGIN @"OphoCallLogin"
#define OPHO_CALL_LOGOUT @"OphoCallLogout"

@implementation OphoMaster

extern NSUser * g_loggedInUser;

@synthesize loginDelegate;

- (id)init
{
    self = [super init];
    if ( self )
    {
        ophoCloudController = [[OphoCloudController alloc] initWithServer:kServerAddress];
        
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
        
        [self pregenerateDataOnLogin];
        
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

- (void)saveToNewWithName:(NSString *)name callbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestNewXmpWithFolderId:0 andName:name andCallbackObj:callbackObj andCallbackSel:selector];
}

- (void)saveToId:(NSInteger)xmpId withData:(NSString *)data callbackObj:(id)callbackObj selector:(SEL)selector
{
    [ophoCloudController requestSaveXmpWithId:xmpId andXmpFile:nil andXmpData:data andCallbackObj:callbackObj andCallbackSel:selector];
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

- (void)pregenerateDataOnLogin
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


@end
