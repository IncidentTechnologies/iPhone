//
//  CustomSegmentedControl.h
//  gTarPlay
//
//  Created by Joel Greenia on 11/8/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegmentedControl : UIView
{
    
    NSArray * m_segmentViews;
    NSInteger m_selectedSegmentIndex;
    
}

@property (nonatomic, readonly) NSInteger m_selectedSegmentIndex;

- (IBAction)segmentButtonClicked:(id)sender;

@end
