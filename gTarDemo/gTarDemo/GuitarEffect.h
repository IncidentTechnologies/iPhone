//
//  GuitarEffect.h
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuitarEffect : NSObject

@property (unsafe_unretained, nonatomic) CGFloat m_duration;

@property (unsafe_unretained, nonatomic) BOOL m_clearFirst;
    
@property (unsafe_unretained, nonatomic) NSInteger m_colorRed;
@property (unsafe_unretained, nonatomic) NSInteger m_colorGreen;
@property (unsafe_unretained, nonatomic) NSInteger m_colorBlue;
@property (unsafe_unretained, nonatomic) BOOL m_colorRandom;
    
@property (unsafe_unretained, nonatomic) NSInteger m_direction;
@property (unsafe_unretained, nonatomic) BOOL m_directionScattering;

@end
