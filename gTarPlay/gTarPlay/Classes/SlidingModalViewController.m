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
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (IBAction)closeButtonClicked:(id)sender
{
    [self startSlideDown];
}

- (void)startSlideUp
{
    [UIView setAnimationsEnabled:YES];
    
    // Needs to be on screen to measure components
    double screenWidth = [[UIScreen mainScreen] bounds].size.height;
    double contentWidth = _contentView.frame.size.width;
    
    onFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, _contentView.frame.origin.y, contentWidth, _contentView.frame.size.height);
    
    offFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, _contentView.frame.size.height, contentWidth, _contentView.frame.size.height);
    
    // Start off screen
    [_contentView setHidden:NO];
    [_contentView setFrame:offFrame];
    
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
