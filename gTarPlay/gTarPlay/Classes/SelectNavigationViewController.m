//
//  SelectNavigationViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SelectNavigationViewController.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongs.h>
#import <gTarAppCore/XmlDom.h>
#import <gTarAppCore/SongPlaybackController.h>

#import "SelectListViewController.h"
#import "SelectSongDetailViewController.h"
#import "SelectSongOptionsPopupViewController.h"
#import "SongViewController.h"
#import "PullToUpdateTableView.h"

extern FileController * g_fileController;
extern CloudController * g_cloudController;
extern AudioController * g_audioController;

@implementation SelectNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        m_title = @"Song List";
        
        m_selectListViewController = [[SelectListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
        m_selectSearchViewController = [[SelectListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
        
        m_popupOptionsViewController = [[SelectSongOptionsPopupViewController alloc] initWithNibName:nil bundle:nil];
        
        m_playbackController = [[SongPlaybackController alloc] initWithAudioController:g_audioController];
        
        // See if we have any cached songs from previous runs
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        NSData * songArrayData = [settings objectForKey:@"UserSongArray"];
        
        if ( songArrayData == nil )
        {
            // If we don't have any cache data, just use the preload
            NSString * filePath = [[NSBundle mainBundle] pathForResource:@"UserSongsList" ofType:@"xml"];
            NSString * xmlBlob = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
            
            XmlDom * dom = [[XmlDom alloc] initWithXmlString:xmlBlob];
            
            UserSongs * userSongs = [[UserSongs alloc] initWithXmlDom:dom];
            
            m_userSongArray = [userSongs.m_songsArray retain];
            
            [dom release];
            
            [userSongs release];
            
            // If we still have nothing, use an empty array
            if ( m_userSongArray == nil )
            {
                m_userSongArray = [[NSArray alloc] init];
            }
            
        }
        else
        {
            // If we have cached data, use that. Note 
            m_userSongArray = [[NSKeyedUnarchiver unarchiveObjectWithData:songArrayData] retain];
        }

    }
    
    return self;
}

- (void)dealloc
{
    
    [m_userSongArray release];
//    [m_preloadedUserSongArray release];
    
    [m_selectListViewController release];
    [m_selectSearchViewController release];
    
    [m_popupOptionsViewController release];
    [m_playbackController release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Display the selection vc
    [self switchInViewController:m_selectListViewController];
        
    // If we recovered some cached song info, show it now
    if ( [m_userSongArray count] > 0 )
    {
        m_selectListViewController.m_userSongArray = m_userSongArray;
        
        // Two files for each some (xmp and img)
        m_outStandingFileDownloads += ([m_userSongArray count] * 2);
        
        // download the images if they aren't here yet.
        for ( UserSong * userSong in m_userSongArray )
        {
            [g_fileController getFileOrDownloadAsync:userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
            [g_fileController getFileOrDownloadAsync:userSong.m_xmpFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
        }
        
    }
    
    // get the current song list.
    [self refreshSongList];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [m_selectListViewController refreshDisplay];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
}

- (void)fileDownloadFinished:(id)file
{
    
    m_outStandingFileDownloads--;
    
    if ( m_outStandingFileDownloads == 0 )
    {
        // Reload the table
        [m_selectListViewController.m_tableView stopAnimating];
        [m_selectListViewController refreshDisplay];
    }
    
}

#pragma mark - ViewController stuff

- (void)showSongOptions:(UserSong*)userSong
{
    
    m_popupOptionsViewController.m_userSong = userSong;
    m_popupOptionsViewController.m_navigationController = self;
    
    [m_popupOptionsViewController attachToSuperViewWithBlackBackground:self.view];
    
}

- (void)startSongInstance:(SongViewController*)songViewController
{
    
    // Get the XMP, stick it in the user song, and push to the game mode
    NSString * songString = (NSString*)[g_fileController getFileOrDownloadSync:songViewController.m_userSong.m_xmpFileId];
    
    songViewController.m_userSong.m_xmlDom = [[[XmlDom alloc] initWithXmlString:songString] autorelease];
    
    [self.navigationController pushViewController:songViewController animated:YES];
    
}

- (void)previewUserSong:(UserSong*)userSong
{
    
    // Get the XMP, stick it in the user song, and push to the game mode
    NSString * songString = (NSString*)[g_fileController getFileOrDownloadSync:userSong.m_xmpFileId];
    
//    userSong.m_xmlDom = [[[XmlDom alloc] initWithXmlString:songString] autorelease];
    
    [m_playbackController startWithXmpBlob:songString];
    
}

- (void)stopPreview
{
    
    [m_playbackController pauseSong];
    
}

#pragma mark - CloudController callbacks

- (void)refreshSongList
{
    [m_selectListViewController.m_tableView startAnimating];
    
	[g_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];
}

- (void)requestSongListCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // refresh table data
        UserSongs * userSongs = cloudResponse.m_responseUserSongs;
        
        [m_userSongArray release];
        
        m_userSongArray = [userSongs.m_songsArray retain];
                
        m_selectListViewController.m_userSongArray = m_userSongArray;
        
        // Two files for each some (xmp and img)
        m_outStandingFileDownloads += ([m_userSongArray count] * 2);

        // Download everything
        for ( UserSong * userSong in m_userSongArray )
        {
            [g_fileController getFileOrDownloadAsync:userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
            [g_fileController getFileOrDownloadAsync:userSong.m_xmpFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
        }
        
        if ( m_currentViewController == nil )
        {
            [self switchInViewController:m_selectListViewController];
        }
        
        // save this new array
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        [settings setObject:[NSKeyedArchiver archivedDataWithRootObject:m_userSongArray] forKey:@"UserSongArray"];
        
        [settings synchronize];
        
    }
    else
    {
        [m_selectListViewController.m_tableView stopAnimating];
        
        [self backButtonClicked:nil];
    }
    
}

#pragma mark - Custom Nav controller Search handling

- (void)beginSearch
{
    
    [self switchInViewController:m_selectSearchViewController];
    
}

- (void)cancelSearch
{
    
    [self switchInViewController:m_selectListViewController];
    
}

- (void)searchForString:(NSString*)searchString
{
    
    // search for this string
    
    NSMutableArray * searchResults = [[NSMutableArray alloc] init];
    
    for ( UserSong * userSong in m_userSongArray )
    {
        
        NSString * candidateString;
        
        candidateString = userSong.m_title;
        
        if ( candidateString != nil && [candidateString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound )
        {
            [searchResults addObject:userSong];
            continue;
        }
        
        candidateString = userSong.m_author;
        
        if ( candidateString != nil && [candidateString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound )
        {
            [searchResults addObject:userSong];
            continue;
        }
        
        candidateString = userSong.m_genre;
        
        if ( candidateString != nil && [candidateString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound )
        {
            [searchResults addObject:userSong];
            continue;
        }
        
//        candidateString = userSong.m_description;
//        
//        if ( [candidateString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound )
//        {
//            [searchResults addObject:userSong];
//            continue;
//        }
    
    }

    m_selectSearchViewController.m_userSongArray = searchResults;
    
    if ( m_currentViewController == m_selectSearchViewController )
    {
        [self clearViewController];
    }
    
    [self switchInViewController:m_selectSearchViewController];
    
}

@end
