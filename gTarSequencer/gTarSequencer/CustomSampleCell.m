//
//  CustomSampleCell.m
//  Sequence
//
//  Created by Kate Schnippering on 2/26/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomSampleCell.h"

@implementation CustomSampleCell

@synthesize deleteButton;
@synthesize sampleTitle;
@synthesize sampleArrow;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
}

#pragma mark - Deleting
// Prevent bouncing
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat targetOffset = 42;
    if(scrollView.contentOffset.x >= targetOffset){
        scrollView.contentOffset = CGPointMake(targetOffset, 0.0);
    }
}

@end
