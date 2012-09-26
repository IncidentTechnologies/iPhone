//
//  FirstViewController.h
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SecondViewController.h"

@interface FirstViewController : UIViewController
{
    CGFloat m_duration;
}

@property (unsafe_unretained, nonatomic) SecondViewController * m_secondViewController;

@property (unsafe_unretained, nonatomic) IBOutlet UISwitch * m_clearFirstSwitch;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *m_redColorControl;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *m_greenColorControl;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *m_blueColorControl;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *m_randomColorSwitch;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *m_directionControl;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *m_directionScatteringSwitch;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_durationLabel;

- (IBAction)addButtonClicked:(id)sender;
- (IBAction)plusButtonClicked:(id)sender;
- (IBAction)minusButtonClicked:(id)sender;

@end
