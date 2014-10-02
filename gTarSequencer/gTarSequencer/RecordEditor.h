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
- (void)regenerateDataForTrack:(NSTrack *)track;

// Super-drawing
- (void)redrawProgressView;
- (void)drawGridOverlayLines;
- (void)drawTickmarks;
- (void)setMeasures:(int)newNumMeasures drawGrid:(BOOL)drawGrid;

// Playback
- (void)stopRecordPlaybackAnimatePlayband:(BOOL)animate;

@end

@interface RecordEditor : NSObject <HorizontalAdjustorDelegate>
{
    // Drawing
    UIScrollView * trackView;
    UIView * progressView;
    NSMutableDictionary * trackclips;
    NSMutableDictionary * trackaddclips;
    int numMeasures;
    
    float measureWidth;
    float measureHeight;
    
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
    
    CGFloat colors[STRINGS_ON_GTAR][4];
    
}

- (id)initWithScrollView:(UIScrollView *)scrollView progressView:(UIView *)progress;
- (void)clearAllSubviews;
- (void)deactivateEditingClip;

- (void)setMeasures:(int)measures;

- (UIView *)drawClipViewForClip:(NSClip *)clip track:(NSTrack *)track inFrame:(CGRect)frame atIndex:(int)index;
- (void)drawPatternLetterForClip:(NSClip *)clip inView:(UIView *)view;
- (void)drawPatternNotesForClip:(NSClip *)clip inView:(UIView *)view;
- (void)drawProgressBarForClip:(NSClip *)clip atIndex:(float)trackIndex;
- (void)drawAddClipMeasureForTrack:(NSString *)trackName;

- (float)getXPositionForClipBeat:(float)beat;
- (float)getProgressXPositionForClipBeat:(float)beat;

@property (weak, nonatomic) id<RecordEditorDelegate> delegate;

@end
