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

@interface OptionsViewCell : UITableViewCell <UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    BOOL isActiveSequencer;
    BOOL isActiveSong;
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
- (void)setAsActiveSong;
- (void)unsetAsActiveSong;
- (NSString *)getNameForFile;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

- (void)highlightSetButton;
- (void)highlightSongButton;

//- (void)resetContentOffset;

@property (weak, nonatomic) OptionsViewController * parent;

@property (weak, nonatomic) IBOutlet UILabel * fileText;
@property (weak, nonatomic) IBOutlet UITextField * fileName;
@property (weak, nonatomic) IBOutlet UIButton * fileLoad;
@property (weak, nonatomic) IBOutlet UILabel * fileDate;
@property (weak, nonatomic) IBOutlet UIView * activeIndicator;

@property (weak, nonatomic) IBOutlet UIButton * setButton;
@property (weak, nonatomic) IBOutlet UIButton * songButton;

// Layout resizing

@property (nonatomic, weak) IBOutlet NSLayoutConstraint * rightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * leftConstraint;


// Slide to delete
@property (weak, nonatomic) IBOutlet UIView * container;
@property (nonatomic, strong) UIPanGestureRecognizer * panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * setButtonWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * songButtonLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * songButtonWidth;

@property (weak, nonatomic) IBOutlet UIButton * deleteButton;

- (IBAction)userDidSelectDeleteButton:(id)sender;

//@property (nonatomic) UIScrollView * scroller;
@property (nonatomic) BOOL isRenamable;
@property (nonatomic) BOOL isNameEditing;
@property (nonatomic) int rowid;

@property (assign, nonatomic) NSInteger xmpId;

- (IBAction)userDidSelectSetButton:(id)sender;
- (IBAction)userDidSelectSongButton:(id)sender;

@end
