//
//  SocialSongCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 5/7/13.
//
//

#import <UIKit/UIKit.h>

@class UserSongSession;

@interface SocialSongCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) UserSongSession *userSongSession;

- (void)updateCell;

@end
