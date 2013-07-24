//
//  SongViewCell.m
//  Sketch
//
//  Created by Franco on 7/22/13.
//
//

#import "SongViewCell.h"

@implementation SongViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // DO NOT put init code here as this cell gets created from
        // IB/storyboard, so awakeFromNib is called
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initiation Code here
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    _songTitle.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
    _songTitle.userInteractionEnabled = selected ? YES : NO;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    _songTitle.textColor = highlighted ? [UIColor whiteColor] : [UIColor blackColor];
}

@end
