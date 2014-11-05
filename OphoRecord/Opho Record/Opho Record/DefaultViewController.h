//
//  DefaultViewController.h
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

#import "SoundRecorder.h"
#import "XMPSample.h"

@interface DefaultViewController : UIViewController <UITextFieldDelegate, SoundRecorderDelegate>{
    SoundRecorder *m_soundRecorder;
    
    SampleNode *m_pSampleNode;
    SampleNode *m_pServerSampleNode;
}

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;

- (RESULT) ClearSample;
- (RESULT) TriggerSample;

- (IBAction)recordButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)clearButtonClicked:(id)sender;
- (IBAction)uploadButtonClicked:(id)sender;

@end
