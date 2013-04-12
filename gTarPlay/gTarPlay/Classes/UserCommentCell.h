//
//  UserCommentCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/11/13.
//
//

#import <UIKit/UIKit.h>

@interface UserCommentCell : UITableViewCell

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *comment;
@property (retain, nonatomic) UIImage *picture;

@property (retain, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (retain, nonatomic) IBOutlet UILabel *commentLabel;

- (void)updateCell;

@end
