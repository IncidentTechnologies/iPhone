//
//  SynthViewController.m
//  gTarCreate
//
//  Created by Idan Beck on 5/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "SynthViewController.h"

@interface SynthViewController ()

@end

@implementation SynthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_synth1 = [[SynthSourceViewController alloc] initWithNibName:@"SynthSourceViewController" bundle:NULL];
        m_synth2 = [[SynthSourceViewController alloc] initWithNibName:@"SynthSourceViewController" bundle:NULL];
        m_synth3 = [[SynthSourceViewController alloc] initWithNibName:@"SynthSourceViewController" bundle:NULL];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    int m = 15;
    
    // Do any additional setup after loading the view from its nib.
    m_synth1.view.frame = CGRectOffset(m_synth1.view.frame, m, m);
    [self.view addSubview:m_synth1.view];
    
    m_synth2.view.frame = CGRectOffset(m_synth2.view.frame, m_synth1.view.frame.size.width + m_synth1.view.frame.origin.x + m, m);
    [self.view addSubview:m_synth2.view];
    
    m_synth3.view.frame = CGRectOffset(m_synth3.view.frame, m_synth2.view.frame.size.width + m_synth2.view.frame.origin.x + m, m);
    [self.view addSubview:m_synth3.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
