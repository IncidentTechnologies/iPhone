//
//  ScrollingCell.m
//  Sequence
//
//  Created by Kate Schnippering on 10/1/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "ScrollingCell.h"

@implementation ScrollingCell

@synthesize deleteButton;
@synthesize parent;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    self.panRecognizer.delegate = self;
    
    [self.container addGestureRecognizer:self.panRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)panCell:(UIPanGestureRecognizer *)recognizer
{
    // TODO: constant to turn delete on/off
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            self.panStartPoint = [recognizer translationInView:self.container];
            self.startingLeftConstraint = self.leftConstraint.constant;
            NSLog(@"Pan Began at %@", NSStringFromCGPoint(self.panStartPoint));
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            CGPoint currentPoint = [recognizer translationInView:self.container];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            
            NSLog(@"Pan Moved %f", deltaX);
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            
            //if (self.contentViewLeftConstraint == 0) { //2
            //The cell was closed and is now opening
            if (!panningLeft) {
                CGFloat constant = deltaX;
                if (constant > 0) {
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                } else {
                    self.leftConstraint.constant = constant;
                }
            } else {
                CGFloat constant = deltaX;
                if (constant <= -1 * [self buttonTotalWidth]) {
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                } else {
                    self.leftConstraint.constant = constant;
                }
            }
            //}
            
            break;
        }
        case UIGestureRecognizerStateEnded:
            
            if (self.leftConstraint.constant < 0) {
                //Cell was opening
                CGFloat halfButton = -1 * [self buttonTotalWidth] / 2.0;
                if (self.leftConstraint.constant < halfButton) {
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }else{
                // Re-close
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            }
            
            NSLog(@"Pan Ended");
            break;
            
        case UIGestureRecognizerStateCancelled:
            
            if (self.startingLeftConstraint == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            NSLog(@"Pan Cancelled");
            break;
            
        default:
            break;
    }
}


- (CGFloat)buttonTotalWidth {
    return deleteButton.frame.size.width;
}

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    self.leftConstraint.constant = 0.0;
    self.rightConstraint.constant = -1 * [self buttonTotalWidth];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    self.leftConstraint.constant = -1 * [self buttonTotalWidth];
    self.rightConstraint.constant = 0.0;
}

- (IBAction)userDidSelectDeleteButton:(id)sender
{
    DLog(@"Delete cell!");
}


@end
