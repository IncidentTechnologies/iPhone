//
//  PlayerViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/8/13.
//
//

#import <UIKit/UIKit.h>

@class UserSong;

@interface PlayerViewController : UIViewController

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

- (IBAction)playButtonClicked:(id)sender;

- (void)attachToSuperview:(UIView *)view;


@end
