//
//  SongSelectionViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import "SongSelectionViewController.h"

#define MAX_SIMULTANEOUS_SONG_DOWNLOADS 10

extern FileController *g_fileController;
extern CloudController *g_cloudController;
//extern AudioController *g_audioController;
extern UserController *g_userController;
extern GtarController *g_gtarController;

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
    
    struct SongSortOrder _sortOrder;
    int sortChange;
}

@property (strong, nonatomic) IBOutlet UIButton *sortByTitleButtton;
//@property (retain, nonatomic) IBOutlet UIButton *sortByArtistButton;
//@property (retain, nonatomic) IBOutlet UIImageView *sortByTitleArrow;
//@property (retain, nonatomic) IBOutlet UIImageView *sortByArtistArrow;

@end

@implementation SongSelectionViewController

@synthesize g_soundMaster;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
        
        NSLog(@"Alloc Song Selection VC SoundMaster");
        g_soundMaster = soundMaster;
        [g_soundMaster start];
        
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
            userSongArray = [NSKeyedUnarchiver unarchiveObjectWithData:songArrayData];
        }
        
        _userSongArray = userSongArray;
        NSLog(@"Found %d cached songs",[_userSongArray count]);
        
        sortChange = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
    if ( [_userSongArray count] == 0 ) {
        [_songListTable startAnimating];
    }
    else {
        // Display cached items to avoid blank screen
        [self refreshDisplayedUserSongList];
        [_songListTable startAnimating];
    }
    
    [_topBar addShadow];
    [_fullscreenButton setHidden:YES];
    
    _playerViewController = [[PlayerViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster];
    [_playerViewController setDelegate:self];
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
    
    _sortOrder.type = SORT_SONG_TITLE;
    _sortOrder.fAscending = TRUE;
    
    //_sortByArtistArrow.hidden = YES;
    _sortByTitleButtton.selected = YES;
    //_sortByTitleArrow.highlighted = YES;
    
    [self sortSongList];    // push sorting
    
    // Init volume / instrument views
    if ( _volumeViewController == nil )
    {
        _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil andSoundMaster:g_soundMaster isInverse:NO];
        [_volumeViewController attachToSuperview:_songOptionsModal.contentView withFrame:_volumeView.frame];
    }
    
    if ( _instrumentViewController == nil )
    {
        _instrumentViewController = [[SlidingInstrumentViewController alloc] initWithNibName:nil bundle:nil];
        [_instrumentViewController setDelegate:self];
        [_instrumentViewController attachToSuperview:_songOptionsModal.contentView withFrame:_instrumentView.frame];
    }
}

- (void) localizeViews {
    //[_easyButton setTitle:NSLocalizedString(@"SIGN IN", NULL) forState:UIControlStateNormal];
    
    [_sortByTitleButtton setAttributedTitle:[self generateTitleArtistLabel:YES] forState:UIControlStateNormal];
    
    _easyLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Easy", NULL)];
    _mediumLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", NULL)];
    _hardLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Hard", NULL)];
    
    [_startButton setTitle:NSLocalizedString(@"PRESS TO PLAY", NULL) forState:UIControlStateNormal];
    [_practiceButton setTitle:NSLocalizedString(@"PRACTICE", NULL) forState:UIControlStateNormal];
    
    [_skillButton setTitle:NSLocalizedString(@"SKILL", NULL) forState:UIControlStateNormal];
    [_scoreButton setTitle:NSLocalizedString(@"SCORE", NULL) forState:UIControlStateNormal];
    
    _artistLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"ARTIST", NULL)];
    _titleLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"TITLE", NULL)];
    
    //_backLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Back", NULL)];
    _songListLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Song List", NULL)];
}

- (NSMutableAttributedString *) generateTitleArtistLabel:(BOOL)boldTitle
{
    
    NSString * title = NSLocalizedString(@"TITLE", NULL);
    NSString * artist = NSLocalizedString(@"ARTIST", NULL);
    
    NSString * titleArtist = title;
    titleArtist = [titleArtist stringByAppendingString:@" & "];
    titleArtist = [titleArtist stringByAppendingString:artist];
    
    NSDictionary * boldattributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNext-Bold" size:15.0],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    NSDictionary * normalattributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir Next" size:15.0],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    
    NSMutableAttributedString * titleArtistString = [[NSMutableAttributedString alloc] initWithString:titleArtist];
    
    if(boldTitle){
        [titleArtistString setAttributes:normalattributes range:NSMakeRange(0, [titleArtist length])];
        [titleArtistString setAttributes:boldattributes range:NSMakeRange(0, [title length])];
    }else{
        [titleArtistString setAttributes:normalattributes range:NSMakeRange(0, [titleArtist length])];
        [titleArtistString setAttributes:boldattributes range:NSMakeRange([title length]+3, [artist length])];
    }
    
    return titleArtistString;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ( [_userSongArray count] == 0 ) {
        CloudRequest *cloudRequest = [g_cloudController requestSongListCallbackObj:nil andCallbackSel:nil];
        [self requestSongListCallback:cloudRequest.m_cloudResponse];
    }
    else
        [g_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [g_gtarController removeObserver:self];
    //[g_soundMaster releaseAfterUse];
    //[_sortByTitleArrow release];
    //[_sortByArtistArrow release];
    //[_sortByArtistButton release];
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
    
    [self startSong:_currentUserSong withDifficulty:_currentDifficulty practiceMode:NO];
}

- (IBAction)practiceButtonClicked:(id)sender
{
    [_playerViewController endPlayback];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self startSong:_currentUserSong withDifficulty:_currentDifficulty practiceMode:YES];
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

/*- (IBAction)sortByArtistButtonClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
    _sortByTitleButtton.selected = NO;
    
    if(sender.selected) {
        _sortOrder.type = SORT_SONG_ARTIST;
        _sortOrder.fAscending = TRUE;
    }
    else {
        _sortOrder.type = SORT_SONG_ARTIST;
        _sortOrder.fAscending = FALSE;
    }

    // Sort Arrows
    _sortByTitleArrow.hidden = YES;
    _sortByArtistArrow.hidden = NO;
    _sortByArtistArrow.highlighted = sender.selected;
    
    [self refreshDisplayedUserSongList];
}*/

- (IBAction)sortByTitleButtonClicked:(UIButton*)sender
{
    sortChange++;
    
    BOOL boldTitle = YES;
    
    switch(sortChange%4){
        case 0:
            _sortOrder.type = SORT_SONG_TITLE;
            _sortOrder.fAscending = TRUE;
            break;
        case 1:
            _sortOrder.type = SORT_SONG_TITLE;
            _sortOrder.fAscending = FALSE;
            break;
        case 2:
            _sortOrder.type = SORT_SONG_ARTIST;
            _sortOrder.fAscending = TRUE;
            boldTitle = NO;
            break;
        case 3:
            _sortOrder.type = SORT_SONG_ARTIST;
            _sortOrder.fAscending = FALSE;
            boldTitle = NO;
            break;
    }
    
    // Sort Arrows
    //_sortByArtistArrow.hidden = YES;
    //_sortByTitleArrow.hidden = NO;
    //_sortByTitleArrow.highlighted = sender.selected;
    
    [_sortByTitleButtton setAttributedTitle:[self generateTitleArtistLabel:boldTitle] forState:UIControlStateNormal];
    
    [self refreshDisplayedUserSongList];
}

#pragma mark - UserSong management

- (void)refreshSongList
{
    [_songListTable startAnimating];
    [g_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];
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
    
    _userSongArray = userSongArray;
    
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
        _displayedUserSongArray = _searchedUserSongArray;
    }
    else
    {
        _displayedUserSongArray = _userSongArray;
    }
    
    [self sortSongList];
    
    [_songListTable reloadData];
    
    _searching = NO;
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
	SongListCell *tempCell = [_songListTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (tempCell == NULL)
	{
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"SongListCell" owner:nil options:nil];
        for (UIView *view in views)
            if([view isKindOfClass:[UITableViewCell class]])
                tempCell = (SongListCell*)view;
        
        CGFloat cellHeight = _songListTable.rowHeight-1;
        CGFloat cellRow = _songListTable.frame.size.width;
        
//        tempCell.titleArtistView.translatesAutoresizingMaskIntoConstraints = YES;
//        tempCell.skillView.translatesAutoresizingMaskIntoConstraints = YES;
//        tempCell.scoreView.translatesAutoresizingMaskIntoConstraints = YES;
        
        // Readjust the column headers to match the width
        [tempCell.titleArtistView setFrame:CGRectMake(0, 0, _titleArtistButton.frame.size.width, cellHeight)];
        [tempCell.skillView setFrame:CGRectMake(_skillButton.frame.origin.x, 0, _skillButton.frame.size.width, cellHeight)];
        [tempCell.scoreView setFrame:CGRectMake(_scoreButton.frame.origin.x, 0, _scoreButton.frame.size.width, cellHeight)];
        
        // Readjust the width and height
        [tempCell setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        [tempCell.accessoryView setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
	}
	
	// Clear these in case this cell was previously selected
	tempCell.highlighted = NO;
	tempCell.selected = NO;
	
	NSInteger row = [indexPath row];
    
    UserSong *userSong = [_displayedUserSongArray objectAtIndex:row];
    
    userSong.m_playStars = [g_userController getMaxStarsForSong:userSong.m_songId];
    userSong.m_playScore = [g_userController getMaxScoreForSong:userSong.m_songId];
    
    tempCell.userSong = userSong;
    tempCell.playScore = [g_userController getMaxScoreForSong:userSong.m_songId];

    if ( [g_fileController fileExists:userSong.m_xmpFileId] == YES )
    {
        [tempCell updateCell];
    }
    else
    {
        [tempCell updateCellInactive];
    }
    
	return tempCell;
	
}

#pragma mark - Table view delegate

- (void)openSongOptionsForSongId:(NSInteger)songId
{
    UserSong *userSong = NULL;
    for(UserSong *song in _displayedUserSongArray) {
        if(song.m_songId == songId) {
            userSong = song;
            break;
        }
    }
    
    [self openSongOptionsForSong:userSong];
}

- (void)openSongOptionsForSong:(UserSong*)userSong
{
    // We only want to present it once, otherwise it will crash
    if ( _songOptionsModal.presentingViewController != nil )
        return;
    
    _currentUserSong = userSong;
    [_startButton startActivityIndicator];
    [_startButton setImage:nil forState:UIControlStateNormal];
    NSString *songString = (NSString*)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
    
    _playerViewController.userSong = userSong;
    _playerViewController.xmpBlob = songString;
    
    NSMethodSignature *signature = [SongSelectionViewController instanceMethodSignatureForSelector:@selector(playerLoaded)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:self];
    [invocation setSelector:@selector(playerLoaded)];
    
    _playerViewController.loadedInvocation = invocation;
    
    // Disable instrument menu until instrument has loaded
    [_instrumentButton setEnabled:NO];
    
    [self presentViewController:_songOptionsModal animated:YES completion:nil];
}

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger songId = ((UserSong*)[_displayedUserSongArray objectAtIndex:[indexPath row]]).m_songId;
    [self openSongOptionsForSongId:songId];
}

- (void)playerLoaded
{
    [_instrumentButton setEnabled:YES];
    [_startButton stopActivityIndicator];
    [_startButton setImage:[UIImage imageNamed:@"PlayButtonVideo.png"] forState:UIControlStateNormal];
}

- (void)updateTable
{
    [self refreshSongList];
}

#pragma mark - ViewController stuff

- (void)startSong:(UserSong *)userSong withDifficulty:(NSInteger)difficulty practiceMode:(BOOL)practiceMode
{
    
    PlayViewController *playViewController = [[PlayViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster isStandalone:!g_gtarController.connected practiceMode:practiceMode];
    
    // Get the XMP, stick it in the user song, and push to the game mode.
    // This generally should already have been downloaded.
    NSString *songString = (NSString *)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
    
    playViewController.userSong = userSong;
    playViewController.userSong.m_xmlDom = [[XmlDom alloc] initWithXmlString:songString];
    
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
    /*if ( self.presentedViewController != nil )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];*/
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
    switch (_sortOrder.type) {
        case SORT_SONG_TITLE: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:_sortOrder.fAscending];
        } break;
            
        case SORT_SONG_ARTIST: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:_sortOrder.fAscending];
        } break;
            
        default: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:TRUE];
        } break;
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [_displayedUserSongArray sortedArrayUsingDescriptors:sortDescriptors];
    
    _displayedUserSongArray = sortedArray;
}

- (void)sortByScore
{
    NSArray *sortedArray = [_userSongArray sortedArrayUsingSelector:@selector(comparePlayScore:)];
    
    _userSongArray = sortedArray;
}

- (void)searchForString:(NSString *)searchString
{
    
    NSLog(@"SearchString is %@",searchString);
    
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
    
    _searchedUserSongArray = searchResults;
}


#pragma mark - Sliding Instrument Selector delegate and other audio stuff
- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    NSLog(@"Song Selection VC: did select instrument %@",instrumentName);
    [_playerViewController didSelectInstrument:instrumentName withSelector:cb andOwner:sender];
}

- (void)stopAudioEffects
{
    NSLog(@"Song Selection View Controller: stop audio effects");
    
    [_playerViewController stopAudioEffects];
}

-(NSInteger)getSelectedInstrumentIndex
{
    NSLog(@"Song Selection View Controller: get selected instrument index");
    
    return [_playerViewController getSelectedInstrumentIndex];
}

-(NSArray *)getInstrumentList
{
    NSLog(@"Song Selection View Controller: get instrument list");
    
    return [_playerViewController getInstrumentList];
}

@end