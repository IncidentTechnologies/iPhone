//
//  FriendFeedViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserController.h>
#import "SongPlayerViewController.h"

@class UserSongSession;
@class CloudResponse;

@interface FriendFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{

    UserController * m_userController;
    
    IBOutlet UITableView * m_tableView;
    
    SongPlayerViewController * m_songPlaybackViewController;
    
    NSArray * m_friendSessions;
}

@property (nonatomic, retain) IBOutlet UITableView * m_tableView;

- (void)preloadImages;
- (void)updateFriendFeed;
- (void)playUserSongSession:(UserSongSession*)session;

@end
