//
//  SongSelectionViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import "SongSelectionViewController.h"
#import "SongListCell.h"
#import "SelectSongOptionsPopupViewController.h"
#import "SongViewController.h"
#import "PlayViewController.h"
#import "SlidingModalViewController.h"
#import "VolumeViewController.h"
#import "PlayerViewController.h"
#import "UIView+Gtar.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongs.h>
#import <gTarAppCore/XmlDom.h>
#import <gTarAppCore/SongPlaybackController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/SongPlaybackController.h>

extern FileController * g_fileController;
extern CloudController * g_cloudController;
extern AudioController * g_audioController;
extern UserController * g_userController;

@interface SongSelectionViewController ()
{
    VolumeViewController *_volumeViewController;
    
    NSArray *_userSongArray;
    SelectSongOptionsPopupViewController *_popupOptionsViewController;
    SongPlaybackController *_playbackController;
    PlayerViewController *_playerViewController;
    
    UserSong *_currentUserSong;
    NSInteger _currentDifficulty;
}
@end

@implementation SongSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
        
        // See if we have any cached songs from previous runs
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        NSData * songArrayData = [settings objectForKey:@"UserSongArray"];
        
        // If we have cached data, use that.
        if ( songArrayData == nil )
        {
            _userSongArray = [[NSArray alloc] init];
        }
        else
        {
            _userSongArray = [[NSKeyedUnarchiver unarchiveObjectWithData:songArrayData] retain];
        }

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_topBar addShadow];
    
    _popupOptionsViewController = [[SelectSongOptionsPopupViewController alloc] initWithNibName:nil bundle:nil];
    
//    _playbackController = [[SongPlaybackController alloc] initWithAudioController:g_audioController];
    _playerViewController = [[PlayerViewController alloc] initWithNibName:nil bundle:nil];
    
    [_playerViewController attachToSuperview:_songPlayerView];
    
    _currentDifficulty = 0;
    
    [_easyButton setEnabled:NO];
    
    // Adjust the images in the buttons
    [_closeModalButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_volumeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_instrumentButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    // Download any files we are missing
    if ( [_userSongArray count] > 0 )
    {
        for ( UserSong * userSong in _userSongArray )
        {
//            [g_fileController getFileOrDownloadAsync:userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
            [g_fileController getFileOrDownloadAsync:userSong.m_xmpFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
        }
        
    }
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    _closeModalButton.imageView.transform = CGAffineTransformMakeScale( 0.5, 0.5 );
//    _volumeButton.imageView.transform = CGAffineTransformMakeScale( 0.6, 0.6 );
//    _instrumentButton.imageView.transform = CGAffineTransformMakeScale( 0.7, 0.7 );
//    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( _volumeViewController == nil )
    {
        _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil];
        
        [_volumeViewController attachToSuperview:_volumeView];
        
        _volumeView.userInteractionEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_searchBar release];
    
    [_userSongArray release];
    
    [_songListTable release];
    [_titleArtistButton release];
    [_skillButton release];
    [_scoreButton release];
    [_songOptionsModal release];
    [_volumeButton release];
    [_closeModalButton release];
    [_instrumentButton release];
    [_easyButton release];
    [_mediumButton release];
    [_hardButton release];
    [_volumeView release];
    [_songPlayerView release];
    [_topBar release];
    [super dealloc];
}

#pragma mark - Button Click Handlers

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startButtonClicked:(id)sender
{
    [_playerViewController endPlayback];

    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self startSong:_currentUserSong withDifficulty:_currentDifficulty];
}

- (IBAction)closeModalButtonClicked:(id)sender
{
    [_playerViewController endPlayback];
    [_songOptionsModal closeButtonClicked:sender];
    [_volumeViewController closeVolumeView];
    [_volumeView setUserInteractionEnabled:NO];
}

- (IBAction)volumeButtonClicked:(id)sender
{
    // The volume view is obstructing stuff below it. Hide it until we need it.
    [_volumeViewController toggleVolumeView];
    [_volumeView setUserInteractionEnabled:!_volumeView.userInteractionEnabled];
}

- (IBAction)instrumentButtonClicked:(id)sender
{
    
}

- (IBAction)difficulyButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if ( button == _easyButton )
    {
        _currentDifficulty = 0;
        [_easyButton setEnabled:NO];
        [_mediumButton setEnabled:YES];
        [_hardButton setEnabled:YES];
    }
    else if ( button == _mediumButton )
    {
        _currentDifficulty = 1;
        [_easyButton setEnabled:YES];
        [_mediumButton setEnabled:NO];
        [_hardButton setEnabled:YES];
    }
    else if ( button == _hardButton )
    {
        _currentDifficulty = 2;
        [_easyButton setEnabled:YES];
        [_mediumButton setEnabled:YES];
        [_hardButton setEnabled:NO];
    }
    
}

#pragma mark - UserSong management

- (void)refreshSongList
{
    // Start animating offscreen if there are already songs displayed.
    if ( [_userSongArray count] > 0 )
    {
        [_songListTable startAnimatingOffscreen];
    }
    else
    {
        [_songListTable startAnimating];
    }
    
	[g_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];
}

#pragma mark - Callbacks

- (void)requestSongListCallback:(CloudResponse*)cloudResponse
{
    
    [_songListTable stopAnimating];
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // refresh table data
        UserSongs * userSongs = cloudResponse.m_responseUserSongs;
        
        [_userSongArray release];
        
        _userSongArray = [userSongs.m_songsArray retain];
        
        // Download everything
        for ( UserSong * userSong in _userSongArray )
        {
//            [g_fileController getFileOrDownloadAsync:userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
            [g_fileController getFileOrDownloadAsync:userSong.m_xmpFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
        }
        
        // Save this new array
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        [settings setObject:[NSKeyedArchiver archivedDataWithRootObject:_userSongArray] forKey:@"UserSongArray"];
        
        [settings synchronize];
        
        // Show the new table
        [_songListTable reloadData];
    }
    else
    {
        // Something bad happened, and we don't have any data to show
        if ( [_userSongArray count] == 0 )
        {
            [self backButtonClicked:nil];
        }
    }
    
}

- (void)fileDownloadFinished:(id)file
{
    [_songListTable reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_userSongArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString * CellIdentifier = @"SongListCell";
	
	SongListCell * cell = (SongListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		cell = [[[SongListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"SongListCell" owner:cell options:nil];
        
        CGFloat cellHeight = _songListTable.rowHeight-1;
        CGFloat cellRow = _songListTable.frame.size.width;
        
//        cell.titleArtistView.translatesAutoresizingMaskIntoConstraints = YES;
//        cell.skillView.translatesAutoresizingMaskIntoConstraints = YES;
//        cell.scoreView.translatesAutoresizingMaskIntoConstraints = YES;
        
        // Readjust the column headers to match the width
        [cell.titleArtistView setFrame:CGRectMake(0, 0, _titleArtistButton.frame.size.width, cellHeight)];
        [cell.skillView setFrame:CGRectMake(_skillButton.frame.origin.x, 0, _skillButton.frame.size.width, cellHeight)];
        [cell.scoreView setFrame:CGRectMake(_scoreButton.frame.origin.x, 0, _scoreButton.frame.size.width, cellHeight)];
        
        // Readjust the width and height
        [cell setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        [cell.accessoryView setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
	}
	
	// Clear these in case this cell was previously selected
	cell.highlighted = NO;
	cell.selected = NO;
	
	NSInteger row = [indexPath row];
    
    UserSong *userSong = [_userSongArray objectAtIndex:row];
    
    userSong.m_playStars = [g_userController getMaxStarsForSong:userSong.m_songId];
    userSong.m_playScore = [g_userController getMaxScoreForSong:userSong.m_songId];
    
    cell.userSong = userSong;
    
    if ( [g_fileController fileExists:userSong.m_xmpFileId] == YES )
    {
        [cell updateCell];
    }
    else
    {
        [cell updateCellInactive];
    }
    
	return cell;
	
}

#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( _songOptionsModal.presentingViewController != nil )
    {
        // We only want to present it once, otherwise it will crash
        return;
    }
    
	NSInteger row = [indexPath row];
    UserSong *userSong = [_userSongArray objectAtIndex:row];

//    _popupOptionsViewController.m_userSong = userSong;
//    _popupOptionsViewController.m_navigationController = self;
    
//    [_popupOptionsViewController attachToSuperViewWithBlackBackground:self.view];
    
    _currentUserSong = userSong;
    
    NSString *songString = (NSString*)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];

    _playerViewController.userSong = userSong;
    _playerViewController.xmpBlob = songString;
    
    [self presentViewController:_songOptionsModal animated:YES completion:nil];
    
}

- (void)update
{
    [self refreshSongList];
}

#pragma mark - ViewController stuff

- (void)startSong:(UserSong *)userSong withDifficulty:(NSInteger)difficulty
{
    
#if 1
    PlayViewController *playViewController = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    
    // Get the XMP, stick it in the user song, and push to the game mode.
    // This generally should already have been downloaded.
    NSString *songString = (NSString *)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
    
    playViewController.userSong = userSong;
    playViewController.userSong.m_xmlDom = [[[XmlDom alloc] initWithXmlString:songString] autorelease];
    
    if ( difficulty == 0 )
    {
        // Easy
        playViewController.difficulty = PlayViewControllerDifficultyEasy;
    }
    else if ( difficulty == 1 )
    {
        // Medium
        playViewController.difficulty = PlayViewControllerDifficultyMedium;
        playViewController.muffleWrongNotes = YES;
    }
    else if ( difficulty == 2 )
    {
        // Hard
        playViewController.difficulty = PlayViewControllerDifficultyHard;
        playViewController.muffleWrongNotes = NO;
    }

    [self.navigationController pushViewController:playViewController animated:YES];
    
    [playViewController release];
#else
    
    SongViewController *songController = [[SongViewController alloc] initWithNibName:nil bundle:nil];
    
    // Get the XMP, stick it in the user song, and push to the game mode.
    // This generally should already have been downloaded.
    NSString *songString = (NSString *)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
    
    songController.m_userSong = userSong;
    songController.m_userSong.m_xmlDom = [[[XmlDom alloc] initWithXmlString:songString] autorelease];
    
    if ( difficulty == 0 )
    {
        // Easy
        songController.m_difficulty = SongViewControllerDifficultyEasy;
    }
    else if ( difficulty == 1 )
    {
        // Medium
        songController.m_difficulty = SongViewControllerDifficultyMedium;
        songController.m_muffleWrongNotes = YES;
    }
    else if ( difficulty == 2 )
    {
        // Hard
        songController.m_difficulty = SongViewControllerDifficultyHard;
        songController.m_muffleWrongNotes = NO;
    }
    
    [self.navigationController pushViewController:songController animated:YES];
    
    [songController release];
#endif
}

- (void)previewUserSong:(UserSong*)userSong
{
    // Get the XMP, stick it in the user song, and push to the game mode
    NSString *songString = (NSString*)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
    
    [_playbackController startWithXmpBlob:songString];
}

- (void)stopPreview
{
    [_playbackController pauseSong];
}

@end
