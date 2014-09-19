//
//  RecordEditor.h
//  Sequence
//
//  Created by Kate Schnippering on 9/18/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSTrack.h"
#import "AppData.h"
#import "HorizontalAdjustor.h"

#define MAX_TRACKS 5.0
#define MIN_MEASURES 8.0
#define MEASURES_PER_SCREEN 8.0

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@protocol RecordEditorDelegate <NSObject>

// Data access
- (NSTrack *)trackWithName:(NSString *)trackName;
- (NSTrack *)instTrackAtId:(long)instId;

@end

@interface RecordEditor : NSObject <HorizontalAdjustorDelegate>
{
    // Drawing
    UIScrollView * trackView;
    NSMutableDictionary * trackclips;
    
    // Editing
    NSTrack * editingTrack;
    NSClip * editingClip;
    NSClip * blinkingClip;
    UIView * editingClipView;
    UIView * editingClipLeftSlider;
    UIView * editingClipRightSlider;
    UILabel * editingPatternLetter;
    UIButton * editingPatternLetterOverlay;
    HorizontalAdjustor * horizontalAdjustor;
    float lastDiff;
    
}

- (id)initWithScrollView:(UIScrollView *)scrollView;
- (void)clearAllSubviews;
- (void)longPressEvent:(UILongPressGestureRecognizer *)recognizer;

- (UIView *)drawClipViewForClip:(NSClip *)clip track:(NSTrack *)track inFrame:(CGRect)frame atIndex:(int)index;
- (void)drawPatternLetterForClip:(NSClip *)clip inView:(UIView *)view;

- (float)getXPositionForClipBeat:(float)beat;

@property (weak, nonatomic) id<RecordEditorDelegate> delegate;

@end
