//
//  XYInputView.h
//  keys
//
//  Created by Marty Greenia on 1/31/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYInputView;

@protocol XYInputViewDelegate
-(void)positionChanged:(CGPoint)position forView:(XYInputView*)view; 
@end

@interface XYInputView : UIView
{
	CGPoint m_currentPosition;
	
	IBOutlet UIImageView * m_slider;
	
}

@property (nonatomic, weak) id<XYInputViewDelegate> m_delegate;
@property (nonatomic, strong) UIImageView * m_slider;

- (void)clearSliderFromPosition:(CGPoint)position;
- (void)setCurrentPosition:(CGPoint)point;
- (void)setNormalizedPosition:(CGPoint)point;
- (void)moveSliderToPosition:(CGPoint)position;
- (void)sendNewPosition:(CGPoint)position;

@end
