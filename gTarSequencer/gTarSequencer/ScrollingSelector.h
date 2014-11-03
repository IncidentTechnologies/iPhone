//
//  ScrollingSelector.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/26/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "CustomInstrumentSelector.h"

#define HEIGHT_OF_WHITE_BAR 3

@protocol ScrollingSelectorDelegate <NSObject>

- (void)scrollingSelectorUserDidSelectIndex:(int)indexSelected;
- (void)scrollingSelectorDidRemoveIndex:(int)indexSelected;
- (void)launchCustomInstrumentSelector;

@end

// Given a dictionary containing 3 arrays:
//      1) regular images
//      2) highlighted images
//      3) names
//      the ScrollingSelector will populate a scrollview with the items laid out in a pattern with two rows
//      determined by the following variables:
//      -- topRowIcon & bottomRowIcon
//      -- topRowLabel & bottomRowLabel
//      -- iconSize & labelSize
//      -- gap
//      The icons go top to bottom, such that the first icon is the upper left, the second is the lower left, and so on.
@interface ScrollingSelector : UIView <UIScrollViewDelegate>
{
    NSMutableArray * images;
    NSMutableArray * highlightedImages;
    NSMutableArray * customIndicators;
    NSMutableArray * names;
    NSMutableArray * customized;
    
    int indexToDelete;
    
    NSMutableArray * imageButtons;      // array of UIButtons
    
    NSMutableDictionary * instrumentObjects;
    
    CGSize contentSize;
    BOOL withAnimation;
    
    UIView * backgroundView;
    
    CGPoint currentOrigin;
    
    CGFloat topRowIcon;     // The height of the top row of icons
    CGFloat bottomRowIcon;  // The height of the bottom row of icons
    
    CGFloat topRowLabel;    // Height of the top row of labels
    CGFloat bottomRowLabel; // Height of the bottom row of labels
    
    CGSize iconBorderSize;  // Padding around icons
    CGSize iconSize;        // Height and width of the icons
    CGSize labelSize;       // Height and width of the labels
    
    CGPoint lastContentOffset;
    double gap;
    int cols;
    int pageCount;
    int currentPage;
    int targetPage;
    
}

- (void)moveFrame:(CGRect)newFrame;
- (void)scrollToMax;

@property (weak, nonatomic) id<ScrollingSelectorDelegate> delegate;
@property (retain, nonatomic) NSMutableArray * options;
@property (retain, nonatomic) UIButton * cancelButton;

@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;
@property (weak, nonatomic) IBOutlet UIView * paginationView;

@property (nonatomic) UIImageView * customArrow;

@end
