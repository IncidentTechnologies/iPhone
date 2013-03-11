//
//  TitleGatekeeperViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "FullScreenDialogViewController.h"


@interface TitleGatekeeperViewController : FullScreenDialogViewController
{
    
    MPMoviePlayerController * m_moviePlayer;
    IBOutlet UIButton * m_videoView;
    
}

@property (nonatomic, retain) IBOutlet UIButton * m_videoView;

- (IBAction)buyGtarClicked:(id)sender;
- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)videoButtonClicked:(id)sender;
- (void)moviePlayBackDidFinish:(NSNotification*)notification;
- (void)moviePlayerPlaybackStateChanged:(NSNotification *)notification;

@end
