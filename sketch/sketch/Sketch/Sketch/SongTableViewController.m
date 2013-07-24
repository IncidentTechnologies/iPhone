//
//  SongTableViewController.m
//  Sketch
//
//  Created by Franco on 7/22/13.
//
//

#import "SongTableViewController.h"
#import "SongViewCell.h"

#import <gTarAppCore/UserSongSession.h>

@interface SongTableViewController ()
{

}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;

@property (strong, nonatomic, readwrite) NSMutableArray* songList;

@end

@implementation SongTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // DO NOT put init code here as this cell gets created from
        // IB/storyboard, so initWithCoder is called
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        // Initilization code here
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* songListPath = [self getSongListPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: songListPath])
    {
        self.songList = [NSKeyedUnarchiver unarchiveObjectWithFile: songListPath];
    }
    if (self.songList == nil)
    {
        self.songList = [[NSMutableArray alloc] init];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_songList count] > 0)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_songTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSongSession:(UserSongSession*)songSession
{
    [_songList insertObject:songSession atIndex:0];
    [_songTableView reloadData];
    
    /****** SAVE SONG TO DISK CODE, TODO: move code else where, save on exit *********/
    //////////////////////////////////////////////////////////////////
    
    NSString* songListPath = [self getSongListPath];
    [NSKeyedArchiver archiveRootObject:_songList toFile:songListPath];
    
    /************     END SAVE SONG TO DISK CODE                ************/
    ////////////////////////////////////////////////////////////////////////
}

- (NSString*)getSongListPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    NSString *songListPath = [documentsDirectory stringByAppendingPathComponent:@"songlist.archive"];
    
    return songListPath;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_songList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SongCellIdentifier";
    
    SongViewCell *cell = (SongViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[SongViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    UserSongSession * session = [_songList objectAtIndex:indexPath.row];
    
    cell.songTitle.text = session.m_notes;
    
    NSInteger songLength = session.m_length;
    int minutes = songLength/60;
    int seconds = songLength - minutes * 60;
    cell.songLength.text = [NSMutableString stringWithFormat:@"%d:%02d                                ", minutes, seconds];
    
    NSDate* created = [NSDate dateWithTimeIntervalSince1970:session.m_created];
    cell.songDate.text = [NSDateFormatter localizedStringFromDate:created dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(100/255.0) green:(120/255.0) blue:(130/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


#pragma mark - UITableView Delegate


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // re-calling the cells selectedness ensures that the appropriate textColor
    // is used when a selected cell is coming into view.
    if (cell.isSelected)
    {
        [cell setSelected:YES];;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserSongSession * session = [_songList objectAtIndex:indexPath.row];
    [_delegate playSong:session];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Upon finishing editing the song name, save it to the corresponding songSession
    SongViewCell* cell = (SongViewCell*)[[textField superview] superview];
    NSIndexPath* indexPath = [_songTableView indexPathForCell:cell];
    
    UserSongSession * session = [_songList objectAtIndex:indexPath.row];
    session.m_notes = cell.songTitle.text;
}

@end
