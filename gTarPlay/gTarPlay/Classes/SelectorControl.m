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
}

@end

@implementation SelectorControl

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
//        self.layer.borderColor = [[UIColor grayColor] CGColor];
//        self.layer.borderWidth = 1;
        
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
    // Can't do this in the init, let's do it here
    self.backgroundColor = [UIColor darkGrayColor];
    
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
        NSString *title = [_titleArray objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // +1 for the border between buttons
        [button setFrame:CGRectMake(i*(width+1), 0, width, height)];
        
        [button setBackgroundColor:[UIColor lightGrayColor]];
        
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.numberOfLines = 2;
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
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
    
    // revert the previous segment
    UIButton * oldButton = [_buttonViews objectAtIndex:_selectedIndex];
    UIButton * newButton = [_buttonViews objectAtIndex:index];
    
    [oldButton setEnabled:YES];
    [newButton setEnabled:NO];
    
    [oldButton setBackgroundColor:[UIColor lightGrayColor]];
    [newButton setBackgroundColor:[UIColor grayColor]];
    
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
