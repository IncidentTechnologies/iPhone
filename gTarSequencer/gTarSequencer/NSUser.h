//
//  NSUser.h
//  Sequence
//
//  Created by Kate Schnippering on 9/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudController.h"

@interface NSUser : NSObject


@property (nonatomic) NSString * username;
@property (nonatomic) NSString * password;
@property (nonatomic) NSString * email;

- (void)cache;
- (void)uncache;

@end
