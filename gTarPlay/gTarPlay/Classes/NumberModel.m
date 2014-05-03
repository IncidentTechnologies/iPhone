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
		
		/*NSString * fileName;
        
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
		*/
        
        // Try drawing with CGContext
        
        CGSize imgsize = CGSizeMake(size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(imgsize, NO, 0); // use this to antialias
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        NSString *string = [[NSString alloc] initWithFormat:@"%u", m_value];
        
        float textWidth = 10.0 * [string length] / 2;
        
        [string drawAtPoint:CGPointMake(size.width/2-textWidth/2, 11.0)
             withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:8.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        
        UIImage * textImage = UIGraphicsGetImageFromCurrentImageContext();
        //UIImageView * img = [[UIImageView alloc] initWithImage:textImage];
        
        m_texture = [[Texture2D alloc] initWithImage:textImage];
        
        UIGraphicsEndImageContext();
        
        //
        
        
		//m_texture = [[Texture2D alloc] initWithImage:scaledImage];
		
		//[image release];

	}
	
	return self;
	
}

@end
