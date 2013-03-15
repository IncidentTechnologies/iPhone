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
#import "CyclingTextField.h"
#import "SlidingModalViewController.h"

@interface TitleNavigationController ()
{
    UIView *_currentLeftPanel;
    UIView *_currentRightPanel;
    
    UIButton *_fullScreenButton;
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
    
    for ( NSInteger i = 0; i < (sizeof(viewsNeedingShadows)/sizeof(UIView *)); i++)
    {
        UIView *view = viewsNeedingShadows[i];
        
        view.layer.shadowRadius = 7.0;
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowOpacity = 0.9;
    }
    
    [_feedSelectorControl setTitles:[NSArray arrayWithObjects:@"HISTORY", @"GLOBAL", @"NEWS",nil]];
    
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
    [_currentLeftPanel removeFromSuperview];
    [_currentRightPanel removeFromSuperview];
    [_fullScreenButton removeFromSuperview];
    
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
    [_activityFeedModal release];
    [super dealloc];
}

#pragma mark - Panel management

- (void)swapRightPanel:(UIView *)rightPanel
{
    
    [_currentRightPanel removeFromSuperview];
    
    // Resize the subview as appropriate
    [rightPanel setFrame:CGRectMake(0, 0, _rightPanel.frame.size.width, _rightPanel.frame.size.height )];;
    
    [_rightPanel addSubview:rightPanel];
    
    _currentRightPanel = rightPanel;
    
}

- (void)swapLeftPanel:(UIView *)leftPanel
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
    [self presentViewController:_activityFeedModal animated:NO completion:NULL];
    
}

- (IBAction)menuStoreButtonClicked:(id)sender
{
    // Start store mode
    [self swapRightPanel:_signupRightPanel];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"ActivityFeedCell";

	ActivityFeedCell *cell = (ActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

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

- (void)update
{
    
}

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

#pragma mark - UITextFieldDelegate

- (IBAction)textFieldSelected:(id)sender
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)sender;
    
    UIView *parent = cyclingTextField.superview;
    
    // Shift the superview up enough so that the textfield is
    // centered in the remaining visble space once the keyboard displays.
    // I kinda just tweaked this value till it looked right.
    CGFloat delta = cyclingTextField.frame.origin.y - 35;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    parent.transform = CGAffineTransformMakeTranslation( 0, -delta );
    
    [UIView commitAnimations];
    
    if ( _fullScreenButton == nil )
    {
        // Not retained
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenButton.frame = self.view.frame;
        
        [self.view addSubview:_fullScreenButton];
    }
    else
    {
        // Remove all actions for the button
        [_fullScreenButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }
    
    // Resign first responder on the text field when this button is pressed
    [_fullScreenButton addTarget:cyclingTextField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)textField;
    
    UIView *parent = cyclingTextField.superview;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    parent.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];
    
    // FYI We never retained this
    [_fullScreenButton removeFromSuperview];
    
    _fullScreenButton = nil;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)textField;
    
    if ( cyclingTextField.nextTextField != nil )
    {
        [cyclingTextField.nextTextField becomeFirstResponder];
    }
    else if ( cyclingTextField.submitButton != nil )
    {
        [cyclingTextField.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
//    NSCharacterSet * usernameSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
//    NSCharacterSet * passwordSet =[[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789!@#$%^&*+-/=?^_`|~.[]{}()"] invertedSet];
//    
//    // Backspace character
//    if ( [string length] == 0 )
//    {
//        return YES;
//    }
//    
//    // The username needs alpha num only
//    if ( textField == m_usernameTextField &&
//        [string rangeOfCharacterFromSet:usernameSet].location != NSNotFound )
//    {
//        [m_statusLabel setText:@"Invalid character"];
//        [m_statusLabel setHidden:NO];
//        return NO;
//    }
//    
//    if ( textField == m_passwordTextField &&
//        [string rangeOfCharacterFromSet:passwordSet].location != NSNotFound )
//    {
//        [m_statusLabel setText:@"Invalid character"];
//        [m_statusLabel setHidden:NO];
//        return NO;
//    }
//    
//    [m_statusLabel setHidden:YES];
    
    return YES;
}

@end
