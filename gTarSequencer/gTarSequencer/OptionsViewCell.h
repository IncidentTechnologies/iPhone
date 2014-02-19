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
    
    UIColor * activeColor;
    UIColor * darkGrayColor;
    UIColor * blueColor;

}

- (void)userDidSaveLoad;
- (void)endNameEditing;
- (void)setAsActiveSequencer;
- (void)unsetAsActiveSequencer;

@property (weak, nonatomic) OptionsViewController * parent;

@property (weak, nonatomic) IBOutlet UILabel * fileText;
@property (weak, nonatomic) IBOutlet UITextField * fileName;
@property (weak, nonatomic) IBOutlet UIButton * fileLoad;
@property (weak, nonatomic) IBOutlet UILabel * fileDate;

@property (nonatomic) BOOL isRenamable;
@property (nonatomic) int rowid;

@end
