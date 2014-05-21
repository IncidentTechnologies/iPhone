//
//  SlidingInstrumentViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import "SlidingInstrumentViewController.h"

#import "UIView+Gtar.h"

//extern AudioController *g_audioController;

@interface SlidingInstrumentViewController ()
{
    InstrumentTableViewController *_instrumentViewController;
}
@end

@implementation SlidingInstrumentViewController

@synthesize delegate;

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
    
    //_instrumentViewController = [[InstrumentTableViewController alloc] initWithAudioController:g_audioController];
    _instrumentViewController = [[InstrumentTableViewController alloc] init];
    _instrumentViewController.delegate = self;
    
    // Forces viewDidLoad
    [self addChildViewController:_instrumentViewController];
    [_instrumentViewController didMoveToParentViewController:self];
    
    [_innerContentView addSubview:_instrumentViewController.view];
    
    [_instrumentViewController.view setFrame:_innerContentView.bounds];
    [_instrumentViewController.tableView setFrame:_innerContentView.bounds];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    _loading = YES;
    
    [delegate didSelectInstrument:instrumentName withSelector:cb andOwner:sender];

}

- (void)didLoadInstrument
{
    //[g_audioController reset];
    NSLog(@"TODO: reset audio controller");
    _loading = NO;
}

- (void)stopAudioEffects
{
    [delegate stopAudioEffects];
}

- (NSInteger)getSelectedInstrumentIndex
{
    NSLog(@"Sliding instrument selector get selected instrument index");
    return [delegate getSelectedInstrumentIndex];
}

- (NSArray *)getInstrumentList
{
    NSLog(@"Sliding instrument selector get instrument list");
    
    return [delegate getInstrumentList];
}

@end
