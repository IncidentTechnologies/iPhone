//
//  CustomSegmentedControl.h
//  gTarPlay
//
//  Created by Joel Greenia on 11/8/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegmentedControl : UIControl
{
    
    NSArray * m_segmentViews;
    NSInteger m_selectedSegmentIndex;
    
    BOOL m_usingImages;
    
}

@property (nonatomic, readonly) NSInteger m_selectedSegmentIndex;

- (void)changeTitles:(NSArray*)titleArray;
- (void)changeOnImages:(NSArray*)onImages andOffImages:(NSArray*)offImages;
- (UIImage*)createGradientImage:(CGSize)size withIntensity:(CGFloat)intensity;
- (void)setSelectedIndex:(NSInteger)index;
- (void)setFontSize:(CGFloat)size;
- (IBAction)segmentButtonClicked:(id)sender;

@end
