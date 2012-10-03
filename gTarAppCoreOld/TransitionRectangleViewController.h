//
//  TransitionRectangleViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/9/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopupViewController.h"

// A lot of the animations in this class can actually be replaced with
// core animation layer 'transitions'
@interface TransitionRectangleViewController : PopupViewController
{
    
    NSInteger m_currentIndex;
    
    NSMutableArray * m_viewArray;
    
    UIView * m_currentView;
    UIView * m_nextView;
    
    NSString * m_title;
    NSArray * m_imageArray;
    NSArray * m_textArray;
    
    IBOutlet UIView * m_displayView;
    
    IBOutlet UIButton * m_nextButton;
    IBOutlet UIButton * m_backButton;
    IBOutlet UIButton * m_doneButton;
    
    IBOutlet UIPageControl * m_pageControl;
    
}

@property (nonatomic, retain) NSString * m_title;
@property (nonatomic, retain) NSArray * m_imageArray;
@property (nonatomic, retain) NSArray * m_textArray;

@property (nonatomic, retain) IBOutlet UIView * m_displayView;

@property (nonatomic, retain) IBOutlet UIButton * m_nextButton;
@property (nonatomic, retain) IBOutlet UIButton * m_backButton;
@property (nonatomic, retain) IBOutlet UIButton * m_doneButton;

@property (nonatomic, retain) IBOutlet UIPageControl * m_pageControl;

- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

//- (void)attachToSuperView:(UIView *)superView withImages:(NSArray*)imageNames andText:(NSArray*)text;
- (void)convertImageAndTextArrays;
- (void)addView:(UIView*)newView;
- (void)swapInViewLeft:(UIView*)nextView;
- (void)swapInViewRight:(UIView*)nextView;
- (void)swapViewsWithNextTransform:(CGAffineTransform)nextStartTransform andCurrentTransform:(CGAffineTransform)currentEndTransform;
- (void)swapViewFinished;
- (void)createDefaultViews;

@end
