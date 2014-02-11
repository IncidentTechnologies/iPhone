//
//  CustomStringCell.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/21/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CustomStringCell : UITableViewCell
{
    BOOL cellSelected;
}

- (void)notifySelected:(BOOL)isSelected;
- (void)updateFilename:(NSString *)newFilename isCustom:(BOOL)isCustom;
- (BOOL)isSet;

@property (retain) AVAudioPlayer * audio;
@property (nonatomic) NSString * sampleFilename;
@property (nonatomic) UIColor * defaultFontColor;
@property (nonatomic) int index;
@property (weak, nonatomic) IBOutlet UIButton * stringBox;
@property (weak, nonatomic) IBOutlet UILabel * stringLabel;
@property (nonatomic) BOOL useCustomPath;

@end
