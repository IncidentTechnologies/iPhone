//
//  FrameGenerator.h
//  Sequence
//
//  Created by Kate Schnippering on 9/30/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrameGenerator : NSObject

- (float)getFullscreenWidth;
- (float)getFullscreenHeight;
- (BOOL)isScreenLarge;

- (float)getRecordedTrackScreenWidth;

@end
