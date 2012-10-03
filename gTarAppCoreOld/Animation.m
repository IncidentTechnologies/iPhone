//
//  Animation.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/22/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "Animation.h"


@implementation Animation

- (id)initWithFramesPerModel:(NSInteger)framesPerModel
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_models = [[NSMutableArray alloc] init];
		
		m_framesPerModel = framesPerModel;
		
		m_animating = NO;
		m_loop = NO;
		
		m_currentFrame = 0;
		
		m_animationCenter = CGPointMake( 0, 0 );
		
	}
	
	return self;
    
}

- (void)dealloc
{

	[m_models release];
	
	[super dealloc];
	
}

- (void)addModel:(Model*)model
{
	
	[m_models addObject:model];
	
}

- (void)addModelFromImageName:(NSString*)imageName 
					 withSize:(CGSize)imageSize
					andCenter:(CGPoint)center
					 andColor:(GLubyte*)color
{
	
	NSString * filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
	UIImage * image = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	UIGraphicsBeginImageContext(imageSize);
	[image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
	UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
	UIGraphicsEndImageContext();
	
	Texture2D * texture = [[Texture2D alloc] initWithImage:scaledImage];
	Model * model = [[Model alloc] initWithCenter:center andColor:color andTexture:texture];
	
	[self addModel:model];
	
	[texture release];
	[model release];
	[image release];

}
	

- (void)drawCurrentFrame
{
	
	Model * model = [m_models objectAtIndex:m_currentModel];
	
	//[model draw];
	[model drawWithOffset:m_animationCenter];
	
}

- (void)drawCurrentFrameAndAdvanceFrame
{
	
	[self drawCurrentFrame];
	
	if ( m_animating == YES )
	{
		m_currentFrame++;
		
		if ( m_currentFrame >= m_framesPerModel )
		{

			m_currentFrame = 0;

			NSInteger modelCount = [m_models count];
			
			if ( m_currentModel >= (modelCount-1) )
			{
				if ( m_loop == YES )
				{
					m_currentModel = 1;
				}
				else 
				{
					[self stopAnimation];
				}
			}
			else 
			{

				m_currentModel++;
				
			}
			
		}
	}
}


- (void)startAnimation:(BOOL)loop
{
	
	m_animating = YES;
	m_loop = loop;
	
	m_currentFrame = 0;
	m_currentModel = 1;
	
}

- (void)stopAnimation
{
	
	m_animating = NO;
	m_loop = NO;
	
}

- (void)resetAnimation
{
	
	m_currentFrame = 0;
	m_currentModel = 0;
	m_animating = NO;
	
}

- (void)changeCenter:(CGPoint)center
{
	m_animationCenter = center;
}

- (void)changeAllColors:(GLubyte*)color
{

	for ( unsigned int index = 0; index < [m_models count]; index++ )
	{
	
		Model * model = [m_models objectAtIndex:index];

		[model changeColor:color];
		
	}
	
}

@end
