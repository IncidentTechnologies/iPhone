//
//  SelectNavigationViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomNavigationViewController.h"

@class SelectListViewController;
@class SelectSongOptionsViewController;
@class SelectSongOptionsPopupViewController;
@class SongViewController;
@class CloudResponse;
@class UserSong;
@class SongPlaybackController;

@interface SelectNavigationViewController : CustomNavigationViewController
{
    
    NSArray * m_userSongArray;
//    NSArray * m_preloadedUserSongArray;
    
    SelectListViewController * m_selectListViewController;
    SelectListViewController * m_selectSearchViewController;
    
    SelectSongOptionsPopupViewController * m_popupOptionsViewController;
    SongPlaybackController * m_playbackController;
    
    NSInteger m_outStandingFileDownloads;
    
}

- (void)fileDownloadFinished:(id)file;

- (void)showSongOptions:(UserSong*)userSong;
- (void)startSongInstance:(SongViewController*)songViewController;
- (void)previewUserSong:(UserSong*)userSong;
- (void)stopPreview;

- (void)refreshSongList;
- (void)requestSongListCallback:(CloudResponse*)cloudResponse;

@end
