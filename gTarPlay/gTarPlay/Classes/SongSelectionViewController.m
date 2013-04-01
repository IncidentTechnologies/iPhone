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
    NSArray *_userSongArray;
    SelectSongOptionsPopupViewController *_popupOptionsViewController;
    SongPlaybackController *_playbackController;
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
    
    _popupOptionsViewController = [[SelectSongOptionsPopupViewController alloc] initWithNibName:nil bundle:nil];
    
    _playbackController = [[SongPlaybackController alloc] initWithAudioController:g_audioController];
    
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
    [super dealloc];
}

#pragma mark - Button Click Handlers

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
	NSInteger row = [indexPath row];
    UserSong *userSong = [_userSongArray objectAtIndex:row];
    
    _popupOptionsViewController.m_userSong = userSong;
    _popupOptionsViewController.m_navigationController = self;
    
    [_popupOptionsViewController attachToSuperViewWithBlackBackground:self.view];
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
