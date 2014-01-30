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


@protocol CustomInstrumentSelectorDelegate <NSObject>

- (void)closeCustomInstrumentSelectorAndScroll:(BOOL)scroll;
- (void)saveCustomInstrumentWithStrings:(NSArray *)stringSet andName:(NSString *)instName;

@end

@interface CustomInstrumentSelector : UIView <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    
    UIView * backgroundView;
    NSMutableArray * sampleList;
    NSMutableArray * stringSet;
    NSArray * colorList;
    
    int activesection;
    
    UITableViewCell * selectedSampleCell;
    CustomStringCell * selectedStringCell;
    
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
@property (nonatomic, weak) IBOutlet UIButton * saveButton;
@property (nonatomic, weak) IBOutlet UIButton * backButton;
@property (nonatomic, weak) IBOutlet UITextField * nameField;
@property (nonatomic, weak) IBOutlet UIView * customIcon;

@property (retain, nonatomic) UIButton * cancelButton;

@end
