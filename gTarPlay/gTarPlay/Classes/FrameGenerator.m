//
//  FrameGenerator.m
//  Play
//
//  Created by Kate Schnippering on 9/30/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "FrameGenerator.h"
#define XBASE_LG 568
#define XBASE_SM 480

@implementation FrameGenerator

- (float)getFullscreenWidth
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        
        return [[UIScreen mainScreen] bounds].size.width;
        
    }else{
        
        return [[UIScreen mainScreen] bounds].size.height;
    }
}

- (float)getFullscreenHeight
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        
        return [[UIScreen mainScreen] bounds].size.height;
        
    }else{
        
        return [[UIScreen mainScreen] bounds].size.width;
        
    }
}

- (BOOL)isScreenLarge
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        
        return [[UIScreen mainScreen] bounds].size.width == XBASE_LG;
        
    }else{
        
        return [[UIScreen mainScreen] bounds].size.height == XBASE_LG;
    }
}

@end
