//
//  AmpViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/10/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "AmpViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import <gTarAppCore/StarRatingView.h>
#import <gTarAppCore/NSScoreTracker.h>
#import <gTarAppCore/FullScreenActivityView.h>

#import "PlayLcdScoreView.h"
#import "PlayLcdMultView.h"
#import "FillGaugeView.h"
#import "LedActivityIndicator.h"

@implementation AmpViewController

@synthesize m_delegate;
@synthesize m_songTitle;
@synthesize m_songArtist;
@synthesize m_scoreTracker;
@synthesize m_lcdScoreView;
@synthesize m_lcdMultView;
@synthesize m_fillGaugeView;
@synthesize m_ledIndicatorView;
@synthesize m_contentView;
@synthesize m_menuView;
@synthesize m_scoreView;
@synthesize m_volumeView;
@synthesize m_audioButton;
@synthesize m_metronomeButton;
@synthesize m_shareButton;
@synthesize m_menuButton;
@synthesize m_shareFailedLabel;
@synthesize m_songTitleScoreLabel;
@synthesize m_songArtistScoreLabel;
@synthesize m_songTitleMenuLabel;
@synthesize m_songArtistMenuLabel;
@synthesize m_scoreLabel;
@synthesize m_songSharedLabel;
@synthesize m_starRatingView;
@synthesize m_volumeSlider;

#define AMP_HEIGHT (85.0)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    [StarRatingView class];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_songTitle release];
    [m_songArtist release];
    [m_scoreTracker release];
    [m_lcdScoreView release];
    [m_lcdMultView release];
    [m_fillGaugeView release];
    [m_ledIndicatorView release];
    [m_contentView release];
    [m_menuView release];
    [m_scoreView release];
    [m_volumeView release];
    [m_audioButton release];
    [m_metronomeButton release];
    [m_shareButton release];
    [m_menuButton release];
    [m_customActivityView release];
    [m_shareFailedLabel release];
    [m_songTitleScoreLabel release];
    [m_songArtistScoreLabel release];
    [m_songTitleMenuLabel release];
    [m_songArtistMenuLabel release];
    [m_scoreLabel release];
    [m_songSharedLabel release];
    [m_starRatingView release];
    
    [m_volumeSlider release];
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
    
    [m_menuView setBackgroundColor:[UIColor clearColor]];
    [m_scoreView setBackgroundColor:[UIColor clearColor]];
    
    //
    // Connect the volume view
    //
    [m_volumeView setBackgroundColor:[UIColor clearColor]];

    //
    // Set the volume slider images
    //
    MPVolumeView * volumeView = [[MPVolumeView alloc] initWithFrame:m_volumeView.bounds];
    
    NSArray * subViews = volumeView.subviews;
    
    UIImage * sliderTrackMinImage = [[UIImage imageNamed: @"SliderEndMin.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:0];
    UIImage * sliderTrackMaxImage = [[UIImage imageNamed: @"SliderEndMax.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImage * sliderKnob = [UIImage imageNamed:@"VolumeSliderRev.png"];
    
    for (id current in subViews)
    {
        if ([current isKindOfClass:[UISlider class]])
        {
            
            UISlider * slider = (UISlider*) current;
            
            [slider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
            [slider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
            [slider setThumbImage:sliderKnob forState:UIControlStateNormal];
        }
    }
    
    [volumeView sizeToFit];
    [volumeView setShowsRouteButton:NO];
    [m_volumeView addSubview:volumeView];
    [volumeView release];
    
    [m_volumeSlider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
    [m_volumeSlider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
    [m_volumeSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
        
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_lcdScoreView = nil;
    self.m_lcdMultView = nil;
    self.m_fillGaugeView = nil;
    self.m_ledIndicatorView = nil;
    self.m_contentView = nil;
    self.m_menuView = nil;
    self.m_scoreView = nil;
    self.m_volumeView = nil;
    self.m_audioButton = nil;
    self.m_metronomeButton = nil;
    self.m_shareButton = nil;
    self.m_menuButton = nil;
    self.m_shareFailedLabel = nil;
    self.m_songTitleMenuLabel = nil;
    self.m_songArtistScoreLabel = nil;
    self.m_songTitleScoreLabel = nil;
    self.m_songArtistMenuLabel = nil;
    self.m_scoreLabel = nil;
    self.m_songSharedLabel = nil;
    self.m_starRatingView = nil;
    self.m_volumeSlider = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Animation and view stuff

- (void)attachToSuperview:(UIView*)superview
{
    
    self.view.center = superview.center;
    
    CGRect fr = CGRectMake( self.view.frame.origin.x, superview.frame.size.height - AMP_HEIGHT,
                           self.view.frame.size.width, self.view.frame.size.height );
    
    [self.view setFrame:fr];
    
    [superview addSubview:self.view];
    
    if ( m_customActivityView == nil )
    {
        m_customActivityView = [[FullScreenActivityView alloc] initWithFrame:self.view.bounds];
        
        [superview addSubview:m_customActivityView];
        
        [m_customActivityView setHidden:YES];
    }
    
}

- (void)updateView
{
    
    [m_lcdScoreView setDigitsValue:m_scoreTracker.m_score];

    [m_lcdMultView setDigitsValue:m_scoreTracker.m_multiplier];
    
    if ( m_scoreTracker.m_multiplier == 4 )
    {
        [m_fillGaugeView setLevelToMax];
    }
    else
    {
        [m_fillGaugeView setLevelWithRollover:m_scoreTracker.m_streak];
    }

}

- (void)resetView
{
    [m_lcdScoreView initDigits];
    [m_lcdScoreView clearDigits];
    
    [m_fillGaugeView resetLevel];
    
    [m_lcdMultView initDigits];
    [m_lcdMultView clearDigits];
    
    [m_songSharedLabel setHidden:YES];
    [m_shareFailedLabel setHidden:YES];
    
    [m_menuButton setEnabled:YES];
    
}

- (void)slideViewUp
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];

    self.view.transform = CGAffineTransformMakeTranslation( 0, -(self.view.frame.size.height - AMP_HEIGHT) );
    
    [UIView commitAnimations];

}

- (void)slideViewDown
{

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    self.view.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];

}

- (void)flickerIndicator
{
    
    [m_ledIndicatorView flickerLed];
    
}

- (void)displayScore
{
    
    NSNumberFormatter * numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString * numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:m_scoreTracker.m_score]];
    
    [m_scoreLabel setText:numberAsString];
    
    [m_songTitleScoreLabel setText:m_songTitle];
    [m_songArtistScoreLabel setText:m_songArtist];
    
    [m_contentView addSubview:m_scoreView];
    
    // star
//    UIColor * fill = [UIColor colorWithRed:7.0/256.0 green:124.0/256.0 blue:216.0/256.0 alpha:1.0];
    UIColor * fill = [UIColor yellowColor];
    
    [m_starRatingView setStrokeColor:[[UIColor blackColor] CGColor] andFillColor:[fill CGColor]];
    [m_starRatingView updateStarRating:m_scoreTracker.m_stars];
    
    [m_contentView addSubview:m_scoreView];
    
    [self slideViewUp];
    
    m_isUp = YES;
    m_isScoreDisplayed = YES;
    
    [m_menuButton setEnabled:NO];
    
}

- (void)shareStarted
{
    
    [m_customActivityView setHidden:NO];
    
}

- (void)shareFailed
{
    
    [m_customActivityView setHidden:YES];

    [m_shareFailedLabel setHidden:NO];
    
//    [m_shareButton setHidden:YES];
    
}

- (void)shareSucceeded
{
    
    [m_shareButton setEnabled:NO];
    
    [m_shareButton setHighlighted:YES];
    
    [m_customActivityView setHidden:YES];
    
    [m_songSharedLabel setHidden:NO];

}

#pragma mark - Button clicked handlers

- (IBAction)menuButtonClicked:(id)sender
{
    
    if ( m_isScoreDisplayed == YES )
    {
        // disregarded continue button if score is displayed
        return;
    }
    
    if ( m_isUp == YES )
    {
        [self continueButtonClicked:sender];
//        [m_menuButton setSelected:NO];
        return;
    }
    
//    [m_menuButton setSelected:YES];
    
    [m_delegate menuButtonClicked];
    
    [m_songTitleMenuLabel setText:m_songTitle];
    [m_songArtistMenuLabel setText:m_songArtist];
    
    [m_contentView addSubview:m_menuView];
    
    [self slideViewUp];
    
    m_isUp = YES;
    
}

- (IBAction)backButtonClicked:(id)sender
{
    
    [m_delegate backButtonClicked];
    
    [m_menuView removeFromSuperview];
    [m_scoreView removeFromSuperview];
    
}

- (IBAction)abortButtonClicked:(id)sender
{
    
    [m_delegate abortButtonClicked];
    
    [m_menuView removeFromSuperview];
    [m_scoreView removeFromSuperview];
    
}

- (IBAction)restartButtonClicked:(id)sender
{
    
    [m_delegate restartButtonClicked];
    
    [m_menuView removeFromSuperview];
    [m_scoreView removeFromSuperview];
    
    [m_shareButton setEnabled:YES];
    [m_shareButton setHighlighted:NO];
    
    [m_menuButton setEnabled:YES];
    
    [self slideViewDown];
    
    m_isUp = NO;
    m_isScoreDisplayed = NO;
    
}

- (IBAction)continueButtonClicked:(id)sender
{
    
    [m_delegate continueButtonClicked];
    
    [m_menuView removeFromSuperview];
    [m_scoreView removeFromSuperview];
    
    [self slideViewDown];
    
    m_isUp = NO;
    
}

- (IBAction)shareButtonClicked:(id)sender
{
    
    [self shareStarted];
    
    [m_delegate shareButtonClicked];
    
}

- (IBAction)audioButtonClicked:(id)sender
{
    [m_delegate toggleAudioRoute];
}

- (IBAction)metronomeButtonClicked:(id)sender
{
    
    if ( m_metronomeButton.isSelected == YES )
    {
        [m_metronomeButton setSelected:NO];
    }
    else
    {
        [m_metronomeButton setSelected:YES];
    }
    
    [m_delegate toggleMetronome];
    
}

- (IBAction)setVolumeGain:(id)sender
{
    [m_delegate setVolumeGain:[m_volumeSlider value]];
}

- (void)enableSpeaker
{
    [m_audioButton setSelected:NO];
}

- (void)disableSpeaker
{
    [m_audioButton setSelected:YES];
}

@end
