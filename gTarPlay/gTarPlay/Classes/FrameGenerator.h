//
//  FrameGenerator.h
//  Play
//
//  Created by Kate Schnippering on 9/30/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FrameGenerator : NSObject

- (float)getFullscreenWidth;
- (float)getFullscreenHeight;
- (BOOL)isScreenLarge;

@end
