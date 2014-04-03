//
//  SoundMaster.h
//  Sequence
//
//  Created by Kate Schnippering on 3/11/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "UILevelSlider.h"

@class AudioController;

@interface SoundMaster : NSObject
{
    
}

-(void)start;
-(void)stop;

- (void)releaseMasterLevelSlider;
- (void)commitMasterLevelSlider:(UILevelSlider *)slider;

@end
