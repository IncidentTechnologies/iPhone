//
//  SelectSongDetailViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/22/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SelectSongDetailViewController.h"

#import "SelectNavigationViewController.h"

#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/StarRatingView.h>

extern FileController * g_fileController;
extern CloudController * g_cloudController;

@implementation SelectSongDetailViewController

@synthesize m_albumArtView;
@synthesize m_songAuthor;
@synthesize m_songTitle;
@synthesize m_songGenre;
@synthesize m_songScore;
@synthesize m_songDesc;
@synthesize m_starRatingView;
@synthesize m_backButton;

@synthesize m_userSong;
@synthesize m_songXmpBlob;

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
    [m_songScore release];
    [m_songDesc release];
    [m_backButton release];

    [m_userSong release];
    [m_songXmpBlob release];

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
    
//    [m_backButton setImage:[UIImage imageNamed:@"BackButtonArrow.png"] forState:UIControlStateNormal];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_albumArtView = nil;
    self.m_songAuthor = nil;
    self.m_songGenre = nil;
    self.m_songScore = nil;
    self.m_songTitle = nil;
    self.m_songDesc = nil;
    self.m_backButton = nil;

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
    
    CGFloat stars = m_userSong.m_playStars;
    
    //    UIColor * fill = [UIColor colorWithRed:4.0/256.0 green:66.0/256.0 blue:115.0/256.0 alpha:1.0];
    //    UIColor * fill = [UIColor colorWithRed:0.2 green:0.5 blue:0.7 alpha:1.0];
    UIColor * fill = [UIColor colorWithRed:7.0/256.0 green:124.0/256.0 blue:216.0/256.0 alpha:1.0];
    
    [m_starRatingView setStrokeColor:[[UIColor blackColor] CGColor] andFillColor:[fill CGColor]];
    [m_starRatingView updateStarRating:stars];
    
    NSInteger score = m_userSong.m_playScore;
    
    [m_songScore setText:[NSString stringWithFormat:@"%u", score]];

}

- (IBAction)playButtonClicked:(id)sender
{
    
    [(SelectNavigationViewController*)m_navigationController showSongOptions:m_userSong];

}

@end
