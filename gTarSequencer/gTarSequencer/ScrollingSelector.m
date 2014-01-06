//
//  ScrollingSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/26/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "ScrollingSelector.h"

@implementation ScrollingSelector

@synthesize delegate;
@synthesize options;
@synthesize leftArrow;
@synthesize rightArrow;
@synthesize cancelButton;
@synthesize scrollView;

- (id)initWithFrame:(CGRect)frame
{
        
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect wholeScreen = CGRectMake(0, 0, x, y);
    
    self = [super initWithFrame:wholeScreen];
    if (self) {
        
        // Black out the rest of the screen:
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        // Left and Right arrows
        // TODO: draw without images
        CGFloat arrowHeight = 66;
        CGFloat arrowWidth = 22;
        CGFloat inset = 15;
        CGRect arrowFrame = CGRectMake(x - inset - arrowWidth,
                                       (y - arrowHeight)/2,
                                       arrowWidth,
                                       arrowHeight);
        rightArrow = [[UIButton alloc] initWithFrame:arrowFrame];
        [rightArrow setImage:[UIImage imageNamed:@"Arrow_Right"] forState:UIControlStateNormal];
        [rightArrow addTarget:self action:@selector(userDidTapArrow:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightArrow];
        
        arrowFrame.origin.x = inset;
        
        leftArrow = [[UIButton alloc] initWithFrame:arrowFrame];
        [leftArrow setImage:[UIImage imageNamed:@"Arrow_Left"] forState:UIControlStateNormal];
        [leftArrow addTarget:self action:@selector(userDidTapArrow:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftArrow];
        
        NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:@"ScrollingSelector" owner:self options:nil];
        backgroundView = nibViews[0];
        backgroundView.frame = frame;
        backgroundView.layer.cornerRadius = 5.0;
        [self addSubview:backgroundView];
        
        scrollView.bounces = NO;
        scrollView.delegate = self;
        scrollView.userInteractionEnabled = YES;
        
        // Sizings:
        currentOrigin = CGPointMake(gap, 0);
        
        int iconSideLength = 60;
        gap = (frame.size.width - (iconSideLength*3))/4;
        
        iconSize = CGSizeMake(iconSideLength, iconSideLength);
        labelSize = CGSizeMake(104, 20);
        
        topRowIcon = 20;
        bottomRowIcon = 120;
        
        topRowLabel = 85;
        bottomRowLabel = 185;
    }
    return self;
}

- (void)setOptions:(NSMutableArray *)newOps
{
    options = newOps;
    
    NSString * suffix = @"Button_OFF";
    NSString * highlightedSuffix = @"Button_ON";
    
    names = [[NSMutableArray alloc] init];
    images = [[NSMutableArray alloc] init];
    highlightedImages = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dict in options)
    {
        NSString * name = [dict objectForKey:@"Name"];
        [names addObject:name];
        
        NSString * iconPrefix = [dict objectForKey:@"SelectorIconPrefix"];
        
        UIImage * normalImage = [UIImage imageNamed:[iconPrefix stringByAppendingString:suffix]];
        [images addObject:normalImage];
        
        UIImage * highlightedImage = [UIImage imageNamed:[iconPrefix stringByAppendingString:highlightedSuffix]];
        [highlightedImages addObject:highlightedImage];
    }
    
    [self updateDisplay];
}

- (void)moveFrame:(CGRect)newFrame
{
    backgroundView.frame = newFrame;
}

- (void)updateDisplay
{
    imageButtons = [[NSMutableArray alloc] init];
    
    for (UIView * subview in scrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    [self updateContentSize];
    
    [self layoutContent];
}

- (void)updateContentSize
{
    int columnsCount = [names count] / 2;
    
    if ( [names count] % 2 == 1 )
    {
        columnsCount++;
    }
    
    double totalWidth = gap + ( columnsCount * (iconSize.width + gap) );
    
    double totalHeight = scrollView.frame.size.height;
    
    contentSize = CGSizeMake(totalWidth, totalHeight);
    
    int size = contentSize.width;
    int scrollViewWidth = scrollView.frame.size.width;
    
    if ( size <= scrollViewWidth )
    {
        [self hideLeftArrow:YES rightArrow:YES];
    }
    else {
        [self hideLeftArrow:YES rightArrow:NO];
    }
    
    [scrollView setContentSize:contentSize];
    scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)hideLeftArrow:(BOOL)left rightArrow:(BOOL)right{
    
    [leftArrow setHidden:left];
    [rightArrow setHidden:right];
}

- (void)layoutContent
{
    for (int i=0;i<[images count];i++)
    {
        [self addImageAtIndex:i];
        
        [self addLabelAtIndex:i];
    }
}

- (void)addImageAtIndex:(int)index
{
    // -- update position:
    currentOrigin.x = [self xOriginForImageWithIndex:index];
    
    if ( index%2 == 0)
    {
        currentOrigin.y = topRowIcon;
    }
    else
    {
        currentOrigin.y = bottomRowIcon;
    }
    
    // -- make new image:
    CGRect imageFrame = CGRectMake(currentOrigin.x, currentOrigin.y, iconSize.width, iconSize.height);
    UIButton * button = [[UIButton alloc] initWithFrame:imageFrame];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [button setImage:[images objectAtIndex:index] forState:UIControlStateNormal];
    [button setImage:[highlightedImages objectAtIndex:index] forState:UIControlStateHighlighted];
    //[button setImage:[highlightedImages objectAtIndex:index] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(userDidSelectInstrument:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:button];
    [imageButtons addObject:button];
}

- (void)addLabelAtIndex:(int)index
{
    // -- update position:
    int imageOffset = [self xOriginForImageWithIndex:index];
    currentOrigin.x = imageOffset - gap/2;
    
    if ( index%2 == 0 )
    {
        currentOrigin.y = topRowLabel;
    }
    else
    {
        currentOrigin.y = bottomRowLabel;
    }
    
    // -- make new label:
    CGRect labelFrame = CGRectMake(currentOrigin.x, currentOrigin.y, labelSize.width, labelSize.height);
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:[names objectAtIndex:index]];
    [label setFont:[UIFont systemFontOfSize:14.0]];
    
    [scrollView addSubview:label];
}

- (int)xOriginForImageWithIndex:(int)index
{
    return (gap + (index/2) * (gap + iconSize.width));
}

#pragma mark Actions

- (IBAction)userDidCancel:(id)sender
{
    [delegate scrollingSelectorUserDidSelectIndex:-1];
}

- (IBAction)userDidSelectInstrument:(id)sender
{
    int selectedIndex = [imageButtons indexOfObject:sender];
    
    [delegate scrollingSelectorUserDidSelectIndex:selectedIndex];
}

#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scroller
{
    if (scroller.contentOffset.x <= 0)
    {
        [self hideLeftArrow:YES rightArrow:NO];
    }
    else if (scroller.contentOffset.x >= contentSize.width - scroller.frame.size.width)
    {
        [self hideLeftArrow:NO rightArrow:YES];
    }
    else {
        [self hideLeftArrow:NO rightArrow:NO];
    }
}

#pragma mark Scrolling

- (void)userDidTapArrow:(id)sender
{
    double scrollDistance = gap + iconSize.width;
    double maxScroll = contentSize.width - scrollView.frame.size.width;
    
    CGPoint newOffset = scrollView.contentOffset;

    // identify direction:
    if(sender == rightArrow){
        
        double expectedScroll = floor((scrollView.contentOffset.x+scrollDistance) / scrollDistance) * scrollDistance;
        newOffset.x = MIN(expectedScroll,maxScroll);
        
    }else{
        
        double expectedScroll = ceil((scrollView.contentOffset.x-scrollDistance) / scrollDistance) * scrollDistance;
        newOffset.x = MAX(expectedScroll,0);
    }
    
    [scrollView setContentOffset:newOffset animated:YES];
    
    if (scrollView.contentOffset.x <= 0){
        [self hideLeftArrow:YES rightArrow:NO];
    }else if (scrollView.contentOffset.x >= maxScroll){
        [self hideLeftArrow:NO rightArrow:YES];
    }else{
        [self hideLeftArrow:NO rightArrow:NO];
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