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
@synthesize instrumentButtonImage;
@synthesize shareButton;
@synthesize connectedButton;
@synthesize leftSlider;
@synthesize customIndicator;
@synthesize toggleBorder;

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
    redColor = [UIColor colorWithRed:226/255.0 green:37/255.0 blue:84/255.0 alpha:1.0];
    blueColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1.0];
    greenColor = [UIColor colorWithRed:31/255.0 green:187/255.0 blue:40/255.0 alpha:1.0];
    backgroundColor = [UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0];
    
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
    
    [shareButton setImage:[UIImage imageNamed:@"Share_Icon"] forState:UIControlStateNormal];
    float shareImageHeight = 30.0;
    float shareImageWidth = 30.0;
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake((shareButton.frame.size.height-shareImageHeight)/2, (shareButton.frame.size.width-shareImageWidth)/2, (shareButton.frame.size.height-shareImageHeight)/2, (shareButton.frame.size.width-shareImageWidth)/2)];
    
    [optionsButton setImage:[UIImage imageNamed:@"Save_Icon"] forState:UIControlStateNormal];
    float optionsImageHeight = 26.0;
    float optionsImageWidth = 26.0;
    [optionsButton setImageEdgeInsets:UIEdgeInsetsMake((optionsButton.frame.size.height-optionsImageHeight)/2, (optionsButton.frame.size.width-optionsImageWidth)/2, (optionsButton.frame.size.height-optionsImageHeight)/2, (optionsButton.frame.size.width-optionsImageWidth)/2)];
    
    // Arrow
    //[self drawConnectedLeftArrow];
    
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
        
        [connectedButton setImage:[UIImage imageNamed:@"G_Icon"] forState:UIControlStateNormal];
        [connectedButton setTitle:@"" forState:UIControlStateNormal];
        float gImageHeight = 26.0;
        float gImageWidth = 20.0;
        [connectedButton setContentEdgeInsets:UIEdgeInsetsMake((connectedButton.frame.size.height-gImageHeight)/2, (connectedButton.frame.size.width-gImageWidth)/2, (connectedButton.frame.size.height-gImageHeight)/2, (connectedButton.frame.size.width-gImageWidth)/2)];
    
        
    }else{
        connectedButton.backgroundColor = redColor;
        [connectedButton setTitle:@"i" forState:UIControlStateNormal];
        [connectedButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 2, 0, 0)];
        [connectedButton setImage:nil forState:UIControlStateNormal];
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
    
    currentNavChoice = navChoice;
    
    if([navChoice isEqualToString:@"Options"]){
        optionsButton.backgroundColor = blueColor;
        //optionsButton.layer.borderColor = blueColor.CGColor;
        optionsButton.tintColor = [UIColor whiteColor];
        [self toggleSeqSetButton];
    }else if([navChoice isEqualToString:@"Set"]){
        if(instrumentViewEnabled){
            [self toggleInstrumentButton];
        }else{
            [self toggleSeqSetButton];
        }
    }else if([navChoice isEqualToString:@"Instrument"]){
        [self toggleSeqSetButton];
    }else if([navChoice isEqualToString:@"Share"]){
        shareButton.backgroundColor = blueColor;
        //shareButton.layer.borderColor = blueColor.CGColor;
        shareButton.tintColor = [UIColor whiteColor];
        [self toggleSeqSetButton];
    }else if([navChoice isEqualToString:@"Info"]){
        [self toggleSeqSetButton];
    }
    
    
}

-(void)toggleInstrumentButton
{
    [instrumentButton setHidden:NO];
    [seqSetButton setHidden:YES];
}

-(void)toggleSeqSetButton
{
    [instrumentButton setHidden:YES];
    [seqSetButton setHidden:NO];
    
    if([currentNavChoice isEqualToString:@"Set"]){
        seqSetButton.backgroundColor = blueColor;
        seqSetButton.tintColor = [UIColor whiteColor];
    }
}

-(void)resetButtonColors
{
    optionsButton.backgroundColor = backgroundColor;
    optionsButton.layer.borderColor = silverColor.CGColor;
    optionsButton.layer.borderWidth = 1.0;
    optionsButton.layer.cornerRadius = 5.0;
    optionsButton.tintColor = silverColor;
    
    seqSetButton.backgroundColor = backgroundColor;
    seqSetButton.layer.borderColor = silverColor.CGColor;
    seqSetButton.layer.borderWidth = 1.0;
    seqSetButton.layer.cornerRadius = 5.0;
    seqSetButton.tintColor = silverColor;
    
    instrumentButton.backgroundColor = backgroundColor;
    instrumentButton.layer.borderColor = silverColor.CGColor;
    instrumentButton.layer.borderWidth = 1.0;
    instrumentButton.layer.cornerRadius = 5.0;
    instrumentButton.tintColor = silverColor;
    
    connectedButton.layer.borderColor = silverColor.CGColor;
    connectedButton.layer.borderWidth = 1.0;
    connectedButton.layer.cornerRadius = 5.0;
    
    toggleBorder.layer.borderColor = silverColor.CGColor;
    toggleBorder.layer.borderWidth = 1.0;
    toggleBorder.layer.cornerRadius = 5.0;
    
    shareButton.backgroundColor = backgroundColor;
    shareButton.layer.borderColor = silverColor.CGColor;
    shareButton.layer.borderWidth = 1.0;
    shareButton.layer.cornerRadius = 5.0;
    shareButton.tintColor = silverColor;
    
    
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
    
    [self toggleInstrumentButton];
}

-(void)setInstrumentIcon:(NSString *)instIcon showCustom:(BOOL)isCustom
{
    instrumentButtonImage = [UIImage imageNamed:instIcon];
    
    [instrumentButton setImage:instrumentButtonImage forState:UIControlStateNormal];
    
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
    [self hideCustomIndicator];
    
    [self toggleSeqSetButton];
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

/*
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
*/

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
    
    
    UIGraphicsEndImageContext();
    
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
