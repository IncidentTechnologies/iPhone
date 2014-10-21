//
//  SaveLoadSelector.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/28/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "OptionsViewCell.h"
#import "NSSequence.h"

@protocol OptionsDelegate <NSObject>

- (void) saveSequenceWithId:(NSInteger)xmpId andName:(NSString *)filename;
- (void) loadFromXmpId:(NSInteger)xmpId andType:(NSString *)type;
- (void) renameForXmpId:(NSInteger)xmpId FromName:(NSString *)filename toName:(NSString *)newname andType:(NSString *)type;
- (void) createNewSaveName:(NSString *)filename;

- (void) viewSeqSetWithAnimation:(BOOL)animate;
- (void) viewRecordShareWithAnimation:(BOOL)animate;

- (void) loggedOut:(BOOL)animate;

- (int) countInstruments;
- (int) countSounds;

- (BOOL) isLeftNavOpen;

@end

extern OphoMaster * g_ophoMaster;
extern NSUser * g_loggedInUser;

@interface OptionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSMutableArray * fileIdSet;
    NSMutableArray * fileLoadSet;
    NSMutableArray * fileDateSet;
    
    BOOL showSelectionToggle;
    
    UIButton * selectedButton;
    
    OptionsViewCell * cellToDeselect;
    
    NSString * loadedTableType;
    
    BOOL isScreenLarge;
}

- (IBAction)userDidSelectCreateNew:(id)sender;
- (IBAction)userDidSelectSaveCurrent:(id)sender;
- (IBAction)userDidSelectBack:(id)sender;
- (IBAction)userDidSelectLoad:(id)sender;
- (IBAction)userDidSelectProfile:(id)sender;
- (IBAction)userDidLogout:(id)sender;

- (void)userDidLoadFile:(NSInteger)xmpId;
- (void)userDidSaveFile:(NSInteger)xmpId toName:(NSString *)filename;
- (void)userDidRenameFile:(NSInteger)xmpId fromName:(NSString *)filename toName:(NSString *)newname;

- (void)offsetTable:(id)sender;
- (void)resetTableOffset:(id)sender;

- (void)reloadUserProfile;
- (void)reloadFileTable;
- (void)unloadView;
- (void)loadTableWith:(NSString *)type;

- (BOOL)isLeftNavOpen;

- (void)deleteCell:(OptionsViewCell *)cell;
- (void)deselectAllRowsExcept:(OptionsViewCell *)cell;

- (void)deselectAllRows;
- (BOOL)isDuplicateFilename:(NSString *)filename;
- (void)alertDuplicateFilename;
- (NSString *)generateNextSetName;
- (void)disableScroll;
- (void)enableScroll;

- (void)setActiveSequence:(NSSequence *)sequence;
- (void)setActiveSong:(NSInteger)song;

@property (nonatomic) BOOL isFirstLaunch;

@property (retain, nonatomic) NSSequence * activeSequence;
@property (assign, nonatomic) NSInteger activeSong;

@property (weak, nonatomic) id<OptionsDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton * createNewButton;
@property (weak, nonatomic) IBOutlet UIButton * saveCurrentButton;
@property (weak, nonatomic) IBOutlet UIButton * backButton;
@property (weak, nonatomic) IBOutlet UIButton * loadButton;
@property (weak, nonatomic) IBOutlet UIButton * profileButton;
@property (weak, nonatomic) IBOutlet UILabel * noSetsLabel;
@property (weak, nonatomic) IBOutlet UITableView * loadTable;
@property (nonatomic) NSString * selectMode;

@property (weak, nonatomic) IBOutlet UIView * profileView;
@property (weak, nonatomic) IBOutlet UILabel * profileNameLabel;
@property (weak, nonatomic) IBOutlet UIButton * profileLogoutButton;
@property (weak, nonatomic) IBOutlet UIButton * profileSetIcon;
@property (weak, nonatomic) IBOutlet UIButton * profileInstrumentIcon;
@property (weak, nonatomic) IBOutlet UIButton * profileSoundIcon;
@property (weak, nonatomic) IBOutlet UILabel * profileSetLabel;
@property (weak, nonatomic) IBOutlet UILabel * profileInstrumentLabel;
@property (weak, nonatomic) IBOutlet UILabel * profileSoundLabel;
@property (weak, nonatomic) IBOutlet UILabel * profileSetNameLabel;
@property (weak, nonatomic) IBOutlet UILabel * profileInstrumentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel * profileSoundNameLabel;

@end

