//
//  DefaultViewController.m
//  gTarCreate
//
//  Created by Idan Beck on 2/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "DefaultViewController.h"
#import "AudioController.h"

//#import "AudioNodeCommon.h"
//#import "AUNodeNetwork.h"

@interface DefaultViewController ()

@end

@implementation DefaultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)onButtonTestClicked:(id)sender {
    AudioController *ac = [AudioController sharedAudioController];
    
    /*AudioNode *root = [[ac GetNodeNetwork] GetRootNode];
    WavetableNode *wavNode = new WavetableNode();
    EnvelopeNode *envNode = new EnvelopeNode();
    
    ConnectNodes(wavNode, envNode);
    ConnectNodes(envNode, root);*/
    
    [ac startAUGraph];
}

-(IBAction)onButtonTriggerClicked:(id)sender {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
