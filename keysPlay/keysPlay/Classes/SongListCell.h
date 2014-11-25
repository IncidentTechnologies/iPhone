//
//  SongListCell.h
//  keysPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import <UIKit/UIKit.h>
#import "FrameGenerator.h"

@class UserSong;

@interface SongListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) IBOutlet UIView *titleArtistView;
@property (strong, nonatomic) IBOutlet UIView *skillView;
@property (strong, nonatomic) IBOutlet UIView *scoreView;

@property (strong, nonatomic) IBOutlet UILabel *songTitle;
@property (strong, nonatomic) IBOutlet UILabel *songArtist;
@property (strong, nonatomic) IBOutlet UILabel *songScore;
@property (strong, nonatomic) IBOutlet UIButton *songStar;
@property (strong, nonatomic) IBOutlet UIImageView *songSkill;

@property (strong, nonatomic) IBOutlet UIView * selectedBgView;

@property (strong, nonatomic) UserSong *userSong;
@property (assign, nonatomic) NSInteger playScore;
@property (assign, nonatomic) NSInteger playStars;

- (void)updateCell;
- (void)updateCellInactive;

@end
