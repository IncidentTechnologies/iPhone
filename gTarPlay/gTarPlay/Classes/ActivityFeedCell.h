//
//  ActivityFeedCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/13/13.
//
//

#import <UIKit/UIKit.h>

@class UserSongSession;

@interface ActivityFeedCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *activity;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;

@property (strong, nonatomic) UserSongSession *userSongSession;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

- (IBAction)likeButtonClicked:(id)sender;

- (void)updateCell;

@end
