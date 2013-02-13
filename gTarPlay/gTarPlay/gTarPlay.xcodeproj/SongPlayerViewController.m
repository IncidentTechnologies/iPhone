//
//  SongPlayerViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/12/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongPlayerViewController.h"

#import <gTarAppCore/SongPlaybackController.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/User.h>
#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/RoundedRectangleView.h>

//#import "RootViewController.h"

extern GtarController * g_gtarController;
extern AudioController * g_audioController;

@implementation SongPlayerViewController

@synthesize m_delegate;
@synthesize m_playPauseButton;
@synthesize m_background;
@synthesize m_songNameButton;
@synthesize m_userNameButton;
@synthesize m_trackTimeLabel;
@synthesize m_previewView;
@synthesize m_activityView;

#define UPDATE_FREQUENCY (1/30)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        //m_playbackController = [[SongPlaybackController alloc] init];
        m_playbackController = [[SongPlaybackController alloc] initWithAudioController:g_audioController];
        
        self.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResignActive) name:UIApplicationWillResignActiveNotification object:nil];

        
    }
    
    return self;
    
}

- (void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [m_playbackController release];
    [m_songPreviewScrubberView removeFromSuperview];
    [m_songPreviewScrubberView release];
    [m_userSongSession release];
    [m_progressUpdateTimer invalidate];
    m_progressUpdateTimer = nil;
    
    [m_xmpBlob release];
    [m_playPauseButton release];
    [m_songNameButton release];
    [m_userNameButton release];
    [m_trackTimeLabel release];
    [m_previewView release];
    [m_activityView release];
    
    [m_background release];

    [super dealloc];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_playPauseButton = nil;
    self.m_background = nil;
    self.m_userNameButton = nil;
    self.m_songNameButton = nil;
    self.m_trackTimeLabel = nil;
    self.m_previewView = nil;
    self.m_activityView = nil;
    
}

- (void)handleResignActive
{
    [self pauseSongPlayback];
}

- (IBAction)fullScreenButtonClicked:(id)sender
{
    // no-op 
}

- (void)attachToSuperView:(UIView*)superview andPlaySongSession:(UserSongSession*)userSongSessions
{
    
    if ( m_attached == YES || m_attaching == YES )
    {
        return;
    }
    
    [m_activityView startAnimating];
    
    [m_userSongSession release];
    
    m_userSongSession = [userSongSessions retain];
    
    [m_xmpBlob release];
    
    m_xmpBlob = [userSongSessions.m_xmpBlob retain];
    
    // The view hasn't been loaded before here
    [self attachToSuperViewWithBlackBackground:superview];
    // All UI works needs to be done after this
    
    [m_activityView startAnimating];
    
    [m_userNameButton setTitle:[NSString stringWithFormat:@"interpreted by %@", userSongSessions.m_userProfile.m_firstName] forState:UIControlStateNormal];
    [m_songNameButton setTitle:userSongSessions.m_userSong.m_title forState:UIControlStateNormal];
    
}

- (void)attachToSuperView:(UIView*)superview andPlayXmpBlob:(NSString*)xmpBlob
{
    
    if ( m_attached == YES || m_attaching == YES )
    {
        return;
    }
    
    [m_xmpBlob release];
    
    m_xmpBlob = [xmpBlob retain];

    [self attachToSuperViewWithBlackBackground:superview];
    
}

- (void)attachFinalize
{
    
    // Connect to the gtar
    [m_playbackController observeGtarController:g_gtarController];
    
    // Play the song
    [m_playbackController startWithXmpBlob:m_xmpBlob];
    
    [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPauseButton.png"] forState:UIControlStateNormal];
    
    m_progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_FREQUENCY target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
    m_songPreviewScrubberView = [[SongPreviewScrubberView alloc] initWithFrame:m_previewView.frame andSongModel:m_playbackController.m_songModel];
    
    m_songPreviewScrubberView.m_delegate = self;
    
    [m_background addSubview:m_songPreviewScrubberView];
    [m_background bringSubviewToFront:m_songPreviewScrubberView];
    
    [m_activityView stopAnimating];
    
    [super attachFinalize];
    
}

- (void)detachFromSuperView
{
    
    if ( m_attached == NO )
    {
        return;
    }
    
    [m_progressUpdateTimer invalidate];
    m_progressUpdateTimer = nil;
    
    [m_playbackController endSong];
    
    [super detachFromSuperView];
    
}

- (void)detachFinalize
{
    
    [m_playbackController ignoreGtarController:g_gtarController];
    
    [m_songPreviewScrubberView removeFromSuperview];
    [m_songPreviewScrubberView release];
    
    m_songPreviewScrubberView = nil;
    
    [super detachFinalize];
    
}

- (void)updateProgress
{
    
    if ( m_playbackController.m_songModel.m_percentageComplete >= 1.0 )
    {
        [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPlayButton.png"] forState:UIControlStateNormal];
    }
    
    [m_songPreviewScrubberView updateView];
    
    double currentBeat = m_playbackController.m_songModel.m_currentBeat;
    double currentTime = currentBeat / m_playbackController.m_songModel.m_beatsPerSecond;
    
    NSString * trackTime = [NSString stringWithFormat:@"%02u:%02u",
                            (NSInteger)(currentTime/60),
                            ((NSInteger)currentTime%60)];

    [m_trackTimeLabel setText:trackTime];
    
}

- (void)pauseSongPlayback
{
    
    if ( [m_playbackController isPlaying] == YES )
    {
        [m_playbackController pauseSong];
        [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPlayButton.png"] forState:UIControlStateNormal];
    }

}

- (IBAction)playPauseButtonClicked:(id)sender
{
    
    if ( [m_playbackController isPlaying] == YES )
    {
        [m_playbackController pauseSong];
        [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPlayButton.png"] forState:UIControlStateNormal];
    }
    else
    {
        [m_playbackController playSong];
        [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPauseButton.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)restartButtonClicked:(id)sender
{
    [m_playbackController seekToLocation:0];
}

- (IBAction)songButtonClicked:(id)sender
{
    
    [m_delegate songPlayerDisplayUserSong:m_userSongSession.m_userSong];
    
    [self detachFromSuperView];
    
}

- (IBAction)userButtonClicked:(id)sender
{

    [m_delegate songPlayerDisplayUserProfile:m_userSongSession.m_userProfile];
    
    [self detachFromSuperView];
    
}

#pragma mark - Scrubber callback

- (void)haltPlayback
{
    m_wasPlaying = [m_playbackController isPlaying];
    
    [m_playbackController pauseSong];
    
    [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPlayButton.png"] forState:UIControlStateNormal];
}

- (void)restorePlayback
{
    if ( m_wasPlaying == YES )
    {
        [m_playbackController playSong];
        [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPauseButton.png"] forState:UIControlStateNormal];
    }
}

- (void)pauseSong
{
    
    [m_playbackController pauseSong];
    
    [m_playPauseButton setImage:[UIImage imageNamed:@"PlayerPlayButton.png"] forState:UIControlStateNormal];

}

@end
