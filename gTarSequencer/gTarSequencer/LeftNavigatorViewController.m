//
//  LeftNavigation.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "LeftNavigatorViewController.h"

@implementation LeftNavigatorViewController

@synthesize delegate;
@synthesize optionsButton;
@synthesize seqSetButton;
@synthesize instrumentButton;
@synthesize shareButton;
@synthesize connectedButton;
@synthesize leftSlider;
@synthesize customIndicator;
@synthesize connectedLeftArrow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    silverColor = [UIColor colorWithRed:201/255.0 green:205/255.0 blue:206/255.0 alpha:1.0];
    redColor = [UIColor colorWithRed:203/255.0 green:81/255.0 blue:26/255.0 alpha:1.0];
    blueColor = [UIColor colorWithRed:34/255.0 green:140/255.0 blue:167/255.0 alpha:1.0];
    greenColor = [UIColor colorWithRed:31/255.0 green:187/255.0 blue:40/255.0 alpha:1.0];
    
    // Add icons
    [seqSetButton setImage:[UIImage imageNamed:@"Set_Icon"] forState:UIControlStateNormal];
    float seqSetImageHeight = 22.0;
    float seqSetImageWidth = 30.4;
    [seqSetButton setImageEdgeInsets:UIEdgeInsetsMake((seqSetButton.frame.size.height-seqSetImageHeight)/2, (seqSetButton.frame.size.width-seqSetImageWidth)/2, (seqSetButton.frame.size.height-seqSetImageHeight)/2, (seqSetButton.frame.size.width-seqSetImageWidth)/2)];
    
    defaultInstrumentIcon = [self drawDefaultInstrumentIcon];
    [instrumentButton setImage:defaultInstrumentIcon forState:UIControlStateNormal];
    float instrumentImageHeight = instrumentButton.frame.size.height-5.0;
    float instrumentImageWidth = instrumentButton.frame.size.height-5.0;
    [instrumentButton setImageEdgeInsets:UIEdgeInsetsMake((instrumentButton.frame.size.height-instrumentImageHeight)/2, (instrumentButton.frame.size.width-instrumentImageWidth)/2, (instrumentButton.frame.size.height-instrumentImageHeight)/2, (instrumentButton.frame.size.width-instrumentImageWidth)/2)];
    [self hideCustomIndicator];
    
    [optionsButton setImage:[UIImage imageNamed:@"Save_Icon"] forState:UIControlStateNormal];
    float optionsImageHeight = 26.0;
    float optionsImageWidth = 26.0;
    [optionsButton setImageEdgeInsets:UIEdgeInsetsMake((optionsButton.frame.size.height-optionsImageHeight)/2, (optionsButton.frame.size.width-optionsImageWidth)/2, (optionsButton.frame.size.height-optionsImageHeight)/2, (optionsButton.frame.size.width-optionsImageWidth)/2)];
    
    [connectedButton setImage:[UIImage imageNamed:@"G_Icon"] forState:UIControlStateNormal];
    float gImageHeight = 26.0;
    float gImageWidth = 20.0;
    [connectedButton setImageEdgeInsets:UIEdgeInsetsMake((connectedButton.frame.size.height-gImageHeight)/2, (connectedButton.frame.size.width-gImageWidth)/2, (connectedButton.frame.size.height-gImageHeight)/2, (connectedButton.frame.size.width-gImageWidth)/2)];
    
    // Arrow
    [self drawConnectedLeftArrow];
    
    // Style elements
    [self resetButtonColors];
    
    leftSlider.layer.cornerRadius = 2.0;
}

- (void)viewDidUnload
{
    
}

-(void)changeConnectedButton:(BOOL)isConnected
{
    if(isConnected){
        connectedButton.backgroundColor = greenColor;
        //connectedButton.layer.borderColor = greenColor.CGColor;
    }else{
        connectedButton.backgroundColor = redColor;
        //connectedButton.layer.borderColor = redColor.CGColor;
    }
}

- (IBAction)selectNav:(id)sender
{
    if(sender == optionsButton){
        [delegate selectNavChoice:@"Options" withShift:YES];
    }else if(sender == seqSetButton){
        [delegate selectNavChoice:@"Set" withShift:YES];
    }else if(sender == instrumentButton && instrumentViewEnabled){
        [delegate selectNavChoice:@"Instrument" withShift:YES];
    }else if(sender == shareButton){
        [delegate selectNavChoice:@"Share" withShift:YES];
    }else if(sender == connectedButton){
        [delegate selectNavChoice:@"Info" withShift:YES];
    }
}

-(void)setNavButtonOn:(NSString *)navChoice
{
    [self resetButtonColors];
    
    if([navChoice isEqualToString:@"Options"]){
        optionsButton.backgroundColor = blueColor;
        //optionsButton.layer.borderColor = blueColor.CGColor;
        optionsButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"Set"]){
        seqSetButton.backgroundColor = blueColor;
        //seqSetButton.layer.borderColor = blueColor.CGColor;
        seqSetButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"Instrument"]){
        instrumentButton.backgroundColor = blueColor;
        //instrumentButton.layer.borderColor = blueColor.CGColor;
        instrumentButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"Share"]){
        shareButton.backgroundColor = blueColor;
        //shareButton.layer.borderColor = blueColor.CGColor;
        shareButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"Info"]){
        // todo
    }
}

-(void)resetButtonColors
{
    optionsButton.backgroundColor = [UIColor clearColor];
    optionsButton.layer.borderColor = silverColor.CGColor;
    optionsButton.layer.borderWidth = 1.0;
    optionsButton.layer.cornerRadius = 5.0;
    optionsButton.tintColor = silverColor;
    
    seqSetButton.backgroundColor = [UIColor clearColor];
    seqSetButton.layer.borderColor = silverColor.CGColor;
    seqSetButton.layer.borderWidth = 1.0;
    seqSetButton.layer.cornerRadius = 5.0;
    seqSetButton.tintColor = silverColor;
    
    instrumentButton.backgroundColor = [UIColor clearColor];
    instrumentButton.layer.borderColor = silverColor.CGColor;
    instrumentButton.layer.borderWidth = 1.0;
    instrumentButton.layer.cornerRadius = 5.0;
    instrumentButton.tintColor = silverColor;
    
    connectedButton.layer.borderColor = silverColor.CGColor;
    connectedButton.layer.borderWidth = 1.0;
    connectedButton.layer.cornerRadius = 5.0;
    
    // (share button)
}

-(void)enableInstrumentViewWithIcon:(NSString *)instIcon showCustom:(BOOL)isCustom
{
    
    if(instIcon.length == 0){
        [self disableInstrumentView];
        return;
    }
    
    [instrumentButton setAlpha:1.0];
    instrumentViewEnabled = true;
    [self setInstrumentIcon:instIcon showCustom:isCustom];
}

-(void)setInstrumentIcon:(NSString *)instIcon showCustom:(BOOL)isCustom
{
    [instrumentButton setImage:[UIImage imageNamed:instIcon] forState:UIControlStateNormal];
    
    if(isCustom){
        [self showCustomIndicator];
    }else{
        [self hideCustomIndicator];
    }
}

-(void)disableInstrumentView
{
    [instrumentButton setAlpha:0.2];
    instrumentViewEnabled = false;
    [instrumentButton setImage:defaultInstrumentIcon forState:UIControlStateNormal];
}

-(void)showCustomIndicator
{
    customIndicator.layer.cornerRadius = customIndicator.frame.size.width/2;
    [customIndicator setHidden:NO];
}

-(void)hideCustomIndicator
{
    [customIndicator setHidden:YES];
}

-(void)drawConnectedLeftArrow
{
    CGSize size = CGSizeMake(connectedLeftArrow.frame.size.width, connectedLeftArrow.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 6;
    int playX = connectedLeftArrow.frame.size.width/2 - playWidth/2;
    int playY = 18;
    CGFloat playHeight = connectedLeftArrow.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, silverColor.CGColor);
    CGContextSetFillColorWithColor(context, silverColor.CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    [connectedLeftArrow setImage:newImage];
    
    UIGraphicsEndImageContext();
}

-(UIImage *)drawDefaultInstrumentIcon
{
    CGSize size = CGSizeMake(instrumentButton.frame.size.width, instrumentButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 26;
    int playHeight = 26;
    int playX = instrumentButton.frame.size.width/2 - playWidth/2 + 1;
    int playY = instrumentButton.frame.size.height/2 - playHeight/2;
    CGContextSetStrokeColorWithColor(context, silverColor.CGColor);
    CGContextSetFillColorWithColor(context, silverColor.CGColor);
    
    CGContextSetLineWidth(context, 8.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX+playWidth, playY+playHeight);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, playX+playWidth, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
