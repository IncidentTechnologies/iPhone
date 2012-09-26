//
//  EtarLearnPlayViewController.h
//  EtarLearn
//
//  Created by Marty Greenia on 9/30/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EtarLearnPlayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView * songSelectionTable;
	NSMutableArray * songs;
	NSMutableArray * selectedSong;
	NSString * songSortKey;
}

@property (nonatomic, retain) IBOutlet UITableView * songSelectionTable;
@property (nonatomic, retain) NSArray * songs;
@property (nonatomic, retain) NSMutableArray * selectedSong;
@property (nonatomic, retain) NSString * songSortKey;

// Buttons
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)sortButtonClicked:(id)sender;
- (IBAction)sortAlphaButtonClicked:(id)sender;
- (IBAction)sortGenreButtonClicked:(id)sender;
- (IBAction)sortProgressButtonClicked:(id)sender;

// Data mgmt
- (void)fetchSongData;
- (void)updateProgressPercent:(CGFloat)progress;
- (NSArray*)convertXmpToArray:(NSObject*)xmpData;

// Table functions
- (void)sortSongArray;
- (void)populateSongSelectionTable;
- (void)sortSongSelectionTable;
- (void)selectSongFromTable;

@end
