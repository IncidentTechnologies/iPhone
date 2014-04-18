//
//  SelectorControl.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/14/13.
//
//

#import "SelectorControl.h"

#import <QuartzCore/QuartzCore.h>

@interface SelectorControl ()
{
    NSArray *_titleArray;
    NSArray *_buttonViews;
    
    UIColor * selectedColor;
    UIColor * deselectedColor;
}

@end

@implementation SelectorControl

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        _selectedIndex = 0;
    }
    
    return self;
}

- (void)dealloc
{
    for ( UIButton *button in _buttonViews )
    {
        [button removeFromSuperview];
    }
    
    [_buttonViews release];
    [_titleArray release];
    
    [super dealloc];
}

- (void)layoutSubviews
{
    
    [self initColors];
    
    // Can't do this in the init, let's do it here
    self.backgroundColor = deselectedColor;
    
    //
    // Clean out the old buttons
    //
    for ( UIButton *button in _buttonViews )
    {
        [button removeFromSuperview];
    }
    
    [_buttonViews release];
    
    //
    // Create the new buttons.
    //
    
    NSUInteger titleCount = [_titleArray count];
    
    // Leave 1 pixel between each button as a border
    CGFloat width = (self.frame.size.width - titleCount + 1) / titleCount;
    CGFloat height = self.frame.size.height;
    
    NSMutableArray *newButtons = [[NSMutableArray alloc] init];
    
    for ( NSInteger i = 0; i < [_titleArray count]; i++ )
    {
        id title = [_titleArray objectAtIndex:i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // +1 for the border between buttons
        [button setFrame:CGRectMake(i*(width+1), 0, width, height)];
        
        [button setBackgroundColor:selectedColor];
        
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.numberOfLines = 2;
        [button.titleLabel setFont:[UIFont fontWithName:@"Avenir Next" size:20.0]];
        
        if ( [title isKindOfClass:[NSAttributedString class]] == YES )
        {
            NSMutableAttributedString *whiteString = [[[NSMutableAttributedString alloc] initWithAttributedString:title] autorelease];
            NSMutableAttributedString *grayString = [[[NSMutableAttributedString alloc] initWithAttributedString:title] autorelease];
            
            [whiteString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[whiteString length])];
            [grayString addAttribute:NSForegroundColorAttributeName value:deselectedColor range:NSMakeRange(0,[grayString length])];
            
            [button setAttributedTitle:whiteString forState:UIControlStateNormal];
            [button setAttributedTitle:grayString forState:UIControlStateHighlighted];
        }
        else
        {
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:deselectedColor forState:UIControlStateHighlighted];
        }
//        [button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
//        
//        button.titleLabel.shadowOffset = CGSizeMake(1,1);
//        button.titleLabel.minimumScaleFactor = 10;

//        button.layer.shadowRadius = 4;
//        button.layer.shadowOffset = CGSizeMake(2, 2);
        
        // Set up the actions and add the subview
        [button addTarget:self action:@selector(segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        [newButtons addObject:button];
        
    }
    
    _buttonViews = newButtons;
    
    [self setSelectedIndex:_selectedIndex];
}

- (void)initColors
{
    deselectedColor = [UIColor colorWithRed:63/255.0 green:96/255.0 blue:106/255.0 alpha:1.0];
    selectedColor = [UIColor colorWithRed:110/255.0 green:148/255.0 blue:158/255.0 alpha:1.0];
}

- (void)setTitles:(NSArray*)titleArray
{
    if ( [titleArray count] == 0 )
    {
        return;
    }
    
    _titleArray = [titleArray retain];
    
    [self layoutSubviews];
}

- (void)setTitle:(NSString*)title forIndex:(NSUInteger)index
{
    if ( index >= [_buttonViews count] )
    {
        return;
    }
    
    UIButton *button = [_buttonViews objectAtIndex:index];
    
    [button.titleLabel setText:title];
}

- (void)setSelectedIndex:(NSUInteger)index
{
    if ( index >= [_buttonViews count] )
    {
        return;
    }
    
    [self initColors];
    
    // revert the previous segment
    UIButton * oldButton = [_buttonViews objectAtIndex:_selectedIndex];
    UIButton * newButton = [_buttonViews objectAtIndex:index];
    
    [oldButton setEnabled:YES];
    [newButton setEnabled:NO];
    
    [oldButton setBackgroundColor:selectedColor];
    [newButton setBackgroundColor:deselectedColor];
    
    _selectedIndex = index;
}

- (void)setFontSize:(CGFloat)size
{
    for ( UIButton *button in _buttonViews )
    {
        button.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setFontSize:(CGFloat)size forIndex:(NSUInteger)index
{
    if ( index >= [_buttonViews count] )
    {
        return;
    }
    
    UIButton *button = [_buttonViews objectAtIndex:index];
    
    button.titleLabel.font = [UIFont systemFontOfSize:size];
}

- (void)segmentButtonClicked:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    NSUInteger selected = [_buttonViews indexOfObject:button];
    
    [self setSelectedIndex:selected];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
