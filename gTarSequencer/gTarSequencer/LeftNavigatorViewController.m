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
}

- (void)viewDidUnload
{
    
}

- (IBAction)selectNav:(id)sender
{
    if(sender == optionsButton){
        [delegate selectNavChoice:@"Options"];
    }else if(sender == seqSetButton){
        [delegate selectNavChoice:@"Set"];
    }else if(sender == instrumentButton && instrumentViewEnabled){
        [delegate selectNavChoice:@"Instrument"];
    }else if(sender == shareButton){
        [delegate selectNavChoice:@"Share"];
    }
}

-(void)enableInstrumentView
{
    [instrumentButton setAlpha:1.0];
    instrumentViewEnabled = true;
}

-(void)disableInstrumentView
{
    [instrumentButton setAlpha:0.5];
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
