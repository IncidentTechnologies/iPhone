//
//  LoadingSequencesTable.m
//  gTarSequencer
//
//  Created by Ilan Gray on 6/29/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "SequenceLoaderTable.h"

@implementation SequenceLoaderTable

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self retreiveSaves];
    }
    return self;
}

- (void)retreiveSaves
{
    filePath = [[NSBundle mainBundle] pathForResource:@"sequencerSaves" ofType:@"plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"The sequencer instrument plist exists");
    } else {
        NSLog(@"The sequencer instrument plist does not exist");
    }
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    saves = [plistDictionary objectForKey:@"SavedSequences"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self loadSequencerFromPList];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [saveNames count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaveCell"];
    
    // Configure the cell...
    if ( indexPath.row < [saveNames count] )
    {
        cell.textLabel.text = [saveNames objectAtIndex:indexPath.row];	
    }
    else {
        cell.textLabel.text = @"New Sequence";
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark Loading

- (void)loadSequencerFromPList
{
    saveNames = [saves allKeys];
}

#pragma mark Saving

- (BOOL)saveSequencer:(Sequencer *)toSave withName:(NSString *)saveName
{
    [saves setObject:toSave forKey:saveName];
    
    BOOL success = [saves writeToFile:filePath atomically:YES];
    
    return success;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int selectionIndex = indexPath.row;
    
    NSString * selectionName = [saveNames objectAtIndex:selectionIndex];
    
    Sequencer * saveChosen = [saves objectForKey:selectionName];
    
    [delegate didSelectSequenceToLoad:saveChosen withName:selectionName];
}

@end
