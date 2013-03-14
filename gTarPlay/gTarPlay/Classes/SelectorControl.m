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
    }
    
    return self;
}

- (void)setTitles:(NSArray*)titleArray
{
    
    if ( [titleArray count] == 0 )
    {
        return;
    }
    
    
    self.backgroundColor = [UIColor grayColor];
//    self.layer.borderColor = [[UIColor grayColor] CGColor];
//    self.layer.borderWidth = 1;
    
    // clean house
    for ( UIButton *button in _buttonViews )
    {
        [button removeFromSuperview];
    }
    
    [_buttonViews release];
    
    _buttonViews = nil;
    
    // create the new ones
    CGFloat width = self.frame.size.width / [titleArray count];
    CGFloat height = self.frame.size.height;
    
    NSMutableArray *newButtons = [[NSMutableArray alloc] init];
    
    for ( NSInteger i = 0; i < [titleArray count]; i++ )
    {
        NSString *title = [titleArray objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setFrame:CGRectMake(i*(width+1), 0, width, height)];
        
        // set the title
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        
        button.titleLabel.shadowOffset = CGSizeMake(1,1);
//        button.titleLabel.minimumScaleFactor = 10;
        
        button.layer.shadowRadius = 4;
        button.layer.shadowOffset = CGSizeMake(2, 2);
        
        // Set up the actions and add the subview
        [button addTarget:self action:@selector(segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        [newButtons addObject:button];
        
    }
    
    _buttonViews = newButtons;
    
    [self setSelectedIndex:0];
    
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
    
    _selectedIndex = index;

    // revert the previous segment
    UIButton * oldButton = [_buttonViews objectAtIndex:_selectedIndex];
    UIButton * newButton = [_buttonViews objectAtIndex:index];
    
    [oldButton setEnabled:YES];
    [newButton setEnabled:NO];
    
    _selectedIndex = [_buttonViews indexOfObject:newButton];
    
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
