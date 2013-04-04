//
//  Instruments&EffectsViewController.m
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "Instruments&EffectsViewController.h"

#import "InstrumentTableViewController.h"
#import <AudioController/AudioController.h>

@interface Instruments_EffectsViewController ()

@property (retain, nonatomic) InstrumentTableViewController *instrumentTableVC;

@property (retain, nonatomic) IBOutlet UIView *contentTable;

@end

@implementation Instruments_EffectsViewController

- (id)initWithAudioController:(AudioController*)AC instrumentList:(NSArray*)instruments
{
    self = [super initWithNibName:@"Instruments&EffectsViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _instrumentTableVC = [[InstrumentTableViewController alloc] initWithAudioController:AC instrumentList:instruments];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set up initial content VC to be instruments & effects.
    [self addChildViewController:self.instrumentTableVC];
    [self.contentTable addSubview:self.instrumentTableVC.view];
    [self.instrumentTableVC didMoveToParentViewController:self];
    //self.currentMainContentVC = self.instrumentsAndEffectsVC;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_contentTable release];
    [super dealloc];
}
@end
