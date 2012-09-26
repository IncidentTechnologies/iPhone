//
//  StoreCategoryCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/27/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreCategoryCell.h"


@implementation StoreCategoryCell

@synthesize m_categoryNameLabel;
@synthesize m_backButton;
@synthesize m_categoryName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        // Initialization code
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    
    [m_categoryNameLabel release];
    [m_backButton release];
    [m_categoryName release];
    [super dealloc];
    
}

+ (CGFloat)cellHeight
{
    return 40;
}

- (void)updateCell
{
    [m_categoryNameLabel setText:m_categoryName];
}

@end
