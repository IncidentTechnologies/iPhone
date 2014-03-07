//
//  OptionsViewCell.h
//  Sequence
//
//  Created by Kate Schnippering on 2/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//


#import "AppData.h"
#import <QuartzCore/QuartzCore.h>

@class OptionsViewController;

@interface OptionsViewCell : UITableViewCell <UITextFieldDelegate>
{
    BOOL isActiveSequencer;
    BOOL isEditingMode;
    
    UIColor * activeColor;
    UIColor * darkGrayColor;
    UIColor * blueColor;
    
    NSString * previousNameText;

}

- (void)userDidSaveLoad;
- (void)editingDidBegin;
- (void)editingDidEnd;
- (void)endNameEditing;
- (void)setAsActiveSequencer;
- (void)unsetAsActiveSequencer;
- (NSString *)getNameForFile;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@property (weak, nonatomic) OptionsViewController * parent;

@property (weak, nonatomic) IBOutlet UILabel * fileText;
@property (weak, nonatomic) IBOutlet UITextField * fileName;
@property (weak, nonatomic) IBOutlet UIButton * fileLoad;
@property (weak, nonatomic) IBOutlet UILabel * fileDate;

@property (weak, nonatomic) IBOutlet UIButton * deleteButton;

@property (nonatomic) BOOL isRenamable;
@property (nonatomic) int rowid;

@end
