//
//  SongSelectionViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import "SongSelectionViewController.h"
#import "SongListCell.h"
#import "PlayViewController.h"
#import "SlidingModalViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"
#import "PlayerViewController.h"
#import "UIView+Gtar.h"
#import "UIButton+Gtar.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/CloudRequest.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongs.h>
#import <gTarAppCore/XmlDom.h>
#import <gTarAppCore/SongPlaybackController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/SongPlaybackController.h>

#define MAX_SIMULTANEOUS_SONG_DOWNLOADS 10

extern FileController *g_fileController;
extern CloudController *g_cloudController;
extern AudioController *g_audioController;
extern UserController *g_userController;
extern GtarController *g_gtarController;

typedef enum
{
    SortByTitleAscending,
    SortByTitleDescending,
    SortByArtistAscending,
    SortByArtistDescending
} SortOrder;

@interface SongSelectionViewController ()
{
    VolumeViewController *_volumeViewController;
    SlidingInstrumentViewController *_instrumentViewController;
    
    NSArray *_userSongArray;
    NSArray *_searchedUserSongArray;
    NSArray *_displayedUserSongArray;
    SongPlaybackController *_playbackController;
    PlayerViewController *_playerViewController;
    
    UserSong *_currentUserSong;
    NSInteger _currentDifficulty;
    
    BOOL _searching;
    
    NSInteger _nextUserSong;
    
    SortOrder _sortOrder;
}

@property (retain, nonatomic) IBOutlet UIButton *sortByTitleButtton;
@property (retain, nonatomic) IBOutlet UIButton *sortByArtistButton;
@property (retain, nonatomic) IBOutlet UIImageView *sortByTitleArrow;
@property (retain, nonatomic) IBOutlet UIImageView *sortByArtistArrow;

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
        
        NSArray *userSongArray;
        
        // If we have cached data, use that.
        if ( songArrayData == nil )
        {
            userSongArray = [[NSArray alloc] init];
        }
        else
        {
            userSongArray = [[NSKeyedUnarchiver unarchiveObjectWithData:songArrayData] retain];
            
        }
        
        _userSongArray = userSongArray;
        [_userSongArray retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( [_userSongArray count] == 0 )
    {
        [_songListTable startAnimating];
    }
    
    [_topBar addShadow];
    
    [_fullscreenButton setHidden:YES];
    
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
        [self downloadUserSongs];
    }
    
    [g_gtarController addObserver:self];
    
    // Initialize sorting order
    _sortOrder = SortByTitleAscending;
    _sortByArtistArrow.hidden = YES;
    _sortByTitleButtton.selected = YES;
    _sortByTitleArrow.highlighted = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( _volumeViewController == nil )
    {
        _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil];
        
        [_volumeViewController attachToSuperview:_songOptionsModal.contentView withFrame:_volumeView.frame];
    }
    
    if ( _instrumentViewController == nil )
    {
        _instrumentViewController = [[SlidingInstrumentViewController alloc] initWithNibName:nil bundle:nil];
        
        [_instrumentViewController attachToSuperview:_songOptionsModal.contentView withFrame:_instrumentView.frame];
    }
    
    if ( [_userSongArray count] == 0 )
    {
        CloudRequest *cloudRequest = [g_cloudController requestSongListCallbackObj:nil andCallbackSel:nil];
        [self requestSongListCallback:cloudRequest.m_cloudResponse];
    }
    else
    {
        [g_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
    [g_gtarController removeObserver:self];
    
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
    [_instrumentView release];
    [_searchBar release];
    [_fullscreenButton release];
    [_startButton release];
    [_sortByTitleArrow release];
    [_sortByArtistArrow release];
    [_sortByArtistButton release];
    [_sortByTitleButtton release];
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
    if ( _instrumentViewController.loading == YES )
    {
        return;
    }
    [_playerViewController endPlayback];
    [_songOptionsModal closeButtonClicked:sender];
    
    [_volumeViewController closeView:NO];
    [_instrumentViewController closeView:NO];
    [_songOptionsModal.blackButtonOrig setHidden:YES];
}

- (IBAction)volumeButtonClicked:(id)sender
{
    if ( _instrumentViewController.loading == YES )
    {
        return;
    }
    
    if ( _volumeViewController.isDown == YES )
    {
        [_songOptionsModal.blackButtonOrig setHidden:YES];
    }
    else
    {
        [_songOptionsModal.blackButtonOrig setHidden:NO];
    }
    [_volumeViewController toggleView:YES];
    [_instrumentViewController closeView:YES];
}

- (IBAction)instrumentButtonClicked:(id)sender
{
    if ( _instrumentViewController.loading == YES )
    {
        return;
    }
    
    if ( _instrumentViewController.isDown == YES )
    {
        [_songOptionsModal.blackButtonOrig setHidden:YES];
    }
    else
    {
        [_songOptionsModal.blackButtonOrig setHidden:NO];
    }
    [_playerViewController endPlayback];
    [_instrumentViewController toggleView:YES];
    [_volumeViewController closeView:YES];
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

- (IBAction)blackButtonClicked:(id)sender
{
    if ( _instrumentViewController.loading == YES )
    {
        return;
    }
    [_songOptionsModal.blackButtonOrig setHidden:YES];
    [_instrumentViewController closeView:YES];
    [_volumeViewController closeView:YES];
}

- (IBAction)fullscreenButtonClicked:(id)sender
{
    [_searchBar endSearch];
    [_fullscreenButton setHidden:YES];
}

- (IBAction)sortByArtistButtonClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
    _sortByTitleButtton.selected = NO;
    
    _sortOrder = sender.selected ? SortByArtistAscending : SortByArtistDescending;
    
    // Sort Arrows
    _sortByTitleArrow.hidden = YES;
    _sortByArtistArrow.hidden = NO;
    _sortByArtistArrow.highlighted = sender.selected;
    
    [self refreshDisplayedUserSongList];
}

- (IBAction)sortByTitleButtonClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
    _sortByArtistButton.selected = NO;
    
    _sortOrder = sender.selected ? SortByTitleAscending : SortByTitleDescending;
    
    // Sort Arrows
    _sortByArtistArrow.hidden = YES;
    _sortByTitleArrow.hidden = NO;
    _sortByTitleArrow.highlighted = sender.selected;
    
    [self refreshDisplayedUserSongList];
}

#pragma mark - UserSong management

- (void)refreshSongList
{
    [_songListTable startAnimating];
    [g_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];
    
    // Start animating offscreen if there are already songs displayed.
//    if ( [_userSongArray count] > 0 )
    {
//        [_songListTable startAnimatingOffscreen];
//        [g_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];
    }
//    else
    {
        // First time, do a sync request so we can show the song list quickly
//        [_songListTable startAnimating];
//        CloudRequest *cloudRequest = [g_cloudController requestSongListCallbackObj:nil andCallbackSel:nil];
//        [self requestSongListCallback:cloudRequest.m_cloudResponse];
    }
    
}

- (void)downloadUserSongs
{
    @synchronized(_userSongArray)
    {
        NSInteger songs = 0;
        
        while ( _nextUserSong < [_userSongArray count] && songs < MAX_SIMULTANEOUS_SONG_DOWNLOADS )
        {
            UserSong *userSong = [_userSongArray objectAtIndex:_nextUserSong++];
            
            if ( [g_fileController fileExists:userSong.m_xmpFileId] == NO )
            {
                [g_fileController getFileOrDownloadAsync:userSong.m_xmpFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
                songs++;
            }
        }
    }
}

- (void)setUserSongArray:(NSArray *)userSongArray
{
    [_userSongArray autorelease];
    
    _userSongArray = [userSongArray retain];
    
    // refresh the search list with the new songs
    if ( _searching == YES )
    {
        [self searchForString:_searchBar.searchString];
    }
    
    [self refreshDisplayedUserSongList];
}

- (void)refreshDisplayedUserSongList
{
    if ( _searching == YES )
    {
        [_displayedUserSongArray autorelease];
        _displayedUserSongArray = [_searchedUserSongArray retain];
    }
    else
    {
        [_displayedUserSongArray autorelease];
        _displayedUserSongArray = [_userSongArray retain];
    }
    
    [self sortSongList];
    
    [_songListTable reloadData];
}

#pragma mark - Callbacks

- (void)requestSongListCallback:(CloudResponse*)cloudResponse
{
    
    [_songListTable stopAnimating];
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // refresh table data
        UserSongs *userSongs = cloudResponse.m_responseUserSongs;
        
        [self setUserSongArray:userSongs.m_songsArray];
        
        // Download everything
        [self downloadUserSongs];
        
        // Save this new array
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        
        [settings setObject:[NSKeyedArchiver archivedDataWithRootObject:_userSongArray] forKey:@"UserSongArray"];
        
        [settings synchronize];
        
        // Show the new table
//        [_songListTable reloadData];
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
    // What do we download next
    @synchronized(_userSongArray)
    {
        while ( _nextUserSong < [_userSongArray count] )
        {
            UserSong *userSong = [_userSongArray objectAtIndex:_nextUserSong++];
            
            if ( [g_fileController fileExists:userSong.m_xmpFileId] == NO )
            {
                [g_fileController getFileOrDownloadAsync:userSong.m_xmpFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
                break;
            }
        }
    }
    
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
    return [_displayedUserSongArray count];
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
    
    UserSong *userSong = [_displayedUserSongArray objectAtIndex:row];
    
    userSong.m_playStars = [g_userController getMaxStarsForSong:userSong.m_songId];
    userSong.m_playScore = [g_userController getMaxScoreForSong:userSong.m_songId];
    
    cell.userSong = userSong;
    cell.playScore = [g_userController getMaxScoreForSong:userSong.m_songId];

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
    UserSong *userSong = [_displayedUserSongArray objectAtIndex:row];

    _currentUserSong = userSong;
    
    [_startButton startActivityIndicator];
    
    NSString *songString = (NSString*)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
    
    _playerViewController.userSong = userSong;
    _playerViewController.xmpBlob = songString;
    
    NSMethodSignature *signature = [SongSelectionViewController instanceMethodSignatureForSelector:@selector(playerLoaded)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:self];
    [invocation setSelector:@selector(playerLoaded)];
    
    _playerViewController.loadedInvocation = invocation;
    
    [self presentViewController:_songOptionsModal animated:YES completion:nil];
    
}

- (void)playerLoaded
{
    [_startButton stopActivityIndicator];
}

- (void)updateTable
{
    [self refreshSongList];
}

#pragma mark - ViewController stuff

- (void)startSong:(UserSong *)userSong withDifficulty:(NSInteger)difficulty
{
    
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
}

//- (void)previewUserSong:(UserSong*)userSong
//{
//    // Get the XMP, stick it in the user song, and push to the game mode
//    NSString *songString = (NSString*)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
//    
//    [_playbackController startWithXmpBlob:songString];
//}

//- (void)stopPreview
//{
//    [_playbackController pauseSong];
//}

#pragma mark - GtarControllerObserver

- (void)gtarDisconnected
{
    if ( self.presentedViewController != nil )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ExpandableSearchBarDelegate

- (void)searchBarDidBeginEditing:(ExpandableSearchBar *)searchBar
{
    // nothing
    [_fullscreenButton setHidden:NO];
}

- (void)searchBarSearch:(ExpandableSearchBar *)searchBar
{
    _searching = YES;
    
    [self searchForString:searchBar.searchString];
    [self refreshDisplayedUserSongList];
    [_fullscreenButton setHidden:YES];
}

- (void)searchBarCancel:(ExpandableSearchBar *)searchBar
{
    // revert the displayed contents
    _searching = NO;
    [_fullscreenButton setHidden:YES];
    [self refreshDisplayedUserSongList];
}

#pragma mark - Sort, Search

- (void)sortSongList
{
    NSSortDescriptor *sortDescriptor;
    switch (_sortOrder) {
        case SortByTitleAscending:
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:YES] autorelease];
            break;
        case SortByTitleDescending:
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:NO] autorelease];
            break;
        case SortByArtistAscending:
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:YES] autorelease];
            break;
        case SortByArtistDescending:
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:NO] autorelease];
            break;
            
        default:
            break;
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [_displayedUserSongArray sortedArrayUsingDescriptors:sortDescriptors];
    
    [_displayedUserSongArray autorelease];
    _displayedUserSongArray = [sortedArray retain];
}

- (void)sortByScore
{
    NSArray *sortedArray = [_userSongArray sortedArrayUsingSelector:@selector(comparePlayScore:)];
    
    [_userSongArray release];
    _userSongArray = [sortedArray retain];
}

- (void)searchForString:(NSString *)searchString
{
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    
    for ( UserSong *userSong in _userSongArray )
    {
        NSArray *candidateStrings = [NSArray arrayWithObjects:userSong.m_title, userSong.m_author, nil];

        for ( NSString *candidateString in candidateStrings )
        {
            // If we find a hit, save it for later
            if ( [candidateString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound )
            {
                [searchResults addObject:userSong];
                break;
            }
        }
    }
    
    [_searchedUserSongArray release];
    
    _searchedUserSongArray = searchResults;
}

@end