//
//  ExpandableSearchBar.m
//  keysPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import "ExpandableSearchBar.h"

#import "UIImage+Keys.h"

#define CANCEL_BUTTON_HEIGHT _expandedFrame.size.height
#define CANCEL_BUTTON_BUFFER (_expandedFrame.size.height + 6)
#define CONTRACTED_LENGTH 135.0
#define TEXT_BOX_HEIGHT self.bounds.size.height

@interface ExpandableSearchBar ()
{
    CGRect _contractedFrame;
    CGRect _expandedFrame;
    
    UITextField *_textField;
    
    UIButton *_cancelButton;
    UIButton *_searchButton;
    
    UIImageView *_contractedPadding;
    UIView *_expandedPadding;
    
    UIActivityIndicatorView *_activityView;
    
    BOOL _animating;
    BOOL _expanded;
}

@end

@implementation ExpandableSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        [self sharedInit];
    }
    return self;
}

- (id)init
{
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    [self updateFrames];
    
    _animating = NO;
    _expanded = NO;
    
    // set up padding views
    _expandedPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 17)];
    
    _contractedPadding = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _contractedPadding.image = [UIImage imageNamed:@"MagGlass.png"];
    _contractedPadding.contentMode = UIViewContentModeScaleAspectFit;
    
    // set up the activity view
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.hidesWhenStopped = YES;
    [_activityView setFrame:CGRectMake(0, 0, 30, 17)];
    
    // init the text field
    UIImage *textFieldBackground = [UIImage imageNamed:@"SearchBar.png"];
    
    textFieldBackground = [textFieldBackground aspectFitImage:_expandedFrame.size];
    
    _textField = [[UITextField alloc] initWithFrame:_contractedFrame];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.background = [textFieldBackground resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 50) resizingMode:UIImageResizingModeStretch];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.placeholder = NSLocalizedString(@"Search...", NULL);
    _textField.leftView = _contractedPadding;
    _textField.leftViewMode = UITextFieldViewModeAlways;
//    _textField.rightView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 17)] autorelease];
    _textField.rightView = _activityView;
    _textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.delegate = self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_textField setFont:[UIFont fontWithName:@"Avenir Next" size:17.0]];
    
    // make the cancel button
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - CANCEL_BUTTON_HEIGHT, 0, CANCEL_BUTTON_HEIGHT, CANCEL_BUTTON_HEIGHT)];
    _cancelButton.alpha = 0.0;
    [_cancelButton setImage:[UIImage imageNamed:@"CancelButton"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_searchButton setFrame:CGRectMake(self.bounds.size.width - CANCEL_BUTTON_HEIGHT, 0, CANCEL_BUTTON_HEIGHT, CANCEL_BUTTON_HEIGHT)];
    _searchButton.alpha = 1.0;
    [_searchButton setUserInteractionEnabled:YES];
    [_searchButton setEnabled:YES];
    [_searchButton setTintColor:[UIColor whiteColor]];
    [_searchButton setContentEdgeInsets:UIEdgeInsetsMake(4.0, 6.0, 4.0, 6.0)];
    [_searchButton setImage:[UIImage imageNamed:@"MagGlass"] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(searchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_textField];
    [self addSubview:_cancelButton];
    [self addSubview:_searchButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( _animating == NO )
    {
        [self updateFrames];
        
        [_textField setFrame:_contractedFrame];
        [_cancelButton setFrame:CGRectMake(self.bounds.size.width - CANCEL_BUTTON_HEIGHT, 0, CANCEL_BUTTON_HEIGHT, CANCEL_BUTTON_HEIGHT)];
        [_searchButton setFrame:CGRectMake(self.bounds.size.width - CANCEL_BUTTON_HEIGHT, 0, CANCEL_BUTTON_HEIGHT, CANCEL_BUTTON_HEIGHT)];
    }
}

#pragma mark - External access

- (void)endSearch
{
    [self cancelButtonClicked:nil];
}

- (void)beginSearch
{
    [_textField becomeFirstResponder];
}

- (void)minimizeKeyboard
{
    [_textField resignFirstResponder];
}

- (void)startActivityAnimation
{
    [_activityView startAnimating];
}

- (void)stopActivityAnimation;
{
    [_activityView stopAnimating];
}

#pragma mark - Misc

- (void)searchButtonClicked:(id)sender
{    
    [self expandSearchBar];
    
    if ( [_delegate respondsToSelector:@selector(searchBarDidBeginEditing:)] == YES )
    {
        [_delegate performSelector:@selector(searchBarDidBeginEditing:) withObject:self];
    }
}

- (void)cancelButtonClicked:(id)sender
{
    [_textField resignFirstResponder];
    
    [self contractSearchBar];
    
    if ( [_delegate respondsToSelector:@selector(searchBarCancel:)] == YES )
    {
        [_delegate performSelector:@selector(searchBarCancel:) withObject:self];
    }
}

- (void)updateFrames
{
    // Subtract out a bit from the end for the cancel button
    _expandedFrame = self.bounds;
    _expandedFrame.size.width = self.bounds.size.width - CANCEL_BUTTON_BUFFER;
    _expandedFrame.size.height = TEXT_BOX_HEIGHT;
    _expandedFrame.origin.x = 0.0;
    _expandedFrame.origin.y = (self.bounds.size.height - TEXT_BOX_HEIGHT)/2.0;
    
    _contractedFrame = self.bounds;
    _contractedFrame.size.width = 0.0;
    _contractedFrame.size.height = TEXT_BOX_HEIGHT;
    _contractedFrame.origin.x = self.bounds.size.width + CANCEL_BUTTON_HEIGHT;
    _contractedFrame.origin.y = (self.bounds.size.height - TEXT_BOX_HEIGHT)/2.0;
}

#pragma mark - Animation

- (void)expandSearchBar
{
    _animating = YES;
    _expanded = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDidStopSelector:@selector(expandSearchBarFinished)];
    [UIView setAnimationDelegate:self];
    
    [_textField setFrame:_expandedFrame];
    
    _textField.leftView = _expandedPadding;
    _cancelButton.alpha = 1.0;
    _searchButton.alpha = 0.0;

    [UIView commitAnimations];
}

- (void)expandSearchBarFinished
{
    _animating = NO;
}

- (void)contractSearchBar
{
    _animating = YES;
    _expanded = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDidStopSelector:@selector(contractSearchBarFinished)];
    [UIView setAnimationDelegate:self];
    
    [_textField setFrame:_contractedFrame];
    
    _textField.leftView = _contractedPadding;
    _cancelButton.alpha = 0.0;
    _searchButton.alpha = 1.0;
    
    [UIView commitAnimations];
}

- (void)contractSearchBarFinished
{
    _animating = NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self expandSearchBar];
    
    if ( [_delegate respondsToSelector:@selector(searchBarDidBeginEditing:)] == YES )
    {
        [_delegate performSelector:@selector(searchBarDidBeginEditing:) withObject:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
//    [self contractSearchBar];
    
    [_textField resignFirstResponder];
    
    _searchString = _textField.text;
    
    if ( [_delegate respondsToSelector:@selector(searchBarSearch:)] == YES )
    {
        [_delegate performSelector:@selector(searchBarSearch:) withObject:self];
    }
    
	return NO;
}


@end
