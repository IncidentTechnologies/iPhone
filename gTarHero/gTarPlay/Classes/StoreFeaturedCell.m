//
//  StoreFeaturedCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/27/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreFeaturedCell.h"

@implementation StoreFeaturedCell

@synthesize m_rankingLabel;
@synthesize m_rankBackgroundView;
@synthesize m_rankNumber;

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

    // total hack to make sure this thing doesn't go invisible
    m_rankBackgroundView.backgroundColor = [UIColor blackColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    
    [super setHighlighted:highlighted];
    
}


- (void)dealloc
{

    [m_rankingLabel release];
    
    [super dealloc];
    
}

+ (CGFloat)cellHeight
{
    // default
    return 60.0f;
}

- (void)updateCell
{
    
    NSString * rankString = [NSString stringWithFormat:@"%u", m_rankNumber];
    
    [m_rankingLabel setText:rankString];

    [super updateCell];
    
}

@end
