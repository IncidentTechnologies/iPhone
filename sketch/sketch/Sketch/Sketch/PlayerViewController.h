//
//  PlayerViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/8/13.
//
//

#import <UIKit/UIKit.h>

@class UserSongSession;
@class AudioController;

@interface PlayerViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *playButton;

@property (retain, nonatomic) IBOutlet UIView *fillView;
@property (retain, nonatomic) IBOutlet UIView *knobView;
@property (retain, nonatomic) IBOutlet UIView *indicatorView;

@property (retain, nonatomic) IBOutlet UILabel *songTitle;
@property (retain, nonatomic) IBOutlet UILabel *songArtist;

@property (retain, nonatomic) IBOutlet UIView *touchSurfaceView;

@property (retain, nonatomic) UserSongSession *userSongSession;
@property (assign, nonatomic) BOOL scrollable;

@property (retain, nonatomic) NSInvocation *loadedInvocation;

- (void)startSong;
- (void)pauseSong;
- (void)continueSong;
- (void)playPauseSong;
- (BOOL)isSongLoaded;

- (void)recordMode;

- (void)attachToSuperview:(UIView *)view;

- (void)endPlayback;

- (id)initWithAudioController:(AudioController*)audioController;

@end
