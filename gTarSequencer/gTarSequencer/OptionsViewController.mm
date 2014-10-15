//
//  SaveLoadSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/28/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "OptionsViewController.h"

#define ROW_HEIGHT 65
#define TABLE_Y 55
#define TABLE_HEIGHT 209
#define TABLE_MIN_HEIGHT 103

#define DEFAULT_SET_NAME @"Tutorial"
#define DEFAULT_FILE_TEXT @"Save as"
#define TABLE_SETS @"Sequences"
#define TABLE_SONGS @"Songs"

@implementation OptionsViewController

@synthesize isFirstLaunch;
@synthesize delegate;
@synthesize activeSequencer;
@synthesize activeSong;
@synthesize createNewButton;
@synthesize saveCurrentButton;
@synthesize backButton;
@synthesize loadButton;
@synthesize profileButton;
@synthesize profileSetIcon;
@synthesize profileInstrumentIcon;
@synthesize profileSoundIcon;
@synthesize profileSetLabel;
@synthesize profileInstrumentLabel;
@synthesize profileSoundLabel;
@synthesize profileNameLabel;
@synthesize profileLogoutButton;
@synthesize profileSetNameLabel;
@synthesize profileInstrumentNameLabel;
@synthesize profileSoundNameLabel;
@synthesize loadTable;
@synthesize profileView;
@synthesize selectMode;
@synthesize noSetsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initOptions];
    }
    return self;
}

- (void)viewDidLoad
{
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    isScreenLarge = [frameGenerator isScreenLarge];
    
    [loadTable registerNib:[UINib nibWithNibName:@"OptionsViewCell" bundle:nil] forCellReuseIdentifier:@"LoadCell"];
    
    //loadTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    loadTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    loadTable.separatorInset = UIEdgeInsetsZero;
    loadTable.bounces = NO;
    
    selectMode = nil;
    
    [self drawProfileButtonsAndLabels];
    [self drawBackButton];
    [self drawNewPlusButton];
    
}

- (void)viewDidLayoutSubviews
{
    [self reloadFileTable];
    [self reloadUserProfile];
}

- (void)unloadView
{
    // Hide any cells showing keyboard
    for(NSIndexPath * indexPath in loadTable.indexPathsForSelectedRows){
        OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
        [cell endNameEditing];
    }
}

- (void)initOptions
{
    loadedTableType = TABLE_SETS;
    
    // Check for first launch
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOptions"]){
        isFirstLaunch = FALSE;
    }else{
        isFirstLaunch = TRUE;
    }
    
}

- (void)reloadFileTable
{
    [self loadTableWith:loadedTableType];
}

- (void)loadTableWith:(NSString *)type
{
    loadedTableType = type;
    
    NSDictionary * listData;
    
    if([loadedTableType isEqualToString:TABLE_SETS]){
        
        listData = [g_ophoMaster getSequenceList];
        
    }else if([loadedTableType isEqualToString:TABLE_SONGS]){
        
        listData = [g_ophoMaster getSongList];
    }
    
    fileIdSet = [[NSMutableArray alloc] initWithArray:[listData objectForKey:OPHO_LIST_IDS]];
    fileLoadSet = [[NSMutableArray alloc] initWithArray:[listData objectForKey:OPHO_LIST_NAMES]];
    fileDateSet = [[NSMutableArray alloc] initWithArray:[listData objectForKey:OPHO_LIST_DATES]];
    
    [loadTable reloadData];
    
    if([fileLoadSet count] > 0){
        [self userDidSelectLoad:loadButton];
        [self highlightActive];
        [self hideNoSetsLabel];
    }else{
        [self userDidSelectLoad:loadButton];
        [self showNoSetsLabel];
    }
}

#pragma mark - Save Load Actions
- (void)userDidLoadFile:(NSInteger)xmpId
{
    if([loadedTableType isEqualToString:TABLE_SETS]){
        DLog(@"user did load SET %i",xmpId);
        
        // delegate calls back to set activeSequencer
        [delegate loadFromXmpId:xmpId andType:loadedTableType];
        
        // Delegate sets activeSequencer/activeSong
        [delegate viewSeqSetWithAnimation:YES];
        
    }else if([loadedTableType isEqualToString:TABLE_SONGS]){
        DLog(@"user did load SONG %i",xmpId);
        
        // delegate calls back to set activeSong
        [delegate loadFromXmpId:xmpId andType:loadedTableType];
        
        [delegate viewRecordShareWithAnimation:YES];
        
    }
}


- (void)userDidSaveFile:(NSString *)filename
{
    DLog(@"user did save as %@",filename);
    
    NSString * emptyName = [filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        DLog(@"Error: trying to save with blank set name");
    }else{
        // delegate calls back to set activeSequencer
        [delegate saveWithName:filename];
        [delegate viewSeqSetWithAnimation:YES];
    }
}

- (void)userDidRenameFile:(NSString *)filename toName:(NSString *)newname
{
    DLog(@"user did move set/song %@ to %@",filename,newname);
    
    if([activeSong isEqualToString:filename]){
        activeSong = newname;
    }
    
    // Delegate sets activeSequencer/activeSong
    [delegate renameFromName:filename toName:newname andType:loadedTableType];
    //[self reloadFileTable];
    
    // Delay reload
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reloadFileTable) userInfo:nil repeats:NO];
}

//- (void)userDidDeleteFile:(NSString *)filename
- (void)userDidDeleteFile:(NSInteger)xmpId
{
    DLog(@"user did delete %i",xmpId);
    
    [g_ophoMaster deleteWithId:xmpId];
    
}

#pragma mark - Button Actions

- (IBAction)userDidSelectBack:(id)sender
{
    [delegate viewSeqSetWithAnimation:YES];
}

- (IBAction)userDidSelectCreateNew:(id)sender
{
    selectMode = @"Load";
    
    NSString * newSet = ([activeSequencer isEqualToString:@""] || activeSequencer == nil || [activeSequencer isEqualToString:DEFAULT_SET_NAME]) ? [self generateNextSetName] : activeSequencer;
    
    // delegate sets activeSequencer
    [delegate createNewSaveName:newSet];
    
    //[self reloadFileTable];
    [self showSelectionToggle:YES];
    
    //[loadTable reloadData];
    [self resetTableOffset:nil];
    
    //[delegate viewSeqSetWithAnimation:YES];
}

- (IBAction)userDidSelectSaveCurrent:(id)sender
{
    
    DLog(@"User did select save current");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"SaveCurrent";
    
    [profileView setHidden:YES];
    [self showSelectionToggle:NO];
    //NSMutableArray * tempFileLoadSet = [[NSMutableArray alloc] initWithArray:fileLoadSet copyItems:YES];
    //fileLoadSet = nil;
    //[self.loadTable reloadData];
    //fileLoadSet = tempFileLoadSet;
    [self.loadTable reloadData];
    [self resetTableOffset:nil];
    
}

-(IBAction)userDidSelectLoad:(id)sender
{
    DLog(@"User did select load");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"Load";
    
    [profileView setHidden:YES];
    [self showSelectionToggle:YES];
    //NSMutableArray * tempFileLoadSet = [[NSMutableArray alloc] initWithArray:fileLoadSet copyItems:YES];
    //fileLoadSet = nil;
    //[self.loadTable reloadData];
    //fileLoadSet = tempFileLoadSet;
    [self.loadTable reloadData];
    [self resetTableOffset:nil];
    
}

-(IBAction)userDidSelectProfile:(id)sender
{
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    [profileView setHidden:NO];
    [self unloadView];
}

- (IBAction)userDidLogout:(id)sender
{
    [delegate loggedOut:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(userDidSelectBack:) userInfo:nil repeats:NO];
}

- (BOOL)setSelectedButtonTo:(UIButton *)button
{
    
    UIColor * selectedColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    UIColor * deselectedColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1.0];
    
    if(selectedButton == button){
        return FALSE;
    }else{
        selectedButton.backgroundColor = deselectedColor;
        selectedButton = button;
        selectedButton.backgroundColor = selectedColor;
        
        return TRUE;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileLoadSet count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(showSelectionToggle && indexPath.row == 0){
        return ROW_HEIGHT;
    }else if(indexPath.row > 0 && [selectMode isEqualToString:@"SaveCurrent"] && ![fileLoadSet[indexPath.row-1] isEqualToString:activeSequencer]){
        return 0;
    }else if(indexPath.row > 0 && [selectMode isEqualToString:@"SaveCurrent"] && [fileLoadSet[indexPath.row-1] isEqualToString:DEFAULT_SET_NAME]){
        return 0;
    }else{
        return ROW_HEIGHT;
    }
}

- (void)disableScroll
{
    DLog(@"disable scroll");
    loadTable.scrollEnabled = NO;
}

- (void)enableScroll
{
    DLog(@"enable scroll");
    loadTable.scrollEnabled = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"LoadCell";
    
    OptionsViewCell * cell = (OptionsViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[OptionsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.parent = self;
    
    if(indexPath.row > 0 && indexPath.row <= [fileLoadSet count]){
        
        // Rows for previous files
        
        NSString * title = fileLoadSet[indexPath.row-1];
        NSDate * priorDate = fileDateSet[indexPath.row-1];
        NSString * dateString = [self displayTimeFromPriorDate:priorDate];
        
        cell.fileText.text = title;
        cell.fileDate.text = dateString;
        cell.isRenamable = NO;
        cell.xmpId = [fileIdSet[indexPath.row-1] intValue];
        
        if([loadedTableType isEqualToString:TABLE_SETS]){
            [cell unsetAsActiveSong];
            if([cell.fileText.text isEqualToString:activeSequencer]){
                [cell setAsActiveSequencer];
            }else{
                [cell unsetAsActiveSequencer];
            }
        }else if([loadedTableType isEqualToString:TABLE_SONGS]){
            [cell unsetAsActiveSequencer];
            if([cell.fileText.text isEqualToString:activeSong]){
                [cell setAsActiveSong];
            }else{
                [cell unsetAsActiveSong];
            }

        }
        
    }else{
        
        // Row for new file
        cell.fileText.text = DEFAULT_FILE_TEXT;
        cell.fileDate.text = @"0s";
        cell.isRenamable = YES;
    }
    
    [cell.setButton setHidden:YES];
    [cell.songButton setHidden:YES];
    
    // iOS 7.1 seems to ignore heights
    if((showSelectionToggle && indexPath.row == 0)){
        cell.isRenamable = NO;
        [cell.setButton setHidden:NO];
        [cell.songButton setHidden:NO];
        cell.fileText.text = @"";
        
        if([loadedTableType isEqualToString:TABLE_SETS]){
            [cell highlightSetButton];
        }else if([loadedTableType isEqualToString:TABLE_SONGS]){
            [cell highlightSongButton];
        }
        
        //[cell setHidden:YES];
    }else if(indexPath.row > 0 && [selectMode isEqualToString:@"SaveCurrent"] && ![fileLoadSet[indexPath.row-1] isEqualToString:activeSequencer]){
        [cell setHidden:YES];
    }else if(indexPath.row > 0 && [selectMode isEqualToString:@"SaveCurrent"] && [fileLoadSet[indexPath.row-1] isEqualToString:DEFAULT_SET_NAME]){
        [cell setHidden:YES];
    }else{
        [cell setHidden:NO];
    }
    
    
    cell.rowid = (int)indexPath.row;
    
    DLog(@"Cell row id is %i",cell.rowid);
    
    return cell;
}

#pragma mark - Cell editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deselect a cell that's held on
    if(cellToDeselect != nil){
        [cellToDeselect setSelected:NO animated:NO];
        cellToDeselect = nil;
    }
}

- (void)deleteCell:(OptionsViewCell *)cell
{
    NSIndexPath * indexPath = [loadTable indexPathForCell:cell];
    NSString * filename = [cell getNameForFile];
    
    [cell unsetAsActiveSequencer];
    [cell unsetAsActiveSong];
    [cell setSelected:NO];
    
    int indexToRemove = -1;
    for(int i = 0; i < [fileLoadSet count]; i++){
        if([[fileLoadSet objectAtIndex:i] isEqualToString:filename]){
            indexToRemove = i;
        }
    }
    
    // Remove object at index
    if(indexToRemove >= 0 && indexToRemove < [fileLoadSet count]){
        [fileLoadSet removeObjectAtIndex:indexToRemove];
        [fileDateSet removeObjectAtIndex:indexToRemove];
        [fileIdSet removeObjectAtIndex:indexToRemove];
    }
    
    // remove from table
    [loadTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    // delete the data
    [self userDidDeleteFile:cell.xmpId];
    
    //[loadTable reloadData];
    [self reloadFileTable];
    
    if([fileLoadSet count] == 0){
        // schedule this because the table loading inevitably has a delay
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showNoSetsLabel) userInfo:nil repeats:NO];
    }

}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath
{
    OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
    [self deleteCell:cell];
}

- (BOOL)isLeftNavOpen
{
    return [delegate isLeftNavOpen];
}

#pragma mark - Custom logic for cell display

-(NSString *)displayTimeFromPriorDate:(NSDate *)priorDate
{
    
    NSDate * now = [NSDate date];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * priorCal = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:priorDate];
    NSDateComponents * nowCal = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:now];
    
    NSTimeInterval gap = [now timeIntervalSinceDate:priorDate];
    double secondsPerMinute = 60;
    double secondsPerHour = 3600;
    double secondsPerDay = 3600*24;
    double secondsPerWeek = 3600*24*7;
    
    NSArray * monthSet = [[NSArray alloc] initWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec", nil];
    
    int gapMins = gap / secondsPerMinute;
    int gapHours = gap / secondsPerHour;
    int gapDays = gap / secondsPerDay;
    int gapWeeks = gap / secondsPerWeek;
    
    NSString * dateString;
    if(gapMins < 60){
        dateString = [NSString stringWithFormat:@"%im",gapMins];
    }else if(gapHours < 24){
        dateString = [NSString stringWithFormat:@"%ih",gapHours];
    }else if(gapDays < 7){
        dateString = [NSString stringWithFormat:@"%id",gapDays];
    }else if(gapWeeks < 5){
        dateString = [NSString stringWithFormat:@"%iw",gapWeeks];
    }else if([priorCal year] == [nowCal year]){
        dateString = [NSString stringWithFormat:@"%@",monthSet[[priorCal month]-1]];
    }else{
        dateString = [NSString stringWithFormat:@"%i",[priorCal year]];
    }
    
    return dateString;
    
}

#pragma mark - Active Sequence / Song

-(void)setActiveSequencer:(NSString *)sequence
{
    activeSequencer = sequence;
    
    [self loadTableWith:loadedTableType];
}

-(void)setActiveSong:(NSString *)song
{
    activeSong = song;
    
    [self loadTableWith:loadedTableType];
}

-(void)highlightActive
{
    for(NSIndexPath * indexPath in loadTable.indexPathsForVisibleRows){
        OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
        
        if([loadedTableType isEqualToString:TABLE_SETS]){
            if([cell.fileText.text isEqualToString:activeSequencer]){
                [cell setAsActiveSequencer];
            }else if(!cell.isSelected){
                [cell unsetAsActiveSequencer];
            }
        }else if([loadedTableType isEqualToString:TABLE_SONGS]){
            if([cell.fileText.text isEqualToString:activeSong]){
                [cell setAsActiveSong];
            }else if(!cell.isSelected){
                [cell unsetAsActiveSong];
            }
        }
    }
}

#pragma mark - Select actions
-(void)delayedSelectLoadTableTopRow
{
    int firstIndex = 0;
    
    if([fileLoadSet count] > firstIndex){
        [loadTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:firstIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

-(void)showSelectionToggle:(BOOL)isHidden
{
    showSelectionToggle = isHidden;
}

-(void)deselectAllRows
{
    DLog(@"Deselect all rows");
    @synchronized(self){
        for(int i = 0; i < [fileLoadSet count]+1; i++){
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [loadTable deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

-(void)deselectAllRowsExcept:(OptionsViewCell *)cell
{
    NSIndexPath * cellToIgnore = [loadTable indexPathForCell:cell];
    
    DLog(@"Deselect all rows except %i",cellToIgnore.row);
    
    // TODO: figure out why this fails during scrolling - max 3 rows/screen?
    for(int i = 0; i < [loadTable numberOfRowsInSection:0]; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        OptionsViewCell * cellToCheck = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
        
        if(cellToCheck != nil && cellToCheck != cell && cellToCheck.isSelected){
            [loadTable deselectRowAtIndexPath:indexPath animated:NO];
            [cellToCheck setSelected:NO animated:NO];
        }
    }
}

// Shrink table so any row can be renamed
-(void)offsetTable:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^(void){
        [loadTable setFrame:CGRectMake(0, TABLE_Y, loadTable.frame.size.width, TABLE_MIN_HEIGHT)];
    }];
    
    if(sender != nil){ // Renaming, scroll to anywhere in the table
        [loadTable scrollToRowAtIndexPath:[loadTable indexPathForCell:sender] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{
        [self deselectAllRows];
        [self delayedSelectLoadTableTopRow];
    }
}

// Unshrink table when the keyboard is down
-(void)resetTableOffset:(id)sender
{
    // Not sure why this offset is needed for animation to be smooth
    [loadTable setFrame:CGRectMake(0, TABLE_Y, loadTable.frame.size.width, 170)];
    
    if([selectMode isEqualToString:@"Load"]){
        if(sender == nil){
            [self delayedSelectLoadTableTopRow];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^(void){
        [loadTable setFrame:CGRectMake(0, TABLE_Y, loadTable.frame.size.width, TABLE_HEIGHT)];
    } completion:^(BOOL finished){
        
        if(sender != nil){
            [loadTable scrollToRowAtIndexPath:[loadTable indexPathForCell:sender] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }else{
            [self deselectAllRows];
            [self delayedSelectLoadTableTopRow];
        }
    }];
}

#pragma mark - Name checking

-(BOOL)isDuplicateFilename:(NSString *)filename
{
    for(int i = 0; i < [fileLoadSet count]; i++){
        if([fileLoadSet[i] isEqualToString:filename]){
            return YES;
        }
    }
    
    return NO;
}

-(void)alertDuplicateFilename
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Set Name" message:@"Cannot override an existing set." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark - Empty set

- (void)showNoSetsLabel
{
    if([noSetsLabel isHidden]){
        [noSetsLabel setHidden:NO];
        [noSetsLabel setAlpha:0.0];
        [UIView animateWithDuration:0.5 animations:^(void){[noSetsLabel setAlpha:1.0];}];
    }
}

- (void)hideNoSetsLabel
{
    [noSetsLabel setHidden:YES];
}

- (NSString *)generateNextSetName
{
    int customCount = 0;
    
    for(int i = 0; i < [fileLoadSet count]; i++){
        NSString * filename = fileLoadSet[i];
        if(!([filename rangeOfString:@"Set"].location == NSNotFound)){
            
            NSString * customSuffix = [filename stringByReplacingCharactersInRange:[filename rangeOfString:@"Set"] withString:@""];
            int numFromSuffix = [customSuffix intValue];
            
            customCount = MAX(customCount,numFromSuffix);
        }
    }
    
    customCount++;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setMinimumIntegerDigits:3];
    
    NSNumber * number = [NSNumber numberWithInt:customCount];
    
    NSString * numberString = [numberFormatter stringFromNumber:number];
    
    return [@"Set" stringByAppendingString:numberString];
    
}

#pragma mark - Drawing

- (void)reloadUserProfile
{
    UIImage * image = [UIImage imageNamed:@"Bear_Brown"];
    
    if(g_loggedInUser.m_image != nil && g_loggedInUser.m_userProfile.m_imgFileId > 1){
        image = g_loggedInUser.m_image;
        profileButton.imageView.layer.cornerRadius = 5.0;
        profileButton.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        profileButton.imageView.layer.borderWidth = 1.0;
    }else{
        profileButton.imageView.layer.cornerRadius = 0.0;
        profileButton.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        profileButton.imageView.layer.borderWidth = 0.0;
    }
    
    // User info
    [profileButton setImage:image forState:UIControlStateNormal];
    profileNameLabel.text = g_loggedInUser.m_username;
    
    // Counts
    [self showSetCount];
    [self showInstrumentCount];
    [self showSoundCount];
}

-(void)drawProfileButtonsAndLabels
{
    float margin = (isScreenLarge) ? 34 : 25;
    
    [profileButton setImageEdgeInsets:UIEdgeInsetsMake(5, margin, 5, margin)];
    [profileButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    profileSetIcon.layer.cornerRadius = profileSetIcon.frame.size.width/2.0;
    profileInstrumentIcon.layer.cornerRadius = profileInstrumentIcon.frame.size.width/2.0;
    profileSoundIcon.layer.cornerRadius = profileSoundIcon.frame.size.width/2.0;
    
    [self reloadUserProfile];
    
}

- (void)showSetCount
{
    [profileSetLabel setText:[NSString stringWithFormat:@"%i",[fileLoadSet count]+1]];
    
    if([fileLoadSet count] > 0){
        [profileSetNameLabel setText:@"sets"];
    }else{
        [profileSetNameLabel setText:@"set"];
    }
    
}

- (void)showInstrumentCount
{
    // Subtract the custom instrument creator
    int instrumentCount = [delegate countInstruments]-1;
    
    [profileInstrumentLabel setText:[NSString stringWithFormat:@"%i",instrumentCount]];
    
}

- (void)showSoundCount
{
    int soundCount = [delegate countSounds];
    
    [profileSoundLabel setText:[NSString stringWithFormat:@"%i",soundCount]];
    
}

-(void)drawBackButton
{
    float margin = (isScreenLarge) ? 40 : 33;
    
    [backButton setImage:[UIImage imageNamed:@"Set_Icon"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(15, margin, 15, margin)];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    backButton.tintColor = [UIColor whiteColor];
}

-(void)drawNewPlusButton
{
    float margin = (isScreenLarge) ? 12 : 0;
    
    CGSize size = CGSizeMake(createNewButton.frame.size.width, createNewButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float plusWidth = 22;
    float plusX = margin + createNewButton.frame.size.width/2 - plusWidth/2;
    float plusY = 16;
    CGFloat plusHeight = createNewButton.frame.size.height - 2*plusY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 5.0);
    
    CGContextMoveToPoint(context, plusX, plusY);
    CGContextAddLineToPoint(context, plusX, plusY+plusHeight);
    
    CGContextMoveToPoint(context, plusX-plusWidth/2, plusY+plusHeight/2);
    CGContextAddLineToPoint(context, plusX+plusWidth/2, plusY+plusHeight/2);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [createNewButton addSubview:image];
    
    UIGraphicsEndImageContext();
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
