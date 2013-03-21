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

- (void)updateCell;

@property (retain, nonatomic) IBOutlet UIImageView *picture;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *activity;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (retain, nonatomic) UserSongSession *userSongSession;

@end
