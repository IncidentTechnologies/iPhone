//
//  HighlightModel.m
//  keysPlay
//
//  Created by Kate Schnippering on 4/24/14.
//
//

#import "HighlightModel.h"

@implementation HighlightModel

@synthesize highlightImage;

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andShape:(NSString *)shape
{
	
    [self changeCenter:center];
    
    [self changeColor:color];
    
    // Try drawing with CGContext
    
    CGSize imgsize = CGSizeMake(size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(imgsize, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor);
    
    if([shape isEqualToString:@"Round"]){
        CGContextFillEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));
    }else{
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    }
    
    highlightImage = UIGraphicsGetImageFromCurrentImageContext();
    
    m_texture = [[Texture2D alloc] initWithImage:highlightImage];
    
    UIGraphicsEndImageContext();
    
	return self;
	
}

@end
