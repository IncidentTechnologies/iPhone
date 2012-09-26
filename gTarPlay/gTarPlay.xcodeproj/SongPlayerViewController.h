//
//  SongPlayerViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/12/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupViewController.h"
#import "SongPreviewScrubberView.h"

@class SongPlaybackController;
@class UserSongSession;
@class RoundedRectangleView;
@class SongPreviewScrubberView;
@class UserProfile;
@class UserSong;

@protocol SongPlayerDelegate <NSObject>

- (void)songPlayerDisplayUserProfile:(UserProfile*)userProfile;
- (void)songPlayerDisplayUserSong:(UserSong*)userSong;

@end

@interface SongPlayerViewController : PopupViewController <SongPreviewScrubberViewDelegate>
{
    
    id<SongPlayerDelegate> m_delegate;
    
    NSString * m_xmpBlob;
    
    SongPlaybackController * m_playbackController;
    
    SongPreviewScrubberView * m_songPreviewScrubberView;
    
    UserSongSession * m_userSongSession;
    
    NSTimer * m_progressUpdateTimer;
    
    IBOutlet UIButton * m_playPauseButton;
    IBOutlet UIView * m_background;
    
    IBOutlet UIButton * m_userNameButton;
    IBOutlet UIButton * m_songNameButton;
    IBOutlet UILabel * m_trackTimeLabel;
    IBOutlet UIView * m_previewView;
    
}

@property (nonatomic, assign) id<SongPlayerDelegate> m_delegate;
@property (nonatomic, retain) IBOutlet UIButton * m_playPauseButton;
@property (nonatomic, retain) IBOutlet UIView * m_background;
@property (nonatomic, retain) IBOutlet UIButton * m_userNameButton;
@property (nonatomic, retain) IBOutlet UIButton * m_songNameButton;
@property (nonatomic, retain) IBOutlet UILabel * m_trackTimeLabel;
@property (nonatomic, retain) IBOutlet UIView * m_previewView;

- (void)attachToSuperView:(UIView*)superview andPlaySongSession:(UserSongSession*)userSongSessions;
- (void)attachToSuperView:(UIView*)superview andPlayXmpBlob:(NSString*)xmpBlob;
- (void)updateProgress;
- (void)pauseSongPlayback;

- (IBAction)playPauseButtonClicked:(id)sender;
- (IBAction)restartButtonClicked:(id)sender;
- (IBAction)songButtonClicked:(id)sender;
- (IBAction)userButtonClicked:(id)sender;

@end
