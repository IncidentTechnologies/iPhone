//
//  CustomSampleCell.h
//  Sequence
//
//  Created by Kate Schnippering on 2/26/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSampleCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UIButton * deleteButton;
@property (weak, nonatomic) IBOutlet UILabel * sampleTitle;
@property (weak, nonatomic) IBOutlet UIImageView * sampleArrow;

@end
