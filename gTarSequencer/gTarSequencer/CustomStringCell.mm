//
//  CustomStringCell.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/21/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomStringCell.h"

@implementation CustomStringCell
@synthesize delegate;
@synthesize index;
@synthesize stringLabel;
@synthesize stringBox;
@synthesize defaultFontColor;
@synthesize sampleFilename;
@synthesize sampleDisplayname;
@synthesize useCustomPath;
@synthesize stringColor;
@synthesize stringImage;
@synthesize xmpId;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (BOOL)isSet
{
    if(sampleFilename != nil){
        return TRUE;
    }
    
    return FALSE;
}

-(void)layoutSubviews
{
    [self drawStringIndicator];
    
}

// Overriding this for custom behavior
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)notifySelected:(BOOL)isSelected
{
    cellSelected = isSelected;
    
    [self updateSelectedUI];
}

- (void)updateFilename:(NSString *)newFilename xmpId:(NSInteger)newXmpId isCustom:(BOOL)isCustom
{
    sampleFilename = newFilename;
    
    xmpId = newXmpId;
    
    // parse _ to /
    newFilename = [newFilename stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    sampleDisplayname = newFilename; //[@"../" stringByAppendingString:newFilename];
    
    useCustomPath = isCustom;
    
    [stringLabel setText:sampleDisplayname];
    
    defaultFontColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
    
    [self updateSelectedUI];
}

- (void)updateSelectedUI
{
    if(cellSelected){
        
        // draw play button
        
        [self.stringLabel setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
        [self setBackgroundColor:stringColor];
        
        if([self isSet]){
            [self showPlayButton];
        }

    }else{
        
        
        [self.stringLabel setTextColor:defaultFontColor];
        
        // reset background color
        if(self.index % 2 == 0){
            [self setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
        }else{
            [self setBackgroundColor:[UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0]];
        }
        
        if([self isSet]){
            [self hidePlayButton];
        }
    }
}

- (void)drawStringIndicator
{
    
    CGSize size = CGSizeMake(stringBox.frame.size.width, stringBox.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 10;
    int playX = stringBox.frame.size.width/2 - playWidth/2;
    int playY = 12;
    CGFloat playHeight = stringBox.frame.size.height - 2*playY;
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    [stringImage setImage:newImage];
    
    [stringImage setAlpha:0.3];
    
    UIGraphicsEndImageContext();
}

- (void)showPlayButton
{
    [UIView animateWithDuration:0.3 animations:^(void){
        
        [stringImage setAlpha:1.0];
        
        _stringBoxWidthConstraint.constant = 30.0;
        _stringImageMarginLeftConstraint.constant = 10.0;
        _stringLabelMarignLeftConstraint.constant = 30.0;
        
        [self.contentView layoutIfNeeded];
        
    }completion:^(BOOL finished){
        
        [stringBox addTarget:self action:@selector(playAudioForSampleFile) forControlEvents:UIControlEventTouchUpInside];
    
    }];
}

- (void)hidePlayButton
{
    [UIView animateWithDuration:0.3 animations:^(void){
        
        [stringImage setAlpha:0.3];
        
        _stringBoxWidthConstraint.constant = 10.0;
        _stringImageMarginLeftConstraint.constant = 0.0;
        _stringLabelMarignLeftConstraint.constant = 18.0;
        
        [self.contentView layoutIfNeeded];
    
    } completion:^(BOOL finished){
        [stringBox removeTarget:self action:@selector(playAudioForSampleFile) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)playAudioForSampleFile
{
    [delegate playAudioForFile:sampleFilename withCustomPath:useCustomPath xmpId:xmpId];
}

@end
