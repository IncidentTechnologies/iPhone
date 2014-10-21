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
#import "CustomSampleCell.h"
#import "CustomSoundRecorder.h"
#import "TutorialViewController.h"
#import "HorizontalAdjustor.h"

@protocol CustomInstrumentSelectorDelegate <NSObject>

- (void)closeCustomInstrumentSelectorAndScroll:(BOOL)scroll;
- (void)saveCustomInstrumentWithStrings:(NSArray *)stringSet stringIds:(NSArray *)stringIdSet andName:(NSString *)instName andStringPaths:(NSArray *)stringPaths andIcon:(NSString *)iconName;
- (NSMutableArray *)getCustomInstrumentOptions;

- (void)stopAllPlaying;
- (void)startAllPlaying;
- (BOOL)checkIsPlaying;
- (BOOL)checkIsRecording;

@end

@interface CustomInstrumentSelector : UIView <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CustomSoundDelegate,TutorialDelegate,HorizontalAdjustorDelegate,CustomSampleCellDelegate,CustomStringCellDelegate,OphoSampleDelegate>
{
    int viewState;
    
    // Sample and string lists
    UIView * backgroundView;
    
    NSMutableArray * sampleList;
    NSMutableArray * customSampleList;
    NSMutableArray * sampleStack;
    NSMutableArray * sampleListSubset;
    
    NSMutableArray * stringSet;
    NSMutableArray * stringPaths;
    NSMutableArray * stringIdSet;
    NSArray * colorList;
    NSString * customSampleListPath;
    
    int activesection;
    
    CustomSampleCell * selectedSampleCell;
    CustomStringCell * selectedStringCell;

    // Naming
    NSArray * customIconSet;
    int customIconCounter;
    
    // Recorder
    CustomSoundRecorder * customSoundRecorder;
    int recordState;
    double progressBarPercent;
    double playBarPercent;
    NSTimer * recordTimer;
    NSTimer * progressBarTimer;
    NSTimer * playBarTimer;
    NSTimer * playResetTimer;
    NSTimer * audioLoadTimer;
    //NSTimer * recordProcessingTimer;
    
    int recordProcessingCounter;
    
    BOOL isRecordingReady;
    BOOL isRecordingNameReady;
    BOOL isPaused;
    BOOL pausePlaying;
    
    float timePlayed;
    
}

- (void)moveFrame:(CGRect)newFrame;
- (void)launchSelectorView;
- (IBAction)reverseSampleStack:(id)sender;

- (int)countSamples;

@property (nonatomic) BOOL isFirstLaunch;

@property (retain, nonatomic) TutorialViewController * tutorialViewController;

@property (nonatomic) CGRect viewFrame;
@property (nonatomic) NSString * instName;

@property (retain) AVAudioPlayer * audio;
@property (weak, nonatomic) id<CustomInstrumentSelectorDelegate> delegate;
@property (nonatomic ,weak) IBOutlet UITableView * sampleTable;
@property (nonatomic, weak) IBOutlet UITableView * stringTable;

@property (nonatomic, weak) IBOutlet UIButton * sampleLibraryTitle;
@property (nonatomic, weak) UIImageView * sampleLibraryArrow;
@property (nonatomic, weak) IBOutlet UIButton * nextButton;
@property (nonatomic, weak) UIImageView * nextButtonArrow;
@property (nonatomic, weak) IBOutlet UIButton * recordButton;
@property (nonatomic, weak) IBOutlet UIView * recordCircle;

@property (nonatomic, weak) IBOutlet UIButton * saveButton;
@property (nonatomic, weak) IBOutlet UITextField * nameField;
@property (nonatomic, weak) IBOutlet UIView * customIcon;
@property (nonatomic) UIButton * customIconButton;
@property (nonatomic, weak) IBOutlet UIButton * customIndicator;

//@property (nonatomic, weak) IBOutlet UIButton * recordBackButton;
@property (nonatomic, weak) IBOutlet UIButton * recordRecordButton;
@property (nonatomic, weak) IBOutlet UIButton * recordClearButton;
@property (nonatomic, weak) IBOutlet UIButton * recordSaveButton;
@property (nonatomic, weak) IBOutlet UILabel * recordProcessing;
@property (nonatomic) UIImageView * recordActionView;
@property (nonatomic, weak) IBOutlet UIView * progressBar;
@property (nonatomic, weak) IBOutlet UIView * progressBarContainer;
@property (nonatomic, weak) IBOutlet UIView * playBar;
@property (nonatomic, weak) IBOutlet UIView * recordLine;
@property (nonatomic, weak) IBOutlet UITextField * recordingNameField;

@property (nonatomic, retain) HorizontalAdjustor * horizontalAdjustor;

@property (retain, nonatomic) UIButton * cancelButton;

@end
