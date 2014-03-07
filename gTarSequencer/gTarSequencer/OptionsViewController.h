//
//  SaveLoadSelector.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/28/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "OptionsViewCell.h"

@protocol OptionsDelegate <NSObject>

- (void) saveWithName:(NSString *)filename;
- (void) loadFromName:(NSString *)filename;
- (void) renameFromName:(NSString *)filename toName:(NSString *)newname;
- (void) createNewSaveName:(NSString *)filename;
- (void) deleteWithName:(NSString *)filename;

- (void) viewSeqSetWithAnimation:(BOOL)animate;

@end

@interface OptionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    //NSMutableDictionary * fileSet;
    NSMutableArray * fileLoadSet;
    NSMutableArray * fileDateSet;
    
    BOOL hideNewFileRow;
    
    UIButton * selectedButton;
    
    OptionsViewCell * cellToDeselect;
}

- (IBAction)userDidSelectCreateNew:(id)sender;
- (IBAction)userDidSelectSaveCurrent:(id)sender;
- (IBAction)userDidSelectRename:(id)sender;
- (IBAction)userDidSelectBack:(id)sender;
- (IBAction)userDidSelectLoad:(id)sender;

- (void)userDidLoadFile:(NSString *)filename;
- (void)userDidSaveFile:(NSString *)filename;
- (void)userDidRenameFile:(NSString *)filename toName:(NSString *)newname;
- (void)userDidCreateNewFile:(NSString *)filename;

- (void)offsetTable:(id)sender;
- (void)resetTableOffset:(id)sender;

- (void)reloadFileTable;
- (void)unloadView;

- (void)deselectAllRows;
//- (BOOL)isDuplicateFilename:(NSString *)filename;
- (NSString *)generateNextSetName;
- (void)disableScroll;
- (void)enableScroll;

@property (retain, nonatomic) NSString * activeSequencer;

@property (weak, nonatomic) id<OptionsDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton * createNewButton;
@property (weak, nonatomic) IBOutlet UIButton * saveCurrentButton;
@property (weak, nonatomic) IBOutlet UIButton * backButton;
@property (weak, nonatomic) IBOutlet UIButton * loadButton;
@property (weak, nonatomic) IBOutlet UILabel * noSetsLabel;
@property (weak, nonatomic) IBOutlet UITableView * loadTable;
@property (nonatomic) NSString * selectMode;

@end

