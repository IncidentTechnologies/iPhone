//
//  CustomInstrumentSelector.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/20/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CustomStringCell.h"
#import "CustomSoundRecorder.h"

@protocol CustomInstrumentSelectorDelegate <NSObject>

- (void)closeCustomInstrumentSelectorAndScroll:(BOOL)scroll;
- (void)saveCustomInstrumentWithStrings:(NSArray *)stringSet andName:(NSString *)instName andStringPaths:(NSArray *)stringPaths;

@end

@interface CustomInstrumentSelector : UIView <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CustomSoundDelegate>
{
    
    UIView * backgroundView;
    NSMutableArray * sampleList;
    NSMutableArray * customSampleList;
    NSMutableArray * stringSet;
    NSMutableArray * stringPaths;
    NSArray * colorList;
    NSString * customSampleListPath;
    
    int activesection;
    
    UITableViewCell * selectedSampleCell;
    CustomStringCell * selectedStringCell;
    
    // Recorder
    CustomSoundRecorder * customSoundRecorder;
    int recordState;
    double progressBarPercent;
    double playBarPercent;
    NSTimer * recordTimer;
    NSTimer * progressBarTimer;
    NSTimer * playBarTimer;
    
    BOOL isRecordingReady;
    BOOL isRecordingNameReady;
    
}

- (void)moveFrame:(CGRect)newFrame;
- (void)launchSelectorView;

@property (nonatomic) CGRect viewFrame;
@property (nonatomic) NSString * instName;

@property (retain) AVAudioPlayer * audio;
@property (weak, nonatomic) id<CustomInstrumentSelectorDelegate> delegate;
@property (nonatomic ,weak) IBOutlet UITableView * sampleTable;
@property (nonatomic, weak) IBOutlet UITableView * stringTable;
@property (nonatomic, weak) IBOutlet UIButton * nextButton;
@property (nonatomic, weak) IBOutlet UIButton * recordButton;

@property (nonatomic, weak) IBOutlet UIButton * saveButton;
@property (nonatomic, weak) IBOutlet UIButton * backButton;
@property (nonatomic, weak) IBOutlet UITextField * nameField;
@property (nonatomic, weak) IBOutlet UIView * customIcon;

@property (nonatomic, weak) IBOutlet UIButton * recordBackButton;
@property (nonatomic, weak) IBOutlet UIButton * recordRecordButton;
@property (nonatomic, weak) IBOutlet UIButton * recordClearButton;
@property (nonatomic, weak) IBOutlet UIButton * recordSaveButton;
@property (nonatomic, weak) IBOutlet UIView * progressBar;
@property (nonatomic, weak) IBOutlet UIView * progressBarContainer;
@property (nonatomic, weak) IBOutlet UIView * playBar;
@property (nonatomic, weak) IBOutlet UITextField * recordingNameField;

@property (retain, nonatomic) UIButton * cancelButton;

@end
