//
//  PlayerViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/8/13.
//
//

#import "PlayerViewController.h"

//#import "UIView+Gtar.h"

#import <AVFoundation/AVFoundation.h>

#import <gTarAppCore/SongPlaybackController.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/NSSong.h>
#import <AudioController/AudioController.h>
#import "Mixpanel.h"

@class AudioController;
@class GtarController;

@interface PlayerViewController ()
{
    AudioController *_audioController;
    SongPlaybackController *_songPlaybackController;
    
    NSTimer *_updateTimer;

    BOOL _init;
    
    BOOL _isScrolling;
    BOOL _shouldPlayAfterScroll;
}

@property (assign, nonatomic) IBOutlet UILabel *songTimeLabel;
@property (assign, nonatomic) IBOutlet UILabel *songLengthLabel;

@end

@implementation PlayerViewController

- (id)initWithAudioController:(AudioController*)audioController
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self )
    {
        _audioController = audioController;
        _init = NO;
        _scrollable = YES;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
        _init = NO;
        _scrollable = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
	
    //[_songTitle addShadowWithRadius:2.0 andOpacity:0.7];
    //[_songArtist addShadowWithRadius:2.0 andOpacity:0.7];
    //[_knobView addShadowWithRadius:6.0];
    //[_playButton addShadowWithRadius:2.0 andOpacity:0.5];
        
    [self updateScrollable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( _songPlaybackController == nil )
    {
        _songPlaybackController = [[SongPlaybackController alloc] initWithAudioController:_audioController];
    }
    
    _init = NO;
    
//    [self performSelectorInBackground:@selector(backgroundLoading) withObject:nil];
    
    // Start the progress bar at zero when we open up.
    _fillView.layer.transform = CATransform3DMakeTranslation( 0, 0, 0 );
    
    [_songPlaybackController observeGtarController:[GtarController sharedInstance]];
    
    [_songPlaybackController startWithXmpBlob:_userSongSession.m_xmpBlob];
    [_songPlaybackController stopMainEventLoop];

    // Change the current sample pack to the new one
    [_audioController setSamplePackWithName:_songPlaybackController.m_songModel.m_song.m_instrument withSelector:@selector(finishedLoadingSamplePack:) andOwner:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeInstrument:) name:@"InstrumentChanged" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InstrumentChanged" object:nil];
//    [_songPlaybackController ignoreGtarController:g_gtarController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    [_songPlaybackController ignoreGtarController:g_gtarController];
    [_songPlaybackController release];
    
    [_playButton release];
    [_fillView release];
    [_knobView release];
    [_songTitle release];
    [_songArtist release];
    [_touchSurfaceView release];
    [_indicatorView release];
    
    [super dealloc];
}

// This loads the preview song in the background
- (void)backgroundLoading
{
    @synchronized( self )
    {
        [_songPlaybackController startWithXmpBlob:_userSongSession.m_xmpBlob];
        [_songPlaybackController stopMainEventLoop];
        
        _init = YES;
        
        [_loadedInvocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
    }
}

- (void)finishedLoadingSamplePack:(NSNumber *)result
{
    _init = YES;
    
    [_loadedInvocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
}

- (void)attachToSuperview:(UIView *)view
{
    [self.view setFrame:view.bounds];
    
    [view addSubview:self.view];
}


- (void)setScrollable:(BOOL)scrollable
{
    _scrollable = scrollable;
    
    [self updateScrollable];
}

#pragma mark - Helpers

- (void)updateScrollable
{
    if ( _scrollable == NO )
    {
        [_indicatorView setHidden:NO];
        [_knobView setHidden:YES];
    }
    else
    {
        [_indicatorView setHidden:YES];
        [_knobView setHidden:NO];
    }
    
    [self updateProgress];
}

- (void)endPlayback
{
    [_playButton setSelected:NO];
    
    [_songPlaybackController pauseSong];
    
    [self pauseUpdating];
}

- (void)startUpdating
{
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)pauseUpdating
{
    [_updateTimer invalidate];
    _updateTimer = nil;
}

- (void)updateProgress
{
    CGFloat width;
    
    if ( _scrollable == NO )
    {
        width = (_fillView.bounds.size.width -_indicatorView.bounds.size.width);
    }
    else
    {
        width = (_fillView.bounds.size.width -_knobView.bounds.size.width);
    }
    
    CGFloat delta = width * _songPlaybackController.m_songModel.m_percentageComplete;
    
    _fillView.layer.transform = CATransform3DMakeTranslation( delta, 0, 0 );
    
    // Time elapsed so far
    int songTime = _userSongSession.m_length * _songPlaybackController.m_songModel.m_percentageComplete;
    
    // We are done with the song
    if ( _songPlaybackController.m_songModel.m_percentageComplete >= 1.0 )
    {
        songTime = _userSongSession.m_length;
        
        [_playButton setSelected:NO];
        _shouldPlayAfterScroll = NO;
        [self pauseUpdating];
    }

    [self updateTimeLabelWithTime:songTime];
}

- (void)updateTimeLabelWithTime:(NSTimeInterval)time
{
    int minutes = time/60;
    int seconds = time - minutes * 60;
    
    NSString* timeString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    _songTimeLabel.text = timeString;
}

- (void)setUserSongSession:(UserSongSession *)userSongSession
{
    _userSongSession = userSongSession;
    
    // If view is hidden from record mode, unhide it.
    if (self.view.hidden)
    {
        self.view.hidden = NO;
    }
    
    [_playButton setSelected:YES];
    [self pauseSong];
    
    [self updateTimeLabelWithTime:0];
    _fillView.layer.transform = CATransform3DMakeTranslation( 0, 0, 0 );
    
    NSTimeInterval songLength = _userSongSession.m_length;
    int minutes = songLength/60;
    int seconds = songLength - minutes * 60;
    NSString* time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    _songLengthLabel.text = time;
    
    [_songPlaybackController startWithXmpBlob:_userSongSession.m_xmpBlob];
    [_songPlaybackController pauseSong];
    
}

- (void)startSong
{
    // Do this now because the AC might not be ready sooner
    @synchronized( self )
    {
        if ( _init == YES )
        {
            _shouldPlayAfterScroll = YES;
            [_playButton setSelected:YES];
            
            [self pauseUpdating];
            [_songPlaybackController startWithXmpBlob:_userSongSession.m_xmpBlob];
            [self startUpdating];
            
            [self logSongPlayBack];
        }
    }
}

- (void)playPauseSong
{
    if ( _songPlaybackController.isPlaying == YES )
    {
        [self pauseSong];
    }
    else
    {
        [self continueSong];
    }
}

- (void)pauseSong
{
    _shouldPlayAfterScroll = NO;
    [_songPlaybackController pauseSong];
    [self pauseUpdating];
}

- (void)continueSong
{
    _shouldPlayAfterScroll = YES;
    if ([_songPlaybackController percentageComplete] >= 1.0 || [_songPlaybackController percentageComplete] <= 0.0)
    {
        // Finished playing song already, restart it
        [self startSong];
    }
    else
    {
        
        [_songPlaybackController playSong];
        [self startUpdating];
    }
}

- (void)recordMode
{
    [_songPlaybackController pauseSong];
    [self pauseUpdating];
    
    self.view.hidden = YES;
}

#pragma mark - Touch handling

- (void)updateProgressFromTouch:(CGPoint)point
{
    
    CGFloat biasedWidth = _touchSurfaceView.frame.size.width - _knobView.frame.size.width;
    CGFloat biasedPoint = point.x - _knobView.frame.size.width / 2.0;
    
    CGFloat percentage = biasedPoint / biasedWidth;
    
    percentage = MAX(percentage, 0.0f);
    percentage = MIN(percentage, 1.0f);
    
    [_songPlaybackController.m_songModel changePercentageComplete:percentage];
    
    int timeElapsed = _userSongSession.m_length * percentage;
    [self updateTimeLabelWithTime:timeElapsed];
    
    [self updateProgress];

}

- (void)didTap:(UIGestureRecognizer *)gestureRecognizer
{
    // If a touchMove/scroll just happened don't handle the tap.
    // This works based on the behavior that gesturRecognizer handler
    // gets called before UITouch handlers.
    /*if (!_isScrolling)
    {
        [self playPauseSong];
    }
     */
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Do nothing, just here to intercept touches so
    // they are not passed to parent view.
    
    if ( _init == NO )
    {
        return;
    }
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    if ( CGRectContainsPoint( _touchSurfaceView.frame, currentPoint) == YES )
    {
        // Don't call [self pauseSong] here, don't want to change _shouldPlayAfterScroll state
        [_songPlaybackController pauseSong];
        [self pauseUpdating];
        [self updateProgressFromTouch:currentPoint];
        if (_shouldPlayAfterScroll)
        {
            [self continueSong];
        }
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if ( _init == NO )
    {
        return;
    }
    
    if ( _scrollable == NO )
    {
        return;
    }
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    if ( CGRectContainsPoint( _touchSurfaceView.frame, currentPoint) == YES )
    {
        _isScrolling = YES;
        // Don't call pauseSong here, don't want to change _shouldPlayAfterScroll state
        [_songPlaybackController pauseSong];
        [self pauseUpdating];
        
        [self updateProgressFromTouch:currentPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isScrolling)
    {
        _isScrolling = NO;
        // uncomment to continue playback after scroll ends
        if (_shouldPlayAfterScroll)
        {
            [self continueSong];
        }
    }
    
    // If the play button is still selected, we should keep playing
    if ( _playButton.isSelected == YES )
    {
        [self startUpdating];
        [_songPlaybackController playSong];
    }
}

- (void)logSongPlayBack
{
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Song Playback" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                _userSongSession.m_notes, @"Song Name",
                                                [NSNumber numberWithInteger:_userSongSession.m_length], @"Song Length",
                                                nil]];
}

- (void) didChangeInstrument:(NSNotification *)notification
{
    [self finishedLoadingSamplePack:[NSNumber numberWithBool:YES]];
}

@end
