//
//  GuitarEffectSequence.h
//  gTarDemo
//
//  Created by Joel Greenia on 11/16/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GuitarEffect;
@class GuitarEffectSerialized;

@interface GuitarEffectSequence : NSObject

@property (retain, nonatomic) NSMutableArray * m_effectSequenceSerialized;
@property (unsafe_unretained, nonatomic) CGFloat m_duration;


- (void)serializeEffectArray:(NSArray*)array;
- (NSArray*)serializeEffect:(GuitarEffect*)effect;
- (NSArray*)serializeDirectionEffect:(GuitarEffect*)effect;

@end
