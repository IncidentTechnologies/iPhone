//
//  ScrollingCell.h
//  Sequence
//
//  Created by Kate Schnippering on 10/1/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"

@interface ScrollingCell : UITableViewCell <UIGestureRecognizerDelegate>
{
    
}

@property (weak, nonatomic) id parent;

@property (weak, nonatomic) IBOutlet UIView * container;
@property (nonatomic, strong) UIPanGestureRecognizer * panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * rightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * leftConstraint;

@property (weak, nonatomic) IBOutlet UIButton * deleteButton;

- (IBAction)userDidSelectDeleteButton:(id)sender;

@end
