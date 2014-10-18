//
//  CustomSampleCell.h
//  Sequence
//
//  Created by Kate Schnippering on 2/26/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"

@protocol CustomSampleCellDelegate <NSObject>

- (void)deleteCustomSampleCell:(id)cell;
    
@end

@interface CustomSampleCell : UITableViewCell
{
    
}

@property (weak, nonatomic) id<CustomSampleCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton * deleteButton;
@property (weak, nonatomic) IBOutlet UILabel * sampleTitle;
@property (weak, nonatomic) IBOutlet UIImageView * sampleArrow;
@property (nonatomic) NSString * parentCategory;
@property (assign, nonatomic) NSInteger xmpId;


// Slide to delete
@property (weak, nonatomic) IBOutlet UIView * container;
@property (nonatomic, strong) UIPanGestureRecognizer * panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingLeftConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint * rightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * leftConstraint;

- (IBAction)userDidSelectDeleteButton:(id)sender;

@end
