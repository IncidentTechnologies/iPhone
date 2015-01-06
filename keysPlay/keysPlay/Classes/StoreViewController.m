//
//  StoreViewController.m
//  keysPlay
//
//  Created by Franco on 8/28/13.
//
//

#import "StoreViewController.h"
#import "InAppPurchaseManager.h"

#import "CloudController.h"
#import "CloudResponse.h"
#import "CloudRequest.h"
#import "UserSong.h"
#import "UserSongs.h"
#import "XmlDom.h"
#import <gTarAppCore/UserController.h>
#import "FileController.h"

#import "SongSelectionViewController.h"
#import "StoreSongListCell.h"

#import "UIButton+Keys.h"

#define kStoreSongCacheKey @"StoreSongArray"

extern KeysController * g_keysController;
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

@synthesize g_soundMaster;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSoundMaster:(SoundMaster *)soundMaster
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
            storeSongArray = [NSKeyedUnarchiver unarchiveObjectWithData:songArrayData];
        
        g_soundMaster = soundMaster;
        [g_soundMaster start];
        
        m_storeSongArray = storeSongArray;
        m_displayedStoreSongArray = storeSongArray;
        
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
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    double screenWidth = [frameGenerator getFullscreenWidth];
    
    // Add shadow and placement to header bar
    CGRect shadowRect = CGRectMake(0.0f, 0.0f, screenWidth, _viewTopBar.frame.size.height);
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
    bottomBorder.frame = CGRectMake(0.0f, _viewTopBar.frame.size.height, screenWidth + 1.0f, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:(102.0f/255.0f) green:(104.0f/255.0f) blue:(105.0f/255.0f) alpha:1.0f].CGColor;
    [_viewTopBar.layer addSublayer:bottomBorder];
    
    // Add divider borders in column headers
    CALayer *bottomBorderHeader = [CALayer layer];
    bottomBorderHeader.frame = CGRectMake(0.0f, _colBar.frame.size.height, screenWidth + 1.0f, 1.0f);
    bottomBorderHeader.backgroundColor = [UIColor colorWithWhite:(192.0f/255.0f) alpha:1.0f].CGColor;
    [_colBar.layer addSublayer:bottomBorderHeader];
    
    CALayer *borderTitleArtist = [CALayer layer];
    borderTitleArtist.frame = CGRectMake(screenWidth - 132.0f, 0.0f, 1.0f, _colBar.frame.size.height);
    borderTitleArtist.backgroundColor = [UIColor colorWithWhite:(128.0f/255.0f) alpha:1.0f].CGColor;
    [_colBar.layer addSublayer:borderTitleArtist];
    
    CALayer *borderSkill = [CALayer layer];
    borderSkill.frame = CGRectMake(screenWidth - 66.0f, 0.0f, 1.0f, _colBar.frame.size.height);
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
        DLog(@"Can make in app purchase");
        [purchaseManager loadStore];
    }
    else
    {
        DLog(@"Can NOT make in app purchase");
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
    _playerViewController = [[PlayerViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster];
    [_playerViewController setDelegate:self];
    [_playerViewController attachToSuperview:_songPlayerView];
    
    _currentDifficulty = 0;
    [_easyButton setEnabled:NO];
    
    // Adjust the images in the buttons
    [_closeModalButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_volumeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_instrumentButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
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
    
    [g_keysController addObserver:self];
}

- (void)localizeViews {
    
    
    [_buttonTitleArtist setTitle:NSLocalizedString(@"TITLE & ARTIST", NULL) forState:UIControlStateNormal];
    [_buttonSkill setTitle:NSLocalizedString(@"SKILL", NULL) forState:UIControlStateNormal];
    [_buttonBuy setTitle:NSLocalizedString(@"BUY", NULL) forState:UIControlStateNormal];
    
    _easyLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Easy", NULL)];
    _mediumLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", NULL)];
    _hardLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Hard", NULL)];
    
    [_startButton setTitle:NSLocalizedString(@"PRESS TO PLAY", NULL) forState:UIControlStateNormal];
    
    //_backLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Back", NULL)];
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

- (void)dealloc
{
    [g_keysController removeObserver:self];
    
    // Turn off all LEDs
    if(g_keysController.connected){
        [g_keysController turnOffAllLeds];
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

/*
 - (IBAction)fullscreenButtonClicked:(id)sender
 {
 [_searchBar endSearch];
 [_fullscreenButton setHidden:YES];
 }
 */

#pragma mark - ViewController stuff

- (void)startSong:(UserSong *)userSong withDifficulty:(NSInteger)difficulty practiceMode:(BOOL)practiceMode
{
    // TODO: pass keysController
    PlayViewController *playViewController = [[PlayViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster isStandalone:!g_keysController.connected practiceMode:practiceMode selectedTrack:0];
    
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
        
        NSMutableAttributedString *attributedTextSkill = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"SKILL", NULL) attributes:attrs];
        [attributedTextSkill setAttributes:subAttrs range:rangeSkill];
        
        NSMutableAttributedString *attributedTextBuy = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"BUY", NULL) attributes:attrs];
        [attributedTextBuy setAttributes:subAttrs range:rangeBuy];
        
        [_buttonTitleArtist setAttributedTitle:attributedTextTitleArtist forState:UIControlStateNormal];
        [_buttonSkill setAttributedTitle:attributedTextSkill forState:UIControlStateNormal];
        [_buttonBuy setAttributedTitle:attributedTextBuy forState:UIControlStateNormal];
    }
    else
    {
        [_buttonTitleArtist setTitle:NSLocalizedString(@"TITLE & ARTIST", NULL) forState:UIControlStateNormal];
        [_buttonSkill setTitle:NSLocalizedString(@"SKILL", NULL) forState:UIControlStateNormal];
        [_buttonBuy setTitle:NSLocalizedString(@"BUY", NULL) forState:UIControlStateNormal];
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
    m_storeSongArray = storeSongArray;
    
    [self refreshDisplayedStoreSongList];
}

- (void)refreshDisplayedStoreSongList
{
    //[m_displayedStoreSongArray autorelease];
    
    if ( m_fSearching == TRUE )
        m_displayedStoreSongArray = m_searchedStoreSongArray;
    else
        m_displayedStoreSongArray = m_storeSongArray;
    
    
    [self sortSongList];
    [_pullToUpdateSongList reloadData];
}

-(void)openSongListToSong:(UserSong*)userSong
{
    // We only want to present it once, otherwise it will crash
    if ( _songOptionsModal.presentingViewController != nil )
        return;
    
    _currentUserSong = userSong;
    [_practiceButton startActivityIndicator];
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
    
    [_songOptionsModal setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
    [self presentViewController:_songOptionsModal animated:NO completion:nil];
}

- (void)playerLoaded
{
    [_instrumentButton setEnabled:YES];
    [_practiceButton stopActivityIndicator];
    [_startButton stopActivityIndicator];
    [_startButton setImage:[UIImage imageNamed:@"PlayButtonVideo.png"] forState:UIControlStateNormal];
}

#pragma mark - Sort, Search

- (void)sortSongList
{
    NSSortDescriptor *sortDescriptor = NULL;
    
    switch (m_storeSortOrder.type)
    {
        case SORT_TITLE: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:m_storeSortOrder.fAscending];
        } break;
            
        case SORT_ARTIST: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:m_storeSortOrder.fAscending];
        } break;
            
        case SORT_SKILL: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"m_difficulty" ascending:m_storeSortOrder.fAscending];
        } break;
            
        case SORT_COST: {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"m_cost" ascending:m_storeSortOrder.fAscending];
        } break;
            
        default: break;
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [m_displayedStoreSongArray sortedArrayUsingDescriptors:sortDescriptors];
    
    m_displayedStoreSongArray = sortedArray;
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
     
     [_songOptionsModal setModalPresentationStyle:UIModalPresentationOverCurrentContext];
     
     [self presentViewController:_songOptionsModal animated:YES completion:nil];
     */
    
    DLog(@"Table view row selected!");
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
    
    m_searchedStoreSongArray = searchResults;
}

-(void) dismissSearchBar
{
    [_searchBar endSearch];
}

#pragma mark - Callbacks

- (void)requestStoreSongListCallback:(CloudResponse*)cloudResponse
{
    DLog(@"Got Cloud Response for Song List");
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
            DLog(@"Failed to syncronize standardUserDefaults");
        
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
        
        DLog(@"Something bad happened, no data to show");
    }
}


#pragma mark - Sliding Instrument Selector delegate and other audio stuff
- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    DLog(@"Song Selection VC: did select instrument %@",instrumentName);
    [_playerViewController didSelectInstrument:instrumentName withSelector:cb andOwner:sender];
}

- (void)stopAudioEffects
{
    DLog(@"Song Selection View Controller: stop audio effects");
    
    [_playerViewController stopAudioEffects];
}

-(NSInteger)getSelectedInstrumentIndex
{
    DLog(@"Song Selection View Controller: get selected instrument index");
    
    return [_playerViewController getSelectedInstrumentIndex];
}

-(NSArray *)getInstrumentList
{
    DLog(@"Song Selection View Controller: get instrument list");
    
    return [_playerViewController getInstrumentList];
}

@end

