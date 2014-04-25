//
//  SlidingViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import "SlidingViewController.h"

#import <AVFoundation/AVFoundation.h>

#define SCREEN_HEIGHT 320

@interface SlidingViewController ()
{
//    BOOL _isDown;
    BOOL _isSliding;
    BOOL invertView;
}
@end

@implementation SlidingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)dealloc
{
    [_contentView release];
    [super dealloc];
}

//- (void)attachToSuperview:(UIView *)view
//{
//    [self attachToSuperview:view withFrame:view.bounds];
//}

- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect
{
    [self.view setFrame:rect];
    
    self.view.userInteractionEnabled = NO;
    
    //_contentView.layer.transform = CATransform3DMakeTranslation(0 , -self.view.frame.size.height, 0);
    
    [_contentView setFrame:[self contentViewOffFrame]];
    
    [view addSubview:self.view];
    
    _isDown = NO;
    _isSliding = NO;
    
    [_triangleIndicatorImage setHidden:YES];
}

- (void)invertView:(BOOL)invert
{
    invertView = invert;
}

- (void)toggleView:(BOOL)animated
{
    if ( _isDown )
    {
        [self closeView:animated];
    }
    else
    {
        [self openView:animated];
    }
    
//    self.view.userInteractionEnabled = _isDown;
//    
//    if ( _isDown == YES )
//    {
//        [_triangleIndicatorImage setHidden:NO];
//    }
//    
//    if ( animated == YES )
//    {
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.3f];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(slidingComplete)];
//    }
//    
//    if ( _isDown == YES )
//    {
//        _contentView.layer.transform = CATransform3DIdentity;
//    }
//    else
//    {
//        _contentView.layer.transform = CATransform3DMakeTranslation(0 , -_contentView.frame.size.height, 0);
//    }
//    
//    if ( animated == YES )
//    {
//        [UIView commitAnimations];
//    }
}

- (void)slidingComplete
{
    _isSliding = NO;
    
    if ( _isDown == NO )
    {
        [_triangleIndicatorImage setHidden:YES];
        self.view.userInteractionEnabled = NO;
    }
}

- (CGRect)contentViewOnFrame
{
    CGRect onFrame = CGRectMake(_contentView.frame.origin.x, 0, _contentView.frame.size.width, _contentView.frame.size.height);
    
    return onFrame;
}

- (CGRect)contentViewOffFrame
{
    // check for inversion
    CGRect offFrame;
    
    if(invertView){
        offFrame = CGRectMake(_contentView.frame.origin.x, SCREEN_HEIGHT, _contentView.frame.size.width, _contentView.frame.size.height);
    }else{
        offFrame = CGRectMake(_contentView.frame.origin.x, -1*_contentView.frame.size.height, _contentView.frame.size.width, _contentView.frame.size.height);
    }
    
    return offFrame;
}

- (void)closeView:(BOOL)animated
{
//    if ( _isSliding )
//    {
//        // We don't want to slide multiple times at once
//        return;
//    }
    
    if ( _isDown == NO )
    {
        // Nothing to do
        return;
    }
    
    _isDown = NO;
    
    self.view.userInteractionEnabled = NO;
    
    float animationDuration = 0.0;
    
    // Animate as requested
    if ( animated == YES )
    {
        _isSliding = YES ;
        animationDuration = 0.3;
        
        //[UIView beginAnimations:nil context:NULL];
        //[UIView setAnimationDuration:0.3f];
        //[UIView setAnimationDelegate:self];
        //[UIView setAnimationDidStopSelector:@selector(slidingComplete)];
    }
    
    //_contentView.layer.transform = CATransform3DMakeTranslation(0 , -_contentView.frame.size.height, 0);
    
    [UIView animateWithDuration:animationDuration animations:^(void){
        [_contentView setFrame:[self contentViewOffFrame]];
    } completion:^(BOOL finished){
        [self slidingComplete];
    }];
    
    if ( animated == YES )
    {
        [UIView commitAnimations];
    }
    else
    {
        [_triangleIndicatorImage setHidden:YES];
    }
}

- (void)openView:(BOOL)animated
{
//    if ( _isSliding )
//    {
//        // We don't want to slide multiple times at once
//        return;
//    }
    
    if ( _isDown == YES )
    {
        // Nothing to do
        return;
    }
    
    _isDown = YES;
    
    self.view.userInteractionEnabled = YES;
    
    [_triangleIndicatorImage setHidden:NO];
    
    float animationDuration = 0.0;
    
    // Animate as requested
    if ( animated == YES )
    {
        _isSliding = YES ;
        
        animationDuration = 0.3;
        //[UIView beginAnimations:nil context:NULL];
        //[UIView setAnimationDuration:0.3f];
        //[UIView setAnimationDelegate:self];
        //[UIView setAnimationDidStopSelector:@selector(slidingComplete)];
    }
    
    
    //    _contentView.layer.transform = CATransform3DIdentity;
    
    [UIView animateWithDuration:animationDuration animations:^(void){
        [_contentView setFrame:[self contentViewOnFrame]];
    } completion:^(BOOL finished){
        [self slidingComplete];
    }];
    
    if ( animated == YES )
    {
        [UIView commitAnimations];
    }

}

- (void)setFrame:(CGRect)frame
{
    //_contentView.layer.transform = CATransform3DIdentity;
    
    [_contentView setFrame:[self contentViewOnFrame]];
    
    self.view.frame = frame;
    
    if ( _isDown == YES )
    {
        //_contentView.layer.transform = CATransform3DIdentity;
        
        [_contentView setFrame:[self contentViewOnFrame]];
    }
    else
    {
        //_contentView.layer.transform = CATransform3DMakeTranslation(0 , -_contentView.frame.size.height, 0);
        
        [_contentView setFrame:[self contentViewOffFrame]];
    }
}


- (void)colorTriangleIndicator:(UIColor *)color
{
    _triangleIndicatorImage.tintColor = color;
}

- (void)invertTriangleIndicator
{
    [_triangleIndicatorImage setFrame:CGRectMake(_triangleIndicatorImage.frame.origin.x, _contentView.frame.size.height-_triangleIndicatorImage.frame.size.height, _triangleIndicatorImage.frame.size.width, _triangleIndicatorImage.frame.size.height)];
    
    _triangleIndicatorImage.transform = CGAffineTransformMakeScale(1, -1);
}

//- (UIImage *)drawTriangleInRect:(CGSize)size
//{
//    UIGraphicsBeginImageContext(size);
//
//    CGContextRef contextRef = UIGraphicsGetCurrentContext();
//
//    // Draw the square itself and close the path
//    CGContextBeginPath( contextRef );
//    CGContextMoveToPoint(contextRef, 0, 0);
//    CGContextAddLineToPoint( contextRef, size.width, 0 );
//    CGContextAddLineToPoint( contextRef, size.width / 2.0, size.height );
//    CGContextAddLineToPoint( contextRef, 0, 0 );
//
//    CGContextClosePath( contextRef );
//    CGContextSetFillColorWithColor( contextRef, [UIColor redColor].CGColor);
//    CGContextFillPath( contextRef );
//
//    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    return image;
//}

@end
