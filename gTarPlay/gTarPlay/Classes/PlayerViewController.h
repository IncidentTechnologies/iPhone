//
//  PlayerViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "SoundMaster.h"

@class UserSong;

@interface PlayerViewController : UIViewController

@property (strong, nonatomic) SoundMaster *g_soundMaster;

@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet UIView *fillView;
@property (strong, nonatomic) IBOutlet UIView *knobView;
@property (strong, nonatomic) IBOutlet UIView *indicatorView;

@property (strong, nonatomic) IBOutlet UILabel *songTitle;
@property (strong, nonatomic) IBOutlet UILabel *songArtist;

@property (strong, nonatomic) IBOutlet UIView *touchSurfaceView;

@property (strong, nonatomic) UserSong *userSong;
@property (strong, nonatomic) NSString *xmpBlob;
@property (assign, nonatomic) BOOL scrollable;

@property (strong, nonatomic) NSInvocation *loadedInvocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster;

- (IBAction)playButtonClicked:(id)sender;

- (void)attachToSuperview:(UIView *)view;

- (void)endPlayback;


- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender;
- (void)stopAudioEffects;
- (NSInteger)getSelectedInstrumentIndex;
- (NSArray *)getInstrumentList;

@end
