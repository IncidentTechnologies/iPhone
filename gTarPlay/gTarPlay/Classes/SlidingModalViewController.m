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

- (void)viewWillAppear:(BOOL)animated
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
    // Start off screen
//    _contentView.transform = CGAffineTransformMakeTranslation(0, _contentView.frame.size.height);
    _contentView.layer.transform = CATransform3DMakeTranslation( 0, _contentView.frame.size.height, 0 );
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    // Slide up from the bottom of the screen
//    _contentView.transform = CGAffineTransformIdentity;
    _contentView.layer.transform = CATransform3DIdentity;

    [UIView commitAnimations];
}

- (void)startSlideDown
{
    // Start on the screen
//    _contentView.transform = CGAffineTransformIdentity;
    _contentView.layer.transform = CATransform3DIdentity;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endSlideDown)];
    
    // Slide off the bottom of the screen
    // For some reason, transform isn't working properly. Might be Apple bug?
//    _contentView.transform = CGAffineTransformMakeTranslation(0, _contentView.frame.size.height);
    _contentView.layer.transform = CATransform3DMakeTranslation( 0, _contentView.frame.size.height, 0 );

    // Animating the center is fine.
//    _contentView.center = CGPointMake(_contentView.center.x, _contentView.center.y+_contentView.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)endSlideDown
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
}

@end
