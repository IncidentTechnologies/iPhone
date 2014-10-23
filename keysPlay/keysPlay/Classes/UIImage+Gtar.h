//
//  UIImage+Gtar.h
//  gTarPlay
//
//  Created by Marty Greenia on 5/6/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Gtar)

// A work in progress, none of these functions work yet.
- (UIImage *)resizeImage:(CGSize)size;
- (UIImage *)scaleImage:(CGFloat)scale;
- (UIImage *)aspectFitImage:(CGSize)size;

@end
