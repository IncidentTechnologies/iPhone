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
}


- (void)localizeViews
{
    int numFreeSongs = 10;
    
    _freeSongsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Get %u free songs.", NULL), numFreeSongs];
    
    _registerLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Register your gTar.", NULL)];
    
    [_laterButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"LATER", NULL)] forState:UIControlStateNormal];
    [_registerButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"REGISTER", NULL)] forState:UIControlStateNormal];
    
}

- (IBAction)registerButtonClicked:(id)sender
{
    
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

- (void)startSlideUp
{
    [UIView setAnimationsEnabled:YES];
    
    double screenWidth = [[UIScreen mainScreen] bounds].size.height;
    double contentWidth = _contentView.frame.size.width;
    
    onFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, _contentView.frame.origin.y, contentWidth, _contentView.frame.size.height);
    
    offFrame = CGRectMake(screenWidth/2.0 - contentWidth/2.0, 1.7*_contentView.frame.size.height, contentWidth, _contentView.frame.size.height);
    
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
