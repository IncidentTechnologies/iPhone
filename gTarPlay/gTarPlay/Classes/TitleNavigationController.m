//
//  TitleNavigationController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import "TitleNavigationController.h"

@interface TitleNavigationController ()
{
    UIView *_currentLeftPanel;
    UIView *_currentRightPanel;
}
@end

@implementation TitleNavigationController

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
    // Do any additional setup after loading the view from its nib.
    
    [self swapLeftPanel:_signinLeftPanel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_rightPanel release];
    [_leftPanel release];
    [_signinLeftPanel release];
    [_signupRightPanel release];

    [_signupSelectButton release];
    [_signinSelectButton release];
    [_signinRightPanel release];
    [super dealloc];
}

#pragma mark - Panel management

- (void)swapRightPanel:(UIView*)rightPanel
{
    
    [_currentRightPanel removeFromSuperview];
    
    rightPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [_rightPanel addSubview:rightPanel];
    
    _currentRightPanel = rightPanel;
    
}

- (void)swapLeftPanel:(UIView*)leftPanel
{
    
    [_currentLeftPanel removeFromSuperview];
    
    [_leftPanel addSubview:leftPanel];
    
    _currentLeftPanel = leftPanel;
    
}

- (IBAction)signinSelectButtonClicked:(id)sender
{
    [self swapRightPanel:_signinRightPanel];
}

- (IBAction)signupSelectButtonClicked:(id)sender
{
    [self swapRightPanel:_signupRightPanel];
}

- (IBAction)signupButtonClicked:(id)sender {
}

- (IBAction)facebookButtonClicked:(id)sender {
}
@end
