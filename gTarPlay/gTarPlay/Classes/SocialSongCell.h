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

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *artistLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

@property (retain, nonatomic) UserSongSession *userSongSession;

- (void)updateCell;

@end
