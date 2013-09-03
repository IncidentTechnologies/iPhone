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

#import "StoreSongListCell.h"

#define kStoreSongCacheKey @"StoreSongArray"

extern CloudController *g_cloudController;

@interface StoreViewController () {
    NSArray *m_UserSongArray;
    
    NSArray *m_storeSongArray;
    NSArray *m_displayedStoreSongArray;
    
    BOOL m_fSearching;
    SongSortOrder m_sortOrder;
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
        {
            storeSongArray = [[NSArray alloc] init];
        }
        else
        {
            storeSongArray = [[NSKeyedUnarchiver unarchiveObjectWithData:songArrayData] retain];
        }
        
        m_storeSongArray = [storeSongArray retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [_pullToUpdateSongList setIndicatorTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    
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
    m_displayedStoreSongArray = [m_storeSongArray retain];
    [self sortSongList];
    
    [_pullToUpdateSongList reloadData];
}

#pragma mark - Sort, Search

- (void)sortSongList
{
    NSSortDescriptor *sortDescriptor;
    
    switch (m_sortOrder)
    {
        case SortByTitleAscending:  sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:YES] autorelease];
                                    break;
            
        case SortByTitleDescending: sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:NO] autorelease];
                                    break;
            
        case SortByArtistAscending: sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:YES] autorelease];
                                    break;
            
        case SortByArtistDescending:    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:NO] autorelease];
                                        break;
            
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

- (void)playerLoaded
{
    //[_startButton stopActivityIndicator];
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
	StoreSongListCell *tempCell = NULL;
	static NSString *CellIdentifier = @"StoreSongListCell";
    //tempCell = (StoreSongListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (tempCell == nil)
	{
		tempCell = [[[StoreSongListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[[NSBundle mainBundle] loadNibNamed:@"StoreSongListCell" owner:tempCell options:nil];
        
        CGFloat cellHeight = _pullToUpdateSongList.rowHeight-1;
        CGFloat cellRow = _pullToUpdateSongList.frame.size.width;
        
        // Readjust the column headers to match the width
        /*
        [tempCell.titleArtistView setFrame:CGRectMake(0, 0, _titleArtistButton.frame.size.width, cellHeight)];
        [tempCell.skillView setFrame:CGRectMake(_skillButton.frame.origin.x, 0, _skillButton.frame.size.width, cellHeight)];
        [tempCell.scoreView setFrame:CGRectMake(_scoreButton.frame.origin.x, 0, _scoreButton.frame.size.width, cellHeight)];
         */
        
        // Readjust the width and height
        [tempCell setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        [tempCell.accessoryView setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
	}
	
	// Clear these in case this cell was previously selected
	tempCell.highlighted = NO;
	tempCell.selected = NO;
	
	NSInteger row = [indexPath row];
    
    // assign data to cell
    UserSong *userSong = [m_displayedStoreSongArray objectAtIndex:row];
    tempCell.userSong = userSong;
    [tempCell updateCell];
    
	return tempCell;
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
    
        // Save this new array
        /*
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:[NSKeyedArchiver archivedDataWithRootObject:m_storeSongArray] forKey:kStoreSongCacheKey];
        [settings synchronize];
         */
        
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
    }
}

@end
    
