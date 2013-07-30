//
//  SongTableViewController.h
//  Sketch
//
//  Created by Franco on 7/22/13.
//
//

#import <UIKit/UIKit.h>

@class UserSongSession;

@protocol SongTableViewControllerDelegate <NSObject>

- (void)selectedSong:(UserSongSession*)songSession;
- (void)playSong:(UserSongSession*)songSession;

@end

@interface SongTableViewController : UITableViewController <UITableViewDataSource, UITabBarControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<SongTableViewControllerDelegate> delegate;
@property (strong, nonatomic, readonly) NSMutableArray* songList;

- (void)addSongSession:(UserSongSession*)songSession;

@end
