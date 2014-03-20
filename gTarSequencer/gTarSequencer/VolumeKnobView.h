//
//  VolumeKnobView.h
//  Sequence
//
//  Created by Kate Schnippering on 3/19/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VolumeKnobViewDelegate <NSObject>

- (void)knobRegionHit;

@end

@interface VolumeKnobView : UIButton
{
    
    
}

@property (weak, nonatomic) id<VolumeKnobViewDelegate>delegate;

@end
