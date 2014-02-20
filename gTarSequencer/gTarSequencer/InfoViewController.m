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
    
    NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@"Visit gTar.fm to Learn More >"];
    [titleString setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0]} range:NSMakeRange(6,7)];
    
    [infoButton setAttributedTitle:titleString forState:UIControlStateNormal];
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

@end
