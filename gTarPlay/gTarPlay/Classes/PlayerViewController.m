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

#import <gTarAppCore/SongPlaybackController.h>
#import <gTarAppCore/UserSong.h>

@class AudioController;
@class GtarController;

extern AudioController *g_audioController;
extern GtarController *g_gtarController;

@interface PlayerViewController ()
{
    SongPlaybackController *_songPlaybackController;
    
    NSTimer *_updateTimer;
    
    BOOL _init;
}
@end

@implementation PlayerViewController

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
	
    [_songTitle addShadowWithRadius:2.0 andOpacity:0.7];
    [_songArtist addShadowWithRadius:2.0 andOpacity:0.7];
    [_knobView addShadowWithRadius:6.0];
    [_playButton addShadowWithRadius:2.0 andOpacity:0.5];
    
    // Connect to the gtar
    [_songPlaybackController observeGtarController:g_gtarController];
    
    [self updateScrollable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_songPlaybackController ignoreGtarController:g_gtarController];
    [_songPlaybackController release];
    [_userSong release];
    
    [_playButton release];
    [_fillView release];
    [_knobView release];
    [_songTitle release];
    [_songArtist release];
    [_touchSurfaceView release];
    [_indicatorView release];
    
    [super dealloc];
}

- (void)attachToSuperview:(UIView *)view
{
    [self.view setFrame:view.bounds];
    
    [view addSubview:self.view];
}

- (void)setUserSong:(UserSong *)userSong
{
    [_userSong release];
    _userSong = [userSong retain];
    
    [_songTitle setText:_userSong.m_author];
    [_songArtist setText:_userSong.m_title];
    
//    _init = NO;
    
}

- (void)setXmpBlob:(NSString *)xmpBlob
{
    [_xmpBlob release];
    _xmpBlob = [xmpBlob retain];
    
    // Do this now because the AC might not be ready sooner 
    if ( _songPlaybackController == nil )
    {
        _songPlaybackController = [[SongPlaybackController alloc] initWithAudioController:g_audioController];
    }
    
    [_songPlaybackController startWithXmpBlob:_xmpBlob];
    [_songPlaybackController stopMainEventLoop];
    
    [self updateProgress];
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
    
    // We are done with the song
    if ( _songPlaybackController.m_songModel.m_percentageComplete >= 1.0 )
    {
        [_playButton setSelected:NO];
        [self pauseUpdating];
    }
}

#pragma mark - Button click handlers

- (IBAction)playButtonClicked:(id)sender
{
    if ( _songPlaybackController.isPlaying == YES )
    {
        [_playButton setSelected:NO];
        
        [_songPlaybackController pauseSong];
        
        [self pauseUpdating];
    }
    else
    {
        [_playButton setSelected:YES];
        
//        if ( _init == NO )
//        {
//            [_songPlaybackController startWithXmpBlob:_xmpBlob];
//            [self updateProgress];
//            _init = YES;
//        }
//        else
        {
            [_songPlaybackController playSong];
        }
        
        [self startUpdating];
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
    
//    if ( _init == NO )
//    {
//        return;
//    }
    
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
    
//    if ( _init == NO )
//    {
//        return;
//    }
    
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
