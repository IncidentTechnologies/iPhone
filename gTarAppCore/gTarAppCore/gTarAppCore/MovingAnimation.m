//
//  MovingAnimation.m
//  gTarAppCore
//
//  Created by Marty Greenia on 5/11/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "MovingAnimation.h"


@implementation MovingAnimation

@synthesize m_mode;
@synthesize m_sinusoidalAmplitude;
@synthesize m_sinusoidalFrequency;


- (void)changePositioin:(CGPoint)position
{
	m_position = position;
}

- (void)changeVelocity:(CGPoint)velocity
{
	m_velocity = velocity;
}

- (void)changeAcceleration:(CGPoint)acceleration
{
	m_acceleration = acceleration;
}

- (void)incrementTimeDelta:(double)delta
{
	
	m_currentTime += delta;
	
//	CGFloat offsetY;
	
	m_sinusoidalAmplitude = 6;
	m_sinusoidalFrequency = 2;
	
	switch ( m_mode )
	{
/*
		case MovingAnimationModeSinusoidal:
		{
			
			// varying the position vector over time
			//CGFloat offsetX = sin( m_currentTime * 2 * 3.14159265 );
			offsetY = cos( m_currentTime * 2 * 3.14159265 * m_sinusoidalFrequency ) * m_sinusoidalAmplitude;
			
			m_position.x += delta * m_velocity.x;
			m_position.y += delta * m_velocity.y;
			
			m_velocity.x += delta * m_acceleration.x;
			m_velocity.y += delta * m_acceleration.y;

//			m_position.y = offsetY;
			
		} break;
*/
		case MovingAnimationModeStraight:
		default:
		{
			
			m_position.x += delta * m_velocity.x;
			m_position.y += delta * m_velocity.y;
			
			m_velocity.x += delta * m_acceleration.x;
			m_velocity.y += delta * m_acceleration.y;
			
		}; break;

	}
	
	m_animationCenter = m_position;
//	m_animationCenter.y = m_position.y + offsetY;
	//m_animationCenter.x = m_position.x;
		
}

@end
