//
//  SessionModalViewController.h
//  keysPlay
//
//  Created by Marty Greenia on 5/7/13.
//
//

#import "SlidingModalViewController.h"

#import "AppCore.h"
#import "PlayerViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"
#import "UIView+Keys.h"
#import "FileController.h"
#import "UserSong.h"
#import "UserSongSession.h"
#import "SoundMaster.h"

@class UserSongSession;

@interface SessionModalViewController : SlidingModalViewController <SlidingInstrumentDelegate, PlayerViewDelegate>

@property (strong, nonatomic) SoundMaster * g_soundMaster;

@property (strong, nonatomic) IBOutlet UIView *volumeView;
@property (strong, nonatomic) IBOutlet UIView *instrumentView;
@property (strong, nonatomic) IBOutlet UIView *playerView;

@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *volumeButton;
@property (strong, nonatomic) IBOutlet UIButton *shortcutButton;
@property (strong, nonatomic) IBOutlet UIButton *blackButton;

@property (strong, nonatomic) UserSongSession *userSongSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster;

- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)shortcutButtonClicked:(id)sender;
- (IBAction)blackButtonClicked:(id)sender;

@end
