//
//  CustomSegmentedControl.m
//  gTarPlay
//
//  Created by Marty Greenia on 11/8/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "CustomSegmentedControl.h"

#import <QuartzCore/QuartzCore.h>

@implementation CustomSegmentedControl

@synthesize m_selectedSegmentIndex;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code

    }
    
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)changeTitles:(NSArray*)titleArray
{
    
    if ( [titleArray count] == 0 )
    {
        return;
    }
    
    m_usingImages = NO;
    
    self.backgroundColor = [UIColor grayColor];
//    self.layer.borderColor = [[UIColor grayColor] CGColor];
//    self.layer.borderWidth = 1;

    // clean house
    for ( UIButton * segment in m_segmentViews )
    {
        [segment removeFromSuperview];
    }
    
    [m_segmentViews release];
    
    m_segmentViews = nil;
    
    // create the new ones
    CGFloat width = self.frame.size.width / [titleArray count];
    CGFloat height = self.frame.size.height;
    
    NSMutableArray * newSegments = [[NSMutableArray alloc] init];
    
    for ( NSInteger i = 0; i < [titleArray count]; i++ )
    {
        NSString * title = [titleArray objectAtIndex:i];
        UIButton * segment = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [segment setFrame:CGRectMake(i*(width+1), 0, width, height)];
        
        // set the title
        [segment setTitle:title forState:UIControlStateNormal];
        [segment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [segment setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [segment setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
        [segment setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        segment.titleLabel.shadowOffset = CGSizeMake(1,1);
        segment.titleLabel.minimumFontSize = 10;
        
        // Create the background image gradients for these buttons
        UIImage * image = [self createGradientImage:segment.frame.size withIntensity:1.0f];
        
        [segment setBackgroundImage:image forState:UIControlStateNormal];
        
        image = [self createGradientImage:segment.frame.size withIntensity:0.4f];
        [segment setBackgroundImage:image forState:UIControlStateSelected];
        
        image = [self createGradientImage:segment.frame.size withIntensity:0.60f];
        [segment setBackgroundImage:image forState:UIControlStateDisabled];
        
        segment.layer.shadowRadius = 4;
        segment.layer.shadowOffset = CGSizeMake(2, 2);
        
        // Set up the actions and add the subview
        [segment addTarget:self action:@selector(segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:segment];
        
        [newSegments addObject:segment];
        
    }
    
    m_segmentViews = newSegments;
    
    [self setSelectedIndex:0];
    
}

- (void)changeOnImages:(NSArray*)onImages andOffImages:(NSArray*)offImages
{
    
    if ( [onImages count] == 0 || [onImages count] != [offImages count] )
    {
        return;
    }
    
    m_usingImages = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    // clean house
    for ( UIButton * segment in m_segmentViews )
    {
        [segment removeFromSuperview];
    }
    
    [m_segmentViews release];
    
    m_segmentViews = nil;
    
    // create the new ones
    CGFloat width = self.frame.size.width / [onImages count];
    CGFloat height = self.frame.size.height;
    
    NSMutableArray * newSegments = [[NSMutableArray alloc] init];
    
    for ( NSInteger i = 0; i < [onImages count]; i++ )
    {
        UIImage * onImage = [onImages objectAtIndex:i];
        UIImage * offImage = [offImages objectAtIndex:i];

        UIButton * segment = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [segment setFrame:CGRectMake(i*(width+1), 0, width, height)];
        [segment setImage:offImage forState:UIControlStateNormal];
        [segment setImage:onImage forState:UIControlStateDisabled]; // counter-intuitive, 'on' image == 'disabled' state
        [segment setBackgroundColor:[UIColor clearColor]];
        [segment addTarget:self action:@selector(segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:segment];
        
        [newSegments addObject:segment];
        
    }
    
    m_segmentViews = newSegments;
    
    [self setSelectedIndex:0];
    
}

- (UIImage*)createGradientImage:(CGSize)size withIntensity:(CGFloat)intensity
{
    
    // Create context
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat value;
    
    value = 215.0f/255.0f*intensity;
    UIColor * color1 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    
    value = 180.0f/255.0f*intensity;
    UIColor * color2 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    
    value = 150.0f/255.0f*intensity;
    UIColor * color3 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    
    value = 100.0f/255.0f*intensity;
    UIColor * color4 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];

    // Create gradient.
    CGColorRef colorRefs[4] =
    {
        [color1 CGColor], 
        [color2 CGColor], 
        [color3 CGColor], 
        [color4 CGColor]
    };
    
    CGFloat locations[4] =
    {
        0.0f,
        0.1f,
        0.92f,
        1.0f
    };
    
    CFArrayRef colors = CFArrayCreate( NULL, (const void **)colorRefs, 4, NULL );
    CGGradientRef gradient = CGGradientCreateWithColors( NULL, colors, locations );
        
    // Create image.
    CGContextDrawLinearGradient( context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0 );
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Clean up.
    CFRelease(colors);
    CGGradientRelease(gradient);
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)setSelectedIndex:(NSInteger)index
{
    
    // revert the previous segment 
    UIButton * oldSegment = [m_segmentViews objectAtIndex:m_selectedSegmentIndex];
    UIButton * segment = [m_segmentViews objectAtIndex:index];
    
    [oldSegment setEnabled:YES];
    [segment setEnabled:NO];
    
    if ( m_usingImages == NO )
    {
//        [oldSegment setBackgroundColor:[UIColor lightGrayColor]];
//        [segment setBackgroundColor:[UIColor darkGrayColor]];
    }
    
    m_selectedSegmentIndex = [m_segmentViews indexOfObject:segment];

}

- (void)setFontSize:(CGFloat)size
{
    
    for ( UIView * view in m_segmentViews )
    {
        
        // Only change the font size if the view is actually a button
        if ( [view isKindOfClass:[UIButton class]] == YES )
        {
            
            UIButton * button = (UIButton*)view;
            
            button.titleLabel.font = [UIFont systemFontOfSize:size];
            
        }
        
    }
    
}

- (IBAction)segmentButtonClicked:(id)sender
{
    
    // revert the previous segment 
    UIButton * oldSegment = [m_segmentViews objectAtIndex:m_selectedSegmentIndex];
    UIButton * segment = (UIButton*)sender;
    
    [oldSegment setEnabled:YES];
    [segment setEnabled:NO];
    
    if ( m_usingImages == NO )
    {
//        [oldSegment setBackgroundColor:[UIColor lightGrayColor]];
//        [segment setBackgroundColor:[UIColor darkGrayColor]];
    }

    m_selectedSegmentIndex = [m_segmentViews indexOfObject:segment];
    
    // tell whoever is interested that things changed
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}

@end
