//
//  TransitionRectangleViewController.m
//  keysPlay
//
//  Created by Marty Greenia on 6/9/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "TransitionRectangleViewController.h"
#import "RoundedRectangleView.h"
#import "RoundedRectangleButton.h"

@implementation TransitionRectangleViewController

@synthesize m_title;
@synthesize m_imageArray;
@synthesize m_textArray;
@synthesize m_displayView;
@synthesize m_nextButton;
@synthesize m_backButton;
@synthesize m_doneButton;
@synthesize m_pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        m_viewArray = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    if ( m_displayView == nil || m_nextButton == nil || m_backButton == nil || m_doneButton == nil )
    {
        [self createDefaultViews];
    }
    
    // add gesture recognizers
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonClicked:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextButtonClicked:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer];
    
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_displayView = nil;
    self.m_nextButton = nil;
    self.m_backButton = nil;
    self.m_doneButton = nil;
    self.m_pageControl = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self convertImageAndTextArrays];
    
    // attach first view (if it exists)
    if ( [m_viewArray count] > 0 )
    {
        m_currentView = [m_viewArray objectAtIndex:0];   
    }
    
    if ( [m_viewArray count] > 1 )
    {
        [m_backButton setHidden:YES];
        [m_nextButton setHidden:NO];
        [m_doneButton setHidden:YES];
    }
    else
    {
        [m_backButton setHidden:YES];
        [m_nextButton setHidden:YES];
        [m_doneButton setHidden:NO];
    }
    
    m_currentIndex = 0;
    
    // update the page control
    [m_pageControl setNumberOfPages:[m_viewArray count]];
    [m_pageControl setCurrentPage:0];
    
    // attach the view
    m_currentView.center = CGPointMake( m_displayView.frame.size.width/2, m_displayView.frame.size.height/2 );
    m_currentView.alpha = 1.0f;
    m_currentView.transform = CGAffineTransformIdentity;
    
    [m_displayView addSubview:m_currentView];
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [m_currentView removeFromSuperview];

    m_currentView = nil;
    
    // clear out old junk
    m_viewArray = nil;

}

#pragma mark - Button clicked handlers

- (IBAction)nextButtonClicked:(id)sender
{
    
    // kinda hacky but prevents the guesture recognize from screwing us up
    if ( m_nextButton.hidden == YES || m_nextButton.enabled == NO )
    {
        return;
    }

    m_currentIndex++;
    
    if ( m_currentIndex < [m_viewArray count] )
    {
        
        // do animation
        UIView * newView = [m_viewArray objectAtIndex:m_currentIndex];
        
        [m_pageControl setCurrentPage:m_currentIndex];

        [self swapInViewLeft:newView];
        
    }
    
    if ( m_currentIndex == ( [m_viewArray count] - 1 ) )
    {
        
        // hide the next button
        [m_nextButton setHidden:YES];
        [m_doneButton setHidden:NO];
        
    }
    else
    {
        
        // show the button
        [m_nextButton setHidden:NO];
        [m_doneButton setHidden:YES];
        
    }
    

    if ( [m_viewArray count] > 1 )
    {
        [m_backButton setHidden:NO];
    }
    
}

- (IBAction)backButtonClicked:(id)sender
{
    
    // kinda hacky but prevents the guesture recognize from screwing us up
    if ( m_backButton.hidden == YES || m_nextButton.enabled == NO )
    {
        return;
    }
    
    m_currentIndex--;
    
    if ( m_currentIndex >= 0 )
    {
        // do animation
        UIView * newView = [m_viewArray objectAtIndex:m_currentIndex];
        
        [m_pageControl setCurrentPage:m_currentIndex];

        [self swapInViewRight:newView];
        
    }
    
    if ( m_currentIndex == 0 )
    {
        
        // hide the back button
        [m_backButton setHidden:YES];
        
    }
    else
    {

        // show the button
        [m_backButton setHidden:NO];
        
    }
    
    if ( [m_viewArray count] > 1 )
    {
        [m_nextButton setHidden:NO];
    }

    [m_doneButton setHidden:YES];

}

- (IBAction)doneButtonClicked:(id)sender;
{
    
    [self closeButtonClicked:sender];

}

#pragma mark - Manage views

//- (void)sharedAttachToSuperView:(UIView*)superview
//{
//    
//    [super sharedAttachToSuperView:superview];
//    
//}

- (void)convertImageAndTextArrays
{
    
    if ( [m_imageArray count] == 0 || [m_imageArray count] != [m_textArray count] )
    {
        return;
    }
    
    
    m_viewArray = [[NSMutableArray alloc] init];

    NSInteger count = [m_imageArray count];
    
    // Create a title slide if requested
    if ( [m_title isEqualToString:@""] == NO )
    {
        
        UIView * currentView = [[UIView alloc] initWithFrame:m_displayView.frame];
        
        UILabel * textView = [[UILabel alloc] initWithFrame:currentView.frame];
        CGRect fr = textView.frame;
        fr.origin.x = 0;
        fr.origin.y = 0;
        textView.frame = fr;
        
        textView.backgroundColor = [UIColor clearColor];            
        textView.textAlignment = NSTextAlignmentCenter;
        textView.text = m_title;
        
        // make it bold
        textView.font = [UIFont boldSystemFontOfSize:30];
        
        [currentView addSubview:textView];
        
        [m_viewArray addObject:currentView];
        
        
    }
    
    // Create a slide for each one provided
    for ( NSInteger index = 0; index < count; index++ )
    {
        
        NSString * imageString = [m_imageArray objectAtIndex:index];
        NSString * textString = [m_textArray objectAtIndex:index];
        
        UIView * currentView = [[UIView alloc] initWithFrame:m_displayView.frame];
        
        if ( [imageString isEqualToString:@""] == NO )
        {
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:currentView.frame];
            CGRect fr = imageView.frame;
            fr.origin.x = 0;
            fr.origin.y = 0;
            imageView.frame = fr;
            
            imageView.image = [UIImage imageNamed:imageString];
            
            [currentView addSubview:imageView];
            
            if ( [textString isEqualToString:@""] == NO )
            {
                
                NSInteger height = 80;
                NSInteger width = imageView.frame.size.width/4*3;
                
                CGRect rect = CGRectMake( (imageView.frame.size.width - width) / 2,
                                         imageView.frame.size.height - height,
                                         width, height );
                
                UITextView * textView = [[UITextView alloc] initWithFrame:rect];
                textView.backgroundColor = [UIColor clearColor];
                textView.textAlignment = NSTextAlignmentCenter;
                textView.text = textString;
                
                [imageView addSubview:textView];
                
                
            }
            
            
        }
        else if ( [textString isEqualToString:@""] == NO )
        {
            
            //            UITextView * textView = [[UITextView alloc] initWithFrame:currentView.frame];
            UILabel * textView = [[UILabel alloc] initWithFrame:currentView.frame];
            CGRect fr = textView.frame;
            fr.origin.x = 20;
            fr.origin.y = 0;
            fr.size.width -= 40;
            textView.frame = fr;
            
            textView.backgroundColor = [UIColor clearColor];            
            textView.textAlignment = NSTextAlignmentCenter;
            textView.text = textString;
            
            textView.numberOfLines = 10;
            
            [currentView addSubview:textView];
            
        }
        
        [m_viewArray addObject:currentView];
        
        
    }

}

- (void)addView:(UIView*)newView
{
    
    [m_viewArray addObject:newView];
    
}

- (void)swapInViewLeft:(UIView*)nextView
{
    
    m_nextView = nextView;
    
    // calculate start and end points
    CGAffineTransform nextStartTransform = CGAffineTransformMakeTranslation( m_displayView.frame.size.width/2 + m_nextView.frame.size.width/2, 0);
    CGAffineTransform currentEndTransform = CGAffineTransformMakeTranslation( -m_displayView.frame.size.width/2 - m_currentView.frame.size.width/2, 0);
    
    [self swapViewsWithNextTransform:nextStartTransform andCurrentTransform:currentEndTransform];

}

- (void)swapInViewRight:(UIView*)nextView
{

    m_nextView = nextView;
    
    // calculate start and end points
    CGAffineTransform nextStartTransform = CGAffineTransformMakeTranslation( -m_displayView.frame.size.width/2 - m_nextView.frame.size.width/2, 0);
    CGAffineTransform currentEndTransform = CGAffineTransformMakeTranslation( m_displayView.frame.size.width/2 + m_currentView.frame.size.width/2, 0);
    
    [self swapViewsWithNextTransform:nextStartTransform andCurrentTransform:currentEndTransform];
    
}

- (void)swapViewsWithNextTransform:(CGAffineTransform)nextStartTransform andCurrentTransform:(CGAffineTransform)currentEndTransform
{
    
    // disable the button so it isn't clicked twice
    [m_nextButton setEnabled:NO];
    [m_backButton setEnabled:NO];
    
    // start the view off screen.
    m_nextView.center = CGPointMake( m_displayView.frame.size.width/2, m_displayView.frame.size.height/2 );
    m_nextView.alpha = 0.0f;
    m_nextView.transform = nextStartTransform;
    [m_displayView addSubview:m_nextView];
    
    // do the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(swapViewFinished)];
    
    m_nextView.transform = CGAffineTransformIdentity;
    m_currentView.transform = currentEndTransform;
    
    m_nextView.alpha = 1.0f;
    m_currentView.alpha = 0.0f;
    
    [UIView commitAnimations];
    
}

- (void)swapViewFinished
{
    // remove the old one
    [m_currentView removeFromSuperview];
    
    // the next becomes the current. 
    m_currentView = m_nextView;
    
    [m_nextButton setEnabled:YES];
    [m_backButton setEnabled:YES];

}

#pragma mark - Default Buttons

- (void)createDefaultViews
{
    
    //
    // Create some default buttons. Next, Back, Done
    //
//    CGFloat buttonHeight = 37;
//    CGFloat buttonWidth = 75;
//    
//    CGFloat buttonSpace = 37;
//    CGFloat buttonBottomBuffer = 5;
    
    // wide enough to hold two buttons
//    CGRect containerFrame = CGRectMake( 0, 0,
//                                        buttonSpace + buttonWidth*2,
//                                        buttonHeight );
//
//    CGPoint containerCenter = CGPointMake( self.view.frame.size.width/2, 
//                                           self.view.frame.size.height - buttonHeight/2 - buttonBottomBuffer );
//
//    UIView * buttonContainer = [[UIView alloc] initWithFrame:containerFrame];
//    
//    buttonContainer.center = containerCenter;
    
    // Now we can add some buttons.
//    RoundedRectangleButton * back = [[RoundedRectangleButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
//    RoundedRectangleButton * next = [[RoundedRectangleButton alloc] initWithFrame:CGRectMake(buttonWidth + buttonSpace, 0, buttonWidth, buttonHeight)];
//    RoundedRectangleButton * done = [[RoundedRectangleButton alloc] initWithFrame:CGRectMake(buttonWidth + buttonSpace, 0, buttonWidth, buttonHeight)];

//    UIButton * back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
//    UIButton * next = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth + buttonSpace, 0, buttonWidth, buttonHeight)];
//    UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth + buttonSpace, 0, buttonWidth, buttonHeight)];

    // 
    // If buttons have been preasigned (e.g. from nib) dont recreate them
    //
    
//    UIButton * back;
//    UIButton * next;
//    UIButton * done;
//    
//    if ( m_backButton == nil )
//    {
//        back = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        back.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
//    }
//    else
//    {
//        back = m_backButton;
//    }
//    
//    if ( m_nextButton == nil )
//    {
//        next = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        next.frame = CGRectMake(buttonWidth + buttonSpace, 0, buttonWidth, buttonHeight);
//    }
//    else
//    {
//        next = m_nextButton;
//    }
//    
//    if ( m_doneButton == nil )
//    {
//        done = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth + buttonSpace, 0, buttonWidth, buttonHeight)];
//    }
//    else
//    {
//        done = m_doneButton;
//    }
//
//    [back addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [next addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [done addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    [back setTitle:@"<-" forState:UIControlStateNormal];
//    [next setTitle:@"->" forState:UIControlStateNormal];
//    [done setTitle:@"X" forState:UIControlStateNormal];
    
//    if ( m_backButton == nil )
//    {
//        [buttonContainer addSubview:back];
//    }
    
//    [buttonContainer addSubview:done];

//    if ( m_nextButton == nil )
//    {
//        [buttonContainer addSubview:next];
//    }
    
//    [self.view addSubview:buttonContainer];
    
//    self.m_backButton = back;
//    self.m_nextButton = next;
//    self.m_doneButton = done;
    
//    [back release];
//    [next release];
//    [done release];
    
    [m_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [m_nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [m_doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    //
    // Also create default display view
    //
    if ( m_displayView == nil )
    {
        CGFloat displayBuffer = 20;
        
        CGFloat displayWidth = self.view.frame.size.width - displayBuffer*2;

        CGFloat displayHeight = self.view.frame.size.height - displayBuffer*2;

        CGRect displayFrame = CGRectMake( displayBuffer, displayBuffer, displayWidth, displayHeight );
        
        UIView * displayView = [[UIView alloc] initWithFrame:displayFrame];
        
        displayView.clipsToBounds = YES;
        displayView.layer.cornerRadius = 8.0;
        
        [self.view addSubview:displayView];
        [self.view bringSubviewToFront:m_backButton];
        [self.view bringSubviewToFront:m_nextButton];

        self.m_displayView = displayView;
        
        
        m_displayView.backgroundColor = [UIColor whiteColor];
    }
    
}

@end
