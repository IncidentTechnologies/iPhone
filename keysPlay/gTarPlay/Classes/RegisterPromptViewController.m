//
//  RegisterPromptViewController.m
//  gTarPlay
//
//  Created by Kate Schnippering on 5/20/14.
//
//

#import "RegisterPromptViewController.h"

@interface RegisterPromptViewController ()

@end

@implementation RegisterPromptViewController

@synthesize delegate;

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
    
    [self localizeViews];
    
    frameGenerator = [[FrameGenerator alloc] init];
    
    double screenWidth = [frameGenerator getFullscreenWidth];
    double contentWidth = _contentView.frame.size.width;
    double onY = _contentView.frame.origin.y;
    double offY = 1.7*_contentView.frame.size.height;
    
    onFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, onY, contentWidth, _contentView.frame.size.height);
    
    offFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, 1.7*offY, contentWidth, _contentView.frame.size.height);
    
}


- (void)localizeViews
{
    int numFreeSongs = 15;
    
    _freeSongsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Get %u free songs.", NULL), numFreeSongs];
    
    _registerLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Register your gTar.", NULL)];
    
    [_laterButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"LATER", NULL)] forState:UIControlStateNormal];
    [_registerButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"REGISTER", NULL)] forState:UIControlStateNormal];
    
}

- (IBAction)registerButtonClicked:(id)sender
{
    [delegate registerDevice];
    
    [self startSlideDown];
}

- (IBAction)laterButtonClicked:(id)sender
{
    [self startSlideDown];
}


- (void)viewDidAppear:(BOOL)animated
{
    [self startSlideUp];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidLayoutSubviews
{
    // For some reason, in iOS 8+ it needs to start off screen and in iOS 7 this breaks...
    
    if([frameGenerator startOffscreen]){
        [_contentView setFrame:offFrame];
    }
}

- (void)startSlideUp
{
    [UIView setAnimationsEnabled:YES];
    
    [_contentView setFrame:offFrame];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        [_contentView setFrame:onFrame];
    }completion:^(BOOL finished){}];
    
}

- (void)startSlideDown
{
    
    [UIView setAnimationsEnabled:YES];
    
    [_contentView setFrame:onFrame];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        [_contentView setFrame:offFrame];
    }completion:^(BOOL finished){[self endSlideDown];}];
    
}

- (void)endSlideDown
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
