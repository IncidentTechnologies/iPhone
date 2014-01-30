//
//  SaveLoadSelector.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/28/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SaveLoadSelectorDelegate <NSObject>

- (void) closeSaveLoadSelector;
- (void) saveWithName:(NSString *)filename;
- (void) loadFromName:(NSString *)filename;

@end

@interface SaveLoadSelector : UIView <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    UIView * backgroundView;
    
    NSMutableArray * fileLoadSet;

}

- (void)userDidSaveSequence;
- (void)userDidLoadSequence;
- (void)moveFrame:(CGRect)newFrame;

// Save
- (IBAction)userDidLoadFromSave:(id)sender;
- (void)userDidSaveFromSave:(id)sender;

// Load
- (IBAction)userDidSaveFromLoad:(id)sender;
- (IBAction)userDidLoadFromLoad:(id)sender;

@property (retain, nonatomic) NSString * activeSequencer;

@property (weak, nonatomic) id<SaveLoadSelectorDelegate> delegate;
@property (nonatomic) CGRect viewFrame;
@property (retain, nonatomic) UIButton * cancelButton;

@property (weak, nonatomic) IBOutlet UIButton * saveSaveButton;
@property (weak, nonatomic) IBOutlet UIButton * saveLoadButton;
@property (weak, nonatomic) IBOutlet UIButton * loadSaveButton;
@property (weak, nonatomic) IBOutlet UIButton * loadLoadButton;

// Save
@property (weak, nonatomic) IBOutlet UITextField * saveField;
@property (weak, nonatomic) IBOutlet UILabel * saveWarning;

// Load
@property (weak, nonatomic) IBOutlet UIPickerView * filePicker;
@property (weak, nonatomic) IBOutlet UILabel * noFilesLabel;

@end

