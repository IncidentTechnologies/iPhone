//
//  AmpViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/10/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AmpViewDelegate <NSObject>

- (void)menuButtonClicked;
- (void)backButtonClicked;
- (void)restartButtonClicked;
- (void)continueButtonClicked;
- (void)shareButtonClicked;

- (void)toggleAudioRoute;
- (void)toggleMetronome;

- (void)setVolumeGain:(float)gain;

@end

@class NSScoreTracker;
@class PlayLcdScoreView;
@class PlayLcdMultView;
@class FillGaugeView;
@class LedActivityIndicator;
@class StarRatingView;
@class FullScreenActivityView;

@interface AmpViewController : UIViewController
{
    
    id<AmpViewDelegate> m_delegate;

    NSString * m_songTitle;
    NSString * m_songArtist;
    
    NSScoreTracker * m_scoreTracker;
    
    IBOutlet PlayLcdScoreView * m_lcdScoreView;
    IBOutlet PlayLcdMultView * m_lcdMultView;
    IBOutlet FillGaugeView * m_fillGaugeView;
    IBOutlet LedActivityIndicator * m_ledIndicatorView;
    
    IBOutlet UIView * m_contentView;
    IBOutlet UIView * m_menuView;
    IBOutlet UIView * m_scoreView;

    IBOutlet UIView * m_volumeView;
    IBOutlet UIButton * m_audioButton;
    IBOutlet UIButton * m_shareButton;
    IBOutlet UIButton * m_menuButton;
    
    FullScreenActivityView * m_customActivityView;
    
    IBOutlet UILabel * m_shareFailedLabel;
    
    IBOutlet UILabel * m_songTitleScoreLabel;
    IBOutlet UILabel * m_songArtistScoreLabel;
    IBOutlet UILabel * m_songTitleMenuLabel;
    IBOutlet UILabel * m_songArtistMenuLabel;
    IBOutlet UILabel * m_scoreLabel;
    IBOutlet UILabel * m_songSharedLabel;
    IBOutlet StarRatingView * m_starRatingView;

    BOOL m_isUp;
    BOOL m_isScoreDisplayed;

}

@property (nonatomic, assign) id<AmpViewDelegate> m_delegate;

@property (nonatomic, retain) NSString * m_songTitle;
@property (nonatomic, retain) NSString * m_songArtist;
@property (nonatomic, retain) NSScoreTracker * m_scoreTracker;
@property (nonatomic, retain) IBOutlet PlayLcdScoreView * m_lcdScoreView;
@property (nonatomic, retain) IBOutlet PlayLcdMultView * m_lcdMultView;
@property (nonatomic, retain) IBOutlet FillGaugeView * m_fillGaugeView;
@property (nonatomic, retain) IBOutlet LedActivityIndicator * m_ledIndicatorView;

@property (nonatomic, retain) IBOutlet UIView * m_contentView;
@property (nonatomic, retain) IBOutlet UIView * m_menuView;
@property (nonatomic, retain) IBOutlet UIView * m_scoreView;

@property (nonatomic, retain) IBOutlet UIView * m_volumeView;
@property (nonatomic, retain) IBOutlet UIButton * m_audioButton;
@property (nonatomic, retain) IBOutlet UIButton * m_metronomeButton;
@property (nonatomic, retain) IBOutlet UIButton * m_shareButton;
@property (nonatomic, retain) IBOutlet UIButton * m_menuButton;

@property (nonatomic, retain) IBOutlet UILabel * m_shareFailedLabel;


@property (nonatomic, retain) IBOutlet UILabel * m_songTitleScoreLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_songArtistScoreLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_songTitleMenuLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_songArtistMenuLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_songSharedLabel;
@property (nonatomic, retain) IBOutlet StarRatingView * m_starRatingView;

@property (retain, nonatomic) IBOutlet UISlider * m_volumeSlider;


- (void)attachToSuperview:(UIView*)superview;
- (void)updateView;
- (void)resetView;
- (void)slideViewUp;
- (void)slideViewDown;
- (void)flickerIndicator;
- (void)displayScore;
- (void)shareStarted;
- (void)shareFailed;
- (void)shareSucceeded;

- (IBAction)menuButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)restartButtonClicked:(id)sender;
- (IBAction)continueButtonClicked:(id)sender;
- (IBAction)shareButtonClicked:(id)sender;
- (IBAction)audioButtonClicked:(id)sender;
- (IBAction)metronomeButtonClicked:(id)sender;
- (IBAction)setVolumeGain:(id)sender;
- (void)enableSpeaker;
- (void)disableSpeaker;

@end
