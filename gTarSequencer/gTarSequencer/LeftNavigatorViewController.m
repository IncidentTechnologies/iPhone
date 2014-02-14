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
@synthesize leftSliderPinTop;
@synthesize leftSliderPinBottom;

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
    redColor = [UIColor colorWithRed:216/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
    blueColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:1.0];
    greenColor = [UIColor colorWithRed:40/255.0 green:194/255.0 blue:94/255.0 alpha:1.0];
    
    // Add icons
    [seqSetButton setImage:[UIImage imageNamed:@"Set_Icon"] forState:UIControlStateNormal];
    float seqSetImageHeight = 22.0;
    float seqSetImageWidth = 30.4;
    [seqSetButton setImageEdgeInsets:UIEdgeInsetsMake((seqSetButton.frame.size.height-seqSetImageHeight)/2, (seqSetButton.frame.size.width-seqSetImageWidth)/2, (seqSetButton.frame.size.height-seqSetImageHeight)/2, (seqSetButton.frame.size.width-seqSetImageWidth)/2)];
    
    defaultInstrumentIcon = @"Icon_Sound";
    [instrumentButton setImage:[UIImage imageNamed:defaultInstrumentIcon] forState:UIControlStateNormal];
    float instrumentImageHeight = instrumentButton.frame.size.height-5.0;
    float instrumentImageWidth = instrumentButton.frame.size.height-5.0;
    [instrumentButton setImageEdgeInsets:UIEdgeInsetsMake((instrumentButton.frame.size.height-instrumentImageHeight)/2, (instrumentButton.frame.size.width-instrumentImageWidth)/2, (instrumentButton.frame.size.height-instrumentImageHeight)/2, (instrumentButton.frame.size.width-instrumentImageWidth)/2)];
    
    [optionsButton setImage:[UIImage imageNamed:@"Options_Icon"] forState:UIControlStateNormal];
    float optionsImageHeight = 22.0;
    float optionsImageWidth = 19.0;
    [optionsButton setImageEdgeInsets:UIEdgeInsetsMake((optionsButton.frame.size.height-optionsImageHeight)/2, (optionsButton.frame.size.width-optionsImageWidth)/2, (optionsButton.frame.size.height-optionsImageHeight)/2, (optionsButton.frame.size.width-optionsImageWidth)/2)];
    
    // Style elements
    [self resetButtonColors];
    
    connectedButton.layer.borderColor = redColor.CGColor;
    connectedButton.layer.borderWidth = 0.5;
    connectedButton.layer.cornerRadius = 5.0;
    
    leftSliderPinTop.layer.cornerRadius = 3.0;
    leftSliderPinBottom.layer.cornerRadius = 3.0;
}

- (void)viewDidUnload
{
    
}

-(void)changeConnectedButton:(BOOL)isConnected
{
    if(isConnected){
        connectedButton.backgroundColor = greenColor;
        connectedButton.layer.borderColor = greenColor.CGColor;
    }else{
        connectedButton.backgroundColor = redColor;
        connectedButton.layer.borderColor = redColor.CGColor;
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
        [delegate selectNavChoice:@"gTar Info" withShift:YES];
    }
}

-(void)setNavButtonOn:(NSString *)navChoice
{
    [self resetButtonColors];
    
    if([navChoice isEqualToString:@"Options"]){
        optionsButton.backgroundColor = blueColor;
        optionsButton.layer.borderColor = blueColor.CGColor;
        optionsButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"Set"]){
        seqSetButton.backgroundColor = blueColor;
        seqSetButton.layer.borderColor = blueColor.CGColor;
        seqSetButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"Instrument"]){
        instrumentButton.backgroundColor = blueColor;
        instrumentButton.layer.borderColor = blueColor.CGColor;
        instrumentButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"Share"]){
        shareButton.backgroundColor = blueColor;
        shareButton.layer.borderColor = blueColor.CGColor;
        shareButton.tintColor = [UIColor whiteColor];
    }else if([navChoice isEqualToString:@"gTar Info"]){
        // todo
    }
}

-(void)resetButtonColors
{
    optionsButton.backgroundColor = [UIColor clearColor];
    optionsButton.layer.borderColor = silverColor.CGColor;
    optionsButton.layer.borderWidth = 0.5;
    optionsButton.layer.cornerRadius = 5.0;
    optionsButton.tintColor = silverColor;
    
    seqSetButton.backgroundColor = [UIColor clearColor];
    seqSetButton.layer.borderColor = silverColor.CGColor;
    seqSetButton.layer.borderWidth = 0.5;
    seqSetButton.layer.cornerRadius = 5.0;
    seqSetButton.tintColor = silverColor;
    
    instrumentButton.backgroundColor = [UIColor clearColor];
    instrumentButton.layer.borderColor = silverColor.CGColor;
    instrumentButton.layer.borderWidth = 0.5;
    instrumentButton.layer.cornerRadius = 5.0;
    instrumentButton.tintColor = silverColor;
    
    // (share button)
}

-(void)enableInstrumentViewWithIcon:(NSString *)instIcon
{
    
    if(instIcon.length == 0){
        [self disableInstrumentView];
        return;
    }
    
    [instrumentButton setAlpha:1.0];
    instrumentViewEnabled = true;
    [self setInstrumentIcon:instIcon];
}

-(void)setInstrumentIcon:(NSString *)instIcon
{
    NSLog(@"instIcon 2 is %@",instIcon);
    
    [instrumentButton setImage:[UIImage imageNamed:instIcon] forState:UIControlStateNormal];
}

-(void)disableInstrumentView
{
    [instrumentButton setAlpha:0.2];
    instrumentViewEnabled = false;
    [instrumentButton setImage:[UIImage imageNamed:defaultInstrumentIcon] forState:UIControlStateNormal];
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
