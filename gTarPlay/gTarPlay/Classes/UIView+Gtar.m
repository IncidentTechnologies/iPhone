//
//  UIView+Gtar.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/10/13.
//
//

#import "UIView+Gtar.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (Gtar)

- (void)addShadow
{
    [self addShadowWithRadius:7.0];
}

- (void)addShadowWithRadius:(CGFloat)radius
{
    [self addShadowWithRadius:radius andOpacity:0.9];
}

- (void)addShadowWithRadius:(CGFloat)radius andOpacity:(CGFloat)opacity
{
    self.layer.shadowRadius = radius;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = opacity;
}

@end
