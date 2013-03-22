//
//  ExpandableSearchBar.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import "ExpandableSearchBar.h"

@implementation ExpandableSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        // Custom initialization
        
        // Hide the view
        for ( UIView * subview in self.subviews )
        {
            if ( [subview isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] )
            {
                subview.alpha = 0.0f;
            }
            
            if ( [subview isKindOfClass:NSClassFromString(@"UISegmentedControl") ] )
            {
                subview.alpha = 0.0f;
            }
        }
        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Search stuff


- (void)resignSearchBarFirstResponder
{
    
    // resign first responder the normal way
    [self resignFirstResponder];
    
    // re-enable the cancel button. this is silly, but works
    for ( UIView * possibleButton in self.subviews )
    {
        // This is a button .. the cancel button is the only button we have
        if ( [possibleButton isKindOfClass:[UIButton class]] )
        {
            // enable it, break out -- we are done
            UIButton * cancelButton = (UIButton*)possibleButton;
            
            cancelButton.enabled = YES;
            
            return;
        }
    }
    
}

- (void)contractSearchBar
{
    
    // All done searching, clear everything out
    [self setText:@""];
    [self resignFirstResponder];
    
    // remove the cancel button
    [self setShowsCancelButton:NO animated:YES];
    
    // contract the search box
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    self.frame = _contractedView.frame;
    
    [UIView commitAnimations];
    
}

- (void)beginSearch
{
    // switch over to the search view
    //    m_searchViewController.m_previousViewController = m_currentViewController;
    //
    //    [self switchInViewController:m_searchViewController];
    
}

- (void)cancelSearch
{
    
    // return back to the previous controller
    //    [self returnToPreviousViewController:m_searchViewController];
    
}

- (void)searchForString:(NSString*)searchString
{
    
    //    // inform the search controller that we have something worth searching for
    //    [m_searchViewController startIndicator];
    //
    //    // send the search to the cloud
    //    [m_storeController requestSongListSearch:searchBar.text];
    
}

#pragma mark - Search delegates

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    
//    // display cancel button
//    [searchBar setShowsCancelButton:YES animated:YES];
//    
//    // add the search string back into the bar
//    [searchBar setText:m_currentSearchString];
//    
//    // expand out the search box with a nice animation
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3f];
//    
//    searchBar.frame = m_searchExpanded.frame;
//    
//    [UIView commitAnimations];
//    
//    [self beginSearch];
//    
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    
//    // nothing for now
//    
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    
//    // if the search is empty, we do nothing
//    if ( searchBar.text == nil || [searchBar.text isEqualToString:@""] )
//    {
//        // do nothing
//        return;
//    }
//    
//    [m_currentSearchString release];
//    
//    // hold onto the search string for later
//    m_currentSearchString = [searchBar.text retain];
//    
//    [self resignSearchBarFirstResponder];
//    
//    [self searchForString:m_currentSearchString];
//    
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
//{
//    
//    [self contractSearchBar];
//    
//    [self cancelSearch];
//    
//}
//
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    
//    return YES;
//    
//}


@end
