//
//  CustomComboBox.m
//  gTarPlay
//
//  Created by Marty Greenia on 2/19/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "CustomComboBox.h"

@implementation CustomComboBox

@synthesize m_scrollView;
@synthesize m_contentLength;
@synthesize m_selectedIndex;
@synthesize m_contentArray;
@synthesize m_headerIndices;
@synthesize m_contentSubviews;
@synthesize m_flickerTimer;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if ( self )
    {
        // Initialization code
        m_rowHeight = 40;
        
        m_selectedIndex = 0;

        m_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        m_contentSubviews = [[NSMutableArray alloc] init];

        m_scrollView.backgroundColor = [UIColor clearColor];
        m_scrollView.showsVerticalScrollIndicator = NO;
        m_scrollView.delegate = self;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        tap.numberOfTapsRequired = 1;
        [m_scrollView addGestureRecognizer:tap];
        [tap release];
                
        [self addSubview:m_scrollView];
        [self bringSubviewToFront:m_scrollView];
        
        m_headerIndices = [[NSMutableArray alloc] init];
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_scrollView removeFromSuperview];
    [m_scrollView release];
    [m_contentArray release];
    [m_headerIndices release];
    [m_contentSubviews release];
    [m_flickerTimer release];
    
    [super dealloc];
    
}

- (void)populateWithImages:(NSArray*)images
{
    m_contentLength = [images count];
    
    CGFloat frameHeight = self.frame.size.height;
    CGFloat frameWidth = self.frame.size.width;
    
    // Set the scroll view's content height. We add a buffer of
    // frameHeight so that the top/bottom items can be centered.
    CGFloat contentHeight = (frameHeight - m_rowHeight) + (m_contentLength * m_rowHeight);
    CGFloat contentWidth = frameWidth;
    
    m_scrollView.contentSize = CGSizeMake( contentWidth, contentHeight );
    
    // Create the frame for the initial image position
    CGFloat zeroOffset = [self convertIndexToOffset:0];
    
    CGRect fr = CGRectMake( 0, zeroOffset, frameWidth, m_rowHeight  );
    
    // Create each image and stick them in the view
    for ( UIImage * image in images )
    {
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:fr];
        
        imageView.image = image;
        
        [m_scrollView addSubview:imageView];
        [m_contentSubviews addObject:imageView];
        
        [imageView release];
        
        // Increment for the next image
        fr.origin.y += m_rowHeight;
        
    }
}

- (void) populateWithText:(NSArray*)text
{
    self.m_contentArray = text;
    m_contentLength = [text count];
    
    CGFloat frameHeight = self.frame.size.height;
    CGFloat frameWidth = self.frame.size.width;
    
    // Set the scroll view's content height. We add a buffer of
    // frameHeight so that the top/bottom items can be centered.
    CGFloat contentHeight = (frameHeight - m_rowHeight) + (m_contentLength * m_rowHeight);
    CGFloat contentWidth = frameWidth;
    
    m_scrollView.contentSize = CGSizeMake( contentWidth, contentHeight );
    
    // Create the frame for the initial image position
    CGFloat zeroOffset = [self convertIndexToOffset:0];
    
    CGRect fr = CGRectMake( 0, zeroOffset, frameWidth, m_rowHeight  );
    for (NSString* string  in text) 
    {
        UILabel *label = [[UILabel alloc] initWithFrame:fr];
        
        NSArray *words = [string componentsSeparatedByString:@" "];
        NSString *firstWord = [words objectAtIndex:0];
        [label setText:[firstWord uppercaseString]];
        
        [label setNumberOfLines:1];
        [label setMinimumFontSize:12];
        [label setAdjustsFontSizeToFitWidth:YES];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        
        UIFont *font = [label font];
        font = [font fontWithSize:13];
        [label setFont:font];
        [label setTextAlignment:UITextAlignmentCenter];
        
        [m_scrollView addSubview:label];
        [m_contentSubviews addObject:label];
        [label release];
        
        // Increment for the next row
        fr.origin.y += m_rowHeight;
    }
}

- (void)snapToClosestIndex
{
    
    CGFloat currentOffset = m_scrollView.contentOffset.y + m_rowHeight / 2;
    
    [self snapToOffset:currentOffset];
    
}

- (void)snapToLocation:(CGFloat)location
{
    
    // We need to convert from "offset space" into "index space"
    CGFloat zeroOffset = [self convertIndexToOffset:0];
    
    CGFloat deltaOffset = location - zeroOffset;
    
    [self snapToOffset:deltaOffset];
    
}

- (void)snapToOffset:(CGFloat)offset
{
    // Just figure out how many rows go into this offset
    CGFloat fractionalIndex = offset / m_rowHeight;
    
    NSInteger index = floor( fractionalIndex );
    
    [self snapToIndex:index];
}
                      
- (void)snapToIndex:(NSInteger)index
{
    // Bound it up and down
    index = MIN( index, m_contentLength-1 );
    index = MAX( 0, index );
    
    // Check if the selected index is a header row, if so go to the
    // next index down the list.
    for (NSNumber *header in m_headerIndices) 
    {
        if (index == [header intValue])
        {
            index++;
            break;
        }
    }
    
    // move scroll to center around the selected index.
    CGFloat offset = index * m_rowHeight;
    [m_scrollView setContentOffset:CGPointMake( 0, offset ) animated:YES];
    
    int oldIndex = m_selectedIndex;
    m_selectedIndex = index;
    
    // set alpha of old index to 1.
    [[m_contentSubviews objectAtIndex:oldIndex] setAlpha:1.0];
    
    if (oldIndex != m_selectedIndex)
    {
        // The value just changed, so let any observers know
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (CGFloat)convertIndexToOffset:(NSInteger)index
{
    
    // Convert from "offset space" to "index space" by subtracting
    // the buffer space we put at the begining of the scroll view
    
    CGFloat frameHeight = self.frame.size.height;

    CGFloat offset = index * m_rowHeight + (frameHeight-m_rowHeight)/2;
    
    return offset;
    
}

- (void)tapHandler:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint location = [gestureRecognizer locationInView:m_scrollView];
    
    [self snapToLocation:location.y];
    
}

// Make the currently selected (center) item flash on and off. The flashing will
// continue until stopFlicker is called. If scroll is moved to select a new item
// then the first item will stop flickering and the newly selected item will flicker.
- (void) flickerSelectedItem
{
    // If selected item is already flickering do nothing, i.e. only start a 
    // new timer if it is currently invalid, let a running timer continue
    if (![m_flickerTimer isValid])
    {
        [m_flickerTimer invalidate];
        self.m_flickerTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animateFlicker:) userInfo:nil repeats:YES];
    }
}

- (void) stopFlicker
{
    [m_flickerTimer invalidate];
    [[m_contentSubviews objectAtIndex:m_selectedIndex] setAlpha:1.0];
}

- (void) animateFlicker:(NSTimer*)theTimer
{
    UILabel *view = [m_contentSubviews objectAtIndex:m_selectedIndex];
    static float increment = 0;

    if (1.0 <= [view alpha])
    {
        increment += -0.1;
    }
    else if (0.0 >= [view alpha])
    {
        increment += 0.1;
    }
    
    [view setAlpha:([view alpha] + increment)];
}

- (void) makeHeaderEntryAtIndex:(NSUInteger)index
{
    [m_headerIndices addObject:[NSNumber numberWithInteger:index]];
    UILabel *view = [m_contentSubviews objectAtIndex:index];
    [view setTextColor:[UIColor blackColor]];
    [view setFont:[UIFont boldSystemFontOfSize:16]];
}

- (NSString*) getNameAtIndex:(NSUInteger)index
{
    return [m_contentArray objectAtIndex:index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    // We are about to stop scrolling. Snap to the closest row
    if ( decelerate == NO )
    {
        [self snapToClosestIndex];
    }
    
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
     [self snapToClosestIndex];
}

@end
