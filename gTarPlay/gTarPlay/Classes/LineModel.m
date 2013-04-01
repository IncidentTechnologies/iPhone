//
//  LineModel.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/10/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "LineModel.h"


@implementation LineModel

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color
{
    
    self = [super init];
    
	if ( self )
    {
        
		m_center = center;
        
		[self changeColor:color];
        
        // Draw a blank rectangle for the lines
		UIGraphicsBeginImageContext(size);
		
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, color[0] / 255.0, color[1] / 255.0, color[2] / 255.0, color[3] / 255.0 );

        CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
        
		UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
		UIGraphicsEndImageContext();
		
		m_texture = [[Texture2D alloc] initWithImage:scaledImage];
		
	}
	
	return self;
	
}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andImage:(UIImage*)image
{
    
    self = [super init];
    
	if ( self )
    {
		
		m_center = center;
		
		[self changeColor:color];
		
		UIGraphicsBeginImageContext(size);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		m_texture = [[Texture2D alloc] initWithImage:scaledImage];
		
	}
	
	return self;
	
}

@end
