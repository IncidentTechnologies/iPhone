//
//  SynthSourceViewController.m
//  gTarCreate
//
//  Created by Idan Beck on 5/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "SynthSourceViewController.h"

@interface SynthSourceViewController ()

@end

@implementation SynthSourceViewController

const char *SYNTH_TYPE_STR[] = {
    "off",
    "sine",
    "sawtooth",
    "square",
    "triangle"
};

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_synthType = 0;
    }
    return self;
}

/* TODO: Such that parent view doesn't need to position etc
- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    if([[self childViewControllers] count] == 0) {
        SynthSourceViewController *realViewController = [[SynthSourceViewController alloc] initWithNibName:@"SynthSourceViewController" bundle:NULL];
        
        realViewController.view.frame = self.view.frame;
        realViewController.view.autoresizingMask = self.view.autoresizingMask;
        realViewController.view.alpha = self.view.alpha;
        
        return realViewController;
    }
    
    return self;
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_m_labelSynthType setText:[[NSString alloc] initWithFormat:@"%s", SYNTH_TYPE_STR[m_synthType]]];
}

- (IBAction) OnTypeClick:(id)sender {
    UIButton *temp = (UIButton*)(sender);
    if(temp == _m_buttonTypeLeft)
        m_synthType--;
    else if(temp == _m_buttonTypeRight)
        m_synthType++;
    
    if(m_synthType == SYNTH_COUNT)
        m_synthType = 0;
    else if(m_synthType < 0)
        m_synthType = SYNTH_COUNT - 1;
    
    [_m_labelSynthType setText:[[NSString alloc] initWithFormat:@"%s", SYNTH_TYPE_STR[m_synthType]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
