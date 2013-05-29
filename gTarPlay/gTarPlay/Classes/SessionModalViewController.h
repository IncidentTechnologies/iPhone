//
//  SessionModalViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 5/7/13.
//
//

#import "SlidingModalViewController.h"

@class UserSongSession;

@interface SessionModalViewController : SlidingModalViewController

@property (retain, nonatomic) IBOutlet UIView *volumeView;
@property (retain, nonatomic) IBOutlet UIView *instrumentView;
@property (retain, nonatomic) IBOutlet UIView *playerView;

@property (retain, nonatomic) IBOutlet UIButton *menuButton;
@property (retain, nonatomic) IBOutlet UIButton *volumeButton;
@property (retain, nonatomic) IBOutlet UIButton *shortcutButton;
@property (retain, nonatomic) IBOutlet UIButton *blackButton;

@property (retain, nonatomic) UserSongSession *userSongSession;

- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)shortcutButtonClicked:(id)sender;
- (IBAction)blackButtonClicked:(id)sender;

@end
