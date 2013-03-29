//
//  PlayViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/28/13.
//
//

#import "PlayViewController.h"

@interface PlayViewController ()

@end

@implementation PlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    _backButton.translatesAutoresizingMaskIntoConstraints = YES;
//    _volumeButton.translatesAutoresizingMaskIntoConstraints = YES;
//    _backButton.imageView.translatesAutoresizingMaskIntoConstraints = YES;
//    _volumeButton.imageView.translatesAutoresizingMaskIntoConstraints = YES;
    
    [_backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_volumeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_backButton release];
    [_volumeButton release];
    [super dealloc];
}

#pragma mark - Button click handlers

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)volumeButtonClicked:(id)sender
{
    
}

@end
