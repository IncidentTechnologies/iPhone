//
//  CustomStringCell.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/21/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"

@protocol CustomStringCellDelegate <NSObject>

- (void)playAudioForFile:(NSString *)filename withCustomPath:(BOOL)useCustomPath xmpId:(NSInteger)xmpId;

@end

@interface CustomStringCell : UITableViewCell
{
    BOOL cellSelected;
}

- (void)notifySelected:(BOOL)isSelected;
- (void)updateFilename:(NSString *)newFilename xmpId:(NSInteger)newXmpId isCustom:(BOOL)isCustom;
- (BOOL)isSet;

@property (weak, nonatomic) id<CustomStringCellDelegate> delegate;

@property (nonatomic) NSString * sampleFilename;
@property (nonatomic) NSString * sampleDisplayname;
@property (nonatomic) UIColor * defaultFontColor;
@property (nonatomic) int index;
@property (weak, nonatomic) IBOutlet UIButton * stringBox;
@property (weak, nonatomic) IBOutlet UILabel * stringLabel;
@property (retain, nonatomic) IBOutlet UIImageView * stringImage;
@property (nonatomic) BOOL useCustomPath;
@property (nonatomic) UIColor * stringColor;
@property (assign, nonatomic) NSInteger xmpId;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint * stringBoxWidthConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint * stringLabelMarignLeftConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint * stringImageMarginLeftConstraint;

@end
