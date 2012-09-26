//
//  CustomComboBox.h
//  gTarPlay
//
//  Created by Joel Greenia on 2/19/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomComboBox : UIControl <UIScrollViewDelegate>
{

    CGFloat m_rowHeight;
    
}

@property (retain) UIScrollView *m_scrollView;
@property (nonatomic, readonly) NSInteger m_contentLength;
@property (nonatomic, readonly) NSInteger m_selectedIndex;
@property (nonatomic, retain) NSArray *m_contentArray;
@property (nonatomic, retain) NSMutableArray *m_headerIndices;
@property (retain) NSMutableArray *m_contentSubviews;

@property (retain) NSTimer *m_flickerTimer;

- (void) populateWithImages:(NSArray*)images;
- (void) populateWithText:(NSArray*)text;
- (void) snapToClosestIndex;
- (void) snapToLocation:(CGFloat)location;
- (void) snapToOffset:(CGFloat)offset;
- (void) snapToIndex:(NSInteger)index;

- (CGFloat) convertIndexToOffset:(NSInteger)index;
- (void) tapHandler:(UIGestureRecognizer*)gestureRecognizer;

- (void) flickerSelectedItem;
- (void) stopFlicker;
- (void) animateFlicker:(NSTimer*)theTimer;
- (void) makeHeaderEntryAtIndex:(NSUInteger)index;

- (NSString*) getNameAtIndex:(NSUInteger)index;

@end
