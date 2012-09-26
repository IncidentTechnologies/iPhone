//
//  StoreSongDetailViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreSongDetailViewController.h"
#import "StoreNavigationViewController.h"
#import "UserSong.h"
#import "StoreBuyCreditsPopupViewController.h"

#import <StarRatingView.h>
#import <CloudController.h>
#import <FileController.h>

extern FileController * g_fileController;
extern CloudController * g_cloudController;

@implementation StoreSongDetailViewController

@synthesize m_albumArtView;
@synthesize m_songAuthor;
@synthesize m_songTitle;
@synthesize m_songGenre;
@synthesize m_songDesc;
@synthesize m_starRatingView;
@synthesize m_buyButton;
@synthesize m_confirmButton;
@synthesize m_buyActivityIndicator;
@synthesize m_statusLabel;
@synthesize m_creditsLabel;

@synthesize m_userSong;

@synthesize m_owned;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        
    }
    
    return self;
    
}

- (void)dealloc
{

    [m_albumArtView release];
    [m_songAuthor release];
    [m_songTitle release];
    [m_songGenre release];
    [m_songDesc release];
    [m_buyButton release];
    [m_confirmButton release];
    [m_buyActivityIndicator release];
    [m_statusLabel release];
    [m_creditsLabel release];

    [m_userSong release];
    
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    m_creditsLabel.shadowOffset = CGSizeMake(1, 1);
    m_creditsLabel.shadowColor = [UIColor grayColor];
    
    [self updateCreditCount:m_credits];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_albumArtView = nil;
    self.m_songAuthor = nil;
    self.m_songGenre = nil;
    self.m_songTitle = nil;
    self.m_songDesc = nil;
    self.m_buyButton = nil;
    self.m_confirmButton = nil;
    self.m_buyActivityIndicator = nil;
    self.m_statusLabel = nil;
    self.m_creditsLabel = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [m_songTitle setText:m_userSong.m_title];
    [m_songAuthor setText:m_userSong.m_author];
    [m_songGenre setText:m_userSong.m_genre];
    [m_songDesc setText:m_userSong.m_description];
    
    UIImage * image = [g_fileController getFileOrDownloadSync:m_userSong.m_imgFileId];
    
    if ( image != nil )
    {
        [m_albumArtView setImage:image];
    }

    CGFloat rating = [m_userSong.m_rating floatValue];
    
//    UIColor * fill = [UIColor colorWithRed:4.0/256.0 green:66.0/256.0 blue:115.0/256.0 alpha:1.0];
//    UIColor * fill = [UIColor colorWithRed:0.2 green:0.5 blue:0.7 alpha:1.0];
    UIColor * fill = [UIColor colorWithRed:7.0/256.0 green:124.0/256.0 blue:216.0/256.0 alpha:1.0];

    [m_starRatingView setStrokeColor:[[UIColor blackColor] CGColor] andFillColor:[fill CGColor]];
    [m_starRatingView updateStarRating:rating];

    // make the buy button visible if aplicable
    [m_buyButton setHidden:NO];
    [m_confirmButton setHidden:YES];
    
    if ( m_owned == YES )
    {
        [m_buyButton setEnabled:NO];
    }
    else
    {
        [m_buyButton setEnabled:YES];
    }
    
    [m_statusLabel setHidden:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Button clicked handlers

- (IBAction)buyButtonClicked:(id)sender
{
    
    if ( [m_userSong.m_cost integerValue] > m_credits )
    {
        // if we don't have enough credits, prompt the user
        [(StoreNavigationViewController*)m_navigationController showBuyCreditsView];
    }
    else
    {
        // go ahead with purchase (i.e. confirm)
        [m_confirmButton setHidden:NO];
    }
    
}

- (IBAction)confirmButtonClicked:(id)sender
{

    [self startPurchaseAnimation];
    
    [(StoreNavigationViewController*)m_navigationController buySong:m_userSong];

}

- (IBAction)redeemButtonClicked:(id)sender
{
    
    [(StoreNavigationViewController*)m_navigationController showRedemptionView];

}

- (IBAction)buyCreditsButtonClicked:(id)sender
{
    
    [(StoreNavigationViewController*)m_navigationController showBuyCreditsView];
    
}

#pragma mark - Purchase results

- (void)purchaseSuccessful
{
    
    [m_buyActivityIndicator stopAnimating];
    
    // we own the song so disable the buy button
    [m_buyButton setHidden:NO];
    [m_buyButton setEnabled:NO];
    
    m_owned = YES;
    
}

- (void)purchaseFailed:(NSString*)error
{
    
    [m_buyActivityIndicator stopAnimating];
    
    [m_buyButton setHidden:NO];
    [m_buyButton setEnabled:YES];
    
    [m_statusLabel setText:error];
    [m_statusLabel setHidden:NO];
    
}

#pragma mark - Animations

- (void)startPurchaseAnimation
{
    
    [m_buyActivityIndicator startAnimating];
    
    [m_buyButton setHidden:YES];
    [m_confirmButton setHidden:YES];
    [m_statusLabel setHidden:YES];

}

- (void)updateCreditCount:(NSInteger)credits
{
    
    m_credits = credits;
    
    if ( credits == 1 )
    {
//        [m_creditsLabel setHidden:YES];
        
        NSString * str = [NSString stringWithFormat:@"1 credit remaining"];
        
        [m_creditsLabel setText:str];
    }
    else if ( credits > 1 )
    {
//        [m_creditsLabel setHidden:YES];
        
        NSString * str = [NSString stringWithFormat:@"%u credits remaining", credits];
        
        [m_creditsLabel setText:str];
    }
    else
    {
//        [m_creditsLabel setHidden:YES];
        
        NSString * str = [NSString stringWithFormat:@"No credits remaining"];
        
        [m_creditsLabel setText:str];
    }
    
}

@end
