//
//  SongSelectionViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import "SongSelectionViewController.h"

@interface SongSelectionViewController ()

@end

@implementation SongSelectionViewController

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_searchBar release];
    [super dealloc];
}

#pragma mark - Button Click Handlers

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
