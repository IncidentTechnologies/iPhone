//
//  PopupViewController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 6/15/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "PopupViewController.h"

#import <QuartzCore/QuartzCore.h>

//#import "RoundedRectangleView.h"

@implementation PopupViewController

@synthesize m_popupDelegate;
//@synthesize m_backgroundView;
@synthesize m_closeButtonImage;
@synthesize m_popupTitle;

#define CLOSE_BUTTON_SIZE 33

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        
        m_attaching = NO;
        m_attached = NO;

    }
    
    return self;
    
}

- (void)dealloc
{

    [m_closeButtonImage release];
    [m_closeButton release];
    
    [m_fullScreenButton removeFromSuperview];
    [m_fullScreenButton release];

    [m_blackBackgroundView removeFromSuperview];
    [m_blackBackgroundView release];
    
    [m_popupTitle release];
//    [m_popupTitleLabel release];
    [m_popupTitleView release];
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // clear out the background so the rounded corners show through
    self.view.backgroundColor = [UIColor clearColor];
    
    CGFloat buttonSize = CLOSE_BUTTON_SIZE;
    
    CGRect buttonFrame = CGRectMake( self.view.frame.size.width - buttonSize, 0, buttonSize, buttonSize );
    
    m_closeButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    [m_closeButton setTitle:@"x" forState:UIControlStateNormal];
    [m_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [m_closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    [m_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:m_closeButton];
    
    self.view.layer.cornerRadius = 8.0;
    self.view.layer.borderWidth = 2.0;
    self.view.layer.borderColor = [[UIColor grayColor] CGColor];
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.view.clipsToBounds = YES;
    
    // Add a gray background gradient
    if ( YES )
    {
        // Draw a background gradient for the header view
        UIColor * color1 = [UIColor colorWithRed:180.0f/255.0f green:180.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        UIColor * color2 = [UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f];
//        UIColor * color3 = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
//        UIColor * color4 = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
                
        CAGradientLayer * gradient = [CAGradientLayer layer];
        
        gradient.frame = self.view.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[color1 CGColor],
//                           (id)[color2 CGColor],
//                           (id)[color3 CGColor],
                           (id)[color2 CGColor], nil];
        gradient.locations = [NSArray arrayWithObjects:
                              (id)[NSNumber numberWithFloat:0.05f],
//                              (id)[NSNumber numberWithFloat:0.2f],
//                              (id)[NSNumber numberWithFloat:0.8f],
                              (id)[NSNumber numberWithFloat:1.0f], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
    }
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma -
#pragma Attach view

- (void)attachToSuperView:(UIView*)superview
{
    
    if ( m_attached == YES || m_attaching == YES)
    {
        return;
    }
    
    m_attaching = YES;
    
    [self sharedAttachToSuperView:superview];
    
}

- (void)attachToSuperViewWithBlackBackground:(UIView *)superview
{
    
    if ( m_attached == YES || m_attaching == YES)
    {
        return;
    }
    
    m_attaching = YES;
    
    m_blackBackgroundView = [[UIView alloc] initWithFrame:superview.frame];
    
    m_blackBackgroundView.backgroundColor = [UIColor blackColor];
    m_blackBackgroundView.alpha = 0.0f;
    
    [superview addSubview:m_blackBackgroundView];
    
    [self sharedAttachToSuperView:superview];
    
}

- (void)sharedAttachToSuperView:(UIView*)superview
{
    
    // attach an invisible button behind us
    m_fullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 
                                                                    superview.frame.size.width,
                                                                    superview.frame.size.height) ];
    
    [m_fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [superview addSubview:m_fullScreenButton];
    
    // attach the main view to the super view
    // this forces the viewDidLoad to run
    [superview addSubview:self.view];
    
    // change the button image if possible
    if ( m_closeButtonImage != nil )
    {
        [m_closeButton setTitle:@"" forState:UIControlStateNormal];
        [m_closeButton setImage:m_closeButtonImage forState:UIControlStateNormal];
        [m_closeButton setImageEdgeInsets:UIEdgeInsetsMake(6, 4, 4, 6)];
    }
    
    self.view.transform = CGAffineTransformIdentity;
    
    // create a title bar if requested
    // It is a small blue gradient at the top of the window
    if ( m_popupTitle != nil )
    {
        m_popupTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        
        // Draw a background gradient for the header view
        UIColor * color1 = [UIColor colorWithRed:0.0f/255.0f green:174.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
        UIColor * color2 = [UIColor colorWithRed:0.0f/255.0f green:137.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
        UIColor * color3 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
        UIColor * color4 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:183.0f/255.0f alpha:1.0f];
        
        CAGradientLayer * gradient = [CAGradientLayer layer];
        
        gradient.frame = m_popupTitleView.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[color1 CGColor],
                           (id)[color2 CGColor],
                           (id)[color3 CGColor],
                           (id)[color4 CGColor], nil];
        gradient.locations = [NSArray arrayWithObjects:
                              (id)[NSNumber numberWithFloat:0.05f],
                              (id)[NSNumber numberWithFloat:0.2f],
                              (id)[NSNumber numberWithFloat:0.8f],
                              (id)[NSNumber numberWithFloat:1.0f], nil];
        [m_popupTitleView.layer insertSublayer:gradient atIndex:0];
        
        // create a label and stick it in the view
        CGRect frame = CGRectMake(CLOSE_BUTTON_SIZE, 0, self.view.frame.size.width - 2*CLOSE_BUTTON_SIZE, 30);
        UILabel * label = [[[UILabel alloc] initWithFrame:frame] autorelease];
        
        [label setText:m_popupTitle];
        
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake( 1, 1 );
        
        [m_popupTitleView addSubview:label];
        
        [self.view insertSubview:m_popupTitleView belowSubview:m_closeButton];
                
    }
    
    // set the view to a 'minimized' state
    self.view.alpha = 0.0f;
    self.view.transform = CGAffineTransformMakeScale( 0.1f, 0.1f );
    self.view.center = superview.center;
    
    // fade in animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationDidStopSelector:@selector(attachFinalize)];
    [UIView setAnimationDelegate:self];
    
    self.view.alpha = 1.0f;
    self.view.transform = CGAffineTransformIdentity;
    
    // if present
    m_blackBackgroundView.alpha = 0.8f;
    
    [UIView commitAnimations];
    
    // this won't get called automatically otherwise
//    if ( self.view != nil )
//    {
//        [self viewWillAppear:NO];
//    }
    
}

- (void)attachFinalize
{
    // nothing to do here by default
    m_attached = YES;
}

- (void)detachFromSuperView
{
    
    if ( m_attached == NO )
    {
        return;
    }

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDidStopSelector:@selector(detachFinalize)];
    [UIView setAnimationDelegate:self];
    
    self.view.alpha = 0.0f;
    self.view.transform = CGAffineTransformMakeScale( 0.1f, 0.1f );
    
    m_blackBackgroundView.alpha = 0.0f;
    
    [UIView commitAnimations];
    
    [m_fullScreenButton removeFromSuperview];
    [m_fullScreenButton release];
    m_fullScreenButton = nil;
    
}

- (void)detachFinalize
{

    [self.view removeFromSuperview];

    [m_blackBackgroundView removeFromSuperview];
    [m_blackBackgroundView release];
    m_blackBackgroundView = nil;

    [self viewWillDisappear:NO];
    
    if ( m_popupDelegate && [m_popupDelegate respondsToSelector:@selector(popupClosed:)] == YES )
    {
        [m_popupDelegate popupClosed:self];
    }
    
    [m_popupTitleView removeFromSuperview];
    [m_popupTitleView release];
    m_popupTitleView = nil;
    
    m_attached = NO;
    m_attaching = NO;
    
}

- (IBAction)fullScreenButtonClicked:(id)sender
{

    [self closeButtonClicked:sender];
    
}

- (IBAction)closeButtonClicked:(id)sender;
{
    
    [self detachFromSuperView];
    
}

@end
