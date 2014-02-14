//
//  DefaultViewController.m
//  gTarCreate
//
//  Created by Idan Beck on 2/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "DefaultViewController.h"
#import "AudioController.h"

#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

@interface DefaultViewController () {
    WavetableNode *m_wavNode;
    EnvelopeNode *m_envNode;
}

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
    
    AudioNode *root = [[ac GetNodeNetwork] GetRootNode];
    
    m_wavNode = new WavetableNode();
    m_envNode = new EnvelopeNode();
    
    ConnectNodes(m_wavNode, m_envNode);
    ConnectNodes(m_envNode, root);
    
    [ac startAUGraph];
}

-(IBAction)onButtonTriggerClicked:(id)sender {
    NSLog(@"trig");
    
    if(!m_envNode->IsNoteOn()) {
        m_wavNode->trigger();
        m_envNode->NoteOn();
    } else
        m_envNode->NoteOff();
       
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
