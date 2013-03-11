//
//  LedActivityIndicator.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/11/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LedActivityIndicator : UIView
{
    
    IBOutlet UIImageView * m_indicatorImage;
    
    NSTimer * m_timer;
    
}

@property (nonatomic, retain) IBOutlet UIImageView * m_indicatorImage;

- (void)flickerLed;
- (void)flickerLedForTime:(double)delta;
- (void)endFlicker;

@end
