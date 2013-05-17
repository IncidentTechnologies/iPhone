//
//  SlidingInstrumentViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import "SlidingInstrumentViewController.h"

#import <AudioController/AudioController.h>
#import "UIView+Gtar.h"

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
    
    _instrumentViewController.delegate = self;
    
    // Forces viewDidLoad
    [self addChildViewController:_instrumentViewController];
    [_instrumentViewController didMoveToParentViewController:self];
    
    [_innerContentView addSubview:_instrumentViewController.view];
    
    [_instrumentViewController.view setFrame:_innerContentView.bounds];
    [_instrumentViewController.tableView setFrame:_innerContentView.bounds];
    
    [_innerContentView bringSubviewToFront:_indicatorView];
    [_indicatorView addShadow];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_innerContentView release];
    [_indicatorView release];
    [super dealloc];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_instrumentViewController.view setFrame:_innerContentView.bounds];
    [_instrumentViewController.tableView setFrame:_innerContentView.bounds];
}

- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect
{
    [super attachToSuperview:view withFrame:rect];
    
    // Otherwise, the frame doesn't center properly.
//    [_instrumentViewController.tableView setFrame:_innerContentView.bounds];
}

#pragma mark - InstrumentSelectionDelegate

- (void)didSelectInstrument
{
    _loading = YES;
    [_indicatorView startAnimating];
}

- (void)didLoadInstrument
{
    _loading = NO;
    [_indicatorView stopAnimating];
}

@end
