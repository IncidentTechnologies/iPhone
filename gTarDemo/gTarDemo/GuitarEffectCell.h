//
//  GuitarEffectCell.h
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuitarEffect;
@class SecondViewController;

@interface GuitarEffectCell : UITableViewCell

@property (unsafe_unretained, nonatomic) SecondViewController * m_secondViewController;
@property (unsafe_unretained, nonatomic) GuitarEffect * m_guitarEffect;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_clearFirstLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_colorLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_colorRandomLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_directionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_directionRandomLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_durationLabel;

- (IBAction)upButtonClicked:(id)sender;
- (IBAction)downButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;
- (void)updateCell;

@end
