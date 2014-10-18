//
//  CustomSampleCell.m
//  Sequence
//
//  Created by Kate Schnippering on 2/26/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomSampleCell.h"

@implementation CustomSampleCell

@synthesize delegate;
@synthesize deleteButton;
@synthesize sampleTitle;
@synthesize sampleArrow;
@synthesize parentCategory;
@synthesize xmpId;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        xmpId = -3;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [self setUserInteractionEnabled:YES];
    
    if([self respondsToSelector:@selector(setLayoutMargins:)]){
        self.layoutMargins = UIEdgeInsetsZero; // iOS 8+
    }
    [self setSeparatorInset:UIEdgeInsetsZero];
}

- (void)awakeFromNib
{
    // Add swipe recognizer for deleting
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    self.panRecognizer.delegate = self;
    
    [self.container addGestureRecognizer:self.panRecognizer];
}


#pragma mark - Editing

// Allow the table to scroll vertically
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

- (void)panCell:(UIPanGestureRecognizer *)recognizer
{
    if(![parentCategory isEqualToString:@"Custom"]){
        return;
    }
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            self.panStartPoint = [recognizer translationInView:self.container];
            self.startingLeftConstraint = self.leftConstraint.constant;
            //DLog(@"Pan Began at %@", NSStringFromCGPoint(self.panStartPoint));
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            CGPoint currentPoint = [recognizer translationInView:self.container];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            
            //DLog(@"Pan Moved %f", deltaX);
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
                    self.rightConstraint.constant = -1 * [self buttonTotalWidth] - constant;
                }
            } else if (fabs(self.leftConstraint.constant) < [self buttonTotalWidth]){
                CGFloat constant = deltaX;
                if (constant <= -1 * [self buttonTotalWidth]) {
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                } else {
                    self.leftConstraint.constant = constant;
                    self.rightConstraint.constant = -1 * [self buttonTotalWidth] - constant;
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
            
            //DLog(@"Pan Ended");
            break;
            
        case UIGestureRecognizerStateCancelled:
            
            if (self.startingLeftConstraint == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            DLog(@"Pan Cancelled");
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
    DLog(@"Delete cell");
    
    [delegate deleteCustomSampleCell:self];
    
}

@end
