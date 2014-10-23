//
//  CustomComboBox.h
//  gTarPlay
//
//  Created by Marty Greenia on 2/19/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomComboBox : UIControl <UIScrollViewDelegate>
{

    CGFloat m_rowHeight;
    
}

@property (strong) UIScrollView *m_scrollView;
@property (nonatomic, readonly) NSInteger m_contentLength;
@property (nonatomic, readonly) NSInteger m_selectedIndex;
@property (nonatomic, strong) NSArray *m_contentArray;
@property (nonatomic, strong) NSMutableArray *m_headerIndices;
@property (strong) NSMutableArray *m_contentSubviews;

@property (strong) NSTimer *m_flickerTimer;

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
