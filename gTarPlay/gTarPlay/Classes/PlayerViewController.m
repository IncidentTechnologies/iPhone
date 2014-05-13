//
//  PlayerViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/8/13.
//
//

#import "PlayerViewController.h"

#import "UIView+Gtar.h"

#import <AVFoundation/AVFoundation.h>

#import "SongPlaybackController.h"
#import "UserSong.h"
#import <gTarAppCore/NSSong.h>

#import "UIButton+Gtar.h"

//@class AudioController;
@class GtarController;

//extern AudioController *g_audioController;
//extern GtarController *g_gtarController;

@interface PlayerViewController ()
{
    SongPlaybackController *_songPlaybackController;
    
    NSTimer *_updateTimer;
    
    BOOL _init;
}
@end

@implementation PlayerViewController

@synthesize g_soundMaster;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
        _init = NO;
        _scrollable = YES;
        
        g_soundMaster = soundMaster;
        [g_soundMaster start];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [_songTitle addShadowWithRadius:1.0 andOpacity:0.7];
    [_songArtist addShadowWithRadius:1.0 andOpacity:0.7];
    [_knobView addShadowWithRadius:2.0];
    //[_playButton addShadowWithRadius:2.0 andOpacity:0.5];
    
    [self updateScrollable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkInitSongPlaybackController];
    
    _init = NO;
    
    // Start the progress bar at zero when we open up.
    _fillView.layer.transform = CATransform3DMakeTranslation( 0, 0, 0 );

    [_songPlaybackController startWithXmpBlob:_xmpBlob];
    [_songPlaybackController stopMainEventLoop];
    
    [self waitForInstrumentToLoad];
    
    if([_songPlaybackController.m_songModel.m_song.m_instrument length] > 0){
        NSLog(@"Player View Select instrument %@",_songPlaybackController.m_songModel.m_song.m_instrument);
        
        [_songPlaybackController didSelectInstrument:_songPlaybackController.m_songModel.m_song.m_instrument withSelector:@selector(finishedLoadingSamplePack:) andOwner:self];
    }
    
}


- (void)checkInitSongPlaybackController
{
    if ( _songPlaybackController == nil )
    {
        NSLog(@"Player View Controller: init Song Playback");
        _songPlaybackController = [[SongPlaybackController alloc] initWithSoundMaster:g_soundMaster];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [_songPlaybackController ignoreGtarController:g_gtarController];
    
    _songPlaybackController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    [_songPlaybackController ignoreGtarController:g_gtarController];
    _songPlaybackController = nil;
    
    //[g_soundMaster releaseAfterUse];
    
}

- (void)waitForInstrumentToLoad
{
    [_playButton setImage:nil forState:UIControlStateNormal];
    [_playButton startActivityIndicator];
}

// This loads the preview song in the background
- (void)backgroundLoading
{
    @synchronized( self )
    {
        [_songPlaybackController startWithXmpBlob:_xmpBlob];
        [_songPlaybackController stopMainEventLoop];
        
        _init = YES;
        
        [_loadedInvocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
    }
}

- (void)finishedLoadingSamplePack:(NSNumber *)result
{
    _init = YES;
    
    [_playButton setImage:[UIImage imageNamed:@"PreviewIcon.png"] forState:UIControlStateNormal];
    [_playButton stopActivityIndicator];
    
    NSLog(@"Finished loading sample pack");
    
    [_loadedInvocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
    
    if([delegate respondsToSelector:@selector(instrumentLoadingReady)]){
        [delegate instrumentLoadingReady];
    }
    
}

- (void)attachToSuperview:(UIView *)view
{
    [self.view setFrame:view.bounds];
    
    [view addSubview:self.view];
}

- (void)setUserSong:(UserSong *)userSong
{
    _userSong = userSong;
    
    [_songTitle setText:_userSong.m_author];
    [_songArtist setText:_userSong.m_title];
}

- (void)setXmpBlob:(NSString *)xmpBlob
{
    _xmpBlob = xmpBlob;
    
//    [self updateProgress];
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
    
    [_playButton setImage:[UIImage imageNamed:@"PreviewIcon.png"] forState:UIControlStateNormal];
    
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
    
    // We are done with the song
    if ( _songPlaybackController.m_songModel.m_percentageComplete >= 1.0 )
    {
        [_playButton setSelected:NO];
        [self pauseUpdating];
    }
}


- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    NSLog(@"Did select instrument callback");
    [_songPlaybackController didSelectInstrument:instrumentName withSelector:cb andOwner:sender];
}

- (void)stopAudioEffects
{
    [_songPlaybackController stopAudioEffects];
}

- (NSInteger)getSelectedInstrumentIndex
{
    return [_songPlaybackController getSelectedInstrumentIndex];
}

- (NSArray *)getInstrumentList
{
    [self checkInitSongPlaybackController];
    
    return [_songPlaybackController getInstrumentList];
}

#pragma mark - Button click handlers

- (IBAction)playButtonClicked:(id)sender
{
    NSLog(@"Player VC: play button clicked");
    
    if ( _songPlaybackController.isPlaying == YES )
    {
        NSLog(@"Playing, pause song");
        
        //[_playButton setSelected:NO];
        
        [_songPlaybackController pauseSong];
        
        [self pauseUpdating];
    }
    else
    {
        
        NSLog(@"Not playing, play");
        
        // Do this now because the AC might not be ready sooner
        @synchronized( self )
        {
            if ( _init == YES )
            {
                NSLog(@"Successful play");
                //[_playButton setSelected:YES];
                [_playButton setImage:[UIImage imageNamed:@"PauseButtonVideo.png"] forState:UIControlStateNormal];
                
//                _init = YES;
                
                [_songPlaybackController playSong];
//                [_songPlaybackController observeGtarController:g_gtarController];
                
                [self startUpdating];
            }
            
        }
        
    }
    

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
    
    [self updateProgress];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches began Player View Controller");
    
    if ( _init == NO )
    {
        return;
    }
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    if ( CGRectContainsPoint( _touchSurfaceView.frame, currentPoint) == YES )
    {
        [self pauseUpdating];
        [_songPlaybackController pauseSong];
        
        [self updateProgressFromTouch:currentPoint];
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
        [self updateProgressFromTouch:currentPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If the play button is still selected, we should keep playing
    if ( _playButton.isSelected == YES )
    {
        [self startUpdating];
        [_songPlaybackController playSong];
    }
}

@end
