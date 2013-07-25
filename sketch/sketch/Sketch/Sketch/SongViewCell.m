//
//  SongViewCell.m
//  Sketch
//
//  Created by Franco on 7/22/13.
//
//

#import "SongViewCell.h"

#import <QuartzCore/QuartzCore.h>

@interface SongViewCell ()
{
    
}

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

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
    _deleteButton.hidden = YES;
}

- (void)showDeleteButton
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.6;
    [_deleteButton.layer addAnimation:animation forKey:nil];
    _deleteButton.hidden = NO;
    _songDate.hidden = YES;
}

- (void)hideDeleteButton
{
    _deleteButton.hidden = YES;
    _songDate.hidden = NO;
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
    
    _songTitle.textColor = (highlighted | self.selected) ? [UIColor whiteColor] : [UIColor blackColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_songTitle isFirstResponder] && [touch view] != _songTitle) {
        [_songTitle resignFirstResponder];
    }
}

@end
