//
//  SlidingInstrumentViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import "SlidingInstrumentViewController.h"

#import "InstrumentTableViewController.h"

#import <AudioController/AudioController.h>

extern AudioController *g_audioController;

@interface SlidingInstrumentViewController ()
{
    InstrumentTableViewController *_instrumentViewController;
}
@end

@implementation SlidingInstrumentViewController

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
    
    _instrumentViewController = [[InstrumentTableViewController alloc] initWithAudioController:g_audioController];
    
    [self addChildViewController:_instrumentViewController];
    
    [_instrumentViewController.tableView setFrame:_innerContentView.bounds];
    [_innerContentView addSubview:_instrumentViewController.view];
    
    [_instrumentViewController didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_innerContentView release];
    [super dealloc];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_instrumentViewController.tableView setFrame:_innerContentView.bounds];
}

@end
