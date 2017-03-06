//
//  NSUser.h
//  Sequence
//
//  Created by Kate Schnippering on 9/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "UserProfile.h"

@interface NSUser : NSObject

@property (nonatomic) NSString * m_username;
@property (nonatomic) NSString * m_password;
@property (nonatomic) NSString * m_email;
@property (nonatomic) NSInteger m_userId;
@property (nonatomic) UserProfile * m_userProfile;

@property (nonatomic) UIImage * m_image;

- (void)cache;
- (void)uncache;
- (void)clear;
- (void)loadWithId:(NSInteger)userid Name:(NSString *)name Password:(NSString *)password Email:(NSString *)email Image:(NSInteger)fileid Profile:(UserProfile *)profile;

@end
