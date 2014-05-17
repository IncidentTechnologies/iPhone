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

static void cbLevel(float val, void *pObject, void *pContext) {
    UILevelSlider *slider = (__bridge UILevelSlider*)(pObject);
    
    //val = 1.0f - val;
    
    val *= 10.0f;
    
    if(val > 1.0f)
        val = 1.0f;
    else if(val < 0.0f)
        val = 0.0f;
    
    //NSLog(@"%f", val);
    
    [slider setDisplayValue:val];
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
        
        m_samplerNode->SetBankGain(i, 0.5f);
    }
    
    //m_samplerNode->ReleaseBank(2);
    //m_samplerNode->ReleaseBank(newBank);
    
    //m_samplerNode->SubscribeLevel(LEVEL_ABS_GEOMETRIC_MEAN, (__bridge void*)(_m_levelSlider), cbLevel, NULL);
    //m_samplerNode->SubscribeRMS((__bridge void*)(_m_levelSlider), cbLevel, NULL);
    LevelSubscriber *sub = m_samplerNode->SubscribeAbsoluteMean((__bridge void*)(_m_levelSlider), cbLevel, NULL);
    
    [[[AudioController sharedAudioController] GetNodeNetwork] GetRootNode]->ConnectInput(0, m_samplerNode, 0);
    
//    [[AudioController sharedAudioController] startAUGraph];
    
    
  //  m_samplerNode->UnSubscribe(sub);
}

-(IBAction)onKnobChanged:(id)sender {
    UIKnob *knob = (UIKnob*)sender;
    double val = [knob GetValue];
    NSLog(@"Knob value %f", val);
}

-(IBAction)onLevelSliderChanged:(id)sender {
    UILevelSlider *slider = (UILevelSlider*)sender;
    double val = [slider GetValue];
    NSLog(@"Slider value %f", val);
}

-(void)testDisconnect {
    int i = 2;
    SampleNode *samples[16];
    NSString *strBaseName = @"Acoustic Guitar";
    
    for(int j = 0; j < 16; j++) {
        int openStringVal = 40 + i * 5;
        if(i > 3) openStringVal -= 1;
        int midiVal = openStringVal + j;
        
        NSString *resourceName = [[NSString alloc] initWithFormat:@"%@ %d", strBaseName, midiVal];
        
        NSLog(@"Loading sample:%@ str:%d", resourceName, i);
        samples[j] = new SampleNode((char *)[[[NSBundle mainBundle] pathForResource:resourceName ofType:@"mp3"] UTF8String]);
        
        [[[AudioController sharedAudioController] GetNodeNetwork] GetRootNode]->ConnectInput(0, samples[j], 0);
    }
    
    delete samples[0];
    
}

- (IBAction)onSliderChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    float val = slider.value;
    
    AudioController *ac = [AudioController sharedAudioController];
    if(![ac SetVolume:val])
        NSLog(@"Failed to set volume to %f", val);
}

-(void)testFxNode {
    AudioNode *rootNode = [[[AudioController sharedAudioController] GetNodeNetwork] GetRootNode];
    
    m_sampNode = new SampleNode((char *)[[[NSBundle mainBundle] pathForResource:@"Clapping" ofType:@"m4a"] UTF8String]);
    NSLog(@"Sample is %f ms long", m_sampNode->GetLength());
    
    m_sampNode->SetStart(700.0f);
    m_sampNode->SetEnd(850.0f);
    
    //m_sampNode->SetChannelGain(0.25f, CONN_OUT);
    
    //DiffusionTankNode *fxNode = new DiffusionTankNode(150.7f, 0.9, true, 1.0f);
    //FirstOrderFilterNode *fxNode = new FirstOrderFilterNode(0.2f, 1.0f);
    ReverbNode *revNode = new ReverbNode(1.0f);
    
    LevelNode *levelNode = new LevelNode();
    levelNode->Subscribe(LEVEL_RMS, (void*)CFBridgingRetain(_m_levelSlider), cbLevel, NULL);
    
    rootNode->ConnectInput(0, levelNode, 0);
    levelNode->ConnectInput(0, revNode, 0);
    revNode->ConnectInput(0, m_sampNode, 0);
    
    // Test saving the manipulated file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *newFilepath = [documentsDirectory stringByAppendingPathComponent:@"NewClap.m4a"];
    
    m_sampNode->SaveToFile((char*)[newFilepath UTF8String], true);
}

-(void) testFilenode {
    //AudioNode *rootNode = [[[AudioController sharedAudioController] GetNodeNetwork] GetRootNode];
    
    WavetableNode *genNode = new WavetableNode();
    genNode->SetType(WAVETABLE_SINE);
    //rootNode->ConnectInput(0, genNode, 0);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *newFilepath = [documentsDirectory stringByAppendingPathComponent:@"test.m4a"];
    FileoutNode *fileNode = new FileoutNode((char*)[newFilepath UTF8String], true);
    
    fileNode->ConnectInput(0, genNode, 0);
    
    for(int i = 0; i < 10; i++)
        fileNode->SaveSamples(44100);
    
    if(fileNode != NULL) {
        delete fileNode;
        fileNode = NULL;
    }
}

-(IBAction)onButtonTestClicked:(id)sender {
    AudioController *ac = [AudioController sharedAudioController];
    
    //[self testDisconnect];
    
    [self setUpSamplerWithBaseName:@"Acoustic Guitar"];

    //[self testFxNode];
    
    //[self testFilenode];
    
    //m_sampNode = new SampleNode((char *)[[[NSBundle mainBundle] pathForResource:@"Clapping" ofType:@"m4a"] UTF8String]);
    //XMPSample *xmpSample = [[XMPSample alloc] initWithSampleBuffer:m_sampNode->GetSampleBuffer()];
    //[xmpSample CreateXMPTreeAndSaveToFile:"test.xmp" andOverwrite:TRUE];
    
    //XMPTree *xmpTree = new XMPTree((char *)[[[NSBundle mainBundle] pathForResource:@"seqTest" ofType:@"xmp"] UTF8String]);
    //xmpTree->PrintXMPTree();
    
    //XMPObject *xmpObj = [XMPObjectFactory MakeXMPObjectFromFilename:@"seqTest"];
    //int a = 5;
    
    /*
    XMPObject *xmpObj = [[XMPObject alloc] init];
    XMPSong *xmpSong = [[XMPSong alloc] initWithSongTitle:@"test song" author:@"test author" description:@"test description"];
    [xmpObj AddXMPObject:xmpSong];
    
    XMPTrack *newTrack = [xmpSong AddNewTrackWithName:@"new track"];
    [[[[newTrack AddNewInstrumentWithName:@"instrums"] AddNewSamplerWithName:@"sampler 1"] AddNewBankWithName:@"bank 1"] AddNewSampleWithValue:40 path:@"idanrulez.mp3"];
    
    XMPClip *newClip = [newTrack AddNewClipWithName:@"new clip" Start:0.0f End:4.0f];
    [newClip AddNewNote:40 beatstart:2.0f duration:1.0f];
    [newClip AddNewNote:41 beatstart:1.25f duration:0.75f];
    
    XMPTree *tree = [xmpObj GetXMPTree];
    //tree->PrintXMPTree();

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *newFilepath = [documentsDirectory stringByAppendingPathComponent:@"test.xmp"];
    
    tree->SaveXMPToFile((char*)[newFilepath UTF8String], true);
     */
    
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
    
    //m_sampNode->Trigger();
    
    
    //m_envNode->NoteOn();
    
    /*
    SampleNode *bank = m_samplerNode[0][0][0][0];
    bank->Trigger();
     */
    
    
    
    ///*
    static int str = 0;
    static int ind = 0;
    
    m_samplerNode->TriggerBankSample(str, ind);
    
    ind++;
    if(ind >= 16) {
        ind = 0;
        str++;
        //if(str >= 6)
        if(str >= 5)
            str = 0;
    }
    //*/
}

-(IBAction)onNavButtonClicked:(id)sender {
    UIButton *senderButton = (UIButton*)(sender);
    
    //[m_navigationController popViewControllerAnimated:false];
    [m_navigationController popToRootViewControllerAnimated:false];
    
    NSArray *tempArr = [m_navigationController viewControllers];
    
    if(senderButton == _m_buttonSynth) {
        if((id)(m_synthViewController) != [[m_navigationController viewControllers] lastObject])
            [m_navigationController pushViewController:m_synthViewController animated:false];
    }
    else if(senderButton == _m_buttonSettings) {
        if((id)(m_settingsViewController) != [[m_navigationController viewControllers] lastObject])
            [m_navigationController pushViewController:m_settingsViewController animated:false];
    }
    else if(senderButton == _m_buttonGtar) {
        if((id)(m_gtarViewController) != [[m_navigationController viewControllers] lastObject])
            [m_navigationController pushViewController:m_gtarViewController animated:false];
    }
    else if(senderButton == _m_buttonLED) {
        if((id)(m_ledViewController) != [[m_navigationController viewControllers] lastObject])
            [m_navigationController pushViewController:m_ledViewController animated:false];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    m_navigationController = [[UINavigationController alloc] init];
    m_navigationController.view.frame = CGRectOffset(_m_navView.frame, 0.0f, 48.0f);
    
    [m_navigationController setNavigationBarHidden:YES];
    [_m_navView addSubview:m_navigationController.view];
    
    m_createRootViewController = [[CreateRootViewController alloc] initWithNibName:@"CreateRootViewController" bundle:NULL];
    
    m_synthViewController = [[SynthViewController alloc] initWithNibName:@"SynthViewController" bundle:NULL];
    m_settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:NULL];
    m_gtarViewController = [[GtarViewController alloc] initWithNibName:@"GtarViewController" bundle:NULL];
    m_ledViewController = [[LEDViewController alloc] initWithNibName:@"LEDViewController" bundle:NULL];
    
    // Push the default
    [m_navigationController pushViewController:m_createRootViewController animated:FALSE];  // should never hit this
    [m_navigationController pushViewController:m_gtarViewController animated:FALSE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
