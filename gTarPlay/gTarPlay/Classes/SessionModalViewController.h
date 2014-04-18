//
//  SessionModalViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 5/7/13.
//
//

#import "SlidingModalViewController.h"

#import "PlayerViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"
#import "UIView+Gtar.h"
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongSession.h>
#import "SoundMaster.h"

@class UserSongSession;

@interface SessionModalViewController : SlidingModalViewController <SlidingInstrumentDelegate>

@property (retain, nonatomic) SoundMaster * g_soundMaster;

@property (retain, nonatomic) IBOutlet UIView *volumeView;
@property (retain, nonatomic) IBOutlet UIView *instrumentView;
@property (retain, nonatomic) IBOutlet UIView *playerView;

@property (retain, nonatomic) IBOutlet UIButton *menuButton;
@property (retain, nonatomic) IBOutlet UIButton *volumeButton;
@property (retain, nonatomic) IBOutlet UIButton *shortcutButton;
@property (retain, nonatomic) IBOutlet UIButton *blackButton;

@property (retain, nonatomic) UserSongSession *userSongSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster;

- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)shortcutButtonClicked:(id)sender;
- (IBAction)blackButtonClicked:(id)sender;

@end
