//
//  Instruments&EffectsViewController.m
//  keysPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "InstrumentsAndEffectsViewController.h"

@interface InstrumentsAndEffectsViewController ()

// @property (retain, nonatomic) AudioController *audioController;
@property (strong, nonatomic) SoundMaster *soundMaster;
@property (strong, nonatomic) InstrumentTableViewController *instrumentTableVC;
@property (strong, nonatomic) EffectsTableViewController *effectsTableVC;

@property (nonatomic) NSInteger selectedEffectIndex;

@property (strong, nonatomic) IBOutlet JamPad *jamPad;

@property (strong, nonatomic) IBOutlet UIView *contentTable;
@property (strong, nonatomic) UIViewController *currentMainContentVC;

-(void) switchMainContentControllerToVC:(UIViewController *)newVC;
-(void) setupJamPadWithEffectAtIndex:(int)index;

@end

@implementation InstrumentsAndEffectsViewController

@synthesize soundMaster;
@synthesize instrumentTableVC;
@synthesize effectsTableVC;
@synthesize jamPad;

//- (id)initWithAudioController:(AudioController*)AC
- (id)initWithSoundMaster:(SoundMaster*)SM
{
    self = [super initWithNibName:@"InstrumentsAndEffectsViewController" bundle:nil];
    if (self) {
        
        // _audioController = [AC retain];
        
        soundMaster = SM;
        
        //_instrumentTableVC = [[InstrumentTableViewController alloc] initWithAudioController:AC];
        instrumentTableVC = [[InstrumentTableViewController alloc] init];
        instrumentTableVC.delegate = self;
        
        //_effectsTableVC = [[EffectsTableViewController alloc] initWithAudioController:AC];
        effectsTableVC = [[EffectsTableViewController alloc] init];
        effectsTableVC.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [jamPad setupJamPadWithRows:9 andColumns:10];
    
    // Do any additional setup after loading the view from its nib.
    
    // Set up JamPad
    // Flip y axis of JamPad so that +y points upwards instead of down
    self.jamPad.transform = CGAffineTransformMakeScale(1, -1);
    self.jamPad.m_delegate = self;
    [self setupJamPadWithEffectAtIndex:0];
    
    // Set up initial content VC to be instrumentsVC
    [self addChildViewController:self.instrumentTableVC];
    self.instrumentTableVC.tableView.frame = self.contentTable.bounds;
    [self.contentTable addSubview:self.instrumentTableVC.view];
    [self.instrumentTableVC didMoveToParentViewController:self];
    self.currentMainContentVC = self.instrumentTableVC;
    
    self.effectsTableVC.tableView.frame = self.contentTable.bounds;
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.instrumentTableVC.tableView.frame = self.contentTable.bounds;
    self.effectsTableVC.tableView.frame = self.contentTable.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

// Called whenever a new effect is selected
-(void) setupJamPadWithEffectAtIndex:(int)index
{
    CGPoint normalizedPoint = [soundMaster getPointForEffectAtIndex:index];
    
    NSLog(@"Setup jam pad with effect at index %i using %f %f", index,normalizedPoint.x,normalizedPoint.y);
    
    [self.jamPad setNormalizedPosition:normalizedPoint];
    
}

#pragma mark - XYInputViewDelegate (JamPad delegate)

-(void) positionChanged:(CGPoint)position forView:(XYInputView *)view
{
    [soundMaster adjustEffectAtIndex:self.selectedEffectIndex toPoint:position];
}

#pragma mark - EffectSelectionDelegate
- (void)didSelectEffectAtIndex:(NSInteger)index
{
    NSLog(@"Did select effect at index %li",index);
    self.selectedEffectIndex = index;
   
    if([self isEffectOnAtIndex:self.selectedEffectIndex]){
        [self setupJamPadWithEffectAtIndex:(int)self.selectedEffectIndex];
    }
}

- (NSString *)getEffectNameAtIndex:(NSInteger)index
{
    return [soundMaster getEffectNameAtIndex:index];
}

- (NSInteger)getNumEffects
{
    return [soundMaster getNumEffects];
}

- (BOOL)isEffectOnAtIndex:(NSInteger)index
{
    return [soundMaster isEffectOnAtIndex:index];
}

- (void)toggleEffect:(NSInteger)index isOn:(BOOL)on
{
    [soundMaster toggleEffect:index isOn:on];
}


#pragma mark - Instrument Selector delegate
- (void)stopAudioEffects
{
    NSLog(@"InstrumentsAndEffectsViewController stopAudioEffects");
    BOOL enableSlide = [soundMaster isSlideEnabled];
    
    [soundMaster stopAllEffects];
    
    [effectsTableVC turnOffAllEffects];
    
    if(enableSlide){
        [effectsTableVC turnOnFirstEffect];
    }
    
    
    // Reset effect buttons
/*    int numEffects = (int)[self getNumEffects];
    for(int i = 0; i < numEffects; i++){
        
        if([self isEffectOnAtIndex:i]){
            // TODO: turn effect button off
            [effectsTableVC tu]
        }
        
    }*/

}

- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    
    BOOL enableSlide = [soundMaster isSlideEnabled];
    
    [soundMaster didSelectInstrument:instrumentName withSelector:cb andOwner:sender];
    
    // But restore sliding
    if(enableSlide){
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:effectsTableVC selector:@selector(turnOnFirstEffect) userInfo:nil repeats:NO];
        //[soundMaster enableSliding];
        //[effectsTableVC turnOnFirstEffect];
    }
}

- (NSArray *)getInstrumentList
{
    return [soundMaster getInstrumentList];
}

- (NSInteger)getSelectedInstrumentIndex
{
    return [soundMaster getCurrentInstrument];
}

@end
