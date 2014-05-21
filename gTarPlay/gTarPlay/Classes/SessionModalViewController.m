//
//  SessionModalViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 5/7/13.
//
//

#import "SessionModalViewController.h"

extern FileController *g_fileController;

@interface SessionModalViewController ()
{
    PlayerViewController *_playerViewController;
    VolumeViewController *_volumeViewController;
    SlidingInstrumentViewController *_instrumentViewController;
}
@end

@implementation SessionModalViewController

@synthesize g_soundMaster;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        //NSLog(@"Alloc Session Modal VC SoundMaster");
        g_soundMaster = soundMaster;
        [g_soundMaster start];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_menuButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_volumeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_shortcutButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [_likeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    // Set up the player modal
    _playerViewController = [[PlayerViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster];
    [_playerViewController setDelegate:self];
    [_playerViewController attachToSuperview:_playerView];
    
    _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil andSoundMaster:g_soundMaster isInverse:NO];
    [_volumeViewController attachToSuperview:self.contentView withFrame:_volumeView.frame];
    
    _instrumentViewController = [[SlidingInstrumentViewController alloc] initWithNibName:nil bundle:nil];
    [_instrumentViewController setDelegate:self];
    [_instrumentViewController attachToSuperview:self.contentView withFrame:_instrumentView.frame];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( _userSongSession.m_xmpBlob == nil )
    {
        NSString * xmpBlob = [g_fileController getFileOrDownloadSync:_userSongSession.m_xmpFileId];
    
        _userSongSession.m_xmpBlob = xmpBlob;
    }
    
    if ( _userSongSession.m_xmpBlob == nil )
    {
        return;
    }
    
    _playerViewController.userSong = _userSongSession.m_userSong;
    _playerViewController.xmpBlob = _userSongSession.m_xmpBlob;
    
    // Wait for instrument to load
    [_shortcutButton setEnabled:NO];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    [_volumeViewController setFrame:_volumeView.frame];
//    [_instrumentViewController setFrame:_instrumentView.frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button click handlers

- (IBAction)closeButtonClicked:(id)sender;
{
    if ( _instrumentViewController.loading == YES )
    {
        return;
    }
    
    [_playerViewController endPlayback];
    
    [_blackButton setHidden:YES];
    [_volumeViewController closeView:NO];
    [_instrumentViewController closeView:NO];
    
    [super closeButtonClicked:sender];
}

- (IBAction)volumeButtonClicked:(id)sender
{
    if ( _instrumentViewController.loading == YES )
    {
        return;
    }
    
    if ( _volumeViewController.isDown == YES )
    {
        [_blackButton setHidden:YES];
    }
    else
    {
        [_blackButton setHidden:NO];
    }
    [_volumeViewController toggleView:YES];
    [_instrumentViewController closeView:YES];
}

- (IBAction)shortcutButtonClicked:(id)sender
{
    NSLog(@"Session Modal VC: shortcut button clicked");
    
    if( _instrumentViewController.loading == YES )
    {
        return;
    }
    
    if ( _instrumentViewController.isDown == YES )
    {
        [_blackButton setHidden:YES];
    }
    else
    {
        [_blackButton setHidden:NO];
    }
    [_playerViewController endPlayback];
    [_instrumentViewController toggleView:YES];
    [_volumeViewController closeView:YES];
}

- (IBAction)blackButtonClicked:(id)sender
{
    if ( _instrumentViewController.loading == YES )
    {
        return;
    }
    
    [_blackButton setHidden:YES];
    [_volumeViewController closeView:YES];
    [_instrumentViewController closeView:YES];
}

#pragma mark - Sliding Instrument Selector delegate
- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    NSLog(@"Session Modal VC: did select instrument %@",instrumentName);
    [_playerViewController didSelectInstrument:instrumentName withSelector:cb andOwner:sender];
}

- (void)stopAudioEffects
{
    [_playerViewController stopAudioEffects];
}

- (NSInteger)getSelectedInstrumentIndex
{
    return [_playerViewController getSelectedInstrumentIndex];
}

- (NSArray *)getInstrumentList
{
    
    return [_playerViewController getInstrumentList];
}

#pragma mark - Player View Delegate

- (void) instrumentLoadingReady
{
    [_shortcutButton setEnabled:YES];
}

@end
