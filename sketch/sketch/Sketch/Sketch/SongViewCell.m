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
        // Initialization code
    }
    return self;
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
