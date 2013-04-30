//
//  SocialViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/12/13.
//
//

#import "SocialViewController.h"

#import "SelectorControl.h"
#import "Facebook.h"
#import "ActivityFeedCell.h"
#import "SocialUserCell.h"

#import "UIView+Gtar.h"
#import "PullToUpdateTableView.h"

#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/UserEntry.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserResponse.h>

extern UserController *g_userController;
extern Facebook *g_facebook;

@interface SocialViewController ()
{
    UserEntry *_loggedInUserEntry;
    UserEntry *_displayedUserEntry;
    
    UserProfile *_loggedInUserProfile;
    UserProfile *_displayedUserProfile;
}
@end

@implementation SocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_topBar addShadow];
    
//    NSAttributedString *attributedString1 = [self createAttributedStringWithInteger:200 andText:@"SESSIONS"];
//    NSAttributedString *attributedString2 = [self createAttributedStringWithInteger:100 andText:@"FOLLOWERS"];
//    NSAttributedString *attributedString3 = [self createAttributedStringWithInteger:999 andText:@"FOLLOWING"];
//    
//    [_feedSelector setTitles:[NSArray arrayWithObjects:attributedString1,attributedString2,attributedString3,nil]];
    
    UserEntry *entry = [g_userController getUserEntry:0];
    
    [self displayUserEntry:entry];
    
    // Update everything
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_topBar release];
    [_feedSelector release];
    [_feedTable release];
    [_picImageView release];
    [_userNameLabel release];
    [super dealloc];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)accountButtonClicked:(id)sender
{
    [g_userController requestLogoutUserCallbackObj:nil andCallbackSel:nil];
    
    [g_facebook logout];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changePicButtonClicked:(id)sender
{
}

- (IBAction)feedSelectorChanged:(id)sender
{
    [_feedTable reloadData];
}

#pragma mark - Helpers

- (NSAttributedString *)createAttributedStringWithInteger:(NSInteger)num andText:(NSString *)text
{
    NSString *numString = [NSString stringWithFormat:@"%d",num];
    NSString *string = [NSString stringWithFormat:@"%@\n%@",numString,text];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    UIFont *fontSmall = [UIFont systemFontOfSize:11.0];
    UIFont *fontBig = [UIFont systemFontOfSize:17.0];
    
    [attributedString addAttribute:NSFontAttributeName value:fontBig range:NSMakeRange(0,[numString length])];
    [attributedString addAttribute:NSFontAttributeName value:fontSmall range:NSMakeRange([numString length]+1,[text length])];
    
    return [attributedString autorelease];
}

- (void)displayUserEntry:(UserEntry *)userEntry
{
    _displayedUserEntry = userEntry;
    
    [_userNameLabel setText:_displayedUserEntry.m_userProfile.m_name];
    
    [self updateHeaders];
    
    [_feedTable reloadData];
}

- (void)updateHeaders
{
    NSAttributedString *attributedString1 = [self createAttributedStringWithInteger:[_displayedUserEntry.m_sessionsList count] andText:@"SESSIONS"];
    NSAttributedString *attributedString2 = [self createAttributedStringWithInteger:[_displayedUserEntry.m_followedByList count] andText:@"FOLLOWERS"];
    NSAttributedString *attributedString3 = [self createAttributedStringWithInteger:[_displayedUserEntry.m_followsList count] andText:@"FOLLOWING"];
    
    [_feedSelector setTitles:[NSArray arrayWithObjects:attributedString1, attributedString2, attributedString3, nil]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( _feedSelector.selectedIndex == 0 )
    {
        return [_displayedUserEntry.m_sessionsList count];
    }
	else if ( _feedSelector.selectedIndex == 1 )
    {
        return [_displayedUserEntry.m_followsList count];
    }
    else
    {
        return [_displayedUserEntry.m_followedByList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
//    static NSString * CellIdentifierActivity = @"ActivityFeedCell";
//    static NSString * CellIdentifierUser = @"SocialUserCell";
	
    NSInteger row = [indexPath row];
    
    if ( _feedSelector.selectedIndex == 0 )
    {
        static NSString *CellIdentifier = @"ActivityFeedCell";
        
        ActivityFeedCell *cell = (ActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[ActivityFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [[NSBundle mainBundle] loadNibNamed:@"ActivityFeedCell" owner:cell options:nil];
            
            CGFloat cellHeight = _feedTable.rowHeight;
            CGFloat cellRow = _feedTable.frame.size.width;
            
            // Readjust the width and height
            [cell setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
            [cell.accessoryView setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        }
        
        if ( row <= [_displayedUserEntry.m_sessionsList count] )
        {
            cell.userSongSession = [_displayedUserEntry.m_sessionsList objectAtIndex:row];
        }
        else
        {
            cell.userSongSession = nil;
        }
        
        [cell updateCell];
        
        return cell;
    }
	else
    {
        static NSString *CellIdentifier = @"SocialUserCell";
        
        SocialUserCell *cell = (SocialUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[SocialUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [[NSBundle mainBundle] loadNibNamed:@"SongListCell" owner:cell options:nil];
            
            CGFloat cellHeight = _feedTable.rowHeight;
            CGFloat cellRow = _feedTable.frame.size.width;
            
            // Readjust the width and height
            [cell setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
            [cell.accessoryView setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        }
        
        if ( _feedSelector.selectedIndex == 1 )
        {
            if ( row <= [_displayedUserEntry.m_followsList count] )
            {
                cell.userProfile = [_displayedUserEntry.m_followsList objectAtIndex:row];
            }
            else
            {
                cell.userProfile = nil;
            }
        }
        else if ( _feedSelector.selectedIndex == 2 )
        {
            if ( row <= [_displayedUserEntry.m_followedByList count] )
            {
                cell.userProfile = [_displayedUserEntry.m_followedByList objectAtIndex:row];
            }
            else
            {
                cell.userProfile = nil;
            }
        }
        else
        {
            cell.userProfile = nil;
        }
        
        [cell updateCell];
        
        return cell;
    }
    
}

#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
    
    if ( _feedSelector.selectedIndex == 0 )
    {
        // Pop up modal and play the song
    }
    else if ( _feedSelector.selectedIndex == 1 )
    {
        if ( row <= [_displayedUserEntry.m_followsList count] )
        {
            UserProfile *userProfile = [_displayedUserEntry.m_followsList objectAtIndex:row];
            UserEntry *userEntry = [g_userController getUserEntry:userProfile.m_userId];
            
            [self displayUserEntry:userEntry];
        }
        else
        {
            // Do nothing
        }
    }
    else if ( _feedSelector.selectedIndex == 2 )
    {
        if ( row <= [_displayedUserEntry.m_followedByList count] )
        {
            UserProfile *userProfile = [_displayedUserEntry.m_followedByList objectAtIndex:row];
            UserEntry *userEntry = [g_userController getUserEntry:userProfile.m_userId];
            
            [self displayUserEntry:userEntry];
        }
        else
        {
            // Do nothing
        }
    }
}


@end