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
#import "XMPSample.h"
#import "XMPTree.h"

#import "XMPObjectFactory.h"

@interface DefaultViewController () {
    WavetableNode *m_wavNode;
    EnvelopeNode *m_envNode;
    SampleNode *m_sampNode;
    DelayNode *m_delayNode;
    SamplerNode *m_samplerNode;
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

-(void)setUpSamplerWithBaseName:(NSString *)strBaseName {
    m_samplerNode = new SamplerNode();
    SamplerBankNode *newBank = NULL;
    
    // Create a guitar sampler model
    for(int i = 0; i < 6; i++) {
        m_samplerNode->CreateNewBank(newBank);
        
        for(int j = 0; j < 16; j++) {
            int openStringVal = 40 + i * 5;
            if(i > 3) openStringVal -= 1;
            int midiVal = openStringVal + j;
            
            NSString *resourceName = [[NSString alloc] initWithFormat:@"%@ %d", strBaseName, midiVal];
            
            NSLog(@"Loading sample:%@ str:%d", resourceName, i);
            m_samplerNode->LoadSampleIntoBank(i, (char *)[[[NSBundle mainBundle] pathForResource:resourceName ofType:@"mp3"] UTF8String], m_sampNode);
        }
    }
    
    [[[AudioController sharedAudioController] GetNodeNetwork] GetRootNode]->ConnectInput(0, m_samplerNode, 0);
}

-(void)testFxNode {
    AudioNode *rootNode = [[[AudioController sharedAudioController] GetNodeNetwork] GetRootNode];
    
    m_sampNode = new SampleNode((char *)[[[NSBundle mainBundle] pathForResource:@"Clapping" ofType:@"m4a"] UTF8String]);
    NSLog(@"Sample is %f ms long", m_sampNode->GetLength());
    
    m_sampNode->SetStart(700.0f);
    m_sampNode->SetEnd(850.0f);
    
    //DiffusionTankNode *fxNode = new DiffusionTankNode(150.7f, 0.9, true, 1.0f);
    //FirstOrderFilterNode *fxNode = new FirstOrderFilterNode(0.2f, 1.0f);
    ReverbNode *fxNode = new ReverbNode(0.2f);
    
    rootNode->ConnectInput(0, fxNode, 0);
    fxNode->ConnectInput(0, m_sampNode, 0);
}

-(IBAction)onButtonTestClicked:(id)sender {
    AudioController *ac = [AudioController sharedAudioController];

    //[self setUpSamplerWithBaseName:@"Acoustic Guitar"];
    

    //[self testFxNode];
    //m_sampNode = new SampleNode((char *)[[[NSBundle mainBundle] pathForResource:@"Clapping" ofType:@"m4a"] UTF8String]);
    //XMPSample *xmpSample = [[XMPSample alloc] initWithSampleBuffer:m_sampNode->GetSampleBuffer()];
    //[xmpSample CreateXMPTreeAndSaveToFile:"test.xmp" andOverwrite:TRUE];
    
    //XMPTree *xmpTree = new XMPTree((char *)[[[NSBundle mainBundle] pathForResource:@"clap" ofType:@"xmp"] UTF8String]);
    //xmpTree->PrintXMPTree();
    
    XMPObject *xmpObj = [XMPObjectFactory MakeXMPObjectFromFilename:@"clap"];
    
    /*m_envNode = new EnvelopeNode();
    m_delayNode = new DelayNode(500.0f, 0.75f, 1.0f);
    
    // connect the network
    m_envNode->ConnectInput(0, m_sampNode, 0);
    m_delayNode->ConnectInput(0, m_envNode, 0);
     */
    
    //root->ConnectInput(0, m_delayNode, 0);
    
    
    
    /*
    m_wavNode = new WavetableNode();
    root->ConnectInput(0, m_envNode, 0);
    m_envNode->ConnectInput(0, m_wavNode, 0);
     */
    
    
    [ac startAUGraph];
}

-(IBAction)onButtonTriggerClicked:(id)sender {
    NSLog(@"trig");
    
    /*
    if(!m_envNode->IsNoteOn()) {
        m_wavNode->trigger();
        m_envNode->NoteOn();
    } else
        m_envNode->NoteOff();
    */
    
    m_sampNode->Trigger();
    //m_envNode->NoteOn();
    
    /*
    SampleNode *bank = m_samplerNode[0][0][0][0];
    bank->Trigger();
     */
    
    
    
    /*
    static int str = 0;
    static int ind = 0;
    
    m_samplerNode->TriggerBankSample(str, ind);
    
    ind++;
    if(ind >= 16) {
        ind = 0;
        str++;
        if(str >= 6)
            str = 0;
    }
     */
       
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
