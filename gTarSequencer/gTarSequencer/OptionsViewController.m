//
//  SaveLoadSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/28/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "OptionsViewController.h"

#define ROW_HEIGHT 65

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
    loadTable.bounces = NO;
    
    selectMode = nil;
    
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
    
    if(activeSequencer != nil){
        
    }
    /*
    if([fileLoadSet count] > 0){
        
        //[loadTable reloadData];
        
        // default select the active file
        if(activeSequencer != nil){
            for(int i = 0; i < [fileLoadSet count]; i++){
                if([fileLoadSet[i] isEqualToString:activeSequencer]){
                    //[loadTable selectRow:i inComponent:0 animated:YES];
                }
            }
        }
        
    }else{
        //[noFilesLabel setHidden:NO];
        //[filePicker setHidden:YES];
    }*/
}

- (void)reloadFileTable
{
    [self loadFileSet];
    [self userDidSelectLoad:loadButton];
}

- (void)loadFileSet
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError * error;
    NSString * directoryPath = [paths objectAtIndex:0];
    
    //fileSet = [[NSMutableDictionary alloc] init];
    
    fileDateSet = [[NSMutableArray alloc] init];
    fileLoadSet = (NSMutableArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    // Exclude four default files
    for(int i = 0; i < [fileLoadSet count]; i++){
        if([fileLoadSet[i] isEqualToString:@"sequencerInstruments.plist"] || [fileLoadSet[i] isEqualToString:@"sequencerCurrentState"] || [fileLoadSet[i] isEqualToString:@"Samples"] || [fileLoadSet[i] isEqualToString:@"customSampleList.plist"]){
            
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
    [self sortFilesByDates];
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
    
    activeSequencer = filename;
    [delegate saveWithName:filename];
    
    [delegate viewSeqSet];
}

- (void)userDidRenameFile:(NSString *)filename toName:(NSString *)newname
{
    // move file to newname
    NSLog(@"user did move %@ to %@",filename,newname);
}

- (void)userDidCreateNewFile:(NSString *)filename
{
    // reset the set
    NSLog(@"user did create new as %@",filename);
    
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
    [self selectLoadTableTopRow];
    
}

- (IBAction)userDidSelectRename:(id)sender
{
    
    NSLog(@"User did select rename");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;

    selectMode = @"Rename";
    
    [self showHideNewFileRow:YES];
    [loadTable reloadData];
    [self selectLoadTableTopRow];
    
}

- (IBAction)userDidSelectSaveCurrent:(id)sender
{
    
    NSLog(@"User did select save current");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"SaveCurrent";
    
    [self showHideNewFileRow:NO];
    [loadTable reloadData];
    [self selectLoadTableTopRow];
    
    
}

-(IBAction)userDidSelectLoad:(id)sender
{
    NSLog(@"User did select load");
    
    BOOL buttonChanged = [self setSelectedButtonTo:sender];
    if(!buttonChanged) return;
    
    selectMode = @"Load";
    
    [self showHideNewFileRow:YES];
    [loadTable reloadData];
    [self selectLoadTableTopRow];


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
        
    }else{
        
        // Row for new file
        cell.fileText.text = @"New set";
        cell.fileDate.text = @"0s";
        cell.isRenamable = YES;
        
    }
    
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
    
    [loadTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:firstIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
         
}

-(void)showHideNewFileRow:(BOOL)isHidden
{
    hideNewFileRow = isHidden;
}

-(void)deselectAllRows
{
    for(NSIndexPath * indexPath in loadTable.indexPathsForSelectedRows){
        [loadTable deselectRowAtIndexPath:indexPath animated:NO];
    }
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
