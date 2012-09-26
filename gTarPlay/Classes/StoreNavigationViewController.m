//
//  StoreNavigationViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreNavigationViewController.h"

#import "StoreFeaturedViewController.h"
#import "StoreFeaturedGenreViewController.h"
#import "StoreListViewController.h"
#import "StoreTopTenViewController.h"
#import "StoreSongDetailViewController.h"
#import "StoreSearchViewController.h"
#import "StorePurchaseViewController.h"
#import "StoreFeatureCollection.h"
#import "StoreGenreCollection.h"
#import "StoreRedemptionViewController.h"
#import "StoreBuyCreditsPopupViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <StoreController.h>
#import <CloudController.h>
#import <FileController.h>
#import <UserSong.h>
#import <UserSongs.h>
#import <StarRatingView.h>

extern CloudController * g_cloudController;
extern FileController * g_fileController;

@implementation StoreNavigationViewController

@synthesize m_shortcutUserSong;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    // I wish there was a better way to force linking
    [StarRatingView class];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {

        // Custom initialization 
        m_title = @"Store";
        
        m_storeController = [[StoreController alloc] initWithCloudController:g_cloudController andDelegate:self];
        
        m_creditsPopupViewController = [[StoreBuyCreditsPopupViewController alloc] initWithNibName:nil bundle:nil];
        m_creditsPopupViewController.m_navigationController = self;
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    m_storeController.m_delegate = nil;
    
    [m_storeController release];
    
    [m_featuredViewController release];
    [m_featuredGenreViewController release];
    [m_listViewController release];
    [m_topTenViewController release];
    [m_songDetailViewController release];
    [m_searchViewController release];
    [m_redemptionViewController release];
    [m_creditsPopupViewController release];
    
    [m_shortcutUserSong release];
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [m_homeButton setHidden:NO];

    // Spin up the spinner
    [m_activityIndicatorView startAnimating];
    
    // darken the screen button
    m_fullScreenButton.backgroundColor = [UIColor blackColor];
    m_fullScreenButton.alpha = 0.5f;
    
    UIActivityIndicatorView * act = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    act.center = m_fullScreenButton.center;
    [act startAnimating];
    
    [m_fullScreenButton addSubview:act];
    
    //
    // Create the sub view controllers
    //
    
    m_featuredViewController = [[StoreFeaturedViewController alloc] initWithNibName:nil bundle:nil];
    m_featuredGenreViewController = [[StoreFeaturedGenreViewController alloc] initWithNibName:nil bundle:nil];
    m_listViewController = [[StoreListViewController alloc] initWithNibName:nil bundle:nil];
    m_topTenViewController = [[StoreTopTenViewController alloc] initWithNibName:nil bundle:nil];
    m_songDetailViewController = [[StoreSongDetailViewController alloc] initWithNibName:nil bundle:nil];
    m_searchViewController = [[StoreSearchViewController alloc] initWithNibName:nil bundle:nil];
    m_redemptionViewController = [[StoreRedemptionViewController alloc] initWithNibName:nil bundle:nil];
    
    [m_storeController requestUserCredits];
    
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
    
    if ( m_shortcutUserSong != nil )
    {
        [self showUserSongDetail:m_shortcutUserSong];
        self.m_shortcutUserSong = nil;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
 
    // save our content, primarily the imgs in this context
//    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
//    
//    [settings setObject:[NSKeyedArchiver archivedDataWithRootObject:g_fileController] forKey:@"FileController"];
//    
//    [settings synchronize];

    [super viewWillDisappear:animated];
    
}

#pragma mark - Click handler

- (IBAction)homeButtonClicked:(id)sender
{

    // hide the search box if its open
    [self contractSearchBar];
    
    m_featuredViewController.m_previousViewController = m_currentViewController;

    [self switchInViewController:m_featuredViewController];

}

- (IBAction)notifyButtonClicked:(id)sender
{
    
    [self retryPurchase];
    
}

- (IBAction)fullScreenButtonClicked:(id)sender
{

    // derp do nothing ... for now at least
    
    // This also catches any interaction so the user doesn't e.g. push buttons

}

#pragma mark - Animation helpers

- (void)switchInViewController:(CustomViewController*)viewController
{

    if ( viewController == nil )
    {
        viewController = m_featuredViewController;
    }
    
    [super switchInViewController:viewController];

}

- (void)showUserSongDetail:(UserSong*)userSong
{
    
    // If there is another song (or the same song) being displayed, swap it out
    if ( m_currentViewController == m_songDetailViewController )
    {
        if ( m_songDetailViewController.m_userSong == userSong )
        {
            // we are already showing the song we want, return
            return;
        }
        else
        {
            [self clearViewController];
        }
    }
    
    m_songDetailViewController.m_userSong = userSong;
    
    // don't get stuck in a loop, that would be silly.
    if ( m_songDetailViewController.m_previousViewController != m_currentViewController )
    {
        m_songDetailViewController.m_previousViewController = m_currentViewController;
    }
    
    m_songDetailViewController.m_owned = [m_storeController ownUserSong:userSong];
    
    [self switchInViewController:m_songDetailViewController];
    
}

- (void)showSubcategory:(StoreGenreCollection*)genreCollection
{
    
    m_featuredGenreViewController.m_featuredGenreCollection = genreCollection;
    
    m_featuredViewController.m_previousViewController = m_currentViewController;
    
    [self switchInViewController:m_featuredGenreViewController];
    
}

- (void)showFullList:(StoreGenreCollection*)genreCollection
{
    
    m_listViewController.m_genreName = genreCollection.m_genreName;
    m_listViewController.m_userSongList = genreCollection.m_allUserSongs;
    
    m_listViewController.m_previousViewController = m_currentViewController;
    
    [self switchInViewController:m_listViewController];
    
}

- (void)showRedemptionView
{
    
    m_redemptionViewController.m_previousViewController = m_currentViewController;
    
    [self switchInViewController:m_redemptionViewController];

}

- (void)showBuyCreditsView
{
    
    [m_creditsPopupViewController attachToSuperViewWithBlackBackground:self.view];
    
}

#pragma mark - Store delegate

- (void)creditPurchaseResumed:(UserSong*)userSong
{
    
    [m_fullScreenButton setHidden:NO];
    
    [self clearViewController];
    
    [self showUserSongDetail:userSong];
    
    [m_songDetailViewController startPurchaseAnimation];
    [m_creditsPopupViewController startPurchaseAnimation];

}

- (void)creditPurchaseFailed:(NSString*)reason
{
    
    [m_fullScreenButton setHidden:YES];

    [m_songDetailViewController purchaseFailed:reason];
    [m_creditsPopupViewController purchaseFailed:reason];
    
}

- (void)creditPurchaseCanceled:(NSString*)reason
{
    
    [m_fullScreenButton setHidden:YES];
    
    [m_songDetailViewController purchaseFailed:reason];
    [m_creditsPopupViewController purchaseFailed:reason];
    
}

- (void)creditPurchasePending:(NSString*)reason
{
    
    [m_fullScreenButton setHidden:YES];
    [m_notifyButton setHidden:NO];

    [m_songDetailViewController purchaseFailed:reason];
    [m_creditsPopupViewController purchaseFailed:reason];
    
}

- (void)creditPurchaseSucceeded:(NSString*)reason
{
    
    // In the background we already start the credit redemption 
    // process for the requested song, so nothing to update here.
    
//    [m_fullScreenButton setHidden:YES];
//    
//    [m_songDetailViewController purchaseSuccessful];
    [m_storeController requestUserCredits];
    [m_creditsPopupViewController purchaseSuccessful];
    
}


- (void)songPurchaseResumed:(UserSong*)userSong
{
    
    [m_fullScreenButton setHidden:NO];
    
    [self clearViewController];
    
    [self showUserSongDetail:userSong];
    
    [m_songDetailViewController startPurchaseAnimation];
    
}

- (void)songPurchaseFailed:(NSString*)reason
{
    
    [m_fullScreenButton setHidden:YES];
    
    [m_songDetailViewController purchaseFailed:reason];
    
}

- (void)songPurchaseCanceled:(NSString*)reason
{
    
    [m_fullScreenButton setHidden:YES];
    
    [m_songDetailViewController purchaseFailed:reason];
    
}

- (void)songPurchasePending:(NSString*)reason
{
    
    [m_fullScreenButton setHidden:YES];
    [m_notifyButton setHidden:NO];
    
    [m_songDetailViewController purchaseFailed:reason];
    
}

- (void)songPurchaseSucceeded:(NSString*)reason
{
    
    [m_fullScreenButton setHidden:YES];

    [m_songDetailViewController purchaseSuccessful];
    
}

- (void)creditCountUpdated:(NSNumber*)creditCount
{
    // change the $$ credits to integer credits.
    // add a little bit to bump up to the next integer in case of precision erros.
    NSInteger credits = ([creditCount floatValue] / 0.99) + 0.1f;
    
    [m_songDetailViewController updateCreditCount:credits];
    
}

- (void)requestSongListComplete
{
    
    // This gives us a chance to cache the pics
    
    for ( UserSong * userSong in [m_storeController.m_allSongs allValues] )
    {
        [g_fileController precacheFile:userSong.m_imgFileId];
    }
    
}

- (void)requestFeaturedSongListComplete
{

    [m_activityIndicatorView stopAnimating];
    
    m_featuredViewController.m_featureCollection = m_storeController.m_featureCollection;
    
    // if something is pending, we need to take care of that before displaying the features
    // if the user preempts the request response to search, that is ok too.
    if ( m_currentViewController == nil )
    {
        [self switchInViewController:m_featuredViewController];
    }
    
}


//- (void)purchaseFailed:(NSString*)reason
//{
////    [m_purchaseViewController purchaseFailed:reason];
//    [m_songDetailViewController purchaseFailed:reason];
//}
//
//- (void)purchaseSucceed
//{
////    [m_purchaseViewController purchaseSuccessful];
//    [m_songDetailViewController purchaseSuccessful];
//}
//
//- (void)purchasePending:(NSString*)reason
//{
////    [m_purchaseViewController purchasePending:reason];
//    [m_songDetailViewController purchaseFailed:reason];
//}
//
//- (void)purchaseCanceled
//{
////    [self returnToPreviousViewController:m_currentSubviewController];
//    [m_songDetailViewController purchaseFailed:@"User canceled!"];
//}

- (void)userLoggedOut
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)beginSearch
{
    // switch over to the search view 
    m_searchViewController.m_previousViewController = m_currentViewController;
    
    [self switchInViewController:m_searchViewController];
    
}

- (void)cancelSearch
{
    
    // return back to the previous controller
    [self returnToPreviousViewController:m_searchViewController];
    
}

- (void)searchForString:(NSString*)searchString
{
    
    // inform the search controller that we have something worth searching for
//    [m_searchViewController startIndicator];
        
    // search for this string
    
    NSDictionary * songDictionary = m_storeController.m_allSongs;
    
    NSArray * songArray = [songDictionary allValues];
    
    NSMutableArray * searchResults = [[NSMutableArray alloc] init];
    
    for ( UserSong * userSong in songArray )
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
    
    [m_searchViewController displayResults:searchResults];
    
    if ( m_currentViewController == m_searchViewController )
    {
        [self clearViewController];
    }
    
    [self switchInViewController:m_searchViewController];
    
}

- (void)redemptionSucceeded
{
    
    [m_redemptionViewController redeemSucceeded];
    
}

- (void)redemptionFailed:(NSString*)reason
{
    
    [m_redemptionViewController redeemFailed:reason];
    
}


#pragma mark - Misc

- (void)buyCreditsA
{
    [m_creditsPopupViewController startPurchaseAnimation];
    [m_storeController buyCredits1];
}

- (void)buyCreditsB
{
    [m_creditsPopupViewController startPurchaseAnimation];
    [m_storeController buyCredits11];
}

- (void)buyCreditsC
{
    [m_creditsPopupViewController startPurchaseAnimation];
    [m_storeController buyCredits24];
}

- (void)buySong:(UserSong*)userSong
{

    // This disables all the other buttons on the screen untill we want to resign.
    [m_fullScreenButton setHidden:NO];
    
    // switch to this song so we can finish the purchase
    [self showUserSongDetail:userSong];
    
    [m_songDetailViewController startPurchaseAnimation];    

    [m_storeController buySong:userSong];

}

- (void)retryPurchase
{
    
    [m_notifyButton setHidden:YES];

    [m_storeController retryPurchase];

}

//- (void)cancelPurchase
//{
//    [m_storeController cancelPurchase];
//}

- (void)redeemCreditCode:(NSString*)creditCode
{
    
    [m_storeController redeemCreditCode:creditCode];    
    
}

@end
