//
//  NSUser.m
//  Sequence
//
//  Created by Kate Schnippering on 9/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSUser.h"

extern CloudController * g_cloudController;

@implementation NSUser
{
    NSString * m_userFilePath;
}

@synthesize username;
@synthesize password;
@synthesize email;

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
    
    [NSKeyedArchiver archiveRootObject:username toFile:usernamePath];
    [NSKeyedArchiver archiveRootObject:password toFile:passwordPath];
    
}

- (void)uncache
{
    
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    
    username = [NSKeyedUnarchiver unarchiveObjectWithFile:usernamePath];
    password = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordPath];
    
}

@end
