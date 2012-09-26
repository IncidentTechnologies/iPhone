//
//  JamController.h
//  gTar
//
//  Created by Marty Greenia on 1/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "ExperienceController.h"
#import "CSong.h"
#import "SongCreator.h"
#import "SongParser.h"
#import "SongRecorder.h"
#import "SongModel.h"
#import "SongMerger.h"
#import "JamPad.h"
#import "JamIntranetMultiplayerServer.h"
#import "JamIntranetMultiplayerClient.h"

#define JAM_CACHE_SIZE 10

enum JamControllerMultiplayerMode
{
	JamControllerMultiplayerModeSinglePlayer = 0,
	JamControllerMultiplayerModeServer,
	JamControllerMultiplayerModeClient
};
	
@interface JamController : ExperienceController<UITableViewDelegate, UITableViewDataSource, JamIntranetMultiplayerClientDelegate, JamIntranetMultiplayerServerDelegate, JamPadDelegate>
{
	SongRecorder * m_songRecorder;
	
	bool m_isRecording;
	bool m_isPlaying;
	bool m_isBacking;
	
//	CSong * m_recordedSong;
	CSong * m_backingTrackSong;
	
	NSString * m_backingTrackXmpBlob;
	
	SongModel * m_recordedSongModel;
	SongModel * m_backingTrackSongModel;
	
	NSDictionary * m_selectedSongDictionary;
	
	// Table view
	IBOutlet UITableView * m_cachedSongsTable;
	
	// Views
	IBOutlet UIView * m_blackView;
	IBOutlet UIView * m_ampView;
	IBOutlet UIView * m_menuView;
	IBOutlet UIView * m_previewView;
	IBOutlet UIView * m_popupView;
	IBOutlet UIView * m_slideView;
	BOOL m_slide;
	
	IBOutlet UILabel * m_recLabel;
	IBOutlet UIButton * m_recButton;
	IBOutlet UILabel * m_timeLabel;
	IBOutlet UITextField * m_titleText;
	
	IBOutlet JamPad * m_jamPad;
	
	CGPoint m_debugTouchPoint;
	
	NSMutableArray * m_cachedSongs;
	
	NSDictionary * m_backingTrackDictionary;
	
	// Multiplayer
	JamControllerMultiplayerMode m_multiplayerMode;
	MultiplayerController * m_multiplayerController;
	
}

@property (nonatomic, retain) UITableView * m_cachedSongsTable;
@property (nonatomic, retain) UIView * m_blackView;
@property (nonatomic, retain) UIView * m_ampView;
@property (nonatomic, retain) UIView * m_menuView;
@property (nonatomic, retain) UIView * m_previewView;
@property (nonatomic, retain) UIView * m_popupView;
@property (nonatomic, retain) UIView * m_slideView;

@property (nonatomic, retain) UILabel * m_recLabel;
@property (nonatomic, retain) UIButton * m_recButton;
@property (nonatomic, retain) UILabel * m_timeLabel;

@property (nonatomic, retain) JamPad * m_jamPad;
@property (nonatomic, retain) UITextField * m_titleText;

@property (nonatomic, assign) JamControllerMultiplayerMode m_multiplayerMode;
@property (nonatomic, retain) MultiplayerController * m_multiplayerController;

// Button click handlers
- (IBAction)recordButtonClicked:(id)sender;
- (IBAction)previewDoneButtonClicked:(id)sender;
- (IBAction)toggleBeatButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;
- (IBAction)playbackButtonClicked:(id)sender;
- (IBAction)restartButtonClicked:(id)sender;
- (IBAction)shareButtonClicked:(id)sender;
- (IBAction)menuButtonClicked:(id)sender;
- (IBAction)menuDoneButtonClicked:(id)sender;
- (IBAction)leftSlideButtonClicked:(id)sender;
- (IBAction)rightSlideButtonClicked:(id)sender;

- (IBAction)ffButtonClicked:(id)sender;
- (IBAction)naButtonClicked:(id)sender;
- (IBAction)lmButtonClicked:(id)sender;
- (IBAction)noneButtonClicked:(id)sender;

- (void)animateAmpModal:(BOOL)popup;
- (void)animatePreviewModal:(BOOL)popup;
- (void)updateTimeDisplay:(double)time;
- (NSString*)formatTimeIntToString:(unsigned int)time;

- (void)startRecording;
- (void)stopRecording;
- (void)saveRecordedXmpBlobToCache;
- (NSString*)makeRecordedXmpBlob;
- (void)clearStaleRecordedData;

- (NSString*)getXmpFromCache:(NSInteger)index;
- (NSString*)getLengthFromCache:(NSInteger)index;
- (NSString*)getTitleFromCache:(NSInteger)index;
- (NSDictionary*)getEntryFromCache:(NSInteger)index;
- (NSString*)getXmpFromEntry:(NSDictionary*)entry;
- (NSString*)getTitleFromEntry:(NSDictionary*)entry;
- (NSNumber*)getLengthFromEntry:(NSDictionary*)entry;

- (void)addXmpToCache:(NSString*)xmpBlob;
- (void)addToCacheXmp:(NSString*)xmpBlob andTitle:(NSString*)songTitle andLength:(NSNumber*)length;
- (void)removeXmpFromCache:(NSString*)xmpBlob;
- (void)replaceXmpInCache:(NSString*)oldBlob withXmp:(NSString*)newXmp;
- (void)replaceXmp:(NSString*)xmpBlob inEntry:(NSMutableDictionary*)entry;
- (void)replaceTitle:(NSString*)songTitle inEntry:(NSMutableDictionary*)entry;
- (void)replaceLength:(NSString*)length inEntry:(NSMutableDictionary*)entry;
- (void)loadSongCache;
- (void)saveSongCache;

@end
