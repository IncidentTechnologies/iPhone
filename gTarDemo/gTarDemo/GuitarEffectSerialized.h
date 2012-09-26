//
//  GuitarEffectSerialized.h
//  gTarDemo
//
//  Created by Joel Greenia on 11/16/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

enum GuitarEffectType
{
    GuitarEffectTypeClear = 0,
    GuitarEffectTypeLedOn
};

@interface GuitarEffectSerialized : NSObject

@property (unsafe_unretained, nonatomic) enum GuitarEffectType m_effectType;
@property (unsafe_unretained, nonatomic) CGFloat m_effectTime;

@property (unsafe_unretained, nonatomic) char m_string;
@property (unsafe_unretained, nonatomic) char m_fret;

@property (unsafe_unretained, nonatomic) char m_red;
@property (unsafe_unretained, nonatomic) char m_green;
@property (unsafe_unretained, nonatomic) char m_blue;


@end
