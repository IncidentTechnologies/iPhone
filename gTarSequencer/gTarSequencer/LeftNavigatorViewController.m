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
@synthesize leftSliderPin;

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
    
    // Style elements
    [self resetButtonColors];
    
    connectedButton.layer.borderColor = redColor.CGColor;
    connectedButton.layer.borderWidth = 0.5;
    connectedButton.layer.cornerRadius = 5.0;
    
    leftSliderPin.layer.cornerRadius = 3.0;
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
    
    [self resetButtonColors];
    
    if(sender == optionsButton){
        [delegate selectNavChoice:@"Options"];
        optionsButton.backgroundColor = blueColor;
        optionsButton.layer.borderColor = blueColor.CGColor;
    }else if(sender == seqSetButton){
        [delegate selectNavChoice:@"Set"];
        seqSetButton.backgroundColor = blueColor;
        seqSetButton.layer.borderColor = blueColor.CGColor;
    }else if(sender == instrumentButton && instrumentViewEnabled){
        [delegate selectNavChoice:@"Instrument"];
        instrumentButton.backgroundColor = blueColor;
        instrumentButton.layer.borderColor = blueColor.CGColor;
    }else if(sender == shareButton){
        [delegate selectNavChoice:@"Share"];
        shareButton.backgroundColor = blueColor;
        shareButton.layer.borderColor = blueColor.CGColor;
    }else if(sender == connectedButton){
        [delegate selectNavChoice:@"gTar Info"];
    }
}

-(void)resetButtonColors
{
    optionsButton.backgroundColor = [UIColor clearColor];
    optionsButton.layer.borderColor = silverColor.CGColor;
    optionsButton.layer.borderWidth = 0.5;
    optionsButton.layer.cornerRadius = 5.0;
    
    seqSetButton.backgroundColor = [UIColor clearColor];
    seqSetButton.layer.borderColor = silverColor.CGColor;
    seqSetButton.layer.borderWidth = 0.5;
    seqSetButton.layer.cornerRadius = 5.0;
    
    instrumentButton.backgroundColor = [UIColor clearColor];
    instrumentButton.layer.borderColor = silverColor.CGColor;
    instrumentButton.layer.borderWidth = 0.5;
    instrumentButton.layer.cornerRadius = 5.0;
    
    // (share button)
}

-(void)enableInstrumentView
{
    [instrumentButton setAlpha:1.0];
    instrumentViewEnabled = true;
}

-(void)disableInstrumentView
{
    [instrumentButton setAlpha:0.2];
    instrumentViewEnabled = false;
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
