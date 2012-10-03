//
//  SelectListViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"
#import "PullToUpdateTableView.h"

@class UserSong;

@interface SelectListViewController : CustomViewController <PullToUpdateTableViewDelegate>
{
    
    NSArray * m_userSongArray;
    
    IBOutlet PullToUpdateTableView * m_tableView;
    IBOutlet UILabel * m_statusLabel;
    IBOutlet UIImageView * m_titleSort;
    IBOutlet UIImageView * m_artistSort;
    IBOutlet UIImageView * m_difficultySort;
    IBOutlet UIImageView * m_scoreSort;
    
    BOOL m_sortAccending;
    UIImageView * m_sortColumnImage;
    
}

@property (nonatomic, retain) NSArray * m_userSongArray;

@property (nonatomic, retain) IBOutlet PullToUpdateTableView * m_tableView;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;
@property (nonatomic, retain) IBOutlet UIImageView * m_titleSort;
@property (nonatomic, retain) IBOutlet UIImageView * m_artistSort;
@property (nonatomic, retain) IBOutlet UIImageView * m_difficultySort;
@property (nonatomic, retain) IBOutlet UIImageView * m_scoreSort;

- (void)refreshDisplay;
- (void)showSongDetails:(UserSong*)userSong;

- (IBAction)titleSorting:(id)sender;
- (IBAction)artistSorting:(id)sender;
- (IBAction)difficultSorting:(id)sender;
- (IBAction)scoreSorting:(id)sender;
- (void)refreshSortedList;

@end
