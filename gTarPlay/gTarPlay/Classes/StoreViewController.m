//
//  StoreViewController.m
//  gTarPlay
//
//  Created by Franco on 8/28/13.
//
//

#import "StoreViewController.h"
#import "InAppPurchaseManager.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/CloudRequest.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongs.h>
#import <gTarAppCore/XmlDom.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/FileController.h>

#import "SongSelectionViewController.h"
#import "StoreSongListCell.h"

#import "PlayViewController.h"
#import "PlayerViewController.h"
#import "SlidingModalViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"

#import "UIButton+Gtar.h"

#define kStoreSongCacheKey @"StoreSongArray"

extern CloudController *g_cloudController;
extern FileController *g_fileController;

@interface StoreViewController ()
{
    VolumeViewController *_volumeViewController;
    SlidingInstrumentViewController *_instrumentViewController;
    PlayerViewController *_playerViewController;
    UserSong *_currentUserSong;
    NSInteger _currentDifficulty;
    
    NSArray *m_storeSongArray;
    NSArray *m_displayedStoreSongArray;
    
    NSArray *m_searchedStoreSongArray;
    
    BOOL m_fSearching;
    
    StoreSortOrder m_storeSortOrder;
    
    UITapGestureRecognizer *m_tapRecognizer;
}
@end

@implementation StoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // See if we have any cached songs from previous runs
        // Do we want it to cache?        
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        NSData *songArrayData = [settings objectForKey:kStoreSongCacheKey];
        NSArray *storeSongArray;
        
        // If we have cached data, use that.
        if ( songArrayData == nil )
            storeSongArray = [[NSArray alloc] init];
        else
            storeSongArray = [[NSKeyedUnarchiver unarchiveObjectWithData:songArrayData] retain];
        
        m_storeSongArray = [storeSongArray retain];
        m_displayedStoreSongArray = [storeSongArray retain];
        
        m_storeSortOrder.type = SORT_TITLE;
        m_storeSortOrder.fAscending = FALSE;
        
        m_fSearching = FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
    // iOS 7 Check
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
    // Init tap gesture recog.
    m_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBar)];
    [self.view addGestureRecognizer:m_tapRecognizer];
    
    // Add shadow and placement to header bar
    CGRect shadowRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen ] bounds].size.height, _viewTopBar.frame.size.height);
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:shadowRect];
    _viewTopBar.layer.masksToBounds = NO;
    _viewTopBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    _viewTopBar.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _viewTopBar.layer.shadowOpacity = 0.9f;
    _viewTopBar.layer.shadowRadius = 7.0f;
    _viewTopBar.layer.shadowPath = shadowPath.CGPath;
    [self.view bringSubviewToFront:_viewTopBar];
    
    // Add bottom border
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, _viewTopBar.frame.size.height, [[UIScreen mainScreen] bounds].size.height + 1.0f, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:(102.0f/255.0f) green:(104.0f/255.0f) blue:(105.0f/255.0f) alpha:1.0f].CGColor;
    [_viewTopBar.layer addSublayer:bottomBorder];
    
    // Add divider borders in column headers
    CALayer *bottomBorderHeader = [CALayer layer];
    bottomBorderHeader.frame = CGRectMake(0.0f, _colBar.frame.size.height, [[UIScreen mainScreen] bounds].size.height + 1.0f, 1.0f);
    bottomBorderHeader.backgroundColor = [UIColor colorWithWhite:(192.0f/255.0f) alpha:1.0f].CGColor;
    [_colBar.layer addSublayer:bottomBorderHeader];
    
    CALayer *borderTitleArtist = [CALayer layer];
    borderTitleArtist.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - 120.0f, 0.0f, 1.0f, _colBar.frame.size.height);
    borderTitleArtist.backgroundColor = [UIColor colorWithWhite:(128.0f/255.0f) alpha:1.0f].CGColor;
    [_colBar.layer addSublayer:borderTitleArtist];
    
    CALayer *borderSkill = [CALayer layer];
    borderSkill.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - 60.0f, 0.0f, 1.0f, _colBar.frame.size.height);
    borderSkill.backgroundColor = [UIColor colorWithWhite:(128.0f/255.0f) alpha:1.0f].CGColor;
    [_colBar.layer addSublayer:borderSkill];
    
    // Do any additional setup after loading the view from its nib.
    [_pullToUpdateSongList setIndicatorTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    [_pullToUpdateSongList setActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_pullToUpdateSongList setArrowColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    
    [_pullToUpdateSongList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // iOS 7 issue
    if([_pullToUpdateSongList respondsToSelector:@selector(setSeparatorInset:)])
        _pullToUpdateSongList.separatorInset = UIEdgeInsetsZero;
    
    [self updateTopHeaderTextFormatting];
    
    // InAppPurchaseManager is a Singleton
    InAppPurchaseManager* purchaseManager = [InAppPurchaseManager sharedInstance];
    if ([purchaseManager canMakePurchases])
    {
        NSLog(@"Can make in app purchase");
        [purchaseManager loadStore];
    }
    else
    {
        NSLog(@"Can NOT make in app purchase");
    }
    
    if ( [m_storeSongArray count] == 0 ) {
        [_pullToUpdateSongList startAnimating];
    }
    else {
        // Update sorting
        [_pullToUpdateSongList startAnimating];
        [self sortSongList];
    }
    
    // Set up song options
    _playerViewController = [[PlayerViewController alloc] initWithNibName:nil bundle:nil];
    [_playerViewController attachToSuperview:_songPlayerView];
    
    _currentDifficulty = 0;
    [_easyButton setEnabled:NO];
    
    // Adjust the images in the buttons
    [_closeModalButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_volumeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_instrumentButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
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
}

- (void)localizeViews {
    [_buttonTitleArtist setTitle:NSLocalizedString(@"TITLE & ARTIST", NULL) forState:UIControlStateNormal];
    [_buttonSkill setTitle:NSLocalizedString(@"SKILL", NULL) forState:UIControlStateNormal];
    [_buttonBuy setTitle:NSLocalizedString(@"BUY", NULL) forState:UIControlStateNormal];
    
    _easyLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Easy", NULL)];
    _mediumLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", NULL)];
    _hardLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Hard", NULL)];
    
    [_startButton setTitle:NSLocalizedString(@"PRESS TO PLAY", NULL) forState:UIControlStateNormal];
    
    _backLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Back", NULL)];
    _shopLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Shop", NULL)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( [m_storeSongArray count] == 0 )
    {
        CloudRequest *cloudRequest = [g_cloudController requestSongStoreListCallbackObj:nil andCallbackSel:nil];
        [self requestStoreSongListCallback:cloudRequest.m_cloudResponse];
    }
    else
    {
        [g_cloudController requestSongStoreListCallbackObj:self andCallbackSel:@selector(requestStoreSongListCallback:)];
    }
}

#pragma mark - Button Event Handlers

- (IBAction)onBackButtonTouchUpInside:(id)sender
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

/*
- (IBAction)fullscreenButtonClicked:(id)sender
{
    [_searchBar endSearch];
    [_fullscreenButton setHidden:YES];
}
 */

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

#pragma mark - Store List Sorting
-(void)updateTopHeaderTextFormatting
{
    NSUInteger startRangeTitleArtist = 0, rangeLengthTitleArtist = 0;
    NSString * title = NSLocalizedString(@"TITLE", NULL);
    NSString * artist = NSLocalizedString(@"ARTIST", NULL);
    
    if(m_storeSortOrder.type == SORT_ARTIST) {
        startRangeTitleArtist = [title length]+3;
        rangeLengthTitleArtist = [artist length];
    }
    else if(m_storeSortOrder.type == SORT_TITLE) {
        startRangeTitleArtist = 0;
        rangeLengthTitleArtist = [title length];
    }
    
    // Set the new text
    if([_buttonTitleArtist respondsToSelector:@selector(setAttributedTitle:forState:)])
    {
        UIFont *boldFont = [UIFont fontWithName:@"AvenirNext-Bold" size:15.0];
        UIFont *regularFont = [UIFont fontWithName:@"Avenir Next" size:15.0];
        UIColor *foregroundColor = [UIColor whiteColor];
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               regularFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
        
        const NSRange rangeTitleArtist = NSMakeRange(startRangeTitleArtist, rangeLengthTitleArtist);
        const NSRange rangeSkill = NSMakeRange(0, (m_storeSortOrder.type == SORT_SKILL) ? 5 : 0);
        const NSRange rangeBuy = NSMakeRange(0, (m_storeSortOrder.type == SORT_COST) ? 3 : 0);
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedTextTitleArtist = [[NSMutableAttributedString alloc] initWithString:[[title stringByAppendingString:@" & "] stringByAppendingString:artist] attributes:attrs];
        [attributedTextTitleArtist setAttributes:subAttrs range:rangeTitleArtist];
        
        NSMutableAttributedString *attributedTextSkill = [[NSMutableAttributedString alloc] initWithString:@"SKILL" attributes:attrs];
        [attributedTextSkill setAttributes:subAttrs range:rangeSkill];
        
        NSMutableAttributedString *attributedTextBuy = [[NSMutableAttributedString alloc] initWithString:@"BUY" attributes:attrs];
        [attributedTextBuy setAttributes:subAttrs range:rangeBuy];
        
        [_buttonTitleArtist setAttributedTitle:attributedTextTitleArtist forState:UIControlStateNormal];
        [_buttonSkill setAttributedTitle:attributedTextSkill forState:UIControlStateNormal];
        [_buttonBuy setAttributedTitle:attributedTextBuy forState:UIControlStateNormal];
    }
    else
    {
        [_buttonTitleArtist setTitle:@"TITLE & ARTIST" forState:UIControlStateNormal];
        [_buttonSkill setTitle:@"SKILL" forState:UIControlStateNormal];
        [_buttonBuy setTitle:@"BUY" forState:UIControlStateNormal];
    }
}

-(IBAction)onTitleArtistClick:(id)sender
{    
    switch(m_storeSortOrder.type) {
        case SORT_TITLE: {
            if(m_storeSortOrder.fAscending) {
                m_storeSortOrder.fAscending = FALSE;
            }
            else {
                m_storeSortOrder.type = SORT_ARTIST;
                m_storeSortOrder.fAscending = TRUE;
            }
        } break;
        
        case SORT_ARTIST: {
            if(m_storeSortOrder.fAscending) {
                m_storeSortOrder.fAscending = FALSE;
            }
            else {
                m_storeSortOrder.type = SORT_TITLE;
                m_storeSortOrder.fAscending = TRUE;
            }
        } break;
            
        default: {
            m_storeSortOrder.type = SORT_TITLE;
            m_storeSortOrder.fAscending = TRUE;
        } break;
    }
        
    [self updateTopHeaderTextFormatting];
    [self refreshDisplayedStoreSongList];
}

-(IBAction)onSkillClick:(id)sender {
    if(m_storeSortOrder.type != SORT_SKILL) {
        m_storeSortOrder.type = SORT_SKILL;
        m_storeSortOrder.fAscending = TRUE;
    }
    else {
        m_storeSortOrder.fAscending = !m_storeSortOrder.fAscending;
    }
    
    [self updateTopHeaderTextFormatting];
    [self refreshDisplayedStoreSongList];
}

-(IBAction)onBuyClick:(id)sender
{
    if(m_storeSortOrder.type != SORT_COST) {
        m_storeSortOrder.type = SORT_COST;
        m_storeSortOrder.fAscending = TRUE;
    }
    else {
        m_storeSortOrder.fAscending = !m_storeSortOrder.fAscending;
    }
    
    [self updateTopHeaderTextFormatting];
    [self refreshDisplayedStoreSongList];
}

- (void)dealloc
{
    [m_storeSongArray release];
    
    [_buttonGetProductList release];
    [_pullToUpdateSongList release];
    [_buttonGetServerSongList release];
    [super dealloc];
}

- (void)refreshSongList
{
    [_pullToUpdateSongList startAnimating];
    [g_cloudController requestSongStoreListCallbackObj:self andCallbackSel:@selector(requestStoreSongListCallback:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)purchaseSong:(id)sender
{
    [[InAppPurchaseManager sharedInstance] purchaseSong];
}

- (IBAction)getProductList:(id)sender
{
    InAppPurchaseManager *purchaseManager = [InAppPurchaseManager sharedInstance];
    [purchaseManager getProductList];
}

- (IBAction)onGetServerSongListTouchUpInside:(id)sender
{
    // Get the server song list here
}

- (void)setStoreSongArray:(NSArray *)storeSongArray
{
    [m_storeSongArray autorelease];
    m_storeSongArray = [storeSongArray retain];
    
    [self refreshDisplayedStoreSongList];
}

- (void)refreshDisplayedStoreSongList
{
    [m_displayedStoreSongArray autorelease];
    
    if ( m_fSearching == TRUE )
        m_displayedStoreSongArray = [m_searchedStoreSongArray retain];
    else
        m_displayedStoreSongArray = [m_storeSongArray retain];

    
    [self sortSongList];
    [_pullToUpdateSongList reloadData];
}

-(void)openSongListToSong:(UserSong*)userSong
{
    // We only want to present it once, otherwise it will crash
    if ( _songOptionsModal.presentingViewController != nil )
        return;
    
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

#pragma mark - Sort, Search

- (void)sortSongList
{
    NSSortDescriptor *sortDescriptor = NULL;
    
    switch (m_storeSortOrder.type)
    {
        case SORT_TITLE: {
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:m_storeSortOrder.fAscending] autorelease];
        } break;
            
        case SORT_ARTIST: {
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:m_storeSortOrder.fAscending] autorelease];
        } break;
            
        case SORT_SKILL: {
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_difficulty" ascending:m_storeSortOrder.fAscending] autorelease];
        } break;
            
        case SORT_COST: {
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_cost" ascending:m_storeSortOrder.fAscending] autorelease];
        } break;
            
        default: break;
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [m_displayedStoreSongArray sortedArrayUsingDescriptors:sortDescriptors];
    
    [m_displayedStoreSongArray autorelease];
    m_displayedStoreSongArray = [sortedArray retain];
}


#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
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
    */
    
    NSLog(@"Table view row selected!");
}

- (void)updateTable
{
    [self refreshSongList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_displayedStoreSongArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoreSongListCell";
    StoreSongListCell *tempCell = [_pullToUpdateSongList dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (tempCell == NULL)
    {
		//tempCell = [[StoreSongListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		// [NSBundle mainBundle] loadNibNamed:@"StoreSongListCell" owner:tempCell options:nil];
        
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"StoreSongListCell" owner:nil options:nil];
        for (UIView *view in views)
            if([view isKindOfClass:[UITableViewCell class]])
                tempCell = (StoreSongListCell*)view;
        
        tempCell.parentStoreViewController = self;
        
        CGFloat cellHeight = _pullToUpdateSongList.rowHeight - 1;
        CGFloat cellRow = _pullToUpdateSongList.frame.size.width;
        
        // Readjust the width and height
        [tempCell setFrame:CGRectMake(0.0f, 0.0f, cellRow, cellHeight)];
        [tempCell.accessoryView setFrame:CGRectMake(0.0f, 0.0f, cellRow, cellHeight)];
        
        // Readjust the column headers to match the width
        //[tempCell.titleArtistView setFrame:CGRectMake(0.0f, 0.0f, _buttonTitleArtist.frame.size.width, cellHeight)];
        //[tempCell.skillView setFrame:CGRectMake(_buttonSkill.frame.origin.x, 0.0f, _buttonSkill.frame.size.width, cellHeight)];
        //[tempCell.purchaseSongView setFrame:CGRectMake(_buttonBuy.frame.origin.x, 0.0f, _buttonBuy.frame.size.width, cellHeight)];
	}
	
	// Clear these in case this cell was previously selected
	tempCell.highlighted = NO;
	tempCell.selected = NO;
    
    // iOS 7 check
    if([tempCell respondsToSelector:@selector(setSeparatorInset:)])
        [tempCell setSeparatorInset:UIEdgeInsetsZero];
    
    // assign data to cell
    NSInteger row = [indexPath row];
    UserSong *userSong = [m_displayedStoreSongArray objectAtIndex:row];
    tempCell.userSong = userSong;
    [tempCell updateCell];
    
	return tempCell;
}

#pragma mark - ExpandableSearchBarDelegate

- (void)searchBarDidBeginEditing:(ExpandableSearchBar *)searchBar
{
    // Do nothing
}

- (void)searchBarSearch:(ExpandableSearchBar *)searchBar
{
    if([searchBar.searchString length] > 0)
    {
        m_fSearching = YES;
        [self searchForString:searchBar.searchString];
        [self refreshDisplayedStoreSongList];
    }
    else
    {
        m_fSearching = FALSE;
        [self dismissSearchBar];
    }
}

- (void)searchBarCancel:(ExpandableSearchBar *)searchBar
{
    // revert the displayed contents
    m_fSearching = FALSE;
    [self refreshDisplayedStoreSongList];
}

- (void)searchForString:(NSString *)searchString
{
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    
    for ( UserSong *userSong in m_storeSongArray )
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
    
    [m_searchedStoreSongArray release];
    m_searchedStoreSongArray = [searchResults retain];
}

-(void) dismissSearchBar
{
    [_searchBar endSearch];
}

#pragma mark - Callbacks

- (void)requestStoreSongListCallback:(CloudResponse*)cloudResponse
{
    NSLog(@"Got Cloud Response for Song List");
    [_pullToUpdateSongList stopAnimating];
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // refresh table data
        UserSongs *userSongs = cloudResponse.m_responseUserSongs;
        [self setStoreSongArray:userSongs.m_songsArray];
    
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        
        /*
        // If we have cached data, clobber it (doesn't seem to look at the data itself sometimes)
        if ( [settings objectForKey:kStoreSongCacheKey] != nil )
            [settings removeObjectForKey:kStoreSongCacheKey];
        */
        
        // Archive the new array to standardUserDefaults
        [settings setObject:[NSKeyedArchiver archivedDataWithRootObject:m_storeSongArray] forKey:kStoreSongCacheKey];
        if(![settings synchronize])
            NSLog(@"Failed to syncronize standardUserDefaults");
        
        // Reload table data
        [_pullToUpdateSongList reloadData];
    }
    else
    {
        // Something bad happened, and we don't have any data to show
        /*if ( [_userSongArray count] == 0 )
        {
            [self backButtonClicked:nil];
        }*/
        
        NSLog(@"Something bad happened, no data to show");
    }
}

@end
    
