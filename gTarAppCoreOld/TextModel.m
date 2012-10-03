//
//  TextModel.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/10/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "TextModel.h"


@implementation TextModel

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andText:(NSString*)text andHeight:(CGFloat)height
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_center = center;
		
		[self changeColor:color];
				
		m_texture = [[Texture2D alloc] initWithString:text dimensions:size alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:height];
		
	}
	
	return self;
	
}



@end
