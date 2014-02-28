//
//  InfoViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 2/19/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

@synthesize delegate;
@synthesize infoButton;
@synthesize infoArrow;

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
    
    infoButton.layer.cornerRadius = 8.0;
    
    NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@"Visit gTar.fm to Learn More"];
    [titleString setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0]} range:NSMakeRange(6,7)];
    
    [infoButton setAttributedTitle:titleString forState:UIControlStateNormal];
    
    
    [self drawInfoArrow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchLearnMore:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.gtar.fm/"]];
}


- (void)drawInfoArrow
{
    CGSize size = CGSizeMake(infoArrow.frame.size.width, infoArrow.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 8;
    int playX = 0;
    int playY = 8;
    CGFloat playHeight = infoArrow.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    [infoArrow setImage:newImage];
    
    UIGraphicsEndImageContext();
}

@end
