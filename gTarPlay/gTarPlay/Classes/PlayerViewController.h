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

@property (retain, nonatomic) SoundMaster *g_soundMaster;

@property (retain, nonatomic) IBOutlet UIButton *playButton;

@property (retain, nonatomic) IBOutlet UIView *fillView;
@property (retain, nonatomic) IBOutlet UIView *knobView;
@property (retain, nonatomic) IBOutlet UIView *indicatorView;

@property (retain, nonatomic) IBOutlet UILabel *songTitle;
@property (retain, nonatomic) IBOutlet UILabel *songArtist;

@property (retain, nonatomic) IBOutlet UIView *touchSurfaceView;

@property (retain, nonatomic) UserSong *userSong;
@property (retain, nonatomic) NSString *xmpBlob;
@property (assign, nonatomic) BOOL scrollable;

@property (retain, nonatomic) NSInvocation *loadedInvocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster;

- (IBAction)playButtonClicked:(id)sender;

- (void)attachToSuperview:(UIView *)view;

- (void)endPlayback;


- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender;
- (void)stopAudioEffects;
- (NSInteger)getSelectedInstrumentIndex;
- (NSArray *)getInstrumentList;

@end
