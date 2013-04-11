//
//  Instruments&EffectsViewController.m
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "InstrumentsAndEffectsViewController.h"

#import "InstrumentTableViewController.h"
#import "EffectsTableViewController.h"
#import <AudioController/AudioController.h>

@interface InstrumentsAndEffectsViewController ()

@property (retain, nonatomic) InstrumentTableViewController *instrumentTableVC;
@property (retain, nonatomic) EffectsTableViewController *effectsTableVC;

@property (retain, nonatomic) IBOutlet JamPad *jamPad;

@property (retain, nonatomic) IBOutlet UIView *contentTable;
@property (retain, nonatomic) UIViewController *currentMainContentVC;

-(void) switchMainContentControllerToVC:(UIViewController *)newVC;

@end

@implementation InstrumentsAndEffectsViewController

- (id)initWithAudioController:(AudioController*)AC
{
    self = [super initWithNibName:@"InstrumentsAndEffectsViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _instrumentTableVC = [[InstrumentTableViewController alloc] initWithAudioController:AC];
        _effectsTableVC = [[EffectsTableViewController alloc] initWithAudioController:AC];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set up JamPad
    // Flip y axis of JamPad so that +y points upwards instead of down
    self.jamPad.transform = CGAffineTransformMakeScale(1, -1);
    self.jamPad.m_delegate = self;
    
    // Set up initial content VC to be instruments & effects.
    [self addChildViewController:self.instrumentTableVC];
    self.instrumentTableVC.tableView.frame = self.contentTable.bounds;
    [self.contentTable addSubview:self.instrumentTableVC.view];
    [self.instrumentTableVC didMoveToParentViewController:self];
    self.currentMainContentVC = self.instrumentTableVC;
    
    self.effectsTableVC.tableView.frame = self.contentTable.bounds;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_contentTable release];
    [_currentMainContentVC release];
    
    [_jamPad release];
    [super dealloc];
}

- (void)displayInstruments
{
    [self switchMainContentControllerToVC:self.instrumentTableVC];
}

- (void)displayEffects
{
    [self switchMainContentControllerToVC:self.effectsTableVC];
}

-(void) switchMainContentControllerToVC:(UIViewController *)newVC
{
    if (self.currentMainContentVC ==  newVC)
    {
        // already on this view, do nothing
        return;
    }
    
    UIViewController *oldVC = self.currentMainContentVC;
    
    [oldVC willMoveToParentViewController:nil];
    
    [self addChildViewController:newVC];
    
    [self transitionFromViewController:oldVC  toViewController:newVC duration:0.25
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL finished) {
                                [oldVC removeFromParentViewController];
                                [newVC didMoveToParentViewController:self];
                                self.currentMainContentVC = newVC;
                            }];
}

#pragma mark - XYInputViewDelegate (JamPad delegate)

-(void) positionChanged:(CGPoint)position forView:(XYInputView *)view
{
    // translate the normalized value the JamPad position to a range
    // in [min, max] for the respective parameter
    /*Parameter *p = &(m_selectedEffect->getPrimaryParam());
    float min = p->getMin();
    float max = p->getMax();
    float newVal = position.x*(max - min) + min;
    m_selectedEffect->setPrimaryParam(newVal);
    
    p = &(m_selectedEffect->getSecondaryParam());
    min = p->getMin();
    max = p->getMax();
    newVal = position.y*(max - min) + min;
    m_selectedEffect->setSecondaryParam(newVal);
     */
}


@end
