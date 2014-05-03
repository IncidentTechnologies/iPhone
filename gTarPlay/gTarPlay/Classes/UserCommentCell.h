//
//  UserCommentCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/11/13.
//
//

#import <UIKit/UIKit.h>

@interface UserCommentCell : UITableViewCell

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) UIImage *picture;

@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;

- (void)updateCell;

@end
