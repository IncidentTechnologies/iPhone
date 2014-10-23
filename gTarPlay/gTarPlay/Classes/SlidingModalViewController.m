//
//  SlidingModalViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/14/13.
//
//

#import "SlidingModalViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface SlidingModalViewController ()

@end

@implementation SlidingModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Needs to be on screen to measure components
    
    // Custom initialization
    frameGenerator = [[FrameGenerator alloc] init];
    
    double screenWidth = [frameGenerator getFullscreenWidth];
    double contentWidth = _contentView.frame.size.width;
    double onY = _contentView.frame.origin.y;
    double offY = _contentView.frame.size.height;
    
    onFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, onY, contentWidth, _contentView.frame.size.height);
    
    offFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, offY, contentWidth, _contentView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startSlideUp];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidLayoutSubviews
{
    // For some reason, in iOS 8+ it needs to start off screen and in iOS 7 this breaks...
    
    if([frameGenerator startOffscreen]){
        [_contentView setFrame:offFrame];
    }
}

- (IBAction)closeButtonClicked:(id)sender
{
    [self startSlideDown];
    //[self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
}

- (void)startSlideUp
{
    
    [UIView setAnimationsEnabled:YES];
    
    // Start off screen
    [_contentView setFrame:offFrame];
    [_contentView setHidden:NO];
    
    
    [UIView animateWithDuration:0.3 animations:^(void){
        [_contentView setFrame:onFrame];
    }completion:^(BOOL finished){}];
    
}

- (void)startSlideDown
{
    
    [UIView setAnimationsEnabled:YES];
    
    // Start on screen
    [_contentView setFrame:onFrame];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        [_contentView setFrame:offFrame];
    }completion:^(BOOL finished){[self endSlideDown];}];
    
}

- (void)endSlideDown
{
    
    [_contentView setHidden:YES];
    [_contentView setFrame:onFrame];
    
    [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
    
}

@end
