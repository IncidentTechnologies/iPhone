//
//  NSUser.m
//  Sequence
//
//  Created by Kate Schnippering on 9/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSUser.h"

#define DEFAULT_IMAGE @"Bear_Brown"

//extern CloudController * g_cloudController;
//extern FileController * g_fileController;

@implementation NSUser
{
    NSString * m_userFilePath;
}

@synthesize m_username;
@synthesize m_password;
@synthesize m_email;
@synthesize m_userId;
@synthesize m_image;
@synthesize m_userProfile;

- (id)init
{
    self = [super init];
    
    if(self){
    
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * pathsDirectory = [paths objectAtIndex:0];
        m_userFilePath = [pathsDirectory stringByAppendingPathComponent:@"User"];
        
        // Ensure the directory exists
        NSError * err = NULL;
        [[NSFileManager defaultManager] createDirectoryAtPath:m_userFilePath withIntermediateDirectories:YES attributes:nil error:&err];
        
        [self uncache];
        
    }
    
    return self;
}

- (void)cache
{
    [self performSelectorInBackground:@selector(saveCache) withObject:nil];
}

- (void)saveCache
{
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    
    [NSKeyedArchiver archiveRootObject:m_username toFile:usernamePath];
    [NSKeyedArchiver archiveRootObject:m_password toFile:passwordPath];
    
}

- (void)uncache
{
    
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    
    m_username = [NSKeyedUnarchiver unarchiveObjectWithFile:usernamePath];
    m_password = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordPath];
    
}

- (void)clear
{
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    
    // Clear the cached items
    NSError * err = NULL;
    [[NSFileManager defaultManager] removeItemAtPath:usernamePath error:&err];
    [[NSFileManager defaultManager] removeItemAtPath:passwordPath error:&err];
    
    m_username = nil;
    m_password = nil;
    m_email = nil;
    m_userId = 0;
    m_userProfile = nil;
}

- (void)loadWithId:(NSInteger)userid Name:(NSString *)name Password:(NSString *)password Email:(NSString *)email Image:(NSInteger)fileid Profile:(UserProfile *)profile
{
    m_username = name;
    m_password = password;
    m_email = email;
    m_userId = userid;
    m_userProfile = profile;
    
    //[g_fileController getFileOrDownloadAsync:m_userProfile.m_imgFileId callbackObject:self callbackSelector:@selector(profilePicDownloaded:)];
    
}

- (void)profilePicDownloaded:(UIImage *)image
{
    m_image = image;
}


@end
