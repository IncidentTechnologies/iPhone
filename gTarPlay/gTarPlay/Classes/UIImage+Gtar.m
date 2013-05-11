//
//  UIImage+Gtar.m
//  gTarPlay
//
//  Created by Marty Greenia on 5/6/13.
//
//

#import "UIImage+Gtar.h"

@implementation UIImage (Gtar)

- (UIImage *)resizeImage:(CGSize)size
{
    // TODO..
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 1);
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
    [self drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)scaleImage:(CGFloat)scale
{
    CGSize size = CGSizeMake( self.size.width * scale, self.size.height * scale);
    
    return [self resizeImage:size];
}

- (UIImage *)aspectFitImage:(CGSize)size
{
    CGFloat scaleX = 1.0;
    CGFloat scaleY = 1.0;
    
    if ( self.size.width > size.width )
    {
        scaleX = size.width / self.size.width;
    }
    
    if ( self.size.height > size.height )
    {
        scaleY = size.height / self.size.height;
    }
    
    return [self scaleImage:MIN(scaleX,scaleY)];
}

@end
