//
//  SaveLoadSelector.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/28/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionsDelegate <NSObject>

- (void) saveWithName:(NSString *)filename;
- (void) loadFromName:(NSString *)filename;

@end

@interface OptionsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    NSMutableArray * fileLoadSet;

}

- (void)userDidSaveSequence;
- (void)userDidLoadSequence;

@property (retain, nonatomic) NSString * activeSequencer;

@property (weak, nonatomic) id<OptionsDelegate> delegate;

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

