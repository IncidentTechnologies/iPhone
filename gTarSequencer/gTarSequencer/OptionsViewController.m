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

@implementation OptionsViewController

@synthesize delegate;
@synthesize activeSequencer;
@synthesize createNewButton;
@synthesize saveCurrentButton;
@synthesize renameButton;
@synthesize loadButton;
@synthesize loadTable;
@synthesize selectMode;

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
    
    UINib *nib = [UINib nibWithNibName:@"OptionsViewCell" bundle:nil];
    [loadTable registerNib:nib forCellReuseIdentifier:@"LoadCell"];
    
    loadTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    loadTable.separatorInset = UIEdgeInsetsZero;
    loadTable.bounces = NO;
    
    selectMode = nil;
    
    // call this in testing to clear the Documents directory
    // [self clearFileSet];
    
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
    
}

- (void)reloadFileTable
{
    [self loadFileSet];
    
    if([fileLoadSet count] > 0){
        [self userDidSelectLoad:loadButton];
        [self highlightActiveSequencer];
    }
}

// Use this to delete data in the iPhone Documents directory
- (void)clearFileSet
{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError * error;
    NSString * directoryPath = [paths objectAtIndex:0];
    
    NSMutableArray * fileSet = (NSMutableArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    // Exclude four default files
    for(NSString * path in fileSet){
        
        NSString * fullPath = [directoryPath stringByAppendingPathComponent:path];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        
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
    
    [delegate viewSeqSet];
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
        
        [delegate viewSeqSet];
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

- (void)userDidCreateNewFile:(NSString *)filename
{
    // reset the set
    NSLog(@"user did create new as %@",filename);
    activeSequencer = filename;
    [delegate createNewWithName:filename];
    
    [delegate viewSeqSet];
}

#pragma mark - Button Actions

- (IBAction)userDidSelectCreateNew:(id)sender
{
    
    NSLog(@"User did select create new");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"CreateNew";
    
    [self showHideNewFileRow:NO];
    [loadTable reloadData];
    [self resetTableOffset:nil];
    
}

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

- (IBAction)userDidSelectSaveCurrent:(id)sender
{
    
    NSLog(@"User did select save current");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"SaveCurrent";
    
    [self showHideNewFileRow:NO];
    [loadTable reloadData];
    [self resetTableOffset:nil];
    
}

-(IBAction)userDidSelectLoad:(id)sender
{
    NSLog(@"User did select load");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"Load";
    
    [self showHideNewFileRow:YES];
    [loadTable reloadData];
    [self resetTableOffset:nil];

}

- (BOOL)setSelectedButtonTo:(UIButton *)button
{
    
    UIColor * selectedColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    UIColor * deselectedColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:1.0];
    
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
    }else{
        return ROW_HEIGHT;
    }
}

// Need extra logic to force keyboard ot hide when cell goes out of view
/*-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionsViewCell * hiddencell = (OptionsViewCell *)cell;
    
    if(hiddencell.isRenamable){
        NSLog(@"Did end displaying cell at row %i",indexPath.row);
        [hiddencell endNameEditing];
    }
}*/

- (void)disableScroll
{
    loadTable.scrollEnabled = NO;
}

- (void)enableScroll
{
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
        cell.fileText.text = @"New set";
        cell.fileDate.text = @"0s";
        cell.isRenamable = YES;
        
    }
    
    cell.rowid = indexPath.row;
    
    return cell;
}


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

-(void)selectLoadTableTopRow
{
    [self deselectAllRows];
    
    // delay load so data clears, except for Load
    if([selectMode isEqualToString:@"Load"]){
        [self delayedSelectLoadTableTopRow];
    }else{
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(delayedSelectLoadTableTopRow) userInfo:nil repeats:NO];
    }
}
     
-(void)delayedSelectLoadTableTopRow
{
    int firstIndex = 0;
    
    if([selectMode isEqualToString:@"Rename"] || [selectMode isEqualToString:@"Load"]){
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
    for(int i = 0; i < [fileLoadSet count]+1; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [loadTable deselectRowAtIndexPath:indexPath animated:NO];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
