//
//  CustomStringCell.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/21/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomStringCell.h"

@implementation CustomStringCell
@synthesize index;
@synthesize stringLabel;
@synthesize stringBox;
@synthesize defaultFontColor;
@synthesize sampleFilename;

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

- (void)updateFilename:(NSString *)newFilename isCustom:(BOOL)isCustom
{
    sampleFilename = newFilename;
    
    useCustomPath = isCustom;
    
    [stringLabel setText:newFilename];
    
    defaultFontColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
    
    [self drawPlayButton];
    [self updateSelectedUI];
}

- (void)updateSelectedUI
{
    if(cellSelected){
        [self.stringLabel setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
        [self setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3]];
    }else{
        
        [self.stringLabel setTextColor:defaultFontColor];
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)drawPlayButton
{
    
    CGSize size = CGSizeMake(stringBox.frame.size.width, stringBox.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 10;
    int playX = stringBox.frame.size.width/2 - playWidth/2;
    int playY = 3;
    CGFloat playHeight = stringBox.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [stringBox addSubview:image];
    
    UIGraphicsEndImageContext();
    
    [stringBox addTarget:self action:@selector(playAudioForSampleFile) forControlEvents:UIControlEventTouchUpInside];

}

// TODO: share this with the audio on Custom Instrument Selector
- (void)playAudioForSampleFile
{
    
    NSString * path;
    
    if(useCustomPath){
        
        // different filetype and location
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Samples/" stringByAppendingString:[sampleFilename stringByAppendingString:@".m4a"]]];
        
    }else{
        
        path = [[NSBundle mainBundle] pathForResource:sampleFilename ofType:@"mp3"];
    }
    
    NSError * error = nil;
    NSURL * url = [NSURL fileURLWithPath:path];
    
    self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    [self.audio play];
}

@end
