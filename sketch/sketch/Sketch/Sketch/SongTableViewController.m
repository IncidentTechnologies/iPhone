//
//  SongTableViewController.m
//  Sketch
//
//  Created by Franco on 7/22/13.
//
//

#import "SongTableViewController.h"
#import "SongViewCell.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserProfile.h>
#import "Mixpanel.h"

@interface SongTableViewController ()
{
    __weak SongViewCell* _cellShowingDeleteButton;
}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;

@property (strong, nonatomic) NSMutableDictionary* userSongDictionary;
@property (strong, nonatomic, readwrite) NSMutableArray* songList;
@property (strong, nonatomic) NSString* currentUserId;

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
    
    UserProfile *loggedInProfile = [[UserController sharedSingleton] m_loggedInUserProfile];
    _currentUserId = [NSString stringWithFormat:@"%d", loggedInProfile.m_userId];

    NSString* songDictionaryPath = [self getSongDictionaryPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: songDictionaryPath])
    {
        self.userSongDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile: songDictionaryPath];
        self.songList = [_userSongDictionary objectForKey:_currentUserId];
    }
    
    if (self.userSongDictionary == nil)
    {
        self.userSongDictionary = [[NSMutableDictionary alloc] init];
    }
    if (self.songList == nil)
    {
        self.songList = [[NSMutableArray alloc] init];
        [_userSongDictionary setObject:_songList forKey:_currentUserId];
    }
    
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeGestureRecognizer.direction = (UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight);
    swipeGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:swipeGestureRecognizer];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.numberOfTapsRequired = 2;
    tapGestureRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    if ([_songList count] > 0)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_songTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        UserSongSession* song = [_songList objectAtIndex:0];
        [_delegate selectedSong:song];
    }
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                            selector:@selector(applicationWillExit:)
                            name:UIApplicationWillTerminateNotification
                            object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                            selector:@selector(applicationWillExit:)
                            name:UIApplicationDidEnterBackgroundNotification
                            object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                            selector:@selector(applicationWillExit:)
                            name:UIApplicationDidReceiveMemoryWarningNotification
                            object:[UIApplication sharedApplication]];
    
    // Default to select first item in list
    if ([_songList count] > 0)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        //[_songTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        //UserSongSession* song = [_songList objectAtIndex:0];
        //[_delegate selectedSong:song];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
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
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_songTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    UserSongSession* song = [_songList objectAtIndex:0];
    [_delegate selectedSong:song];
}

- (NSString*)getSongDictionaryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    NSString *songListPath = [documentsDirectory stringByAppendingPathComponent:@"songDictionary.archive"];
    
    return songListPath;
}

#pragma mark - UITableView & UITableViewDataSource Delegate

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
    
    [cell hideDeleteButton];
    
    UserSongSession * session = [_songList objectAtIndex:indexPath.row];
    
    cell.songTitle.text = session.m_notes;
    
    NSInteger songLength = session.m_length;
    int minutes = songLength/60;
    int seconds = songLength - minutes * 60;
    cell.songLength.text = [NSMutableString stringWithFormat:@"%d:%02d", minutes, seconds];
    
    NSDate* created = [NSDate dateWithTimeIntervalSince1970:session.m_created];
    cell.songDate.text = [NSDateFormatter localizedStringFromDate:created dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(159/255.0) green:(195/255.0) blue:(204/255.0) alpha:1];
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
    [_songList removeObjectAtIndex:indexPath.row];
    
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
    if (_cellShowingDeleteButton != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else
    {
        UserSongSession * session = [_songList objectAtIndex:indexPath.row];
        [_delegate selectedSong:session];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_cellShowingDeleteButton hideDeleteButton];
    _cellShowingDeleteButton = nil;
}

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

#pragma mark - UIGestureRecognizer handlers & delegate

- (void)didSwipe:(UIGestureRecognizer *)gestureRecognizer
{
    [_songTableView deselectRowAtIndexPath:[_songTableView indexPathForSelectedRow] animated:NO];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        [_cellShowingDeleteButton hideDeleteButton];
        _cellShowingDeleteButton = (SongViewCell*)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        _cellShowingDeleteButton.highlighted = NO;
        [_cellShowingDeleteButton showDeleteButton];
    }
}

- (void)didDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    UserSongSession* song = [_songList objectAtIndex:[_songTableView indexPathForSelectedRow].row];
    [_delegate playSong:song];
}

// This UIGestureRecognizer Delegate method gets called on the touchDown, where as didTap: only gets
// called on the touchUp. We want to take action on the touchDown rather than the touch up.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [_cellShowingDeleteButton hideDeleteButton];
    _cellShowingDeleteButton = nil;
    return YES;
}

- (IBAction)deleteCell:(UIButton *)sender
{
    SongViewCell* cell = (SongViewCell*)[[sender superview] superview];
    NSIndexPath* indexPath = [_songTableView indexPathForCell:cell];
    
    [self logSongDeleted:[_songList objectAtIndex:indexPath.row]];
    
    [_songList removeObjectAtIndex:indexPath.row];
    [_songTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - helpers

- (void)logSongDeleted:(UserSongSession*)songSession
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Song Deleted" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                songSession.m_notes, @"Song Name",
                                                [NSNumber numberWithInteger:songSession.m_length], @"Song Length",
                                                nil]];
}

- (void)saveData
{
    NSString* songDictionaryPath = [self getSongDictionaryPath];
    [NSKeyedArchiver archiveRootObject:_userSongDictionary toFile:songDictionaryPath];
}

// Catch all for applications will enter background, terminate, memory warning
- (void) applicationWillExit:(NSNotification *) notification
{
    [self saveData];
}

@end
