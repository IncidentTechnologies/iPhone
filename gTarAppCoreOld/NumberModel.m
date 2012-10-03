//
//  NumberModel.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/10/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "NumberModel.h"


@implementation NumberModel

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andValue:(NSInteger)value
{
	
	if ( (m_value <= NUMBER_MODEL_MAX_NUMBER) && (self = [super init]) )
	{
		
		m_center = center;
		
		m_value = value;
		
		[self changeColor:color];
		
		NSString * fileName;
        
        if ( m_value >= 0 && m_value < 20 )
        {
            fileName = [NSString stringWithFormat:@"note-%u", m_value];
        }
        else
        {
            fileName = [NSString stringWithFormat:@"note-x"];
        }
        
		NSString * filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
		UIImage * image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		m_texture = [[Texture2D alloc] initWithImage:scaledImage];
		
		[image release];

	}
	
	return self;
	
}

@end
