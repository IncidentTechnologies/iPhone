//
//  IconButton.m
//  gTarPlay
//
//  Created by Marty Greenia on 5/10/13.
//
//

#import "IconButton.h"

@implementation IconButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    CGFloat inset = self.frame.size.height - 20.0;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageEdgeInsets = UIEdgeInsetsMake( inset/2.0, 0, inset/2.0, 0 );
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
