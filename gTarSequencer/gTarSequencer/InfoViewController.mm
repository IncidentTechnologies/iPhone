//
//  InfoViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 2/19/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "InfoViewController.h"

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@interface InfoViewController ()

@end

@implementation InfoViewController

@synthesize delegate;
@synthesize gtarArrow;
@synthesize gtarButton;
@synthesize ophoArrow;
@synthesize ophoButton;

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
    
    gtarButton.layer.cornerRadius = 8.0;
    ophoButton.layer.cornerRadius = 8.0;
    
    [self drawArrowForImageView:gtarArrow];
    [self drawArrowForImageView:ophoArrow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchGtarLearnMore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.gtar.fm/"]];
}

- (IBAction)launchOphoLogin:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.opho.com/user/%@",[g_ophoMaster getUsername]]]];
}

- (void)drawArrowForImageView:(UIImageView *)imageView
{
    CGSize size = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 10;
    int playX = 0;
    int playY = 8;
    CGFloat playHeight = imageView.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 3.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    [imageView setImage:newImage];
    
    UIGraphicsEndImageContext();
}

@end
