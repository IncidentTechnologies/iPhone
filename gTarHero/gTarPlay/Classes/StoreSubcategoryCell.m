//
//  StoreSubcategoryCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/7/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreSubcategoryCell.h"


@implementation StoreSubcategoryCell

@synthesize m_subcategoryLabel;
@synthesize m_subcategoryName;

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
    
    [m_subcategoryLabel release];
    [m_subcategoryName release];
    
    [super dealloc];
}

- (void)updateCell
{
    [m_subcategoryLabel setText:m_subcategoryName];
    
    [super updateCell];
    
}

@end
