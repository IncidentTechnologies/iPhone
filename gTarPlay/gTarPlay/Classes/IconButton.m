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
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Only if IB doesn't override
    if ( self.contentEdgeInsets.top == 0 &&
         self.contentEdgeInsets.left == 0 &&
         self.contentEdgeInsets.bottom == 0 &&
         self.contentEdgeInsets.right == 0 )
    {
        CGFloat inset = 6.0;
        self.contentEdgeInsets = UIEdgeInsetsMake( inset, 0, inset, 0 );
    }
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
