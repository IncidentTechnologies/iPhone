//
//  UserCommentCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/11/13.
//
//

#import "UserCommentCell.h"

@implementation UserCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self )
    {
        // Initialization code
        _name = @"Anonymous";
        _comment = @"Nothing to say";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)updateCell
{
    UIFont *boldFont = [UIFont boldSystemFontOfSize:_commentLabel.font.pointSize];

    NSString *string = [NSString stringWithFormat:@"%@ %@", _name, _comment];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attributedString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0,_name.length)];
    
    _commentLabel.attributedText = attributedString;
}

- (void)dealloc
{
    [_name release];
    [_comment release];
    [_picture release];
    [_pictureImageView release];
    [_commentLabel release];
    [super dealloc];
}
@end
