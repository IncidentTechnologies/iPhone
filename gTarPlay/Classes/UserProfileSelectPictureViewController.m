//
//  UserProfileSelectPictureViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserProfileSelectPictureViewController.h"

@implementation UserProfileSelectPictureViewController

@synthesize m_navigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc
{
    
    [m_navigationController release];
    
    [super dealloc];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)picButtonClicked:(id)sender
{
    
    UIButton * button = (UIButton*)sender;
    
    [m_navigationController updateProfilePicture:[button imageForState:UIControlStateNormal]];
    
    [self closeButtonClicked:sender];
    
}

- (IBAction)pic1Clicked:(id)sender
{
    
}

- (IBAction)pic2Clicked:(id)sender
{
    
}

- (IBAction)pic3Clicked:(id)sender
{
    
}

- (IBAction)pic4Clicked:(id)sender
{
    
}

- (IBAction)pic5Clicked:(id)sender
{
    
}

- (IBAction)pic6Clicked:(id)sender
{
    
}

@end
