//
//  TitleGatekeeperViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "TitleGatekeeperViewController.h"
#import "RootViewController.h"

@implementation TitleGatekeeperViewController

@synthesize m_videoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        
        // Get the Movie
//        NSString * moviePath = [[NSBundle mainBundle] pathForResource:@"gTar Teaser Final Test" ofType:@"mov"];
        NSString * moviePath = [[NSBundle mainBundle] pathForResource:@"gTar Teaser Final Test 480" ofType:@"m4v"];
        NSURL * movieURL = [NSURL fileURLWithPath:moviePath];
                
        m_moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        
        m_moviePlayer.controlStyle = MPMovieControlStyleDefault;
        m_moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        m_moviePlayer.shouldAutoplay = NO;
        
        
        // Register to receive a notification when the movie has finished playing.  
        [[NSNotificationCenter defaultCenter] addObserver:self  
                                                 selector:@selector(moviePlayBackDidFinish:)  
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:m_moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self  
                                                 selector:@selector(moviePlayerPlaybackStateChanged:)  
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:m_moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self  
                                                 selector:@selector(moviePlayerWillExitFullcreen:)
                                                     name:MPMoviePlayerWillExitFullscreenNotification
                                                   object:m_moviePlayer];
        
    }
    
    return self;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:m_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:m_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerWillExitFullscreenNotification
                                                  object:m_moviePlayer];
    
    [m_videoView release];
    [m_moviePlayer release];
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    UIImage * thumbNail = [m_moviePlayer thumbnailImageAtTime:14 timeOption:MPMovieTimeOptionExact];
    
    [m_videoView setImage:thumbNail forState:UIControlStateNormal];
    
    // Add the player to the main view
    [m_moviePlayer.view setFrame:m_videoView.frame];
    
    [self.view insertSubview:m_moviePlayer.view belowSubview:m_videoView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.m_videoView = nil;
    
}

#pragma mark - View mgmt

//- (void)attachToSuperview:(UIView*)superview
//{    
//    
//    self.view.alpha = 1.0f;
//    
//    [self.view setFrame:superview.frame];
//    
//    [superview addSubview:self.view];
//    
//}


- (IBAction)buyGtarClicked:(id)sender
{
    
    // Show them where they can buy a gtar!
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.incidentgtar.com/"]];
    
}

- (IBAction)loginButtonClicked:(id)sender
{
    
    [m_rootViewController displayLoginDialog];
    
}

- (IBAction)videoButtonClicked:(id)sender
{
    
    [m_moviePlayer setFullscreen:YES animated:YES];
    
    // Play the movie.
    [m_moviePlayer play];
    
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    
    [m_moviePlayer setFullscreen:NO animated:YES];
    
}

- (void)moviePlayerPlaybackStateChanged:(NSNotification *)notification
{
    
//    MPMoviePlaybackState playbackState = m_moviePlayer.playbackState;
//    
//    NSLog(@"State: %u", playbackState);
}

- (void)moviePlayerWillExitFullcreen:(NSNotification *)notification
{
    
    if ( m_moviePlayer.playbackState == MPMoviePlaybackStatePlaying )
    {
        [m_moviePlayer pause];
    }
    
}

@end
