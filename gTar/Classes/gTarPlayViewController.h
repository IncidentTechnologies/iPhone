//
//  gTarPlayViewController.h
//  EtarLearn
//
//  Created by Marty Greenia on 9/30/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PlayController.h"
#import "CloudController.h"
#import "CloudCache.h"

extern NSString * g_username;
extern NSString * g_password;

@interface gTarPlayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CloudControllerDelegate>
{
	IBOutlet UITableView * m_songSelectionTable;
//	IBOutlet UIButton * m_difficultyButton;
//	IBOutlet UIActivityIndicatorView * m_spinner;
	NSMutableArray * m_songs;
	NSString * m_songSortKey;
	NSString * m_difficulty;
	
	// Cloud stuff
	CloudController * m_cloudController;
	CloudCache * m_cloudCache;
	CloudCacheEntry * m_selectedCacheEntry;
	//UserSongs * m_userSongs;
	//UserSong * m_selectedSong;
	
	// Debug stuff
//	IBOutlet UIButton * m_debugStatus;
//	IBOutlet UIButton * m_cloneStatus;
	gTarDebug * m_debugger;
	gTarDebug * m_clone;
	
//	IBOutlet UILabel * debugLabel;
	
	// Activity indicator
	IBOutlet UIImageView * m_activityIndicator;
	BOOL m_ledOn;
	NSTimer * m_activityIndicatorTimer;
}
//@property (nonatomic, retain) IBOutlet UILabel * debugLabel;

@property (nonatomic, retain) IBOutlet UITableView * m_songSelectionTable;
//@property (nonatomic, retain) IBOutlet UIButton * m_difficultyButton;
//@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_spinner;
//@property (nonatomic, retain) CloudCache * m_cloudCache;

//@property (nonatomic, retain) IBOutlet UIButton * m_debugStatus;
//@property (nonatomic, retain) IBOutlet UIButton * m_cloneStatus;
//@property (nonatomic, retain) NSArray * m_songs;
//@property (nonatomic, retain) NSMutableArray * m_selectedSong;
//@property (nonatomic, retain) NSString * m_songSortKey;
@property (nonatomic, retain) UIImageView * m_activityIndicator;
// Buttons
- (IBAction)backButtonClicked:(id)sender;
//- (IBAction)sortButtonClicked:(id)sender;
- (IBAction)sortAlphaButtonClicked:(id)sender;
- (IBAction)sortGenreButtonClicked:(id)sender;
- (IBAction)sortProgressButtonClicked:(id)sender;
- (IBAction)difficultyButtonClicked:(id)sender;
- (IBAction)debugButtonClicked:(id)sender;
- (IBAction)cloneButtonClicked:(id)sender;

// Data mgmt
- (void)fetchSongData;
- (void)updateProgressPercent:(CGFloat)progress;
- (NSArray*)convertXmpToArray:(NSObject*)xmpData;

// Table functions
- (void)sortSongArray;
- (void)populateSongSelectionTable;
- (void)sortSongSelectionTable;

@end
