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

		NSString * filePath = [[NSBundle mainBundle] pathForResource:@"string" ofType:@"png"];
		UIImage * stringImage = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(size);
		[stringImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		m_texture = [[Texture2D alloc] initWithImage:scaledImage];
		
		[stringImage release];
		
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
