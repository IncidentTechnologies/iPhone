//
//  DefaultViewController.m
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "DefaultViewController.h"
#import "XMPObjectFactory.h"

#import "OphoController.h"
#import "CloudResponse.h"
#import "XmlDom.h"

extern OphoController *g_ophoController;

@interface DefaultViewController () {
    
}
@end

@implementation DefaultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        m_soundRecorder = [[SoundRecorder alloc] init];
        [m_soundRecorder setDelegate:self];

        m_pSampleNode = NULL;
        m_pServerSampleNode = NULL;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RESULT) ClearSample {
    RESULT r = R_SUCCESS;
    
    if(m_pSampleNode != NULL) {
        m_pSampleNode->Stop();
        delete m_pSampleNode;
        m_pSampleNode = NULL;
    }

Error:
    return r;
}

- (RESULT) TriggerSample {
    RESULT r = R_SUCCESS;
    
    if(m_pServerSampleNode != NULL)
        m_pServerSampleNode->Trigger();
    else if(m_pSampleNode != NULL)
        m_pSampleNode->Trigger();
    
Error:
    return r;
}

#pragma mark - SoundRecorder Delegate Functions

- (void) OnRecordStart {
    NSLog(@"Recording Started");
}

- (void) OnRecordEnd:(SampleNode*)sampNode {
    NSLog(@"Recording Ended");
    
    AudioController *ac = [AudioController sharedAudioController];
    AudioNode *rootNode = [[ac GetNodeNetwork] GetRootNode];
    
    m_pSampleNode = sampNode;
    
    // For testing
    rootNode->ConnectInput(0, m_pSampleNode, 0);
}

#pragma mark - UI Event Handelers

- (IBAction)recordButtonClicked:(id)sender {
    if([m_soundRecorder isRecording]) {
        [m_soundRecorder Stop];
        [(UIButton*)(sender) setTitle:@"Record" forState:UIControlStateNormal];
    }
    else {
        [self ClearSample];
        
        [(UIButton*)(sender) setTitle:@"Stop" forState:UIControlStateNormal];
        [m_soundRecorder Start];
    }
}

- (IBAction)playButtonClicked:(id)sender {
    [self TriggerSample];
}

- (IBAction)clearButtonClicked:(id)sender {
    [self ClearSample];
}

- (IBAction)uploadButtonClicked:(id)sender {
    NSLog(@"Attempt to upload sample to opho");
    OphoCloudController *occ = [g_ophoController GetCloudController];
    
    NSString *strTempName = @"tempName";
    
    if(m_pSampleNode != NULL)
        [occ requestSaveXmpWithSampleNode:m_pSampleNode andName:strTempName andCallbackObj:self andCallbackSel:@selector(saveNewOphoSampleCallback:)];
    
    //- (CloudRequest*)requestSaveXmpWithSampleNode:(SampleNode *)sampleNode andName:(NSString*)name andCallbackObj:(id)obj andCallbackSel:(SEL)sel {
}

-(void) saveNewOphoSampleCallback:(CloudResponse *)cloudResponse {
    // Callback
    long xmpid = (long)cloudResponse.m_id;
    
    // Lets load an SampleNode from XMPID to test it
    OphoCloudController *occ = [g_ophoController GetCloudController];
    [occ requestGetXmpWithId:xmpid isXmpOnly:false andCallbackObj:self andCallbackSel:@selector(xmpLoadedCallback:)];
}


- (void)xmpLoadedCallback:(CloudResponse *)cloudResponse {
    XmlDom *xmp = cloudResponse.m_xmpDom;
    XmlDom *sampleXmp = [xmp getChildWithName:@"sample"];
    
    NSString *datastring = [sampleXmp getText];
    
    if(datastring == NULL || [datastring length] == 0){
        NSLog(@"ERROR: attempting to play string with empty data");
        return;
    }
    
    // Base 64 decode
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:datastring options:NULL];
    unsigned long int length = [decodedData length];
    
    NSLog(@"Length of decoded data is %lu",length);
    
    //[self ClearSample];
    m_pServerSampleNode = new SampleNode((void*)[decodedData bytes], length);
    
    // For testing
    AudioController *ac = [AudioController sharedAudioController];
    AudioNode *rootNode = [[ac GetNodeNetwork] GetRootNode];
    rootNode->ConnectInput(0, m_pServerSampleNode, 0);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
