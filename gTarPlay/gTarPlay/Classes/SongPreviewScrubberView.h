//
//  SongPreviewScrubberView.h
//  gTarPlay
//
//  Created by Marty Greenia on 10/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongPreviewView;
@class NSSongModel;

@protocol SongPreviewScrubberViewDelegate <NSObject>

- (void)haltPlayback;
- (void)restorePlayback;
- (void)pauseSong;

@end

@interface SongPreviewScrubberView : UIView
{
    
    id<SongPreviewScrubberViewDelegate> m_delegate;
    
    UIImageView * m_knobImageView;
    UIImageView * m_leftBarImageView;
    UIImageView * m_rightBarImageView;
    
    SongPreviewView * m_songPreviewView;
    
    NSSongModel * m_songModel;
    
    CGFloat m_seekBarHeight;
    
    BOOL m_dragging;
    
}

@property (nonatomic, assign) id<SongPreviewScrubberViewDelegate> m_delegate;

- (id)initWithFrame:(CGRect)frame andSongModel:(NSSongModel*)songModel;
- (UIImage*)drawKnobImage;
- (UIImage*)drawBarImage:(CGFloat*)colors;
- (void)updateView;
- (void)updateKnobWithPoint:(CGPoint)point;

@end
