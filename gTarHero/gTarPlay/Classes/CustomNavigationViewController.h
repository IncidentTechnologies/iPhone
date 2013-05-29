//
//  CustomNavigationViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomViewController;
@class FullScreenActivityView;

@interface CustomNavigationViewController : UIViewController <UISearchBarDelegate>
{
    
    NSString * m_title;

    CustomViewController * m_currentViewController;

    IBOutlet UILabel * m_titleLabel;
    
    IBOutlet UIView * m_bodyView;
    IBOutlet UIView * m_topbarView;
    
    IBOutlet UIButton * m_backButton;
    IBOutlet UIButton * m_homeButton;
    IBOutlet UIButton * m_notifyButton;
    IBOutlet UIButton * m_fullScreenButton;
    
    IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
    FullScreenActivityView * m_customActivityView;
    
    // search bar
    NSString * m_currentSearchString;
    
    IBOutlet UISearchBar * m_searchBar;
    IBOutlet UIView * m_searchContracted;
    IBOutlet UIView * m_searchExpanded;

}

@property (nonatomic, retain) NSString * m_title;

@property (nonatomic, retain) IBOutlet UILabel * m_titleLabel;

@property (nonatomic, retain) IBOutlet UIView * m_bodyView;
@property (nonatomic, retain) IBOutlet UIView * m_topbarView;

@property (nonatomic, retain) IBOutlet UIButton * m_backButton;
@property (nonatomic, retain) IBOutlet UIButton * m_homeButton;
@property (nonatomic, retain) IBOutlet UIButton * m_notifyButton;
@property (nonatomic, retain) IBOutlet UIButton * m_fullScreenButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
@property (nonatomic, retain) IBOutlet UISearchBar * m_searchBar;
@property (nonatomic, retain) IBOutlet UIView * m_searchContracted;
@property (nonatomic, retain) IBOutlet UIView * m_searchExpanded;

// view controller mgmt
- (void)clearViewController;
- (void)switchInViewController:(CustomViewController*)viewController;
- (void)returnToPreviousViewController:(CustomViewController*)viewController;

// buttons
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)homeButtonClicked:(id)sender;
- (IBAction)notifyButtonClicked:(id)sender;
- (IBAction)fullScreenButtonClicked:(id)sender;

// search stuff
- (void)resignSearchBarFirstResponder;
- (void)contractSearchBar;

// child search functions
- (void)beginSearch;
- (void)cancelSearch;
- (void)searchForString:(NSString*)searchString;

@end
