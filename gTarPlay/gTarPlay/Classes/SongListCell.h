//
//  SongListCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import <UIKit/UIKit.h>

@class UserSong;

@interface SongListCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (retain, nonatomic) IBOutlet UIView *titleArtistView;
@property (retain, nonatomic) IBOutlet UIView *skillView;
@property (retain, nonatomic) IBOutlet UIView *scoreView;

@property (retain, nonatomic) IBOutlet UILabel *songTitle;
@property (retain, nonatomic) IBOutlet UILabel *songArtist;
@property (retain, nonatomic) IBOutlet UILabel *songScore;
@property (retain, nonatomic) IBOutlet UIImageView *songSkill;

@property (retain, nonatomic) IBOutlet UIView * selectedBgView;

@property (retain, nonatomic) UserSong *userSong;
@property (assign, nonatomic) NSInteger playScore;

- (void)updateCell;
- (void)updateCellInactive;

@end
