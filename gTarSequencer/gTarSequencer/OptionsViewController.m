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

@implementation OptionsViewController

@synthesize isFirstLaunch;
@synthesize delegate;
@synthesize activeSequencer;
@synthesize createNewButton;
@synthesize saveCurrentButton;
@synthesize backButton;
@synthesize loadButton;
@synthesize loadTable;
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
    
    // Check screen size for nib
    NSString * nibname = @"OptionsViewCell";
    if([[UIScreen mainScreen] bounds].size.height == XBASE_LG){
        nibname = @"OptionsViewCell_4";
    }
    
    UINib *nib = [UINib nibWithNibName:nibname bundle:nil];
    [loadTable registerNib:nib forCellReuseIdentifier:@"LoadCell"];
    
    //loadTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    loadTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    loadTable.separatorInset = UIEdgeInsetsZero;
    loadTable.bounces = NO;
    
    selectMode = nil;
    
    [self drawBackButton];
    [self drawNewPlusButton];
    
    [self reloadFileTable];
    
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
    
    // Check for first launch
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOptions"]){
        isFirstLaunch = FALSE;
    }else{
        isFirstLaunch = TRUE;
    }
    
}

- (void)reloadFileTable
{
    [self loadFileSet];
    
    if([fileLoadSet count] > 0){
        [self userDidSelectLoad:loadButton];
        [self highlightActiveSequencer];
        [self hideNoSetsLabel];
    }else{
        [self userDidSelectLoad:loadButton];
        [self showNoSetsLabel];
    }
}

- (void)loadFileSet
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError * error;
    NSString * directoryPath = [paths objectAtIndex:0];
    
    //fileSet = [[NSMutableDictionary alloc] init];
    
    fileDateSet = [[NSMutableArray alloc] init];
    fileLoadSet = (NSMutableArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    // Exclude unrelated files
    for(int i = 0; i < [fileLoadSet count]; i++){
        if([fileLoadSet[i] rangeOfString:@"usr_"].location == NSNotFound){
            
            [fileLoadSet removeObjectAtIndex:i--];
            
        }else{
            
            NSString * filePath = [directoryPath stringByAppendingString:@"/"];
            filePath = [filePath stringByAppendingString:fileLoadSet[i]];
            NSDictionary * attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            
            // remove usr_ prefix
            fileLoadSet[i] = [fileLoadSet[i] stringByReplacingCharactersInRange:[fileLoadSet[i] rangeOfString:@"usr_"] withString:@""];
            
            fileDateSet[i] = [attrs objectForKey:NSFileModificationDate];
            
        }
    }

    // Sort by date order
    if([fileLoadSet count] > 0){
        [self sortFilesByDates];
    }
}

// TODO: this can probably be done nicer with comparators
- (void)sortFilesByDates
{
    
    NSDate * newFileLoadSet[[fileDateSet count]];
    NSDate * newFileDateSet[[fileDateSet count]];
    
    NSDate * maxDate;
    int maxDateIndex;
    
    @synchronized(self){
        for(int i = 0; i < [fileDateSet count]; i++){
            
            maxDateIndex = i;
            maxDate = fileDateSet[i];
            //fileDateSet[j] > maxDate
            for(int j = 0; j < [fileDateSet count]; j++){
                if([(NSDate *)fileDateSet[j] compare:maxDate] == NSOrderedDescending){
                    maxDateIndex = j;
                    maxDate = fileDateSet[j];
                }
            }
            
            NSLog(@"Max date index %i",maxDateIndex);
            newFileDateSet[i] = fileDateSet[maxDateIndex];
            newFileLoadSet[i] = fileLoadSet[maxDateIndex];

            fileDateSet[maxDateIndex] = [NSDate distantPast];
        }
    }
    
    for(int i = 0; i < [fileDateSet count]; i++){
        fileLoadSet[i] = newFileLoadSet[i];
        fileDateSet[i] = newFileDateSet[i];
    }
}

#pragma mark - Save Load Actions
- (void)userDidLoadFile:(NSString *)filename
{
    NSLog(@"user did load %@",filename);
    
    activeSequencer = filename;
    [delegate loadFromName:filename];
    
    [delegate viewSeqSetWithAnimation:YES];
}

- (void)userDidSaveFile:(NSString *)filename
{
    NSLog(@"user did save as %@",filename);
    
    NSString * emptyName = [filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        NSLog(@"Error: trying to save with blank set name");
    }else{
        activeSequencer = filename;
        [delegate saveWithName:filename];
        
        [delegate viewSeqSetWithAnimation:YES];
    }
}

- (void)userDidRenameFile:(NSString *)filename toName:(NSString *)newname
{
    // move file to newname
    NSLog(@"user did move %@ to %@",filename,newname);
    
    if([activeSequencer isEqualToString:filename]){
        activeSequencer = newname;
    }
    
    [delegate renameFromName:filename toName:newname];
    [self reloadFileTable];
}

- (void)userDidDeleteFile:(NSString *)filename
{
    NSLog(@"user did delete as %@",filename);
    if([activeSequencer isEqualToString:filename]){
        activeSequencer = @"";
    }
    [delegate deleteWithName:filename];

}

#pragma mark - Button Actions

- (IBAction)userDidSelectBack:(id)sender
{
    [delegate viewSeqSetWithAnimation:YES];
}

- (IBAction)userDidSelectCreateNew:(id)sender
{
    selectMode = @"Load";
    
    NSString * newSet = ([activeSequencer isEqualToString:@""] || activeSequencer == nil) ? [self generateNextSetName] : activeSequencer;
    
    [delegate createNewSaveName:newSet];
    activeSequencer = nil;
    
    [self reloadFileTable];
    [self showHideNewFileRow:YES];
    
    [loadTable reloadData];
    [self resetTableOffset:nil];
    
    [delegate viewSeqSetWithAnimation:YES];
}

/*
- (IBAction)userDidSelectRename:(id)sender
{
    
    NSLog(@"User did select rename");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;

    selectMode = @"Rename";
 
    [self showHideNewFileRow:YES];
    [loadTable reloadData];
    [self resetTableOffset:nil];
    
}
*/
- (IBAction)userDidSelectSaveCurrent:(id)sender
{
    
    NSLog(@"User did select save current");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"SaveCurrent";
    
    [self showHideNewFileRow:NO];
    //NSMutableArray * tempFileLoadSet = [[NSMutableArray alloc] initWithArray:fileLoadSet copyItems:YES];
    //fileLoadSet = nil;
    //[self.loadTable reloadData];
    //fileLoadSet = tempFileLoadSet;
    [self.loadTable reloadData];
    [self resetTableOffset:nil];
    
}

-(IBAction)userDidSelectLoad:(id)sender
{
    NSLog(@"User did select load");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"Load";
    
    [self showHideNewFileRow:YES];
    //NSMutableArray * tempFileLoadSet = [[NSMutableArray alloc] initWithArray:fileLoadSet copyItems:YES];
    //fileLoadSet = nil;
    //[self.loadTable reloadData];
    //fileLoadSet = tempFileLoadSet;
    [self.loadTable reloadData];
    [self resetTableOffset:nil];

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
    if(hideNewFileRow && indexPath.row == 0){
        return 0;
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
    if(TESTMODE) NSLog(@"disable scroll");
    loadTable.scrollEnabled = NO;
}

- (void)enableScroll
{
    if(TESTMODE) NSLog(@"enable scroll");
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
    
    if(indexPath.row > 0){
        
        // Rows for previous files
        
        NSString * title = fileLoadSet[indexPath.row-1];
        NSDate * priorDate = fileDateSet[indexPath.row-1];
        NSString * dateString = [self displayTimeFromPriorDate:priorDate];
        
        cell.fileText.text = title;
        cell.fileDate.text = dateString;
        cell.isRenamable = NO;
        
        if([cell.fileText.text isEqualToString:activeSequencer]){
            [cell setAsActiveSequencer];
        }else{
            [cell unsetAsActiveSequencer];
        }
        
    }else{
        
        // Row for new file
        cell.fileText.text = DEFAULT_FILE_TEXT;
        cell.fileDate.text = @"0s";
        cell.isRenamable = YES;
    }
    
    // iOS 7.1 seems to ignore heights
    if(hideNewFileRow && indexPath.row == 0){
        [cell setHidden:YES];
    }else if(indexPath.row > 0 && [selectMode isEqualToString:@"SaveCurrent"] && ![fileLoadSet[indexPath.row-1] isEqualToString:activeSequencer]){
        [cell setHidden:YES];
    }else if(indexPath.row > 0 && [selectMode isEqualToString:@"SaveCurrent"] && [fileLoadSet[indexPath.row-1] isEqualToString:DEFAULT_SET_NAME]){
        [cell setHidden:YES];
    }else{
        [cell setHidden:NO];
    }
    
    
    cell.rowid = (int)indexPath.row;
    
    NSLog(@"Cell row id is %i",cell.rowid);
    
    return cell;
}

#pragma mark - Cell editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionsViewCell * cell = (OptionsViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if([selectMode isEqualToString:@"Load"] && !cell.isNameEditing && ![cell.fileText.text isEqualToString:DEFAULT_SET_NAME]){
        return YES;
    }else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(TESTMODE) NSLog(@"***** will begin editing row at index path");
    
    OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
    [cell editingDidBegin];
    
    // always select the cell being edited
    [cell setSelected:YES animated:NO];
    if(cellToDeselect != nil){
        [cellToDeselect setSelected:NO animated:NO];
    }
    cellToDeselect = cell;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
    [cell editingDidEnd];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
    [cell editingDidEnd];
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self deleteCellAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deselect a cell that's held on
    if(cellToDeselect != nil){
        [cellToDeselect setSelected:NO animated:NO];
        cellToDeselect = nil;
    }
}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath
{
    OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
    NSString * filename = [cell getNameForFile];
    
    for(int i = 0; i < [fileLoadSet count]; i++){
        if([[fileLoadSet objectAtIndex:i] isEqualToString:filename]){
            [fileLoadSet removeObjectAtIndex:i];
            [fileDateSet removeObjectAtIndex:i];
        }
    }
    
    // delete the data
    [self userDidDeleteFile:filename];
    
    // remove from table
    [loadTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [loadTable reloadData];

    if([fileLoadSet count] == 0){
        // schedule this because the table loading inevitably has a delay
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showNoSetsLabel) userInfo:nil repeats:NO];
    }
    
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

-(void)highlightActiveSequencer
{
    for(NSIndexPath * indexPath in loadTable.indexPathsForVisibleRows){
        OptionsViewCell * cell = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
        
        if([cell.fileText.text isEqualToString:activeSequencer]){
            [cell setAsActiveSequencer];
        }else if(!cell.isSelected){
            [cell unsetAsActiveSequencer];
        }
    }
}

#pragma mark - Select actions
-(void)delayedSelectLoadTableTopRow
{
    int firstIndex = 0;
    
    if([selectMode isEqualToString:@"Load"]){
        firstIndex = 1;
    }
    
    if([fileLoadSet count] > firstIndex){
        [loadTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:firstIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

-(void)showHideNewFileRow:(BOOL)isHidden
{
    hideNewFileRow = isHidden;
}

-(void)deselectAllRows
{
    NSLog(@"Deselect all rows");
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
    
    NSLog(@"Deselect all rows except %i",cellToIgnore.row);
    
    for(int i = 0; i < [fileLoadSet count]+1; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        OptionsViewCell * cellToCheck = (OptionsViewCell *)[loadTable cellForRowAtIndexPath:indexPath];
        
        if(cellToCheck != cell && cellToCheck.isSelected){
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
    [noSetsLabel setHidden:NO];
    [noSetsLabel setAlpha:0.0];
    [UIView animateWithDuration:0.5 animations:^(void){[noSetsLabel setAlpha:1.0];}];
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

-(void)drawBackButton
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float margin = (screenBounds.size.height == XBASE_LG) ? 54 : 43;
    /*CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float margin = (screenBounds.size.height == XBASE_LG) ? 12 : 0;
    
    CGSize size = CGSizeMake(backButton.frame.size.width, backButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 13;
    int playX = margin+backButton.frame.size.width/2 - playWidth/2;
    int playY = 17;
    CGFloat playHeight = backButton.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 4.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX-playWidth, playY+(playHeight/2));
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [backButton addSubview:image];
    
    UIGraphicsEndImageContext();*/
    
    [backButton setImage:[UIImage imageNamed:@"Set_Icon"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(15, margin, 15, margin)];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    backButton.tintColor = [UIColor whiteColor];
}

-(void)drawNewPlusButton
{
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float margin = (screenBounds.size.height == XBASE_LG) ? 12 : 0;
    
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
