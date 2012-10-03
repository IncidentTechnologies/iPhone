//
//  MovingAnimation.h
//  gTarAppCore
//
//  Created by Marty Greenia on 5/11/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "Animation.h"

enum MovingAnimationMode
{
	MovingAnimationModeStraight,
	MovingAnimationModeSinusoidal
};

@interface MovingAnimation : Animation
{
	
	CGPoint m_velocity;
	CGPoint m_acceleration;
	CGPoint m_position;
	
	MovingAnimationMode m_mode;
	
	double m_currentTime;
	
	CGFloat m_sinusoidalAmplitude;
	CGFloat m_sinusoidalFrequency;	
}

- (void)changePositioin:(CGPoint)position;
- (void)changeVelocity:(CGPoint)velocity;
- (void)changeAcceleration:(CGPoint)acceleration;

- (void)incrementTimeDelta:(double)delta;

@property (nonatomic, assign) MovingAnimationMode m_mode;
@property (nonatomic, assign) CGFloat m_sinusoidalAmplitude;
@property (nonatomic, assign) CGFloat m_sinusoidalFrequency;

@end
