//
//  TitleNavigationController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <QuartzCore/QuartzCore.h>

#import "TitleNavigationController.h"
#import "ActivityFeedCell.h"
#import "SelectorControl.h"

@interface TitleNavigationController ()
{
    UIView *_currentLeftPanel;
    UIView *_currentRightPanel;
}
@end

@implementation TitleNavigationController

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
    
    // Do any additional setup after loading the view from its nib.
    
    UIView *viewsNeedingShadows[] =
    {
        _topBarView,
        _gtarLogoImage,
        _loggedoutSigninButton,
        _loggedoutSignupButton,
        _gatekeeperLearnMoreButton,
        _gatekeeperSigninButton,
        _menuPlayButton,
        _menuFreePlayButton,
        _menuStoreButton
    };
    
    for ( NSInteger i = 0; i < (sizeof(viewsNeedingShadows)/sizeof(UIView*)); i++)
    {
        UIView *view = viewsNeedingShadows[i];
        
        view.layer.shadowRadius = 7.0;
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowOpacity = 0.9;
    }
    
    [_feedSelectorControl setTitles:[NSArray arrayWithObjects:@"Test1", @"Test2",nil]];
    
//    [self swapLeftPanel:_loggedoutLeftPanel];
//    [self swapLeftPanel:_gatekeeperLeftPanel];
    [self swapLeftPanel:_menuLeftPanel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_rightPanel release];
    [_leftPanel release];
    [_loggedoutLeftPanel release];
    [_signupRightPanel release];

    [_loggedoutSignupButton release];
    [_loggedoutSigninButton release];
    [_signinRightPanel release];
    [_gtarLogoImage release];
    
    [_topBarView release];
    [_gatekeeperLearnMoreButton release];
    [_gatekeeperSigninButton release];

    [_gatekeeperLeftPanel release];
    [_learnMoreRightPanel release];
    
    [_menuPlayButton release];
    [_menuFreePlayButton release];
    [_menuStoreButton release];
    [_menuLeftPanel release];
    [_feedRightPanel release];
    [_feedTable release];
    [_feedSelectorControl release];
    [super dealloc];
}

#pragma mark - Panel management

- (void)swapRightPanel:(UIView*)rightPanel
{
    
    [_currentRightPanel removeFromSuperview];
    
    // Resize the subview as appropriate
    [rightPanel setFrame:CGRectMake(0, 0, _rightPanel.frame.size.width, _rightPanel.frame.size.height )];;
    
    [_rightPanel addSubview:rightPanel];
    
    _currentRightPanel = rightPanel;
    
}

- (void)swapLeftPanel:(UIView*)leftPanel
{
    
    [_currentLeftPanel removeFromSuperview];
    
    [_leftPanel addSubview:leftPanel];
    
    _currentLeftPanel = leftPanel;
    
}

- (IBAction)loggedoutSigninButtonClicked:(id)sender
{
    [_loggedoutSignupButton setEnabled:YES];
    [_loggedoutSigninButton setEnabled:NO];
    
    [self swapRightPanel:_signinRightPanel];
}

- (IBAction)loggedoutSignupButtonClicked:(id)sender
{
    [_loggedoutSigninButton setEnabled:YES];
    [_loggedoutSignupButton setEnabled:NO];
    
    [self swapRightPanel:_signupRightPanel];
}

- (IBAction)gatekeeperLearnMoreButtonClicked:(id)sender
{
    [_gatekeeperSigninButton setEnabled:YES];
    [_gatekeeperLearnMoreButton setEnabled:NO];
    
    [self swapRightPanel:_learnMoreRightPanel];
}

- (IBAction)gatekeeperSigninButtonClicked:(id)sender
{
    [_gatekeeperLearnMoreButton setEnabled:YES];
    [_gatekeeperSigninButton setEnabled:NO];
    
    [self swapRightPanel:_signinRightPanel];
}

- (IBAction)menuPlayButtonClicked:(id)sender
{
    // Start play mode
    [self swapRightPanel:_feedRightPanel];
}

- (IBAction)menuFreePlayButtonClicked:(id)sender
{
    // Start free play mode
    [_feedTable reloadData];
    
}

- (IBAction)menuStoreButtonClicked:(id)sender
{
    // Start store mode
}

- (IBAction)feedSelectorChanged:(id)sender
{
    
}

- (IBAction)signupButtonClicked:(id)sender {
}

- (IBAction)signupFacebookButtonClicked:(id)sender {
}

- (IBAction)signinButtonClicked:(id)sender {
}

- (IBAction)signinFacebookButtonClicked:(id)sender {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
//    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
//    {
//        // Friends
//        return [m_friendFeed count];
//    }
//    
//    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
//    {
//        // Global
//        return [m_globalFeed count];
//    }
    
    // Should never happen
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString * CellIdentifier = @"ActivityFeedCell";

	ActivityFeedCell * cell = (ActivityFeedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil)
	{
		
		cell = [[[ActivityFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"ActivityFeedCell" owner:cell options:nil];
        
        [cell setFrame:CGRectMake(0, 0, _feedTable.frame.size.width*2, _feedTable.rowHeight)];
        [cell.accessoryView setFrame:CGRectMake(0, 0, _feedTable.frame.size.width*2, _feedTable.rowHeight)];
	}

//	// Clear these in case this cell was previously selected
//	cell.highlighted = NO;
//	cell.selected = NO;
//	
//    NSInteger row = [indexPath row];
//    
//    UserSongSession * session = nil;
//    
//    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
//    {
//        if ( row < [m_friendFeed count] )
//        {
//            session = [m_friendFeed objectAtIndex:row];
//        }
//    }
//    
//    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
//    {
//        if ( row < [m_globalFeed count] )
//        {
//            session = [m_globalFeed objectAtIndex:row];
//        }
//    }
//    
//    cell.m_userSongSession = session;
//    
//    [cell updateCell];
//    
	return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 41;
//}

#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    // We only want one cell to be clicked on at a time
//    m_displayingCell = YES;
//    
//    // Cause the row to spin until the session has started
//    AccountViewCell * cell = (AccountViewCell*)[m_tableView cellForRowAtIndexPath:indexPath];
//    
//    [cell.m_timeLabel setHidden:YES];
//    [cell.m_activityView startAnimating];
//    
//    [self performSelector:@selector(playCell:) withObject:cell afterDelay:0.05];
    
}
@end
